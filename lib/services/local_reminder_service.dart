import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:stumili/core/secure_storage.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/main.dart'; // navigatorKey
import 'package:stumili/navigation/routes/app_routes.dart';

class LocalReminderService {
  LocalReminderService._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  // ✅ if you want: prevent double navigation on rapid taps
  static bool _handlingTap = false;

  static Future<void> init() async {
    // Timezone
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Init settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);

    // ✅ Initialize with tap handlers
    await plugin.initialize(
      settings:  initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapBackground,
    );

    // ✅ Handle cold start (app killed)
    final details = await plugin.getNotificationAppLaunchDetails();
    final launchedFromNoti = details?.didNotificationLaunchApp ?? false;
    final payload = details?.notificationResponse?.payload;

    if (launchedFromNoti && payload != null && payload.isNotEmpty) {
      // wait till navigator ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePayload(payload);
      });
    }

    // Permissions (Android only)
    if (!Platform.isAndroid) return;

    final androidImpl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  // =========================
  // TAP HANDLERS
  // =========================

  static void _onNotificationTap(NotificationResponse res) {
    final payload = res.payload;
    if (payload == null || payload.isEmpty) return;
    _handlePayload(payload);
  }

  /// ✅ Background tap handler: DON'T navigate here.
  /// Just keep it empty OR log. Foreground handler will run when app opens.
  @pragma('vm:entry-point')
  static void _onNotificationTapBackground(NotificationResponse res) {
    // Don't navigate / call API here.
    // App will open and _onNotificationTap will be triggered.
  }

  // =========================
  // MAIN PAYLOAD HANDLER
  // =========================

  static Future<void> _handlePayload(String payload) async {
    if (_handlingTap) return;
    _handlingTap = true;

    try {
      // payload: "category_id=5&reminder_id=123"
      final map = Uri.splitQueryString(payload);
      final categoryIdStr = map['category_id'];

      final categoryId = int.tryParse(categoryIdStr ?? '');
      debugPrint("🔔 Noti tap categoryId=$categoryId");

      if (categoryId == null) return;

      // ✅ Fetch affirmations
      final affirmations = await _fetchAffirmationsByCategory(categoryId);

      if (affirmations == null || affirmations.isEmpty) {
        debugPrint("No affirmations found for category=$categoryId");
        return;
      }

      // ✅ Navigate using navigatorKey (NO context needed)
      navigatorKey.currentState?.pushNamed(
        AppRoutes.player,
        arguments: {"affirmations": affirmations},
      );
    } catch (e) {
      debugPrint("Noti tap error: $e");
    } finally {
      _handlingTap = false;
    }
  }

  // =========================
  // API CALL
  // =========================

  static Future<List<dynamic>?> _fetchAffirmationsByCategory(int categoryId) async {
    try {
      final userId = await SecureStore.getUserId();
      final token = await SecureStore.getToken();

      final response = await ApiService.getRequest(
        "/categoryByAffermation",
        queryParameters: {
          "user_id": userId,
          "token": token,
          "category_id": categoryId,
        },
      );

      final data = response.data?['data'];
      if (data == null) return null;

      // If backend returns list
      if (data is List) return data;

      // If backend returns object with list inside
      // example: {"data": {"affirmations": [...]}}
      if (data is Map && data['affirmations'] is List) {
        return List<dynamic>.from(data['affirmations']);
      }

      return null;
    } catch (e) {
      debugPrint("fetchAffirmations error: $e");
      return null;
    }
  }
}
