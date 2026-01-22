import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double hp(double percent) => size.height * percent / 100;
    double wp(double percent) => size.width * percent / 100;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF191919),
          child: Stack(
            children: [
              Positioned(
                right: wp(-26),
                top: hp(-15),
                child: Container(
                  height: hp(40),
                  width: hp(40),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(180, 180, 180, 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    height: hp(33),
                    width: hp(33),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(180, 180, 180, 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: hp(33),
                left: wp(-45),
                child: Container(
                  height: hp(33),
                  width: hp(33),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(180, 180, 180, 0.1),
                    shape: BoxShape.circle,
                  ),
                   alignment: Alignment.center,
                ),
              ),
              Positioned.fill(child: SafeArea(child: child),)
            ],
          ),
        ),
      ),
    );
  }
}
