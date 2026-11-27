import 'package:bolo_app/data/bolo_database.dart';
import 'package:bolo_app/data/device_identity.dart';
import 'package:bolo_app/features/inbox/inbox_store.dart';
import 'package:bolo_app/features/migration/guest_migration.dart';
import 'package:bolo_app/features/migration/legacy_source.dart';
import 'package:bolo_app/features/records/drift_records_repository.dart';
import 'package:bolo_app/features/records/models.dart';
import 'package:bolo_app/features/records/records_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BoloDatabase memoryDb() => BoloDatabase(NativeDatabase.memory());

/// In-memory stand-in for the old Firestore guest data. Read-only, like the
/// real source; counts reads so tests can see what the migration did.
class FakeLegacySource implements LegacyRecordSource {
  final cache = <String, List<LegacyDoc>>{};
  final server = <String, List<LegacyDoc>>{};
  bool online = true;
  bool sessionValid = true;
  Object? failWith;
  int serverReads = 0;

  @override
  Future<List<LegacyDoc>> readCache(String collection) async {
    if (failWith != null) throw failWith!;
    return cache[collection] ?? const [];
  }

  @override
  Future<List<LegacyDoc>> readServer(String collection) async {
    if (!online) throw const LegacySourceOffline();
    serverReads++;
    return server[collection] ?? const [];
  }

  @override
  bool get canReadServer => sessionValid;

  @override
  Future<void> flushPendingWrites() async {
    if (!online) throw const LegacySourceOffline();
  }
}

Timestamp ts(DateTime d) => Timestamp.fromDate(d);

Map<String, dynamic> reminderDoc(String title, DateTime at, {String status = 'pending', DateTime? updated}) => {
      'title': title,
      'remindAt': ts(at),
      'repeat': 'none',
      'status': status,
      'source': 'voice',
      'createdAt': ts(DateTime.utc(2026, 11, 1)),
      'updatedAt': ts(updated ?? DateTime.utc(2026, 11, 2)),
    };

