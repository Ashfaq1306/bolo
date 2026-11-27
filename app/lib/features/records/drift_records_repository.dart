import 'package:drift/drift.dart';

import '../../data/bolo_database.dart';
import '../../data/device_identity.dart';
import 'models.dart';
import 'records_repository.dart';

/// Records stored in the local Drift database (ADR-10). Used for guests,
/// whose data never leaves the phone (ADR-11), so rows are `sync_state = local`.
///
/// Every query is limited to one [ownerScope] and skips tombstones.
/// Writes complete when the row is on disk: no network involved.
class DriftRecordsRepository implements RecordsRepository {
  DriftRecordsRepository(
    this._db, {
    required this.ownerScope,
    required this.deviceId,
    DateTime Function() clock = DateTime.now,
    this.syncState = SyncStates.local,
  }) : _now = clock;

  final BoloDatabase _db;
  final String ownerScope;
  final String deviceId;
  final String syncState;
  final DateTime Function() _now;

  int get _nowMs => _now().toUtc().millisecondsSinceEpoch;

  @override
  String newId(String collection) => newRecordId();

  // ---- reads ----------------------------------------------------------

  @override
  Stream<List<Reminder>> watchPendingReminders() {
    final q = _db.select(_db.reminders)
      ..where((t) => t.ownerScope.equals(ownerScope) & t.deletedAt.isNull() & t.status.equals('pending'))
      ..orderBy([(t) => OrderingTerm.asc(t.remindAt)]);
    return q.watch().map((rows) => rows.map(reminderFromRow).toList());
  }

  @override
  Stream<List<TaskItem>> watchOpenTasks() {
    final q = _db.select(_db.tasks)
      ..where((t) => t.ownerScope.equals(ownerScope) & t.deletedAt.isNull() & t.status.equals('open'));
    return q.watch().map((rows) => rows.map(taskFromRow).toList()
      ..sort((a, b) {
        final ad = a.dueAt, bd = b.dueAt;
        if (ad == null && bd == null) return a.title.compareTo(b.title);
        if (ad == null) return 1;
        if (bd == null) return -1;
        return ad.compareTo(bd);
      }));
  }

  @override
  Stream<List<Expense>> watchExpensesSince(DateTime since) {
    final q = _db.select(_db.expenses)
      ..where((t) =>
          t.ownerScope.equals(ownerScope) &
          t.deletedAt.isNull() &
          t.spentAt.isBiggerOrEqualValue(since.toUtc().millisecondsSinceEpoch))
      ..orderBy([(t) => OrderingTerm.desc(t.spentAt)]);
    return q.watch().map((rows) => rows.map(expenseFromRow).toList());
  }

  @override
  Stream<List<LedgerEntry>> watchOpenLedger() {
    final q = _db.select(_db.ledgerEntries)
      ..where((t) => t.ownerScope.equals(ownerScope) & t.deletedAt.isNull() & t.status.equals('open'));
    return q.watch().map((rows) => rows.map(ledgerFromRow).toList()
      ..sort((a, b) => a.person.toLowerCase().compareTo(b.person.toLowerCase())));
  }

  // ---- writes ---------------------------------------------------------

  @override
  Future<void> saveReminder(Reminder r, {bool isNew = true}) {
    final now = _nowMs;
    final row = reminderToRow(r, ownerScope: ownerScope, deviceId: deviceId, createdAt: now, updatedAt: now, syncState: syncState);
    return _upsert(_db.reminders, r.id, row, row.copyWith(createdAt: const Value.absent(), origin: const Value.absent()));
  }

  @override
  Future<void> saveTask(TaskItem t, {bool isNew = true}) {
    final now = _nowMs;
    final row = taskToRow(t, ownerScope: ownerScope, deviceId: deviceId, createdAt: now, updatedAt: now, syncState: syncState);
    return _upsert(_db.tasks, t.id, row, row.copyWith(createdAt: const Value.absent(), origin: const Value.absent()));
  }

  @override
  Future<void> saveExpense(Expense e, {bool isNew = true}) {
    final now = _nowMs;
    final row = expenseToRow(e, ownerScope: ownerScope, deviceId: deviceId, createdAt: now, updatedAt: now, syncState: syncState);
    return _upsert(_db.expenses, e.id, row, row.copyWith(createdAt: const Value.absent(), origin: const Value.absent()));
  }

