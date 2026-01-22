
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            child: Image.asset(
              'assets/images/music.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// Dark Overlay
          Positioned.fill(
           child: Container(color: Colors.black.withAlpha((0.93 * 255).round())),

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
                        backgroundImage:
                            AssetImage('assets/images/music.jpg'),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// PageView (RN FlatList pagingEnabled)
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
                      color: controller.affirmations[state.index]
                                  ['is_favorite'] ==
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
                    const Icon(Icons.more_horiz,
                        color: Colors.white, size: 30),
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
                        state.isPaused
                            ? Icons.play_arrow
                            : Icons.pause,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _BottomTab(title: 'Voice'),
                      _BottomTab(title: 'Time'),
                      _BottomTab(title: 'Music'),
                    ],
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

class _BottomTab extends StatelessWidget {
  final String title;
  const _BottomTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(''),
          CircleAvatar(radius: 18),
        ],
      ),
    );
  }
}
