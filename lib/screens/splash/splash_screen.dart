import 'package:flutter/material.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/widgets/auth/auth_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;

        checkLogin();
      // Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

void checkLogin() async {
  await Future.delayed(const Duration(seconds: 2));

  String? token = await SecureStore.getToken();

  // ✅ Guard with mounted
  if (!mounted) return;

  if (token != null) {
    Navigator.pushReplacementNamed(context, AppRoutes.mainTabs);
  } else {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Center(
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
