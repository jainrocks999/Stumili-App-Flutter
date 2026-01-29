import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stumili/screens/main/player/settings_sheet.dart';
import 'package:stumili/widgets/affirmation_menu_modal.dart';

import 'player_controller.dart';
import 'player_state.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};
    final list = (args['affirmations'] as List?) ?? [];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final c = context.read<PlayerController>();
      await c.waitUntilReady();

      if (list.isNotEmpty) {
        await c.startSession(list, autoplay: true);
      } else {
        // if already has a running session or existing list
        await c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();
    final PlayerState s = c.state;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/music.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.93 * 255).round()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
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
                  child: (c.affirmations.isEmpty)
                      ? const Center(
                          child: Text(
                            'No affirmations available',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : PageView.builder(
                          controller: c.pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: c.affirmations.length,
                          onPageChanged: c.onPageChanged,
                          itemBuilder: (_, index) {
                            final item = c.affirmations[index];
                            final txt = (item['affirmation_text'] ?? '')
                                .toString();
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  txt,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: c.toggleFavorite,
                      child: Icon(
                        (c.affirmations.isNotEmpty &&
                                (c.affirmations[s.index]['is_favorite'] ==
                                    true))
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            (c.affirmations.isNotEmpty &&
                                (c.affirmations[s.index]['is_favorite'] ==
                                    true))
                            ? Colors.pink
                            : Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: () => c.repeat(),
                      child: const Icon(
                        Icons.repeat,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 30,
                      ),
                      onTap: () {
                        if (c.affirmations.isEmpty) return;

                        final index = s.index;

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => ChangeNotifierProvider.value(
                            value: c,
                            child: Consumer<PlayerController>(
                              builder: (context, pc, __) {
                                final item =
                                    pc.affirmations[index]
                                        as Map<String, dynamic>;

                                return AffirmationMenuModal(
                                  affirmation: item, // ✅ current affirmation
                                  loading: pc.isFavLoading(
                                    index,
                                  ), // ✅ loading state
                                  onClose: () => Navigator.pop(context),
                                  onFavoriteChanged: (_) async {
                                    await pc.toggleFavoriteAt(
                                      index,
                                    ); // ✅ controller toggle
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                GestureDetector(
                  onTap: c.playPause,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: CircularProgressIndicator(
                          value: s.progress,
                          strokeWidth: 5,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFB72658),
                          ),
                        ),
                      ),
                      Icon(
                        s.isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: BottomTabs(
                    onTap: (tab) async {
                      c.selectTab(tab);
                      if (tab == PlayerTab.voice) await c.loadVoices();
                      if (tab == PlayerTab.music) await c.fetchMusic();

                      if (!mounted) return;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ChangeNotifierProvider.value(
                          value: c,
                          child: const SettingsSheet(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomTabs extends StatelessWidget {
  final Future<void> Function(PlayerTab tab) onTap;
  const BottomTabs({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    Widget pill(PlayerTab tab, String title, String img) {
      final active = c.selectedTab == tab;
      return GestureDetector(
        onTap: () => onTap(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 45,
          width: active ? 130 : 110,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: active ? Colors.white : Colors.black),
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
        pill(PlayerTab.voice, 'Voice', 'assets/profilepic/profile2.jpg'),
        pill(PlayerTab.time, 'Time', 'assets/images/timer.jpg'),
        pill(PlayerTab.music, 'Music', 'assets/images/music1.jpg'),
      ],
    );
  }
}
