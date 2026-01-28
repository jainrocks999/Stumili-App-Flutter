import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_controller.dart';

class MiniPlayerBar extends StatelessWidget {
  final VoidCallback? onTapOpenPlayer;

  const MiniPlayerBar({super.key, this.onTapOpenPlayer});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    if (!c.isReady || c.affirmations.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = c.currentText.isEmpty ? "Affirmations" : c.currentText;

    // progress: 0..1 expected
    final progress = (c.state.progress).clamp(0.0, 1.0);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapOpenPlayer,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 78,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55), // glass tint
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: 2,
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left icon/avatar (optional)
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.graphic_eq, color: Colors.white),
                      ),

                      const SizedBox(width: 12),

                      // Title + subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.isPlaying ? "Playing" : "Paused",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Circular progress + play/pause inside
                      _ProgressPlayButton(
                        progress: progress,
                        isPlaying: c.isPlaying,
                        onTap: () => c.playPause(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressPlayButton extends StatelessWidget {
  final double progress; // 0..1
  final bool isPlaying;
  final VoidCallback onTap;

  const _ProgressPlayButton({
    required this.progress,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 46,
        width: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 46,
              width: 46,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFB72658)),
              ),
            ),
            Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white.withOpacity(0.9),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
