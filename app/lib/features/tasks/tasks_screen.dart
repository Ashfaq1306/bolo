import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dhaka_time.dart';
import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/depth_card.dart';
import '../../l10n/app_localizations.dart';
import '../command/confirmation_sheet.dart';
import '../command/parsed_command.dart';
import '../records/models.dart';
import '../records/records_repository.dart';

/// Reminders and tasks. Everything here also works without voice.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final reminders = ref.watch(remindersProvider).value ?? const <Reminder>[];
    final tasks = ref.watch(tasksProvider).value ?? const <TaskItem>[];
    final now = ref.watch(clockProvider)();
    final repo = ref.watch(recordsRepositoryProvider);
    final scheduler = ref.watch(reminderSchedulerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l.tasksTitle), backgroundColor: Colors.transparent),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addTask',
        onPressed: () => _addMenu(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addManually),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 96), children: [
        _Section(title: l.remindersTitle, icon: Icons.alarm_rounded, color: BoloColors.amber),
        if (reminders.isEmpty) _Empty(l.noReminders),
        for (final r in reminders)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DepthCard(
              accent: BoloColors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: r.done,
                  onChanged: (_) async {
                    await scheduler.cancel(r.notificationId);
                    await repo?.setReminderDone(r.id, true);
                  },
                ),
                title: Text(r.title),
                subtitle: Text(
                  '${DhakaTime.formatDate(r.remindAt, lang)} · ${DhakaTime.formatTime(r.remindAt, lang)}'
                  '${r.repeat == ReminderRepeat.none ? '' : ' · ${l.repeat(r.repeat)}'}',
                  style: TextStyle(color: r.remindAt.isBefore(now) ? Theme.of(context).colorScheme.error : null),
                ),
                trailing: IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await scheduler.cancel(r.notificationId);
                    await repo?.delete(Collections.reminders, r.id);
                  },
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        _Section(title: l.tasksTitle, icon: Icons.task_alt_rounded, color: BoloColors.teal),
        if (tasks.isEmpty) _Empty(l.noTasks),
        for (final t in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DepthCard(
              accent: BoloColors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: t.done,
                  onChanged: (_) async {
                    await scheduler.cancel(t.notificationId);
                    await repo?.setTaskDone(t.id, true);
                  },
                ),
                title: Text(t.title),
                subtitle: t.dueAt == null
                    ? null
                    : Text(
                        '${t.dueAt!.isBefore(now) ? l.overdue : l.due}: ${DhakaTime.formatDate(t.dueAt!, lang)}',
                        style: TextStyle(color: t.dueAt!.isBefore(now) ? Theme.of(context).colorScheme.error : null),
                      ),
                trailing: IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await scheduler.cancel(t.notificationId);
                    await repo?.delete(Collections.tasks, t.id);
                  },
                ),
              ),
            ),
          ),
      ]),
    );
  }

  void _addMenu(BuildContext context, WidgetRef ref) {
    final now = ref.read(clockProvider)();
    showConfirmationSheet(
      context,
      ref,
      ParsedCommand(intent: CommandIntent.createTask, date: DhakaTime.isoDate(now)),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.color});
  final String title;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