  @override
  Future<void> saveLedgerEntry(LedgerEntry e, {bool isNew = true}) {
    final now = _nowMs;
    final row = ledgerToRow(e, ownerScope: ownerScope, deviceId: deviceId, createdAt: now, updatedAt: now, syncState: syncState);
    return _upsert(_db.ledgerEntries, e.id, row, row.copyWith(createdAt: const Value.absent(), origin: const Value.absent()));
  }

  /// Inserts a new row, or (same id, same owner) replaces its fields while
  /// keeping the creation time and origin, and bumps `rev`.
  Future<void> _upsert<T extends Table, D>(TableInfo<T, D> table, String id, Insertable<D> insert, Insertable<D> update) =>
      _db.transaction(() async {
        final changed = await _patch(table, id, update);
        if (changed == 0) await _db.into(table).insert(insert);
      });

  @override
  Future<void> setReminderDone(String id, bool done) async => _patch(
        _db.reminders,
        id,
        RemindersCompanion(status: Value(done ? 'done' : 'pending')),
      );

  @override
  Future<void> setTaskDone(String id, bool done) async => _patch(
        _db.tasks,
        id,
        TasksCompanion(
          status: Value(done ? 'done' : 'open'),
          completedAt: Value(done ? _nowMs : null),
        ),
      );

  @override
  Future<void> settleLedgerEntry(String id) async => _patch(
        _db.ledgerEntries,
        id,
        LedgerEntriesCompanion(status: const Value('settled'), settledAt: Value(_nowMs)),
      );

  /// Deletes are tombstones: the row stays with `deleted_at` set.
  @override
  Future<void> delete(String collection, String id) async {
    final stamp = _nowMs;
    switch (collection) {
      case Collections.reminders:
        await _patch(_db.reminders, id, RemindersCompanion(deletedAt: Value(stamp)));
      case Collections.tasks:
        await _patch(_db.tasks, id, TasksCompanion(deletedAt: Value(stamp)));
      case Collections.expenses:
        await _patch(_db.expenses, id, ExpensesCompanion(deletedAt: Value(stamp)));
      case Collections.ledger:
        await _patch(_db.ledgerEntries, id, LedgerEntriesCompanion(deletedAt: Value(stamp)));
      default:
        throw ArgumentError.value(collection, 'collection');
    }
  }

  /// Updates some fields of one of this owner's rows and stamps the change
  /// (`rev` + 1, `updated_at`, device, sync state). Returns rows changed (0 or 1).
  Future<int> _patch<T extends Table, D>(TableInfo<T, D> table, String id, Insertable<D> fields) {
    final cols = table.columnsByName;
    final idCol = cols['id']! as GeneratedColumn<String>;
    final ownerCol = cols['owner_scope']! as GeneratedColumn<String>;
    final revCol = cols['rev']! as GeneratedColumn<int>;
    return _db.transaction(() async {
      final changed = await (_db.update(table)..where((_) => idCol.equals(id) & ownerCol.equals(ownerScope))).write(fields);
      if (changed == 0) return 0;
      await (_db.update(table)..where((_) => idCol.equals(id) & ownerCol.equals(ownerScope))).write(
        RawValuesInsertable<D>({
          'rev': revCol + const Constant(1),
          'updated_at': Variable<int>(_nowMs),
          'last_device_id': Variable<String>(deviceId),
          'sync_state': Variable<String>(syncState),
        }),
      );
      return changed;
    });
  }
}

// ---- row <-> model mapping (also used by the guest migration) -----------

DateTime _at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
DateTime? _atOrNull(int? ms) => ms == null ? null : _at(ms);
int _ms(DateTime d) => d.toUtc().millisecondsSinceEpoch;
int? _msOrNull(DateTime? d) => d == null ? null : _ms(d);

Reminder reminderFromRow(ReminderRow r) => Reminder(
      id: r.id,
      title: r.title,
      remindAt: _at(r.remindAt),
      repeat: enumByName(ReminderRepeat.values, r.repeat, ReminderRepeat.none),
      done: r.status == 'done',
      source: enumByName(RecordSource.values, r.source, RecordSource.manual),
    );

