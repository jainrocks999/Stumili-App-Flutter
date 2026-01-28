// =============================
// lib/screens/main/player/tabs/voice_tab.dart
// =============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player_controller.dart';

class VoiceTab extends StatelessWidget {
  const VoiceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Voice Settings',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),

          const Text('Voice Over', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),

          SizedBox(
            height: 70,
            child: (c.voices.isEmpty)
                ? const Center(
                    child: Text('No voices found', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: c.voices.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final v = c.voices[i];
                      final selected = c.selectedVoiceId == v.id;

                      return GestureDetector(
                        onTap: () => c.setVoice(v),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          width: selected ? 200 : 165,
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.grey,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 26, backgroundImage: AssetImage(v.avatarAsset)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  v.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 18),
          const Text('Voice Volume', style: TextStyle(color: Colors.grey)),
          Slider(
            value: c.ttsVolume,
            min: 0,
            max: 1,
            onChanged: c.setTtsVolume,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
          ),

          const SizedBox(height: 10),
          const Text('Affirmation Delay', style: TextStyle(color: Colors.grey)),
          Slider(
            value: c.ttsDelaySeconds.clamp(0.0, 2.0),
            min: 0,
            max: 2,
            divisions: 20,
            label: '${c.ttsDelaySeconds.toStringAsFixed(1)}s',
            onChanged: c.setDelay,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
