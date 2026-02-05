import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stumili/core/secure_storage.dart';

class OneSignalService {
  OneSignalService._();

  // TODO: apna ONESIGNAL APP ID yaha
  static const String oneSignalAppId = "YOUR_ONESIGNAL_APP_ID";

  static Future<void> init() async {
    // Optional: OneSignal debug
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(oneSignalAppId);

    // iOS permission prompt (Android pe bhi safe)
    await OneSignal.Notifications.requestPermission(true);
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
  event.notification.display(); // ✅ show in foreground
});
OneSignal.Notifications.addClickListener((event) {
  final data = event.notification.additionalData;
  debugPrint("$data");
  // route handle
});

    // --- Tap handler (notification click) ---
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      // yaha data me "route" bhejoge
      final route = data?['route']?.toString();
      if (route != null && route.isNotEmpty) {
        // navigation ke liye: navigatorKey use karo
        // NOTE: main.dart me navigatorKey global hona chahiye
        // navigatorKey.currentState?.pushNamed(route, arguments: data);
      }
    });

    // --- PlayerId / SubscriptionId save ---
    // OneSignal v5 me "playerId" ko ab subscriptionId bolte hain
    OneSignal.User.pushSubscription.addObserver((state) async {
      final subId = state.current.id; // subscriptionId
      if (subId != null && subId.isNotEmpty) {
        await SecureStore.saveOneSignalId(subId);
        debugPrint("OneSignal subscriptionId: $subId");
      }
    });

    // App start pe bhi try to read
    final subId = OneSignal.User.pushSubscription.id;
    if (subId != null && subId.isNotEmpty) {
      await SecureStore.saveOneSignalId(subId);
      debugPrint("OneSignal subscriptionId (initial): $subId");
    }
  }

  /// Login ke baad call karo: user ko OneSignal me identify karne ke liye
  static Future<void> login(String userId) async {
    OneSignal.login(userId);
    // optional: tags
    OneSignal.User.addTags({"user_id": userId});
  }
  

  /// Logout pe call
  static Future<void> logout() async {
    OneSignal.logout();
  }
}


