import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class LocalReminderService {
  LocalReminderService._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Timezone
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // ✅ 1) Initialize FIRST
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await plugin.initialize(settings:initSettings);

    // ✅ 2) Then permissions (Android only)
    if (!Platform.isAndroid) return;

    final androidImpl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Android 13+ notification permission
    await androidImpl?.requestNotificationsPermission();

    // If you use exactAllowWhileIdle anywhere:
    await androidImpl?.requestExactAlarmsPermission();
  }
}
