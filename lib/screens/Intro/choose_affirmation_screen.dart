import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/widgets/custom_button.dart';

class ChooseAffirmationScreen extends StatefulWidget {
  const ChooseAffirmationScreen({super.key});

  @override
  State<ChooseAffirmationScreen> createState() =>
      _ChooseAffirmationScreenState();
}

class _ChooseAffirmationScreenState extends State<ChooseAffirmationScreen> {
  final List<Map<String, dynamic>> affirmations = [
    {'id': 1, 'text': 'I am worthy of love and respect, just as I am.'},
    {
      'id': 2,
      'text':
          'Every challenge I face is an opportunity for growth and learning.'
    },
    {
      'id': 3,
      'text':
          'I am grateful for the abundance in my life, and more blessings are on their way.'
    },
    {
      'id': 4,
      'text':
          'I trust in my ability to overcome obstacles and achieve my goals.'
    },
    {
      'id': 5,
      'text':
          'I am surrounded by positivity, and I radiate positivity in return.'
    },
    {
      'id': 6,
      'text':
          'I am deserving of success, and I attract success into my life effortlessly.'
    },
    {
      'id': 7,
      'text':
          'I forgive myself for past mistakes and release any lingering negativity.'
    },
  ];

  final List<int> selectedItems = [];

  void toggleSelection(int id) {
    setState(() {
      selectedItems.contains(id)
          ? selectedItems.remove(id)
          : selectedItems.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 45,
                      ),
                    ],
                  ),
                ),

                /// TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'What best describes your positive affirmation practice?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.05,
                      fontFamily: AppFonts.medium,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: affirmations.length,
                    itemBuilder: (context, index) {
                      final item = affirmations[index];
                      final isSelected =
                          selectedItems.contains(item['id']);

                      return GestureDetector(
                        onTap: () => toggleSelection(item['id']),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFD485D1)
                                  : Colors.white,
                              width: isSelected ? 1 : 1,
                            ),
                          ),
                          child: Text(
                            item['text'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.033,
                              fontFamily: AppFonts.medium,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),

            /// BOTTOM BUTTON
            Positioned(
              bottom: 24,
              left: w * 0.2,
              right: w * 0.2,
              child: GestureDetector(
                onTap: () {
                  
                },
                child:CustomButton(height: 50,width: w*0.6,title: "Next",onPress: (){
                  Navigator.pushNamed(context, AppRoutes.askreminder);
                }, )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
