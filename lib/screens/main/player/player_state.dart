import 'package:flutter/foundation.dart';

@immutable
class PlayerState {
  final int index;
  final bool isPaused;
  final double progress; // 0 → 1

  const PlayerState({
    required this.index,
    required this.isPaused,
    required this.progress,
  });

  PlayerState copyWith({
    int? index,
    bool? isPaused,
    double? progress,
  }) {
    return PlayerState(
      index: index ?? this.index,
      isPaused: isPaused ?? this.isPaused,
      progress: progress ?? this.progress,
    );
  }

  static const initial = PlayerState(
    index: 0,
    isPaused: true,
    progress: 0,
  );
}
