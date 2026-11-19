import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models.dart';

/// What the UI can do with a user's records. Screens depend on this
/// interface only, so tests can use a fake and we could later swap Firestore
/// for another local database without touching the UI (docs/04 § 4.3).
abstract class RecordsRepository {
  Stream<List<Reminder>> watchPendingReminders();
  Stream<List<TaskItem>> watchOpenTasks();
  Stream<List<Expense>> watchExpensesSince(DateTime since);
  Stream<List<LedgerEntry>> watchOpenLedger();

  /// A new unique id. Generated locally, so it works offline.
  String newId(String collection);

  Future<void> saveReminder(Reminder reminder, {bool isNew = true});
  Future<void> saveTask(TaskItem task, {bool isNew = true});
  Future<void> saveExpense(Expense expense, {bool isNew = true});
  Future<void> saveLedgerEntry(LedgerEntry entry, {bool isNew = true});

  Future<void> setReminderDone(String id, bool done);
  Future<void> setTaskDone(String id, bool done);
  Future<void> settleLedgerEntry(String id);
  Future<void> delete(String collection, String id);
}

class Collections {
  static const reminders = 'reminders';
  static const tasks = 'tasks';
  static const expenses = 'expenses';
  static const ledger = 'ledger';
}

/// Firestore implementation. Firestore keeps an on-device cache, so every
/// read works offline and every write is queued until the network is back.
///
/// **Important offline detail:** the Future returned by `set()`/`update()`
/// only completes when the *server* confirms the write. Offline that can take
/// hours, so we do not wait for it. The write is already applied to the
/// local cache (and the UI streams) the moment we call it.
class FirestoreRecordsRepository implements RecordsRepository {
  FirestoreRecordsRepository(this._db, this._uid);

  final FirebaseFirestore _db;
  final String _uid;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(_uid).collection(name);

  void _fireAndForget(Future<void> write) {
    unawaited(write.catchError((Object e) {
      // A rejected write (e.g. security rule) is rolled back by Firestore.
      debugPrint('Firestore write failed: $e');
    }));
  }

  Map<String, Object?> _stamp(Map<String, Object?> data, bool isNew) => {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      };

  void _write(String collection, String id, Map<String, Object?> data, bool isNew) {
    final ref = _col(collection).doc(id);
    _fireAndForget(isNew ? ref.set(_stamp(data, true)) : ref.update(_stamp(data, false)));
  }

  @override
  String newId(String collection) => _col(collection).doc().id;

  // Queries use only equality filters and sort on the device. This avoids the
  // need for composite indexes and keeps each query small (open items only).

  @override
  Stream<List<Reminder>> watchPendingReminders() => _col(Collections.reminders)
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) => s.docs.map((d) => Reminder.fromMap(d.id, d.data())).toList()
        ..sort((a, b) => a.remindAt.compareTo(b.remindAt)));

  @override
  Stream<List<TaskItem>> watchOpenTasks() => _col(Collections.tasks)
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((s) => s.docs.map((d) => TaskItem.fromMap(d.id, d.data())).toList()
        ..sort((a, b) {
          final ad = a.dueAt, bd = b.dueAt;
          if (ad == null && bd == null) return a.title.compareTo(b.title);
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        }));

  @override
  Stream<List<Expense>> watchExpensesSince(DateTime since) => _col(Collections.expenses)
      .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
      .orderBy('spentAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Expense.fromMap(d.id, d.data())).toList());

  @override
  Stream<List<LedgerEntry>> watchOpenLedger() => _col(Collections.ledger)
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((s) => s.docs.map((d) => LedgerEntry.fromMap(d.id, d.data())).toList()
        ..sort((a, b) => a.person.toLowerCase().compareTo(b.person.toLowerCase())));

  @override
  Future<void> saveReminder(Reminder r, {bool isNew = true}) async =>
      _write(Collections.reminders, r.id, r.toMap(), isNew);

  @override
  Future<void> saveTask(TaskItem t, {bool isNew = true}) async =>
      _write(Collections.tasks, t.id, t.toMap(), isNew);

  @override
  Future<void> saveExpense(Expense e, {bool isNew = true}) async =>
      _write(Collections.expenses, e.id, e.toMap(), isNew);

  @override
  Future<void> saveLedgerEntry(LedgerEntry e, {bool isNew = true}) async =>
      _write(Collections.ledger, e.id, e.toMap(), isNew);

  @override
  Future<void> setReminderDone(String id, bool done) async =>
      _write(Collections.reminders, id, {'status': done ? 'done' : 'pending'}, false);

  @override
  Future<void> setTaskDone(String id, bool done) async => _write(
        Collections.tasks,
        id,
        {
          'status': done ? 'done' : 'open',
          'completedAt': done ? FieldValue.serverTimestamp() : null,
        },
        false,
      );

  @override
  Future<void> settleLedgerEntry(String id) async => _write(
        Collections.ledger,
        id,
        {'status': 'settled', 'settledAt': FieldValue.serverTimestamp()},
        false,
      );

  @override
  Future<void> delete(String collection, String id) async =>
      _fireAndForget(_col(collection).doc(id).delete());
}
