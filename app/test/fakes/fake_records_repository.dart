import 'dart:async';

import 'package:bolo_app/features/records/models.dart';
import 'package:bolo_app/features/records/records_repository.dart';

/// In-memory repository for tests. No Firebase needed.
class FakeRecordsRepository implements RecordsRepository {
  final reminders = <String, Reminder>{};
  final tasks = <String, TaskItem>{};
  final expenses = <String, Expense>{};
  final ledger = <String, LedgerEntry>{};
  final deleted = <String>[];
  var _next = 0;

  @override
  String newId(String collection) => '$collection-${_next++}';

  @override
  Future<void> saveReminder(Reminder r, {bool isNew = true}) async => reminders[r.id] = r;
  @override
  Future<void> saveTask(TaskItem t, {bool isNew = true}) async => tasks[t.id] = t;
  @override
  Future<void> saveExpense(Expense e, {bool isNew = true}) async => expenses[e.id] = e;
  @override
  Future<void> saveLedgerEntry(LedgerEntry e, {bool isNew = true}) async => ledger[e.id] = e;

  @override
  Future<void> setReminderDone(String id, bool done) async {}
  @override
  Future<void> setTaskDone(String id, bool done) async {}

  @override
  Future<void> settleLedgerEntry(String id) async {
    final e = ledger[id]!;
    ledger[id] = LedgerEntry(
      id: e.id,
      direction: e.direction,
      person: e.person,
      amountPoisha: e.amountPoisha,
      settled: true,
    );
  }

  @override
  Future<void> delete(String collection, String id) async {
    deleted.add(id);
    reminders.remove(id);
    tasks.remove(id);
  }

  @override
  Stream<List<Reminder>> watchPendingReminders() => Stream.value(reminders.values.toList());
  @override
  Stream<List<TaskItem>> watchOpenTasks() => Stream.value(tasks.values.toList());
  @override
  Stream<List<Expense>> watchExpensesSince(DateTime since) => Stream.value(expenses.values.toList());
  @override
  Stream<List<LedgerEntry>> watchOpenLedger() =>
      Stream.value(ledger.values.where((e) => !e.settled).toList());
}