RemindersCompanion reminderToRow(
  Reminder r, {
  required String ownerScope,
  required String deviceId,
  required int createdAt,
  required int updatedAt,
  String syncState = SyncStates.local,
  String origin = RecordOrigins.local,
  int? serverUpdatedAt,
}) =>
    RemindersCompanion.insert(
      id: r.id,
      ownerScope: ownerScope,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastDeviceId: deviceId,
      syncState: Value(syncState),
      origin: Value(origin),
      serverUpdatedAt: Value(serverUpdatedAt),
      title: r.title,
      remindAt: _ms(r.remindAt),
      repeat: r.repeat.name,
      status: r.done ? 'done' : 'pending',
      source: r.source.name,
    );

TaskItem taskFromRow(TaskRow t) => TaskItem(
      id: t.id,
      title: t.title,
      dueAt: _atOrNull(t.dueAt),
      remindAt: _atOrNull(t.remindAt),
      highPriority: t.priority == 'high',
      done: t.status == 'done',
      completedAt: _atOrNull(t.completedAt),
      source: enumByName(RecordSource.values, t.source, RecordSource.manual),
    );

TasksCompanion taskToRow(
  TaskItem t, {
  required String ownerScope,
  required String deviceId,
  required int createdAt,
  required int updatedAt,
  String syncState = SyncStates.local,
  String origin = RecordOrigins.local,
  int? serverUpdatedAt,
}) =>
    TasksCompanion.insert(
      id: t.id,
      ownerScope: ownerScope,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastDeviceId: deviceId,
      syncState: Value(syncState),
      origin: Value(origin),
      serverUpdatedAt: Value(serverUpdatedAt),
      title: t.title,
      dueAt: Value(_msOrNull(t.dueAt)),
      remindAt: Value(_msOrNull(t.remindAt)),
      priority: t.highPriority ? 'high' : 'normal',
      status: t.done ? 'done' : 'open',
      completedAt: Value(_msOrNull(t.completedAt)),
      source: t.source.name,
    );

Expense expenseFromRow(ExpenseRow e) => Expense(
      id: e.id,
      amountPoisha: e.amountMinor,
      spentAt: _at(e.spentAt),
      category: ExpenseCategory.fromWire(e.category),
      note: e.note,
      source: enumByName(RecordSource.values, e.source, RecordSource.manual),
    );

ExpensesCompanion expenseToRow(
  Expense e, {
  required String ownerScope,
  required String deviceId,
  required int createdAt,
  required int updatedAt,
  String syncState = SyncStates.local,
  String origin = RecordOrigins.local,
  int? serverUpdatedAt,
}) =>
    ExpensesCompanion.insert(
      id: e.id,
      ownerScope: ownerScope,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastDeviceId: deviceId,
      syncState: Value(syncState),
      origin: Value(origin),
      serverUpdatedAt: Value(serverUpdatedAt),
      amountMinor: e.amountPoisha,
      category: e.category.wire,
      note: e.note,
      spentAt: _ms(e.spentAt),
      source: e.source.name,
    );

LedgerEntry ledgerFromRow(LedgerRow e) => LedgerEntry(
      id: e.id,
      direction: enumByName(LedgerDirection.values, e.direction, LedgerDirection.receivable),
      person: e.person,
      amountPoisha: e.amountMinor,
      dueAt: _atOrNull(e.dueAt),
      settled: e.status == 'settled',
      settledAt: _atOrNull(e.settledAt),
      note: e.note,
      source: enumByName(RecordSource.values, e.source, RecordSource.manual),
      createdAt: _at(e.createdAt),
    );

LedgerEntriesCompanion ledgerToRow(
  LedgerEntry e, {
  required String ownerScope,
  required String deviceId,
  required int createdAt,
  required int updatedAt,
  String syncState = SyncStates.local,
  String origin = RecordOrigins.local,
  int? serverUpdatedAt,
}) =>
    LedgerEntriesCompanion.insert(
      id: e.id,
      ownerScope: ownerScope,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastDeviceId: deviceId,
      syncState: Value(syncState),
      origin: Value(origin),
      serverUpdatedAt: Value(serverUpdatedAt),
      direction: e.direction.name,
      person: e.person,
      amountMinor: e.amountPoisha,
      dueAt: Value(_msOrNull(e.dueAt)),
      status: e.settled ? 'settled' : 'open',
      settledAt: Value(_msOrNull(e.settledAt)),
      note: e.note,
      source: e.source.name,
    );
