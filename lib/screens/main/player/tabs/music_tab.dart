import 'package:flutter/material.dart';
import 'package:weather_app/screens/main/player/player_controller.dart';
import 'package:provider/provider.dart';


class MusicTab extends StatelessWidget {
  const MusicTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    return Column(
      children: [
        const Text("Background Volume", style: TextStyle(color: Colors.white)),
        newMethod(c),
      ],
    );
  }

  Slider newMethod(PlayerController c) {
    return Slider(
        value: c.bgVolume,
        onChanged: c.setBgVolume,
        min: 0,
        max: 1,
        activeColor: Colors.white,
      );
  }
}
