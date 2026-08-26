import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stumili/ads/ad_manager.dart';
import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/main/home/home_screen.dart';
import 'package:stumili/screens/main/libraries/library_screen.dart';
import 'package:stumili/screens/main/reminders/reminder.screen.dart';
import 'package:stumili/screens/main/settings/setting_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    SizedBox(),
    ReminderScreen(),
    SettingScreen(),
  ];

  BottomNavigationBarItem _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      label: '',
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? const Color(0xFFD485D1) : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFFD485D1) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // _bottomSheetCard(
              //   image: 'assets/images/music.jpg',
              //   title: 'Record your affirmations',
              //   onTap: () {},
              // ),
              const SizedBox(height: 16),
              _bottomSheetGradientCard(
                image: 'assets/images/music.jpg',
                title: 'Create your playlist',
                onTap: () {
                  AdManager.interstitail.showAd(
                    onAdDismissed: () {
                      if (!context.mounted) return;
                      Navigator.pushNamed(context, AppRoutes.selectaffirmation);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            height: Platform.isIOS ? 120 : 90,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (index) {
                if (index == 2) {
                  _openBottomSheet();
                } else {
                  setState(() => _currentIndex = index);
                }
              },
              items: [
                _navItem(icon: Icons.home, label: 'Home', index: 0),
                _navItem(icon: Icons.favorite, label: 'Library', index: 1),
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(),
                  label: '',
                ),
                _navItem(icon: Icons.access_time, label: 'Reminder', index: 3),
                _navItem(icon: Icons.settings, label: 'Setting', index: 4),
              ],
            ),
          ),

          // PLUS BUTTON
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: _openBottomSheet,
              child: Container(
                height: 56,
                width: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFB72658),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget _bottomSheetCard({
//   required String image,
//   required String title,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF222222),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.asset(
//               image,
//               height: 90,
//               width: 90,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _bottomSheetGradientCard({
  required String image,
  required String title,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFD485D1), Color(0xFFB72658)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(image, height: 90, width: 90, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