Map<String, dynamic> expenseDoc(int poisha, {DateTime? updated}) => {
      'amountPoisha': poisha,
      'currency': 'BDT',
      'category': 'food',
      'note': 'lunch',
      'spentAt': ts(DateTime.utc(2026, 11, 20, 6)),
      'source': 'text',
      'createdAt': ts(DateTime.utc(2026, 11, 20, 6)),
      'updatedAt': ts(updated ?? DateTime.utc(2026, 11, 20, 6)),
    };

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late BoloDatabase db;
  late DeviceIdentity identity;
  var now = DateTime.utc(2026, 11, 27, 10);

  setUp(() async {
    db = memoryDb();
    identity = await DeviceIdentity.load(db);
    now = DateTime.utc(2026, 11, 27, 10);
  });
  tearDown(() => db.close());

  DriftRecordsRepository repoFor(String scope) =>
      DriftRecordsRepository(db, ownerScope: scope, deviceId: identity.deviceId, clock: () => now);

  group('DeviceIdentity', () {
    test('is created once and stays the same', () async {
      final again = await DeviceIdentity.load(db);
      expect(again.deviceId, identity.deviceId);
      expect(identity.deviceId, hasLength(20));
      expect(identity.guestScope, 'device:${identity.deviceId}');
    });
  });

  group('DriftRecordsRepository', () {
    test('saves offline and streams pending reminders in time order', () async {
      final repo = repoFor(identity.guestScope);
      await repo.saveReminder(Reminder(id: 'b', title: 'Later', remindAt: DateTime.utc(2026, 11, 28)));
      await repo.saveReminder(Reminder(id: 'a', title: 'Sooner', remindAt: DateTime.utc(2026, 11, 27, 12)));
      final list = await repo.watchPendingReminders().first;
      expect(list.map((r) => r.title), ['Sooner', 'Later']);
      expect(list.first.remindAt.toUtc(), DateTime.utc(2026, 11, 27, 12));
    });

    test('an owner never sees another owner\'s records', () async {
      await repoFor('device:A').saveTask(const TaskItem(id: 't1', title: 'Mine'));
      await repoFor('account:B').saveTask(const TaskItem(id: 't2', title: 'Theirs'));
      final mine = await repoFor('device:A').watchOpenTasks().first;
      expect(mine.map((t) => t.id), ['t1']);
      // Writes are scoped too: B cannot complete A's task.
      await repoFor('account:B').setTaskDone('t1', true);
      expect((await repoFor('device:A').watchOpenTasks().first).single.done, isFalse);
    });

    test('delete leaves a tombstone instead of removing the row', () async {
      final repo = repoFor(identity.guestScope);
      await repo.saveTask(const TaskItem(id: 't', title: 'Gone soon'));
      now = now.add(const Duration(minutes: 1));
      await repo.delete(Collections.tasks, 't');
      expect(await repo.watchOpenTasks().first, isEmpty);
      final row = await (db.select(db.tasks)..where((t) => t.id.equals('t'))).getSingle();
      expect(row.deletedAt, now.millisecondsSinceEpoch);
      expect(row.rev, 2);
    });

    test('editing keeps the creation time and bumps rev', () async {
      final repo = repoFor(identity.guestScope);
      await repo.saveTask(const TaskItem(id: 't', title: 'Draft'));
      final created = now.millisecondsSinceEpoch;
      now = now.add(const Duration(hours: 1));
      await repo.saveTask(const TaskItem(id: 't', title: 'Final'), isNew: false);
      final row = await (db.select(db.tasks)..where((t) => t.id.equals('t'))).getSingle();
      expect(row.title, 'Final');
      expect(row.createdAt, created);
      expect(row.updatedAt, now.millisecondsSinceEpoch);
      expect(row.rev, 2);
      expect(row.syncState, SyncStates.local);
    });

    test('money stays integer poisha; settled entries leave the open ledger', () async {
      final repo = repoFor(identity.guestScope);
      await repo.saveExpense(Expense(id: 'e', amountPoisha: 12345, spentAt: DateTime.utc(2026, 11, 26)));
      await repo.saveExpense(Expense(id: 'old', amountPoisha: 1, spentAt: DateTime.utc(2026, 10, 1)));
      final month = await repo.watchExpensesSince(DateTime.utc(2026, 11, 1)).first;
      expect(month.single.amountPoisha, 12345);

      await repo.saveLedgerEntry(const LedgerEntry(
          id: 'l', direction: LedgerDirection.receivable, person: 'Rahim', amountPoisha: 50000));
      expect((await repo.watchOpenLedger().first).single.person, 'Rahim');
      await repo.settleLedgerEntry('l');
      expect(await repo.watchOpenLedger().first, isEmpty);
    });

    test('new ids are unique and Firestore-shaped', () {
      final ids = {for (var i = 0; i < 1000; i++) newRecordId()};
      expect(ids, hasLength(1000));
      expect(ids.first, matches(RegExp(r'^[A-Za-z0-9]{20}$')));
    });
  });

  group('InboxStore', () {
    test('adds, lists newest first, removes', () async {
      final inbox = InboxStore(db, ownerScope: identity.guestScope);
      await inbox.add(text: 'first', createdAt: DateTime.utc(2026, 11, 1), fromVoice: true);
      await inbox.add(text: 'second', createdAt: DateTime.utc(2026, 11, 2), fromVoice: false);
      final items = await inbox.watch().first;
      expect(items.map((i) => i.text), ['second', 'first']);
      await inbox.remove(items.first);
      expect((await inbox.watch().first).map((i) => i.text), ['first']);
    });

    test('keeps only the newest 20', () async {
      final inbox = InboxStore(db, ownerScope: identity.guestScope);
      for (var i = 0; i < 25; i++) {
        await inbox.add(text: '$i', createdAt: DateTime.utc(2026, 11, 1).add(Duration(minutes: i)), fromVoice: false);
      }
      final items = await inbox.watch().first;
      expect(items, hasLength(InboxStore.maxItems));
      expect(items.first.text, '24');
      expect(await db.select(db.inboxItems).get(), hasLength(InboxStore.maxItems));
    });

    test('imports the old SharedPreferences inbox exactly once and leaves it in place', () async {
      const raw = '[{"text":"buy rice","createdAt":"2026-11-20T10:00:00.000","fromVoice":true},{"bad":1}]';
      SharedPreferences.setMockInitialValues({InboxStore.legacyPrefsKey: raw});
      final prefs = await SharedPreferences.getInstance();
      final inbox = InboxStore(db, ownerScope: identity.guestScope);
      expect(await inbox.importLegacy(prefs), 1);
      expect(await inbox.importLegacy(prefs), 0);
      final items = await inbox.watch().first;
      expect(items.single.text, 'buy rice');
      expect(items.single.fromVoice, isTrue);
      expect(prefs.getString(InboxStore.legacyPrefsKey), raw);
    });
  });

  group('GuestMigration', () {
    late FakeLegacySource source;
    late GuestMigration migration;

    setUp(() {
      source = FakeLegacySource();
      migration = GuestMigration(db: db, identity: identity, sourceFor: (_) => source, clock: () => now);
    });

    Future<List<ReminderRow>> reminderRows() => db.select(db.reminders).get();

    test('nothing to do without an old anonymous user', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: null);
      expect((await migration.run()).phase, MigrationPhase.notNeeded);
    });

    test('the old uid is remembered only on the first launch of this version', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'new-session-uid');
      expect(await db.meta(MetaKeys.legacyAnonUid), 'old-uid');
    });

    test('A: copies cache and server, all statuses, keeping ids; reruns add no duplicates', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.cache[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Call mom', DateTime.utc(2026, 11, 28))),
        LegacyDoc('r2', reminderDoc('Done one', DateTime.utc(2026, 11, 1), status: 'done')),
      ];
      source.server[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Call mom', DateTime.utc(2026, 11, 28))),
        LegacyDoc('r2', reminderDoc('Done one', DateTime.utc(2026, 11, 1), status: 'done')),
        LegacyDoc('r3', reminderDoc('Only on server', DateTime.utc(2026, 11, 29))),
      ];
      source.cache[Collections.expenses] = [LegacyDoc('e1', expenseDoc(25050))];

      final result = await migration.run();
      expect(result.phase, MigrationPhase.done);
      expect(result.copied, 4);

      final rows = await reminderRows();
      expect(rows.map((r) => r.id).toSet(), {'r1', 'r2', 'r3'});
      expect(rows.every((r) => r.ownerScope == identity.guestScope && r.origin == RecordOrigins.migrated), isTrue);
      expect(rows.firstWhere((r) => r.id == 'r2').status, 'done');
      final expense = await db.select(db.expenses).getSingle();
      expect(expense.amountMinor, 25050);

      // The app sees the migrated data through the normal repository.
      final visible = await repoFor(identity.guestScope).watchPendingReminders().first;
      expect(visible.map((r) => r.id), ['r1', 'r3']);

      // Done means done: a later start doesn't read again or duplicate.
      final reads = source.serverReads;
      expect((await migration.run()).phase, MigrationPhase.done);
      expect(source.serverReads, reads);
      expect(await reminderRows(), hasLength(3));
    });

    test('B: offline copies the cache, then finishes when online', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.online = false;
      source.cache[Collections.reminders] = [LegacyDoc('r1', reminderDoc('Cached', DateTime.utc(2026, 11, 28)))];
      source.server[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Cached', DateTime.utc(2026, 11, 28))),
        LegacyDoc('r9', reminderDoc('Server only', DateTime.utc(2026, 11, 30))),
      ];

      final first = await migration.run();
      expect(first.phase, MigrationPhase.cacheOnly);
      expect((await reminderRows()).map((r) => r.id), ['r1']);

      source.online = true;
      final second = await migration.run();
      expect(second.phase, MigrationPhase.done);
      expect((await reminderRows()).map((r) => r.id).toSet(), {'r1', 'r9'});
      expect(await db.select(db.migrationRuns).get(), hasLength(1), reason: 'the same journal run is resumed');
    });

    test('C: old session lost: keeps what the cache had and finishes', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.sessionValid = false;
      source.cache[Collections.reminders] = [LegacyDoc('r1', reminderDoc('Cached', DateTime.utc(2026, 11, 28)))];
      final result = await migration.run();
      expect(result.phase, MigrationPhase.done);
      expect(source.serverReads, 0);
      expect(await reminderRows(), hasLength(1));
    });

    test('a newer server version replaces an untouched copy', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.cache[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Old title', DateTime.utc(2026, 11, 28), updated: DateTime.utc(2026, 11, 2))),
      ];
      source.server[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('New title', DateTime.utc(2026, 11, 28), updated: DateTime.utc(2026, 11, 3))),
      ];
      expect((await migration.run()).phase, MigrationPhase.done);
      expect((await reminderRows()).single.title, 'New title');
    });

    test('a change the user made after copying is never overwritten', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.online = false;
      source.cache[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Copied', DateTime.utc(2026, 11, 28), updated: DateTime.utc(2026, 11, 2))),
      ];
      expect((await migration.run()).phase, MigrationPhase.cacheOnly);

      // The user edits it locally before the server pass runs.
      now = now.add(const Duration(minutes: 5));
      await repoFor(identity.guestScope)
          .saveReminder(Reminder(id: 'r1', title: 'Edited on phone', remindAt: DateTime.utc(2026, 11, 28)), isNew: false);

      source.online = true;
      source.server[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Server edit', DateTime.utc(2026, 11, 28), updated: DateTime.utc(2026, 11, 9))),
      ];
      expect((await migration.run()).phase, MigrationPhase.done);
      expect((await reminderRows()).single.title, 'Edited on phone');
    });

    test('a cached change the server has not confirmed yet is kept', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      final pending = reminderDoc('Changed offline', DateTime.utc(2026, 11, 28))..['updatedAt'] = null;
      source.cache[Collections.reminders] = [LegacyDoc('r1', pending, hasPendingWrites: true)];
      source.server[Collections.reminders] = [
        LegacyDoc('r1', reminderDoc('Older server copy', DateTime.utc(2026, 11, 28), updated: DateTime.utc(2026, 11, 5))),
      ];
      expect((await migration.run()).phase, MigrationPhase.done);
      expect((await reminderRows()).single.title, 'Changed offline');
    });

    test('a failure is journaled, nothing is lost, and the next start resumes', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.cache[Collections.reminders] = [LegacyDoc('r1', reminderDoc('Keep me', DateTime.utc(2026, 11, 28)))];
      source.failWith = StateError('disk hiccup');
      final failed = await migration.run();
      expect(failed.phase, MigrationPhase.failed);
      final run = await db.select(db.migrationRuns).getSingle();
      expect(run.errorCode, 'StateError', reason: 'only the error class is stored, never a message');

      source.failWith = null;
      source.server[Collections.reminders] = source.cache[Collections.reminders]!;
      expect((await migration.run()).phase, MigrationPhase.done);
      expect(await reminderRows(), hasLength(1));
    });

    test('the journal holds counts and ids only, no record content', () async {
      await GuestMigration.rememberLegacyUser(db, anonymousUid: 'old-uid');
      source.cache[Collections.reminders] = [LegacyDoc('r1', reminderDoc('Secret title', DateTime.utc(2026, 11, 28)))];
      source.server[Collections.reminders] = source.cache[Collections.reminders]!;
      await migration.run();
      final run = await db.select(db.migrationRuns).getSingle();
      final items = await db.select(db.migrationItems).get();
      expect(run.counts, isNot(contains('Secret')));
      expect(items.single.checksum, isNot(contains('Secret')));
    });
  });
}
