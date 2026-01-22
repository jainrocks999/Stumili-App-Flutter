import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';

class Intro extends StatelessWidget {
  final String title1;
  final String title2;
  final String title3;
  final EdgeInsets? margin;
  final bool isLogin;
  // final bool? isLogin=true;

  const Intro({
    super.key,
    required this.title1,
    required this.title2,
    required this.title3,
     this.isLogin = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    

    double hp(double percent) => size.height * percent / 100;
    double wp(double percent) => size.width * percent / 100;
    return Container(
      height: hp(isLogin? 35:30),
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const SizedBox(height: 8),
          Image.asset('assets/images/logo.png', height: 65, width: 65),
           const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: wp(7),
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.regular,
                ),
              ),
              Transform.translate(
                offset: Offset(0, wp(-1)),
                child: Text(
                  title2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wp(6),
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.regular,
                  ),
                ),
              ),
              SizedBox(height: wp(0)),
              SizedBox(
                width: wp(55),
                child: Text(
                  title3,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wp(4),
                    height: 1.3,
                    fontFamily: AppFonts.regular,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
