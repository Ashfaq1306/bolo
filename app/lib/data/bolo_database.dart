import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'bolo_database.g.dart';

/// The app's local database: the source of truth for personal records on the
/// phone (ADR-10). Schema notes: docs/05-database-schema.md § 5.7.
///
/// All times are stored as **UTC milliseconds** in integer columns (we don't
/// use Drift's DateTime columns, which store seconds). Money is integer minor
/// units (poisha) with a currency code.
///
/// Regenerate `bolo_database.g.dart` after changing a table:
///   dart run build_runner build
/// and add a step to [BoloDatabase.migration] when [schemaVersion] goes up.

/// Ownership and sync bookkeeping shared by every personal record table.
mixin RecordColumns on Table {
  /// Stable text id. Records migrated from Firestore keep their document id.
  TextColumn get id => text()();

  /// `device:<deviceId>` for a guest, `account:<uid>` for a registered user.
  TextColumn get ownerScope => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Tombstone: set instead of deleting the row, so sync can propagate it.
  IntColumn get deletedAt => integer().nullable()();

  /// Bumped on every local change.
  IntColumn get rev => integer().withDefault(const Constant(1))();
  TextColumn get lastDeviceId => text()();

  /// `local` (guest, never syncs), `pending`, `synced`, `conflict`.
  TextColumn get syncState => text().withDefault(const Constant(SyncStates.local))();

  /// Firestore `updatedAt` of the copy this row was last reconciled with.
  IntColumn get serverUpdatedAt => integer().nullable()();

  /// `local`, `migrated` (copied from the old Firestore guest data), `imported`.
  TextColumn get origin => text().withDefault(const Constant(RecordOrigins.local))();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncStates {
  static const local = 'local';
  static const pending = 'pending';
  static const synced = 'synced';
  static const conflict = 'conflict';
}

class RecordOrigins {
  static const local = 'local';
  static const migrated = 'migrated';
  static const imported = 'imported';
}

@TableIndex(name: 'reminders_owner_status', columns: {#ownerScope, #deletedAt, #status})
@TableIndex(name: 'reminders_owner_time', columns: {#ownerScope, #remindAt})
@TableIndex(name: 'reminders_sync', columns: {#syncState})
@DataClassName('ReminderRow')
class Reminders extends Table with RecordColumns {
  TextColumn get title => text()();
  IntColumn get remindAt => integer()();
  TextColumn get repeat => text()();

  /// `pending` or `done`.
  TextColumn get status => text()();
  TextColumn get source => text()();

  /// IANA zone the user meant the time in.
  TextColumn get timeZone => text().withDefault(const Constant('Asia/Dhaka'))();
}

@TableIndex(name: 'tasks_owner_status', columns: {#ownerScope, #deletedAt, #status})
@TableIndex(name: 'tasks_sync', columns: {#syncState})
@DataClassName('TaskRow')
class Tasks extends Table with RecordColumns {
  TextColumn get title => text()();
  IntColumn get dueAt => integer().nullable()();
  IntColumn get remindAt => integer().nullable()();

  /// `normal` or `high`.
  TextColumn get priority => text()();

  /// `open` or `done`.
  TextColumn get status => text()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get source => text()();
  TextColumn get timeZone => text().withDefault(const Constant('Asia/Dhaka'))();
}

@TableIndex(name: 'expenses_owner_time', columns: {#ownerScope, #spentAt})
@TableIndex(name: 'expenses_sync', columns: {#syncState})
@DataClassName('ExpenseRow')
class Expenses extends Table with RecordColumns {
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  TextColumn get category => text()();
  TextColumn get note => text()();
  IntColumn get spentAt => integer()();
  TextColumn get source => text()();
}

@TableIndex(name: 'ledger_owner_status', columns: {#ownerScope, #deletedAt, #status})
@TableIndex(name: 'ledger_sync', columns: {#syncState})
@DataClassName('LedgerRow')
class LedgerEntries extends Table with RecordColumns {
  /// `receivable` or `payable`.
  TextColumn get direction => text()();
  TextColumn get person => text()();
  IntColumn get amountMinor => integer()();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  IntColumn get dueAt => integer().nullable()();

  /// `open` or `settled`.
  TextColumn get status => text()();
  IntColumn get settledAt => integer().nullable()();
  TextColumn get note => text()();
  TextColumn get source => text()();
}

/// Captures that could not be understood yet (usually offline). Never synced.
@TableIndex(name: 'inbox_owner_time', columns: {#ownerScope, #createdAt})
@DataClassName('InboxRow')
class InboxItems extends Table {
  TextColumn get id => text()();
  TextColumn get ownerScope => text()();
  TextColumn get body => text()();
  BoolColumn get fromVoice => boolean()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Small key/value facts about this install (device id, legacy uid, flags).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Journal of the one-time copy of old Firestore guest data (docs/13 § 11).
@DataClassName('MigrationRunRow')
class MigrationRuns extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// started, copied_cache, cache_only, copied_server, verified, done, failed.
  TextColumn get state => text()();
  IntColumn get startedAt => integer()();
  IntColumn get updatedAt => integer()();

  /// JSON: per-collection counts. Never contains record content.
  TextColumn get counts => text().withDefault(const Constant('{}'))();

  /// Error class only (e.g. `FirebaseException:unavailable`), never a message with user data.
  TextColumn get errorCode => text().nullable()();
}

/// One row per source document the migration has copied or kept.
@DataClassName('MigrationItemRow')
class MigrationItems extends Table {
  IntColumn get runId => integer()();
  TextColumn get collection => text()();
  TextColumn get sourceId => text()();

  /// Checksum of the copied record's fields, or `kept_local` when a newer
  /// local version was kept instead.
  TextColumn get checksum => text()();

  @override
  Set<Column<Object>> get primaryKey => {collection, sourceId};
}

@DriftDatabase(tables: [
  Reminders,
  Tasks,
  Expenses,
  LedgerEntries,
  InboxItems,
  AppMeta,
  MigrationRuns,
  MigrationItems,
])
class BoloDatabase extends _$BoloDatabase {
  BoloDatabase(super.e);

  /// Opens `bolo.sqlite` in the app's private documents folder.
  factory BoloDatabase.open() => BoloDatabase(driftDatabase(name: 'bolo'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Future versions: add `from < N` steps here, each with a test.
        onUpgrade: (m, from, to) async {},
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<String?> meta(String key) async =>
      (await (select(appMeta)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setMeta(String key, String value) =>
      into(appMeta).insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));
}

/// Keys used in [AppMeta].
class MetaKeys {
  static const deviceId = 'device_id';

  /// The anonymous Firebase uid that owned this phone's data before Phase 1.
  static const legacyAnonUid = 'legacy_anon_uid';

  /// Set once the first launch of the Drift version has checked for legacy data.
  static const legacyChecked = 'legacy_checked';

  /// Set once the SharedPreferences inbox was copied into [InboxItems].
  static const inboxImported = 'inbox_imported';
}
