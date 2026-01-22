import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';

class InputField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  const InputField({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
  });
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double hp(double p) => size.height * p / 100;
    double wp(double p) => size.width * p / 100;
    return Container(
      width: double.infinity,
      height: hp(6.5),
      margin: EdgeInsets.only(top: wp(7)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(wp(1)),
      ),
      padding: EdgeInsets.only(right: wp(3), left: wp(3)),
      alignment: Alignment.centerRight,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: wp(5),
          fontFamily: AppFonts.medium,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
