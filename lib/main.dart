import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stumili/core/secure_storage.dart';

import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/main/player/player_controller.dart';
import 'firebase_options.dart';

// NEW
import 'package:stumili/services/push_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init push notifications (Android)
  await PushNotificationService.instance.init(
    onToken: (token)async {
       await SecureStore.saveFcmToken(token); // 
      debugPrint("FCM TOKEN: $token");
    },
    onNotificationTap: (data) {
  
      // Example: if data has route
      final route = data['route']?.toString();
      if (route != null && route.isNotEmpty) {
        navigatorKey.currentState?.pushNamed(route, arguments: data);
      } else {
        // fallback: open splash/home
        // navigatorKey.currentState?.pushNamed(AppRoutes.splash);
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // IMPORTANT for tap navigation
      debugShowCheckedModeBanner: false,
      title: "Auth App",
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
