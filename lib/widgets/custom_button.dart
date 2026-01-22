import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weather_app/core/fonts.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPress;
  final String? title;
  final bool? playlist;
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    this.onPress,
    this.title,
    this.child,
    this.playlist = false,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double hp(double p) => size.height * p / 100;
    double wp(double p) => size.width * p / 100;
    return Container(
      width:width?? hp(88),
      height:height?? hp(6.5), // ~6.5% of screen height
      margin: margin ?? EdgeInsets.only(top: 25), // ~6% top margin
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(wp(1)),
          ),
          elevation: 3,
        ),
        onPressed: () {
          if (onPress != null) {
            onPress!();
          }
          // Optional vibration
          // HapticFeedback.lightImpact();
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFD485D1), Color(0xFFB72658)],
            ),
            borderRadius: BorderRadius.circular(wp(1)),
          ),
          child: Container(
            alignment: Alignment.center,
            child:
                child ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (playlist ?? false)
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: FaIcon(
                          FontAwesomeIcons.play,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    Text(
                      title ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (playlist ?? false) ? 16 : 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.medium
                        // fontFamily: 'YourFont', // set your font
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
