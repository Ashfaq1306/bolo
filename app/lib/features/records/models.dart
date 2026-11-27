// Data models for everything a user saves. Plain, immutable Dart: no
// storage types here. The local database (bolo_database.dart) and the
// Firestore codec (firestore_codec.dart) convert to and from these.

const int kSchemaVersion = 1;

/// How a record was created: by voice, typed command, manual form, or receipt scan.
enum RecordSource { voice, text, manual, scan }

enum ReminderRepeat { none, daily, weekly }

enum ExpenseCategory {
  food,
  transport,
  bills,
  shopping,
  health,
  education,
  mobileRecharge,
  family,
  other;

  /// Firestore value (snake_case, matches the server schema).
  String get wire => this == mobileRecharge ? 'mobile_recharge' : name;

  static ExpenseCategory fromWire(String? v) =>
      ExpenseCategory.values.firstWhere((c) => c.wire == v, orElse: () => ExpenseCategory.other);
}

enum LedgerDirection {
  /// They owe me (আমি পাব).
  receivable,

  /// I owe them (আমি দেব).
  payable,
}

/// Stable 31-bit id for local notifications, derived from a Firestore doc id
/// with FNV-1a. (Dart's `String.hashCode` is not stable between app runs.)
int notificationIdFor(String docId) {
  var hash = 0x811c9dc5;
  for (final unit in docId.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// Reads an enum by its `name`, falling back for unknown or missing values.
T enumByName<T extends Enum>(List<T> values, Object? v, T fallback) =>
    values.firstWhere((e) => e.name == v, orElse: () => fallback);

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.remindAt,
    this.repeat = ReminderRepeat.none,
    this.done = false,
    this.source = RecordSource.manual,
  });

  final String id;
  final String title;
  final DateTime remindAt;
  final ReminderRepeat repeat;
  final bool done;
  final RecordSource source;

  int get notificationId => notificationIdFor(id);
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.dueAt,
    this.remindAt,
    this.highPriority = false,
    this.done = false,
    this.completedAt,
    this.source = RecordSource.manual,
  });

  final String id;
  final String title;
  final DateTime? dueAt;
  final DateTime? remindAt;
  final bool highPriority;
  final bool done;
  final DateTime? completedAt;
  final RecordSource source;

  int get notificationId => notificationIdFor(id);
}

class Expense {
  const Expense({
    required this.id,
    required this.amountPoisha,
    required this.spentAt,
    this.category = ExpenseCategory.other,
    this.note = '',
    this.source = RecordSource.manual,
  });

  final String id;
  final int amountPoisha;
  final DateTime spentAt;
  final ExpenseCategory category;
  final String note;
  final RecordSource source;
}

class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.direction,
    required this.person,
    required this.amountPoisha,
    this.dueAt,
    this.settled = false,
    this.settledAt,
    this.note = '',
    this.source = RecordSource.manual,
    this.createdAt,
  });

  final String id;
  final LedgerDirection direction;
  final String person;
  final int amountPoisha;
  final DateTime? dueAt;
  final bool settled;
  final DateTime? settledAt;
  final String note;
  final RecordSource source;
  final DateTime? createdAt;
}
