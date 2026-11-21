import '../../core/dhaka_time.dart';
import '../records/models.dart';
import '../records/records_repository.dart';
import '../reminders/reminder_scheduler.dart';
import 'parsed_command.dart';

/// Thrown when code tries to save a financial record without the user's
/// explicit confirmation. This is a programming error, never a user error:
/// it exists so that a future bug cannot silently skip the Confirm step.
class FinancialConfirmationRequired implements Exception {
  @override
  String toString() => 'Financial records require explicit user confirmation.';
}

class DraftInvalid implements Exception {
  DraftInvalid(this.problems);
  final List<DraftProblem> problems;
  @override
  String toString() => 'Draft invalid: $problems';
}

/// Result of a save: lets the UI offer "Undo" for non-financial records.
class SaveResult {
  const SaveResult(this.collection, this.id);
  final String collection;
  final String id;
}

/// The ONLY place that turns a confirmed proposal into stored records.
class CommandSaver {
  CommandSaver({required this.repo, required this.scheduler, required this.now});

  final RecordsRepository repo;
  final ReminderScheduler scheduler;
  final DateTime Function() now;

  Future<SaveResult> save(
    ParsedCommand draft, {
    required bool userConfirmed,
    String? settleEntryId,
  }) async {
    if (draft.intent.isFinancial && !userConfirmed) {
      throw FinancialConfirmationRequired();
    }
    final problems = validateDraft(draft, now());
    if (problems.isNotEmpty) throw DraftInvalid(problems);

    switch (draft.intent) {
      case CommandIntent.createReminder:
        final id = repo.newId(Collections.reminders);
        final reminder = Reminder(
          id: id,
          title: draft.title.trim(),
          remindAt: draft.instant!,
          repeat: draft.repeat,
          source: draft.source,
        );
        await repo.saveReminder(reminder);
        await scheduler.scheduleReminder(reminder);
        return SaveResult(Collections.reminders, id);

      case CommandIntent.createTask:
        final id = repo.newId(Collections.tasks);
        // A task's deadline defaults to the end of the working day (18:00).
        final dueAt = DhakaTime.combine(draft.date, draft.time, defaultHour: 18);
        final offset = draft.reminderOffsetMinutes;
        DateTime? remindAt;
        if (dueAt != null && offset != null && offset > 0) {
          final candidate = dueAt.subtract(Duration(minutes: offset));
          if (candidate.isAfter(now())) remindAt = candidate;
        }
        final task = TaskItem(
          id: id,
          title: draft.title.trim(),
          dueAt: dueAt,
          remindAt: remindAt,
          source: draft.source,
        );
        await repo.saveTask(task);
        if (remindAt != null) await scheduler.scheduleTask(task);
        return SaveResult(Collections.tasks, id);

      case CommandIntent.addExpense:
        final id = repo.newId(Collections.expenses);
        // "today" expenses without a time are stamped with the current time.
        final spentAt = draft.date == null || draft.date == DhakaTime.isoDate(now())
            ? now()
            : DhakaTime.combine(draft.date, draft.time, defaultHour: 12)!;
        await repo.saveExpense(Expense(
          id: id,
          amountPoisha: draft.amountPoisha!,
          spentAt: spentAt,
          category: draft.category,
          note: draft.title.trim(),
          source: draft.source,
        ));
        return SaveResult(Collections.expenses, id);

      case CommandIntent.addReceivable || CommandIntent.addPayable:
        final id = repo.newId(Collections.ledger);
        await repo.saveLedgerEntry(LedgerEntry(
          id: id,
          direction: draft.intent == CommandIntent.addReceivable
              ? LedgerDirection.receivable
              : LedgerDirection.payable,
          person: draft.person.trim(),
          amountPoisha: draft.amountPoisha!,
          dueAt: DhakaTime.combine(draft.date, draft.time, defaultHour: 10),
          note: draft.title.trim(),
          source: draft.source,
        ));
        return SaveResult(Collections.ledger, id);

      case CommandIntent.settleLedger:
        // Never guess which entry to settle: the user must have picked one.
        if (settleEntryId == null) throw DraftInvalid([DraftProblem.missingPerson]);
        await repo.settleLedgerEntry(settleEntryId);
        return SaveResult(Collections.ledger, settleEntryId);

      case CommandIntent.querySummary || CommandIntent.unknown || CommandIntent.callContact || CommandIntent.playMedia || CommandIntent.openApp:
        throw DraftInvalid([DraftProblem.notSavable]);
    }
  }

  /// Undo for non-financial creations (reminder/task) shown in a snackbar.
  Future<void> undo(SaveResult result) async {
    if (result.collection == Collections.reminders || result.collection == Collections.tasks) {
      await scheduler.cancel(notificationIdFor(result.id));
      await repo.delete(result.collection, result.id);
    }
  }
}
