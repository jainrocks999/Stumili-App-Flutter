import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/main/player/player_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      debugShowCheckedModeBanner: false,
      title: "Auth App",
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}