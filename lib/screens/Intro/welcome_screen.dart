import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';
import 'package:weather_app/models/affirmation_model.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (currentIndex < affirmations.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.chooseaffirmation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN CONTENT
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_back, color: Colors.white),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 45,
                      ),
                    ],
                  ),
                ),

                /// TITLE
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Let's Personalize Your experience",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: AppFonts.medium,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// PAGE VIEW
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: affirmations.length,
                    onPageChanged: (i) {
                      setState(() => currentIndex = i);
                    },
                    itemBuilder: (context, index) {
                      final item = affirmations[index];
                      return Stack(
                        children: [
                          /// IMAGE
                          Image.network(
                            item.imageUrl,
                            height: h,
                            width: w,
                            fit: BoxFit.cover,
                          ),

                          /// TOP GRADIENT
                          Container(
                            height: h * 0.45,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black87,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          /// BOTTOM CONTENT
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: h * 0.6,
                              width: w,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black54,
                                    Color(0xFF191919),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                /// DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    affirmations.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == currentIndex ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == currentIndex
                            ? const Color(0xFFB72658)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 90), // space for button
              ],
            ),

            /// BOTTOM BUTTON
            Positioned(
              bottom: 24,
              left: w * 0.2,
              right: w * 0.2,
              child: CustomButton(
                height: 50,
                title: currentIndex == affirmations.length - 1
                    ? "Get Started"
                    : "Next",
                onPress: _onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
