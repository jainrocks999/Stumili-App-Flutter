import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/screens/main/player/player_controller.dart';


class TimeTab extends StatelessWidget {
  const TimeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    final times = [1, 5, 10, 20, 30];

    return Wrap(
      spacing: 12,
      children: times.map((t) {
        return GestureDetector(
          onTap: () => c.maxTimeMinutes = t,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("$t min", style: const TextStyle(color: Colors.white)),
          ),
        );
      }).toList(),
    );
  }
}
