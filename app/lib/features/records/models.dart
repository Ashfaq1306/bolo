import 'package:cloud_firestore/cloud_firestore.dart';

/// Data models for everything a user saves. Each class is immutable and
/// converts to/from the Firestore map described in docs/05-database-schema.md.

const int kSchemaVersion = 1;

enum RecordSource { voice, text, manual }

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

DateTime? _ts(Object? v) => v is Timestamp ? v.toDate() : null;
Timestamp? _toTs(DateTime? d) => d == null ? null : Timestamp.fromDate(d);
T _enum<T extends Enum>(List<T> values, Object? v, T fallback) =>
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

  Map<String, Object?> toMap() => {
        'title': title,
        'remindAt': _toTs(remindAt),
        'repeat': repeat.name,
        'status': done ? 'done' : 'pending',
        'notificationId': notificationId,
        'source': source.name,
        'schemaVersion': kSchemaVersion,
      };

  factory Reminder.fromMap(String id, Map<String, dynamic> m) => Reminder(
        id: id,
        title: m['title'] as String? ?? '',
        remindAt: _ts(m['remindAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        repeat: _enum(ReminderRepeat.values, m['repeat'], ReminderRepeat.none),
        done: m['status'] == 'done',
        source: _enum(RecordSource.values, m['source'], RecordSource.manual),
      );
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

  Map<String, Object?> toMap() => {
        'title': title,
        'dueAt': _toTs(dueAt),
        'remindAt': _toTs(remindAt),
        'notificationId': notificationId,
        'priority': highPriority ? 'high' : 'normal',
        'status': done ? 'done' : 'open',
        'completedAt': _toTs(completedAt),
        'source': source.name,
        'schemaVersion': kSchemaVersion,
      };

  factory TaskItem.fromMap(String id, Map<String, dynamic> m) => TaskItem(
        id: id,
        title: m['title'] as String? ?? '',
        dueAt: _ts(m['dueAt']),
        remindAt: _ts(m['remindAt']),
        highPriority: m['priority'] == 'high',
        done: m['status'] == 'done',
        completedAt: _ts(m['completedAt']),
        source: _enum(RecordSource.values, m['source'], RecordSource.manual),
      );
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

  Map<String, Object?> toMap() => {
        'amountPoisha': amountPoisha,
        'currency': 'BDT',
        'category': category.wire,
        'note': note,
        'spentAt': _toTs(spentAt),
        'source': source.name,
        'schemaVersion': kSchemaVersion,
      };

  factory Expense.fromMap(String id, Map<String, dynamic> m) => Expense(
        id: id,
        amountPoisha: (m['amountPoisha'] as num?)?.toInt() ?? 0,
        spentAt: _ts(m['spentAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        category: ExpenseCategory.fromWire(m['category'] as String?),
        note: m['note'] as String? ?? '',
        source: _enum(RecordSource.values, m['source'], RecordSource.manual),
      );
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

  Map<String, Object?> toMap() => {
        'direction': direction.name,
        'person': person,
        'amountPoisha': amountPoisha,
        'currency': 'BDT',
        'dueAt': _toTs(dueAt),
        'status': settled ? 'settled' : 'open',
        'settledAt': _toTs(settledAt),
        'note': note,
        'source': source.name,
        'schemaVersion': kSchemaVersion,
      };

  factory LedgerEntry.fromMap(String id, Map<String, dynamic> m) => LedgerEntry(
        id: id,
        direction: _enum(LedgerDirection.values, m['direction'], LedgerDirection.receivable),
        person: m['person'] as String? ?? '',
        amountPoisha: (m['amountPoisha'] as num?)?.toInt() ?? 0,
        dueAt: _ts(m['dueAt']),
        settled: m['status'] == 'settled',
        settledAt: _ts(m['settledAt']),
        note: m['note'] as String? ?? '',
        source: _enum(RecordSource.values, m['source'], RecordSource.manual),
        createdAt: _ts(m['createdAt']),
      );
}
