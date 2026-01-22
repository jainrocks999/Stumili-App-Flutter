import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final VoidCallback onPressSearch;

  const Header({super.key, required this.onPressSearch});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double hp(double value) => screenHeight * value / 100;
    double wp(double value) => screenWidth * value / 100;

    return Container(
      height: hp(10),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: wp(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(hp(5.5) / 2),
            child: Image.asset(
              'assets/images/logo.png',
              height: hp(5.5),
              width: hp(5.5),
              fit: BoxFit.cover,
            ),
          ),

          /// Search Box
          GestureDetector(
            onTap: onPressSearch,
            child: Container(
              height: hp(5.5),
              width: screenWidth * 0.8,
              padding: EdgeInsets.only(left: wp(5)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(wp(7)),
                border: Border.all(color: Colors.grey, width: wp(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Colors.black),
                  SizedBox(width: wp(3)),
                  const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      // fontFamily: 'Medium', // add if you use custom fonts
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
