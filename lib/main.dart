import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stumili/ads/ad_manager.dart';

import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/main/player/player_controller.dart';
import 'package:stumili/services/local_reminder_service.dart';
import 'package:stumili/services/onesignal_service.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final requestConfiguration = RequestConfiguration(
    maxAdContentRating: MaxAdContentRating.pg,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await MobileAds.instance.updateRequestConfiguration(requestConfiguration);

  await MobileAds.instance.initialize();
  // ✅ MUST await
  await LocalReminderService.init();

  AdManager.interstitail.loadAd();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PlayerController())],
      child: const MyApp(),
    ),
  );

  // ✅ Push init AFTER UI
  Future.microtask(() async {
    await OneSignalService.init();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Auth App",
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
