import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart' as ja;

import 'player_state.dart';

class PlayerController extends ChangeNotifier {
  final List affirmations;
  int maxTimeMinutes = 1; // 1 / 5 / 10
  int _elapsedSeconds = 0;
  Timer? _sessionTimer;

  final PageController pageController = PageController();
  final FlutterTts tts = FlutterTts();
  final ja.AudioPlayer bgPlayer = ja.AudioPlayer();

  // Timer? _timer;

  PlayerState _state = PlayerState.initial;
  PlayerState get state => _state;

  PlayerController(this.affirmations) {
    _init();
  }

  // ---------------- INIT ----------------
  Future<void> _init() async {
    // -------- Background Music --------
    await bgPlayer.setAsset('assets/sound/affirmation.mp3');
    bgPlayer.setLoopMode(ja.LoopMode.one);
    bgPlayer.setVolume(0.35);

    // -------- TTS Natural Indian Voice --------
    await tts.setLanguage("en-IN");

  await tts.setVoice({
  "name": "en-in-x-end-network",
  "locale": "en-IN",
});

// 🔥 Natural human pacing
await tts.setSpeechRate(0.38); // ⬅️ slower = calmer
await tts.setPitch(0.95);      // ⬅️ slightly deep
await tts.setVolume(1.0);

    tts.setCompletionHandler(_onSpeechComplete);

    // OPTIONAL (sirf debug ke liye ek baar)
    // getVoices();
  }

void autoStart() {
  if (!_state.isPaused) return;

  _elapsedSeconds = 0;
  _start();
}
  void playPause() {
    if (_state.isPaused) {
      _start();
    } else {
      _pause();
    }
  }

  void _start() {
    bgPlayer.play();
    _speakCurrent();
    _startSessionTimer();

    _state = _state.copyWith(isPaused: false);
    notifyListeners();
  }

  void _pause() {
    bgPlayer.pause();
    tts.stop();
    _sessionTimer?.cancel();

    _state = _state.copyWith(isPaused: true);
    notifyListeners();
  }

  Future<void> getVoices() async {
 
  }

  // ---------------- TTS ----------------
  void _speakCurrent() {
    if (affirmations.isEmpty) return;

    final text = affirmations[_state.index]['affirmation_text'];
    tts.stop();
    tts.speak(text);
  }

  void _onSpeechComplete() {
    next();
  }

  // ---------------- PAGE CONTROL ----------------
  void next() {
    if (_state.index < affirmations.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // reached end
      _pause();
    }
  }

  void onPageChanged(int index) {
    _state = _state.copyWith(
      index: index,
      // progress: 0,
    );
    notifyListeners();

    if (!_state.isPaused) {
      _speakCurrent();
    }
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();

    final totalSeconds = maxTimeMinutes * 60;
    if (totalSeconds == 0 || affirmations.isEmpty) return;

    final secondsPerAffirmation = totalSeconds / affirmations.length;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.isPaused) return;

      _elapsedSeconds++;

      // ---- progress (0 → 1)
      final progress = _elapsedSeconds / totalSeconds;

      // ---- calculate affirmation index
      final newIndex = (_elapsedSeconds / secondsPerAffirmation).floor();

      if (newIndex != _state.index && newIndex < affirmations.length) {
        pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      // ---- session finished
      if (_elapsedSeconds >= totalSeconds) {
        _pause();
        _elapsedSeconds = 0;
        return;
      }

      _state = _state.copyWith(progress: progress.clamp(0, 1));
      notifyListeners();
      getVoices();
    });
  }

  // ---------------- REPEAT ----------------
  void repeat() {
    _elapsedSeconds = 0;

    pageController.jumpToPage(0);
    _state = _state.copyWith(index: 0, progress: 0);
    notifyListeners();

    if (!_state.isPaused) {
      _speakCurrent();
      _startSessionTimer();
    }
  }

  // ---------------- CLEANUP ----------------
  @override
  void dispose() {
    _sessionTimer?.cancel();
    bgPlayer.dispose();
    tts.stop();
    pageController.dispose();
    super.dispose();
  }
}
