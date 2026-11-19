import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/dhaka_time.dart';
import '../records/models.dart';

/// Schedules on-device notifications. They fire without internet because the
/// Android system (AlarmManager) delivers them, not a server.
abstract class ReminderScheduler {
  Future<void> init();
  Future<bool> requestPermissions();
  Future<void> scheduleReminder(Reminder reminder);
  Future<void> scheduleTask(TaskItem task);
  Future<void> scheduleDailySummary({required int hour, required String title, required String body});
  Future<void> cancel(int notificationId);

  /// Re-creates alarms from the database (new phone, reinstall, lost alarms).
  Future<void> resync({required List<Reminder> reminders, required List<TaskItem> tasks});
}

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _exactAllowed = false;

  /// Fixed id so the daily summary is replaced, not duplicated.
  static const int dailySummaryId = 1;

  static const _channel = AndroidNotificationDetails(
    'bolo_reminders',
    'Reminders',
    channelDescription: 'Bolo reminders and deadlines',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const _summaryChannel = AndroidNotificationDetails(
    'bolo_summary',
    'Daily summary',
    channelDescription: 'Your evening summary from Bolo',
    importance: Importance.defaultImportance,
  );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _exactAllowed = await _android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    final granted = await _android?.requestNotificationsPermission() ?? false;
    if (!(await _android?.canScheduleExactNotifications() ?? false)) {
      await _android?.requestExactAlarmsPermission();
    }
    _exactAllowed = await _android?.canScheduleExactNotifications() ?? false;
    return granted;
  }

  /// Exact if Android allows it; otherwise inexact (may be a few minutes late).
  AndroidScheduleMode get _mode => _exactAllowed
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  Future<void> _schedule(int id, String title, String body, DateTime at,
      {DateTimeComponents? repeat, AndroidNotificationDetails channel = _channel}) async {
    final when = tz.TZDateTime.from(at, DhakaTime.location);
    if (repeat == null && !when.isAfter(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id: id,
        scheduledDate: when,
        notificationDetails: NotificationDetails(android: channel),
        androidScheduleMode: _mode,
        title: title,
        body: body,
        matchDateTimeComponents: repeat,
      );
    } catch (e) {
      debugPrint('Scheduling notification failed: $e');
    }
  }

  @override
  Future<void> scheduleReminder(Reminder r) => _schedule(
        r.notificationId,
        'বলো · Reminder',
        r.title,
        r.remindAt,
        repeat: switch (r.repeat) {
          ReminderRepeat.none => null,
          ReminderRepeat.daily => DateTimeComponents.time,
          ReminderRepeat.weekly => DateTimeComponents.dayOfWeekAndTime,
        },
      );

  @override
  Future<void> scheduleTask(TaskItem t) async {
    if (t.remindAt == null) return;
    await _schedule(t.notificationId, 'বলো · Deadline', t.title, t.remindAt!);
  }

  @override
  Future<void> scheduleDailySummary({required int hour, required String title, required String body}) async {
    await cancel(dailySummaryId);
    if (hour < 0) return;
    final now = DhakaTime.toDhaka(DateTime.now());
    var at = DhakaTime.at(now.year, now.month, now.day, hour);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _schedule(dailySummaryId, title, body, at,
        repeat: DateTimeComponents.time, channel: _summaryChannel);
  }

  @override
  Future<void> cancel(int notificationId) async {
    try {
      await _plugin.cancel(id: notificationId);
    } catch (e) {
      debugPrint('Cancel notification failed: $e');
    }
  }

  @override
  Future<void> resync({required List<Reminder> reminders, required List<TaskItem> tasks}) async {
    for (final r in reminders) {
      if (!r.done) await scheduleReminder(r);
    }
    for (final t in tasks) {
      if (!t.done) await scheduleTask(t);
    }
  }
}

/// Used in tests and on platforms without notifications.
class NoopReminderScheduler implements ReminderScheduler {
  final scheduled = <int>[];
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> scheduleReminder(Reminder r) async => scheduled.add(r.notificationId);
  @override
  Future<void> scheduleTask(TaskItem t) async => scheduled.add(t.notificationId);
  @override
  Future<void> scheduleDailySummary({required int hour, required String title, required String body}) async {}
  @override
  Future<void> cancel(int notificationId) async => scheduled.remove(notificationId);
  @override
  Future<void> resync({required List<Reminder> reminders, required List<TaskItem> tasks}) async {}
}
