import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/screens/main/player/player_controller.dart';

class VoiceTab extends StatelessWidget {
  const VoiceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlayerController>();

    return Column(
      children: [
        const Text(
          "Voice Settings",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),

        const SizedBox(height: 20),

        // Voice Volume
        Slider(
          value: controller.ttsVolume,
          min: 0,
          max: 1,
          onChanged: controller.setTtsVolume,
        ),

        // Background Volume
        Slider(
          value: controller.bgVolume,
          min: 0,
          max: 1,
          onChanged: controller.setBgVolume,
        ),
      ],
    );
  }
}
