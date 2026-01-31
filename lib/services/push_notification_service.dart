import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Important notifications',
    importance: Importance.high,
  );

  Future<void> init({
    required void Function(Map<String, dynamic> data) onNotificationTap,
    required void Function(String token) onToken,
  }) async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications(onNotificationTap);

    // Android 13+ permission
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) onToken(token);

    _messaging.onTokenRefresh.listen((newToken) {
      if (newToken.isNotEmpty) onToken(newToken);
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap(message.data);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onNotificationTap(initialMessage.data);
    }
  }

  Future<void> _initLocalNotifications(
    void Function(Map<String, dynamic> data) onNotificationTap,
  ) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    // ✅ NEW API: settings named parameter required
    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload == null || payload.isEmpty) return;

        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          onNotificationTap(data);
        } catch (_) {}
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notif = message.notification;
    final title = notif?.title ?? (message.data['title']?.toString() ?? '');
    final body = notif?.body ?? (message.data['body']?.toString() ?? '');

    if (title.isEmpty && body.isEmpty) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _local.show(
  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  title: title,
  body: body,
  notificationDetails: details,
  payload: jsonEncode(message.data),
);
  }
}
