import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

/// Converts records to and from the Firestore document shape described in
/// docs/05-database-schema.md. Firestore types stay in this file (and the
/// Firestore repository / migration source), never in the models.

const int kFirestoreSchemaVersion = 1;

DateTime? _ts(Object? v) => v is Timestamp ? v.toDate() : null;
Timestamp? _toTs(DateTime? d) => d == null ? null : Timestamp.fromDate(d);

/// `updatedAt` (or `createdAt`) of a Firestore document, if it has one.
/// Pending server timestamps read from the cache are `null`.
DateTime? firestoreUpdatedAt(Map<String, dynamic> m) => _ts(m['updatedAt']) ?? _ts(m['createdAt']);
DateTime? firestoreCreatedAt(Map<String, dynamic> m) => _ts(m['createdAt']);

Map<String, Object?> reminderToFirestore(Reminder r) => {
      'title': r.title,
      'remindAt': _toTs(r.remindAt),
      'repeat': r.repeat.name,
      'status': r.done ? 'done' : 'pending',
      'notificationId': r.notificationId,
      'source': r.source.name,
      'schemaVersion': kFirestoreSchemaVersion,
    };

Reminder reminderFromFirestore(String id, Map<String, dynamic> m) => Reminder(
      id: id,
      title: m['title'] as String? ?? '',
      remindAt: _ts(m['remindAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      repeat: enumByName(ReminderRepeat.values, m['repeat'], ReminderRepeat.none),
      done: m['status'] == 'done',
      source: enumByName(RecordSource.values, m['source'], RecordSource.manual),
    );

Map<String, Object?> taskToFirestore(TaskItem t) => {
      'title': t.title,
      'dueAt': _toTs(t.dueAt),
      'remindAt': _toTs(t.remindAt),
      'notificationId': t.notificationId,
      'priority': t.highPriority ? 'high' : 'normal',
      'status': t.done ? 'done' : 'open',
      'completedAt': _toTs(t.completedAt),
      'source': t.source.name,
      'schemaVersion': kFirestoreSchemaVersion,
    };

TaskItem taskFromFirestore(String id, Map<String, dynamic> m) => TaskItem(
      id: id,
      title: m['title'] as String? ?? '',
      dueAt: _ts(m['dueAt']),
      remindAt: _ts(m['remindAt']),
      highPriority: m['priority'] == 'high',
      done: m['status'] == 'done',
      completedAt: _ts(m['completedAt']),
      source: enumByName(RecordSource.values, m['source'], RecordSource.manual),
    );

Map<String, Object?> expenseToFirestore(Expense e) => {
      'amountPoisha': e.amountPoisha,
      'currency': 'BDT',
      'category': e.category.wire,
      'note': e.note,
      'spentAt': _toTs(e.spentAt),
      'source': e.source.name,
      'schemaVersion': kFirestoreSchemaVersion,
    };

Expense expenseFromFirestore(String id, Map<String, dynamic> m) => Expense(
      id: id,
      amountPoisha: (m['amountPoisha'] as num?)?.toInt() ?? 0,
      spentAt: _ts(m['spentAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      category: ExpenseCategory.fromWire(m['category'] as String?),
      note: m['note'] as String? ?? '',
      source: enumByName(RecordSource.values, m['source'], RecordSource.manual),
    );

Map<String, Object?> ledgerToFirestore(LedgerEntry e) => {
      'direction': e.direction.name,
      'person': e.person,
      'amountPoisha': e.amountPoisha,
      'currency': 'BDT',
      'dueAt': _toTs(e.dueAt),
      'status': e.settled ? 'settled' : 'open',
      'settledAt': _toTs(e.settledAt),
      'note': e.note,
      'source': e.source.name,
      'schemaVersion': kFirestoreSchemaVersion,
    };

LedgerEntry ledgerFromFirestore(String id, Map<String, dynamic> m) => LedgerEntry(
      id: id,
      direction: enumByName(LedgerDirection.values, m['direction'], LedgerDirection.receivable),
      person: m['person'] as String? ?? '',
      amountPoisha: (m['amountPoisha'] as num?)?.toInt() ?? 0,
      dueAt: _ts(m['dueAt']),
      settled: m['status'] == 'settled',
      settledAt: _ts(m['settledAt']),
      note: m['note'] as String? ?? '',
      source: enumByName(RecordSource.values, m['source'], RecordSource.manual),
      createdAt: _ts(m['createdAt']),
    );
