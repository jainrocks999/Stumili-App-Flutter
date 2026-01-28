// =============================
// lib/screens/main/player/tabs/time_tab.dart
// =============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player_controller.dart';

class TimeTab extends StatelessWidget {
  const TimeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();
    const times = [1, 5, 10, 20, 30];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Session Length',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: times.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final m = times[i];
                final active = c.maxTimeMinutes == m;

                return GestureDetector(
                  onTap: () => c.setSessionMinutes(m),
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: active ? Colors.black : const Color(0xFF4A4949),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$m',
                            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w700),
                          ),
                          const Text('min', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
