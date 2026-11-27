import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../data/bolo_database.dart';
import '../../data/device_identity.dart';
import '../records/drift_records_repository.dart';
import '../records/firestore_codec.dart';
import '../records/models.dart';
import '../records/records_repository.dart';
import 'legacy_source.dart';

/// Where the one-time copy of old Firestore guest data stands.
enum MigrationPhase {
  /// Nothing to copy (new install, or a registered account).
  notNeeded,
  running,

  /// Copied what the phone had; the server pass will run when online.
  cacheOnly,
  done,
  failed,
}

class MigrationStatus {
  const MigrationStatus(this.phase, {this.copied = 0, this.justCompleted = false});
  final MigrationPhase phase;

  /// Records copied into the local database so far.
  final int copied;

  /// The migration finished during this call (not on an earlier start).
  final bool justCompleted;
}

/// Journal states (MigrationRuns.state), docs/13 § 11.
class RunStates {
  static const started = 'started';
  static const copiedCache = 'copied_cache';
  static const cacheOnly = 'cache_only';
  static const copiedServer = 'copied_server';
  static const verified = 'verified';
  static const done = 'done';
  static const failed = 'failed';
}

const keptLocal = 'kept_local';

/// Copies the old anonymous user's Firestore records (scenarios A–C in
/// docs/13 § 11) into the guest workspace of the local database.
///
/// - **Copy, never move:** the source is only read. Nothing in Firestore is
///   changed or deleted.
/// - **Idempotent and resumable:** the Firestore document id becomes the local
///   id, so running again never duplicates; a journal records progress.
/// - **Local changes win:** a row the user changed after it was copied is
///   never overwritten by the migration.
/// - **Verified:** every copied row is re-read and compared by checksum.
class GuestMigration {
  GuestMigration({
    required BoloDatabase db,
    required DeviceIdentity identity,
    required LegacyRecordSource? Function(String legacyUid) sourceFor,
    DateTime Function() clock = DateTime.now,
  })  : _db = db, // ignore: prefer_initializing_formals
        _identity = identity, // ignore: prefer_initializing_formals
        _sourceFor = sourceFor, // ignore: prefer_initializing_formals
        _now = clock;

  final BoloDatabase _db;
  final DeviceIdentity _identity;
  final LegacyRecordSource? Function(String legacyUid) _sourceFor;
  final DateTime Function() _now;

  int get _nowMs => _now().toUtc().millisecondsSinceEpoch;

  /// Records which anonymous uid owned this phone's data **before** this
  /// version, exactly once (first launch of the Drift version). Must run
  /// before the app signs in anonymously for a new session.
  static Future<void> rememberLegacyUser(BoloDatabase db, {required String? anonymousUid}) async {
    if (await db.meta(MetaKeys.legacyChecked) != null) return;
    await db.transaction(() async {
      if (anonymousUid != null) await db.setMeta(MetaKeys.legacyAnonUid, anonymousUid);
      await db.setMeta(MetaKeys.legacyChecked, '1');
    });
  }

  Future<MigrationStatus> status() async {
    if (await _db.meta(MetaKeys.legacyAnonUid) == null) return const MigrationStatus(MigrationPhase.notNeeded);
    final run = await _latestRun();
    final copied = await _copiedCount();
    return switch (run?.state) {
      null => MigrationStatus(MigrationPhase.running, copied: copied),
      RunStates.done => MigrationStatus(MigrationPhase.done, copied: copied),
      RunStates.cacheOnly => MigrationStatus(MigrationPhase.cacheOnly, copied: copied),
      RunStates.failed => MigrationStatus(MigrationPhase.failed, copied: copied),
      _ => MigrationStatus(MigrationPhase.running, copied: copied),
    };
  }

  /// Runs (or resumes) the migration. Safe to call on every app start.
  Future<MigrationStatus> run() async {
    final legacyUid = await _db.meta(MetaKeys.legacyAnonUid);
    if (legacyUid == null) return const MigrationStatus(MigrationPhase.notNeeded);
    final last = await _latestRun();
    if (last?.state == RunStates.done) return status();

    final runId = last?.id ??
        await _db.into(_db.migrationRuns).insert(
              MigrationRunsCompanion.insert(state: RunStates.started, startedAt: _nowMs, updatedAt: _nowMs),
            );
    final source = _sourceFor(legacyUid);
    if (source == null) return status();
    final counts = <String, Map<String, Object>>{};

    try {
      await _setState(runId, RunStates.started);
      await _copyAll(runId, source, fromServer: false, counts: counts);
      await _setState(runId, RunStates.copiedCache, counts: counts);

      if (!source.canReadServer) {
        // Scenario C: the old anonymous session is gone, so the server copy
        // can't be read from this phone. What the cache had is all we get.
        counts['server'] = {'pass': 'identity_lost'};
        return await _finish(runId, counts);
      }
      try {
        await source.flushPendingWrites();
        await _copyAll(runId, source, fromServer: true, counts: counts);
      } on LegacySourceOffline {
        // Scenario B: finish the server pass on a later start.
        await _setState(runId, RunStates.cacheOnly, counts: counts);
        return await status();
      }
      await _setState(runId, RunStates.copiedServer, counts: counts);
      return await _finish(runId, counts);
    } catch (e) {
      final code = e is FirebaseException ? 'FirebaseException:${e.code}' : e.runtimeType.toString();
      debugPrint('Guest migration failed: $code');
      await _setState(runId, RunStates.failed, counts: counts, errorCode: code);
      return status();
    }
  }

