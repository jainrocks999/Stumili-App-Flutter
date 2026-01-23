import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/screens/main/player/tabs/music_tab.dart';
import 'package:weather_app/screens/main/player/tabs/time_tab.dart';
import 'package:weather_app/screens/main/player/tabs/voice_tab.dart';
import 'player_controller.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final affirmations = args['affirmations'] as List;

    return ChangeNotifierProvider(
      create: (_) => PlayerController(affirmations),
      child: const _PlayerView(),
    );
  }
}

void _openSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return const _SettingsSheet();
    },
  );
}

class _PlayerView extends StatelessWidget {
  const _PlayerView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayerController>();
    final state = controller.state;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset('assets/images/music.jpg', fit: BoxFit.cover),
          ),

          /// Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.93 * 255).round()),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                /// Header Card
                Container(
                  height: size.height * 0.07,
                  width: size.width * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Affirmations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage('assets/images/music.jpg'),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                SizedBox(
                  height: size.height * 0.45,
                  child: PageView.builder(
                    controller: controller.pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: controller.affirmations.length,
                    onPageChanged: controller.onPageChanged,
                    itemBuilder: (_, index) {
                      final item = controller.affirmations[index];
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            item['affirmation_text'],
                            maxLines: 5,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                /// Action Icons (Heart / Repeat / Menu)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      controller.affirmations[state.index]['is_favorite'] ==
                              true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          controller.affirmations[state.index]['is_favorite'] ==
                              true
                          ? Colors.pink
                          : Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: controller.repeat,
                      child: const Icon(
                        Icons.repeat,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 40),
                    const Icon(Icons.more_horiz, color: Colors.white, size: 30),
                  ],
                ),

                const SizedBox(height: 30),

                /// Play / Pause + Progress
                GestureDetector(
                  onTap: controller.playPause,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: CircularProgressIndicator(
                          value: state.progress,
                          strokeWidth: 5,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFB72658),
                          ),
                        ),
                      ),
                      Icon(
                        state.isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// Bottom Tabs
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: const PlayerBottomTabs(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerBottomTabs extends StatelessWidget {
  const PlayerBottomTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayerController>();

    Widget tab(PlayerTab tab, String title, String img) {
      final isActive = controller.selectedTab == tab;

      return GestureDetector(
        onTap: () {
          controller.selectTab(tab);
         
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 45,
          width: isActive ? 130 : 110,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: isActive ? Colors.white : Colors.black),
              ),
              CircleAvatar(radius: 18, backgroundImage: AssetImage(img)),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        tab(PlayerTab.voice, 'Voice', 'assets/profilepic/profile2.jpg'),
        tab(PlayerTab.time, 'Time', 'assets/images/timer.jpg'),
        tab(PlayerTab.music, 'Music', 'assets/images/music1.jpg'),
      ],
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayerController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          const PlayerBottomTabs(),
          const SizedBox(height: 20),

          Expanded(
            child: Builder(
              builder: (_) {
                switch (controller.selectedTab) {
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
