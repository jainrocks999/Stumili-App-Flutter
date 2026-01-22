import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/widgets/custom_button.dart';

class InterestItem {
  final String title;
  final String image;

  InterestItem({required this.title, required this.image});
}

class InterestedScreen extends StatefulWidget {
  const InterestedScreen({super.key});

  @override
  State<InterestedScreen> createState() => _InterestedScreenState();
}

class _InterestedScreenState extends State<InterestedScreen> {
  final Set<String> selectedItems = {};

  final List<InterestItem> interests = [
    InterestItem(
      title: 'Get Over Your Fear',
      image: 'assets/interested/icon1.png',
    ),
    InterestItem(
      title: 'Get Higher Self Love',
      image: 'assets/interested/icon2.png',
    ),
    InterestItem(
      title: 'Get Over an Addiction',
      image: 'assets/interested/icon3.png',
    ),
    InterestItem(
      title: 'Get More Health',
      image: 'assets/interested/icon4.png',
    ),
    InterestItem(
      title: 'Get More Motivation',
      image: 'assets/interested/icon5.png',
    ),
    InterestItem(
      title: 'Get More Confidence',
      image: 'assets/interested/icon6.png',
    ),
    InterestItem(
      title: 'Get More Happiness',
      image: 'assets/interested/icon7.png',
    ),
    InterestItem(
      title: 'Get More Abundance',
      image: 'assets/interested/icon8.png',
    ),
  ];

  void toggleSelection(String title) {
    setState(() {
      if (selectedItems.contains(title)) {
        selectedItems.remove(title);
      } else {
        selectedItems.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Welcome to Stimuli',
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

              /// INTRO TEXT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'What are your Interests?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.medium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You are capable, resilient, and worthy of all the good things life offers. '
                      'Your unique qualities shine brightly, guiding you toward success and fulfillment.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: w * 0.035,
                        fontFamily: AppFonts.medium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              /// GRID
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: interests.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: w * 0.04,
                    mainAxisSpacing: h * 0.02,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = interests[index];
                    final isSelected = selectedItems.contains(item.title);

                    return GestureDetector(
                      onTap: () => toggleSelection(item.title),
                      child: Column(
                        children: [
                          Container(
                            height: w * 0.22,
                            width: w * 0.22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(w * 0.02),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD485D1)
                                    : Colors.white,
                                width: 3,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                item.image,
                                width: w * 0.10,
                                height: w * 0.10,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.03,
                              fontFamily: AppFonts.medium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              /// NEXT BUTTON
              CustomButton(
                width: w * 0.6,
                height: 50,
                title: 'Next',
                onPress: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.mainTabs,
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