  Future<MigrationStatus> _finish(int runId, Map<String, Map<String, Object>> counts) async {
    final mismatches = await _verify(runId);
    if (mismatches > 0) {
      await _setState(runId, RunStates.failed, counts: counts, errorCode: 'verify_mismatch:$mismatches');
      return status();
    }
    await _setState(runId, RunStates.verified, counts: counts);
    await _setState(runId, RunStates.done, counts: counts);
    return status();
  }

  // ---- copy -----------------------------------------------------------

  late final List<_Spec> _specs = [
    _Spec(
      collection: Collections.reminders,
      table: _db.reminders,
      fromDoc: (d) => reminderFromFirestore(d.id, d.data),
      checksum: (r) => _checksum(_canonReminder(r as Reminder)),
      toRow: (r, created, updated, server) => reminderToRow(r as Reminder,
          ownerScope: _identity.guestScope,
          deviceId: _identity.deviceId,
          createdAt: created,
          updatedAt: updated,
          origin: RecordOrigins.migrated,
          serverUpdatedAt: server),
      readBack: (id) async {
        final row = await (_db.select(_db.reminders)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row == null ? null : reminderFromRow(row);
      },
    ),
    _Spec(
      collection: Collections.tasks,
      table: _db.tasks,
      fromDoc: (d) => taskFromFirestore(d.id, d.data),
      checksum: (t) => _checksum(_canonTask(t as TaskItem)),
      toRow: (t, created, updated, server) => taskToRow(t as TaskItem,
          ownerScope: _identity.guestScope,
          deviceId: _identity.deviceId,
          createdAt: created,
          updatedAt: updated,
          origin: RecordOrigins.migrated,
          serverUpdatedAt: server),
      readBack: (id) async {
        final row = await (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row == null ? null : taskFromRow(row);
      },
    ),
    _Spec(
      collection: Collections.expenses,
      table: _db.expenses,
      fromDoc: (d) => expenseFromFirestore(d.id, d.data),
      checksum: (e) => _checksum(_canonExpense(e as Expense)),
      toRow: (e, created, updated, server) => expenseToRow(e as Expense,
          ownerScope: _identity.guestScope,
          deviceId: _identity.deviceId,
          createdAt: created,
          updatedAt: updated,
          origin: RecordOrigins.migrated,
          serverUpdatedAt: server),
      readBack: (id) async {
        final row = await (_db.select(_db.expenses)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row == null ? null : expenseFromRow(row);
      },
    ),
    _Spec(
      collection: Collections.ledger,
      table: _db.ledgerEntries,
      fromDoc: (d) => ledgerFromFirestore(d.id, d.data),
      checksum: (e) => _checksum(_canonLedger(e as LedgerEntry)),
      toRow: (e, created, updated, server) => ledgerToRow(e as LedgerEntry,
          ownerScope: _identity.guestScope,
          deviceId: _identity.deviceId,
          createdAt: created,
          updatedAt: updated,
          origin: RecordOrigins.migrated,
          serverUpdatedAt: server),
      readBack: (id) async {
        final row = await (_db.select(_db.ledgerEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
        return row == null ? null : ledgerFromRow(row);
      },
    ),
  ];

  Future<void> _copyAll(
    int runId,
    LegacyRecordSource source, {
    required bool fromServer,
    required Map<String, Map<String, Object>> counts,
  }) async {
    final pass = fromServer ? 'server' : 'cache';
    for (final spec in _specs) {
      final docs = fromServer ? await source.readServer(spec.collection) : await source.readCache(spec.collection);
      var copied = 0, kept = 0;
      // One transaction per collection: all of it lands, or none of it.
      await _db.transaction(() async {
        for (final doc in docs) {
          if (await _copyOne(runId, spec, doc)) {
            copied++;
          } else {
            kept++;
          }
        }
      });
      final c = counts.putIfAbsent(spec.collection, () => {});
      c[pass] = docs.length;
      c['${pass}_copied'] = copied;
      c['${pass}_kept'] = kept;
    }
  }

  /// Returns true when the document was written to the local database.
  Future<bool> _copyOne(int runId, _Spec spec, LegacyDoc doc) async {
    final record = spec.fromDoc(doc);
    final sourceUpdated = doc.hasPendingWrites ? null : firestoreUpdatedAt(doc.data)?.toUtc().millisecondsSinceEpoch;
    final created = firestoreCreatedAt(doc.data)?.toUtc().millisecondsSinceEpoch ?? sourceUpdated ?? _nowMs;
    final updated = sourceUpdated ?? created;

    final existing = await _db
        .customSelect(
          'SELECT rev, origin, server_updated_at FROM ${spec.table.actualTableName} WHERE id = ?',
          variables: [Variable<String>(doc.id)],
        )
        .getSingleOrNull();

    final bool write;
    if (existing == null) {
      write = true;
    } else {
      // Replace only an untouched migrated copy, and only with a newer
      // confirmed server version. Anything the user changed stays.
      final untouched = existing.read<String>('origin') == RecordOrigins.migrated && existing.read<int>('rev') == 1;
      final localServerAt = existing.readNullable<int>('server_updated_at');
      write = untouched && localServerAt != null && sourceUpdated != null && sourceUpdated > localServerAt;
    }

    if (write) {
      await _db.into(spec.table).insertOnConflictUpdate(spec.toRow(record, created, updated, sourceUpdated));
      await _db.into(_db.migrationItems).insertOnConflictUpdate(MigrationItemsCompanion.insert(
            runId: runId,
            collection: spec.collection,
            sourceId: doc.id,
            checksum: spec.checksum(record),
          ));
    } else {
      // Keep the earlier checksum if this item was copied in an earlier pass.
      await _db.into(_db.migrationItems).insert(
            MigrationItemsCompanion.insert(runId: runId, collection: spec.collection, sourceId: doc.id, checksum: keptLocal),
            mode: InsertMode.insertOrIgnore,
          );
    }
    return write;
  }

  // ---- verify ---------------------------------------------------------

  /// Re-reads every copied row and compares checksums. Returns the number of
  /// rows that are missing or differ.
  Future<int> _verify(int runId) async {
    var mismatches = 0;
    for (final spec in _specs) {
      final items = await (_db.select(_db.migrationItems)..where((t) => t.collection.equals(spec.collection))).get();
      for (final item in items) {
        final record = await spec.readBack(item.sourceId);
        if (record == null) {
          mismatches++;
        } else if (item.checksum != keptLocal && item.checksum != spec.checksum(record)) {
          // A row the user changed since it was copied is expected to differ.
          final rev = await _db
              .customSelect('SELECT rev FROM ${spec.table.actualTableName} WHERE id = ?',
                  variables: [Variable<String>(item.sourceId)])
              .getSingle();
          if (rev.read<int>('rev') == 1) mismatches++;
        }
      }
    }
    return mismatches;
  }

  // ---- journal --------------------------------------------------------

  Future<MigrationRunRow?> _latestRun() => (_db.select(_db.migrationRuns)
        ..orderBy([(t) => OrderingTerm.desc(t.id)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> _copiedCount() async {
    final count = _db.migrationItems.sourceId.count();
    final q = _db.selectOnly(_db.migrationItems)
      ..addColumns([count])
      ..where(_db.migrationItems.checksum.equals(keptLocal).not());
    return (await q.getSingle()).read(count) ?? 0;
  }

  Future<void> _setState(int runId, String state, {Map<String, Map<String, Object>>? counts, String? errorCode}) =>
      (_db.update(_db.migrationRuns)..where((t) => t.id.equals(runId))).write(MigrationRunsCompanion(
        state: Value(state),
        updatedAt: Value(_nowMs),
        counts: counts == null ? const Value.absent() : Value(jsonEncode(counts)),
        errorCode: Value(errorCode),
      ));
}

class _Spec {
  _Spec({
    required this.collection,
    required this.table,
    required this.fromDoc,
    required this.checksum,
    required this.toRow,
    required this.readBack,
  });
  final String collection;
  final TableInfo table;
  final Object Function(LegacyDoc) fromDoc;
  final String Function(Object) checksum;
  final Insertable Function(Object record, int createdAt, int updatedAt, int? serverUpdatedAt) toRow;
  final Future<Object?> Function(String id) readBack;
}

// ---- checksums ----------------------------------------------------------

int? _ms(DateTime? d) => d?.toUtc().millisecondsSinceEpoch;

String _canonReminder(Reminder r) => jsonEncode([r.id, r.title, _ms(r.remindAt), r.repeat.name, r.done, r.source.name]);
String _canonTask(TaskItem t) => jsonEncode(
    [t.id, t.title, _ms(t.dueAt), _ms(t.remindAt), t.highPriority, t.done, _ms(t.completedAt), t.source.name]);
String _canonExpense(Expense e) =>
    jsonEncode([e.id, e.amountPoisha, _ms(e.spentAt), e.category.wire, e.note, e.source.name]);
String _canonLedger(LedgerEntry e) => jsonEncode([
      e.id,
      e.direction.name,
      e.person,
      e.amountPoisha,
      _ms(e.dueAt),
      e.settled,
      _ms(e.settledAt),
      e.note,
      e.source.name,
    ]);

/// 64-bit FNV-1a over UTF-8, as hex. Detects copy errors; not a security hash.
String _checksum(String canonical) {
  var hash = 0xcbf29ce484222325;
  for (final byte in utf8.encode(canonical)) {
    hash ^= byte;
    hash *= 0x100000001b3;
  }
  return hash.toUnsigned(64).toRadixString(16);
}
