import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/widgets/custom_button.dart';

class AskReminderScreen extends StatelessWidget {
  const AskReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        'Welcome to stimuli',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.05,
                          fontFamily: AppFonts.medium,
                        ),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        width: 50,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// GIF / IMAGE
                Image.asset(
                  'assets/images/animated.gif', // <-- same gif path rakho
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                /// TITLE TEXT
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: Text(
                    'Get reminded to respect along your favorite affirmations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.medium,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// DESCRIPTION
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                  child: Text(
                    'You are capable, resilient, and worthy of all the good things life offers. '
                    'Your unique qualities shine brightly, guiding you towards success and fulfillment.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: w * 0.035,
                    ),
                  ),
                ),
              ],
            ),

            /// BOTTOM BUTTON
            Positioned(
              bottom: h * 0.08,
              left: w * 0.25,
              right: w * 0.25,
              child:CustomButton(height: 50,width: w*0.6,title: "Get Started",onPress: (){
                Navigator.pushNamed(context, AppRoutes.interested);
              },)
            ),
          ],
        ),
      ),
    );
  }
}
