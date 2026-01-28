import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'player_controller.dart';
import 'tabs/voice_tab.dart';
import 'tabs/time_tab.dart';
import 'tabs/music_tab.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),

          SheetTabs(
            current: c.selectedTab,
            onSelect: (tab) async {
              c.selectTab(tab);
              if (tab == PlayerTab.voice) {
                await c.loadVoices();
              }
              if (tab == PlayerTab.music) {
                await c.fetchMusic();
              }
            },
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Builder(
              builder: (_) {
                switch (c.selectedTab) {
                  case PlayerTab.voice:
                    return const VoiceTab();
                  case PlayerTab.time:
                    return const TimeTab();
                  case PlayerTab.music:
                    return const MusicTab();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SheetTabs extends StatelessWidget {
  final PlayerTab current;
  final ValueChanged<PlayerTab> onSelect;

  const SheetTabs({super.key, required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget pill(PlayerTab tab, String title, String asset) {
      final active = current == tab;
      return GestureDetector(
        onTap: () => onSelect(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 44,
          width: active ? 130 : 115,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(color: active ? Colors.white : Colors.black)),
              CircleAvatar(radius: 18, backgroundImage: AssetImage(asset)),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        pill(PlayerTab.voice, 'Voice', 'assets/profilepic/profile2.jpg'),
        pill(PlayerTab.time, 'Time', 'assets/images/timer.jpg'),
        pill(PlayerTab.music, 'Music', 'assets/images/music1.jpg'),
      ],
    );
  }
}
