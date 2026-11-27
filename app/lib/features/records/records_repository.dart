import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'firestore_codec.dart';
import 'models.dart';

/// What the UI can do with a user's records. Screens depend on this
/// interface only. Guests use [DriftRecordsRepository] (local-only, ADR-11);
/// accounts registered before Phase 2 still use [FirestoreRecordsRepository]
/// until registered sync ships (ADR-10).
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

/// Legacy Firestore implementation, used only for registered (email) accounts
/// until Phase 2 sync replaces it. Guests never write here. Firestore keeps an on-device cache, so every
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
      .map((s) => s.docs.map((d) => reminderFromFirestore(d.id, d.data())).toList()
        ..sort((a, b) => a.remindAt.compareTo(b.remindAt)));

  @override
  Stream<List<TaskItem>> watchOpenTasks() => _col(Collections.tasks)
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((s) => s.docs.map((d) => taskFromFirestore(d.id, d.data())).toList()
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
      .map((s) => s.docs.map((d) => expenseFromFirestore(d.id, d.data())).toList());

  @override
  Stream<List<LedgerEntry>> watchOpenLedger() => _col(Collections.ledger)
      .where('status', isEqualTo: 'open')
      .snapshots()
      .map((s) => s.docs.map((d) => ledgerFromFirestore(d.id, d.data())).toList()
        ..sort((a, b) => a.person.toLowerCase().compareTo(b.person.toLowerCase())));

  @override
  Future<void> saveReminder(Reminder r, {bool isNew = true}) async =>
      _write(Collections.reminders, r.id, reminderToFirestore(r), isNew);

  @override
  Future<void> saveTask(TaskItem t, {bool isNew = true}) async =>
      _write(Collections.tasks, t.id, taskToFirestore(t), isNew);

  @override
  Future<void> saveExpense(Expense e, {bool isNew = true}) async =>
      _write(Collections.expenses, e.id, expenseToFirestore(e), isNew);

  @override
  Future<void> saveLedgerEntry(LedgerEntry e, {bool isNew = true}) async =>
      _write(Collections.ledger, e.id, ledgerToFirestore(e), isNew);

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
