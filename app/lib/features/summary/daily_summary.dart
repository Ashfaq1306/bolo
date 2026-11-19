import '../../core/dhaka_time.dart';
import '../records/models.dart';

/// Today's overview, computed on the phone from the user's own records.
/// No AI call, no cost, works offline (docs/03 § F9).
class DailySummary {
  const DailySummary({
    required this.remindersToday,
    required this.tasksDueOrOverdue,
    required this.openTasks,
    required this.spentTodayPoisha,
    required this.spentMonthPoisha,
    required this.toReceivePoisha,
    required this.toPayPoisha,
    required this.overdueLedger,
  });

  final List<Reminder> remindersToday;
  final List<TaskItem> tasksDueOrOverdue;
  final int openTasks;
  final int spentTodayPoisha;
  final int spentMonthPoisha;
  final int toReceivePoisha;
  final int toPayPoisha;
  final List<LedgerEntry> overdueLedger;

  bool get isEmpty =>
      remindersToday.isEmpty && openTasks == 0 && spentTodayPoisha == 0 &&
      toReceivePoisha == 0 && toPayPoisha == 0;

  static DailySummary compute({
    required DateTime now,
    required List<Reminder> reminders,
    required List<TaskItem> tasks,
    required List<Expense> monthExpenses,
    required List<LedgerEntry> openLedger,
  }) {
    final start = DhakaTime.startOfDay(now);
    final end = DhakaTime.endOfDay(now);
    final monthStart = DhakaTime.startOfMonth(now);
    bool isToday(DateTime t) => !t.isBefore(start) && t.isBefore(end);

    final open = tasks.where((t) => !t.done).toList();
    return DailySummary(
      remindersToday: reminders.where((r) => !r.done && isToday(r.remindAt)).toList(),
      tasksDueOrOverdue: open.where((t) => t.dueAt != null && t.dueAt!.isBefore(end)).toList(),
      openTasks: open.length,
      spentTodayPoisha: monthExpenses
          .where((e) => isToday(e.spentAt))
          .fold(0, (sum, e) => sum + e.amountPoisha),
      spentMonthPoisha: monthExpenses
          .where((e) => !e.spentAt.isBefore(monthStart))
          .fold(0, (sum, e) => sum + e.amountPoisha),
      toReceivePoisha: openLedger
          .where((e) => !e.settled && e.direction == LedgerDirection.receivable)
          .fold(0, (sum, e) => sum + e.amountPoisha),
      toPayPoisha: openLedger
          .where((e) => !e.settled && e.direction == LedgerDirection.payable)
          .fold(0, (sum, e) => sum + e.amountPoisha),
      overdueLedger: openLedger
          .where((e) => !e.settled && e.dueAt != null && e.dueAt!.isBefore(start))
          .toList(),
    );
  }
}
