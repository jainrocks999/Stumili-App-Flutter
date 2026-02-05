import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'local_reminder_service.dart';

class ReminderScheduler {
  static FlutterLocalNotificationsPlugin get _plugin =>
      LocalReminderService.plugin;

  /// MAIN ENTRY
  static Future<void> scheduleReminder({
    required int reminderId,
    required String title,
    required String body,
    required List<String> days,
    required String startTime, // HH:mm
    required String endTime, // HH:mm
    required int frequency, // how many notifications between start–end
  }) async {
    if (frequency <= 0) return;

    final now = DateTime.now();
    final times = _generateTimes(startTime, endTime, frequency);

    final Map<String, int> dayMap = {
      'mon': DateTime.monday,
      'tue': DateTime.tuesday,
      'wed': DateTime.wednesday,
      'thu': DateTime.thursday,
      'fri': DateTime.friday,
      'sat': DateTime.saturday,
      'sun': DateTime.sunday,
    };

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Affirmation reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    );

 

    

    int idOffset = 0;

    for (final day in days) {
      final weekday = dayMap[day.toLowerCase()];
      if (weekday == null) continue;

      for (final t in times) {
        DateTime scheduled = DateTime(
          now.year,
          now.month,
          now.day,
          t.hour,
          t.minute,
        );

        while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
  await _plugin.zonedSchedule(
          id: reminderId+idOffset,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(scheduled, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

      

        idOffset++;
      }
    }
   checkScheduledReminders();
  }

  /// CANCEL ALL NOTIFICATIONS OF THIS REMINDER
  static Future<void> cancelReminder({
    required int reminderId,
    required int daysCount,
    required int frequency,
  }) async {
    final total = daysCount * frequency;
    for (int i = 0; i < total; i++) {
      await _plugin.cancel(id: reminderId + i);
    }
    checkScheduledReminders();
  }

  /// =========================
  /// HELPERS
  /// =========================

  static List<TimeOfDay> _generateTimes(
    String start,
    String end,
    int frequency,
  ) {
    final s = start.split(':').map(int.parse).toList();
    final e = end.split(':').map(int.parse).toList();

    final startMin = s[0] * 60 + s[1];
    final endMin = e[0] * 60 + e[1];

    if (endMin <= startMin) return [];

    final total = endMin - startMin;
    final gap = total ~/ frequency;

    return List.generate(frequency, (i) {
      final mins = startMin + (gap * i);
      return TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    });
  }

  static Future<void> checkScheduledReminders() async {
  final pending =
      await ReminderScheduler._plugin.pendingNotificationRequests();

  debugPrint('Total scheduled notifications: ${pending.length}');

  for (final n in pending) {
    debugPrint(
      'ID: ${n.id}, Title: ${n.title}, Body: ${n.body}',
    );
  }
}
}
