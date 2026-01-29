import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:weather_app/core/helper.dart';

import 'player_models.dart';
import 'player_state.dart';

enum PlayerTab { voice, time, music }

class PlayerController extends ChangeNotifier {
  // ✅ Global mutable session list
  final List affirmations = [];

  // UI
  PlayerTab selectedTab = PlayerTab.voice;

  // Session
  int maxTimeMinutes = 1;
  int _elapsedSeconds = 0;
  Timer? _sessionTimer;

  // TTS
  final FlutterTts tts = FlutterTts();
  double ttsVolume = 1.0;
  double ttsDelaySeconds = 0.0;
  String? selectedVoiceId;
  List<VoiceOption> voices = [];

  // Background Audio
  final ja.AudioPlayer bgPlayer = ja.AudioPlayer();
  double bgVolume = 0.35;
  bool bgEnabled = true;

  // Music dummy
  bool bgLoading = false;
  List<BgCategory> bgCategories = [];
  List<BgSound> bgSounds = [];
  String? selectedBgCategoryId;
  BgSound? selectedBgSound;

  // Page + state
  final PageController pageController = PageController();
  PlayerState _state = PlayerState.initial;
  PlayerState get state => _state;

  // Ready
  bool _ready = false;
  bool get isReady => _ready;
  bool get isPlaying => !_state.isPaused;

  final Completer<void> _readyCompleter = Completer<void>();
  Future<void> waitUntilReady() async {
    if (_ready) return;
    await _readyCompleter.future;
  }

  // Guards
  bool _starting = false;

  /// ✅ IMPORTANT: stop() should not trigger "next"
  bool _suppressCompletion = false;

  /// ✅ Sequence guard: old callbacks ignored
  int _speakSeq = 0;
  int _activeSpeakSeq = 0;

  // Human voice names
  final List<String> _humanVoiceNames = const [
    "Calm Female",
    "Warm Male",
    "Gentle Voice",
    "Soothing Female",
    "Deep Male",
    "Soft Whisper",
    "Friendly Voice",
    "Peaceful Narrator",
    "Serene Female",
    "Confident Male",
    "Relaxing Voice",
    "Natural Speaker",
    "Clear Narrator",
    "Smooth Voice",
    "Bright Voice",
  ];
  final Map<String, String> _voiceNameMap = {};
  final Random _random = Random();

  PlayerController() {
    _init();
  }

  bool _ttsStarted = false; // confirms actual speaking started
  // ignore: unused_field
  bool _ttsBusy = false; // prevents overlaps
  Timer? _ttsRetryTimer;
// PlayerController ke andar
final Set<int> _favLoading = <int>{};

bool isFavLoading(int index) => _favLoading.contains(index);

Future<void> toggleFavoriteAt(int index) async {
  if (affirmations.isEmpty) return;
  if (index < 0 || index >= affirmations.length) return;
  if (_favLoading.contains(index)) return;

  _favLoading.add(index);
  notifyListeners();

  final Map<String, dynamic> item =
      Map<String, dynamic>.from(affirmations[index] as Map);

  final bool currentValue = (item['is_favorite'] == true);

  try {
    final bool newValue = await CommonHelper.toggleFavorite(
      item: item,
      currentValue: currentValue,
      isAffimation: true,
    );

    item['is_favorite'] = newValue;
    affirmations[index] = item;
  } finally {
    _favLoading.remove(index);
    notifyListeners();
  }
}

// current item shortcut
Future<void> toggleFavorite1() => toggleFavoriteAt(_state.index);


  // ================= INIT =================
  Future<void> _init() async {
    try {
      await bgPlayer.setAsset('assets/sound/affirmation.mp3');
      await bgPlayer.setLoopMode(ja.LoopMode.one);
      await bgPlayer.setVolume(bgEnabled ? bgVolume : 0.0);
    } catch (_) {}

    try {
      // completion callbacks enabled
      await tts.awaitSpeakCompletion(true);

      await tts.setLanguage('en-IN');
      await tts.setSpeechRate(0.38);
      await tts.setPitch(0.95);
      await tts.setVolume(ttsVolume);

      // ✅ completion handler MUST be sync
      tts.setCompletionHandler(() {
        _handleTtsComplete();
      });

      // Optional: if plugin supports
      tts.setCancelHandler(() {
        // stop() / cancel triggers here on some devices
        // We do nothing; completion is controlled by _suppressCompletion + seq guards
      });

      tts.setErrorHandler((msg) {
        // ignore old errors
      });
    } catch (_) {}

    await loadVoices();

    try {
      await tts.awaitSpeakCompletion(true);

      tts.setStartHandler(() {
        _ttsStarted = true;
        _ttsBusy = true;
      });

      tts.setCompletionHandler(() {
        _ttsBusy = false;
        _ttsStarted = false;
        _handleTtsComplete();
      });

      tts.setCancelHandler(() {
        _ttsBusy = false;
        _ttsStarted = false;
      });

      tts.setErrorHandler((msg) {
        _ttsBusy = false;
        _ttsStarted = false;
      });
    } catch (_) {}

    _ready = true;
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
    notifyListeners();
  }

  // ================= Helpers =================
  String get currentText {
    if (affirmations.isEmpty) return '';
    final idx = _state.index.clamp(0, affirmations.length - 1);
    return (affirmations[idx]['affirmation_text'] ?? '').toString();
  }

  // ================= TAB =================
  void selectTab(PlayerTab tab) {
    selectedTab = tab;
    notifyListeners();
  }

  // ================= SESSION =================
  Future<void> startSession(
    List newAffirmations, {
    bool autoplay = true,
    int? minutes,
  }) async {
    await waitUntilReady();

    affirmations
      ..clear()
      ..addAll(newAffirmations);

    if (minutes != null) maxTimeMinutes = minutes;

    _elapsedSeconds = 0;
    _sessionTimer?.cancel();

    await _stopTtsInternal();

    // ✅ ALWAYS start in paused state
    _state = _state.copyWith(index: 0, progress: 0, isPaused: true);
    notifyListeners();

    // page reset
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }

    if (autoplay) {
      // ✅ give 1 frame so UI + page attach ho jaye
      await Future.delayed(const Duration(milliseconds: 300));
      await play();
    }
  }

  // ================= PLAY / PAUSE =================
  Future<void> play() async {
    await waitUntilReady();
    if (affirmations.isEmpty) return;
    if (!_state.isPaused) return; // Pehle se chal raha hai toh return
    if (_starting) return;

    _starting = true;
    try {
      // 1. UI ko turant update karein
      _state = _state.copyWith(isPaused: false);
      notifyListeners();

      // 2. Timer shuru karein
      _startSessionTimer();

      // 3. Background music play karein
      if (bgEnabled) {
        bgPlayer.play().catchError((e) => debugPrint("BG Music Error: $e"));
      }

      // 4. TTS trigger karein (Restart: true aur Retry: true zaroori hai)
      await _speakCurrent(restart: true, retryIfNotStarted: true);
    } finally {
      _starting = false;
    }
  }

  Future<void> pause() async {
    if (_state.isPaused) return;

    _state = _state.copyWith(isPaused: true);
    notifyListeners();

    _sessionTimer?.cancel();

    try {
      await bgPlayer.pause();
    } catch (_) {}
    await _stopTtsInternal();
  }

  void playPause() {
    if (_state.isPaused) {
      play();
    } else {
      pause();
    }
  }

  Future<void> repeat() async {
    if (affirmations.isEmpty) return;

    _elapsedSeconds = 0;
    _sessionTimer?.cancel();
    await _stopTtsInternal();

    _state = _state.copyWith(index: 0, progress: 0);
    notifyListeners();

    if (pageController.hasClients) pageController.jumpToPage(0);

    if (!_state.isPaused) {
      _startSessionTimer();
      await _speakCurrent(restart: true);
    }
  }

  // ================= PAGE =================
  void onPageChanged(int index) {
    if (affirmations.isEmpty) return;

    final safe = index.clamp(0, affirmations.length - 1);
    _state = _state.copyWith(index: safe);
    notifyListeners();

    if (_state.isPaused) {
      play(); // ✅ will start + speak
    } else {
      _speakCurrent(restart: true); // ✅ playing -> speak new page
    }
  }

  Future<void> next() async {
    if (affirmations.isEmpty) return;
    final lastIndex = affirmations.length - 1;

    if (_state.index >= lastIndex) {
      // ✅ Agar list khatam ho gayi, toh 0 se restart karein
      _state = _state.copyWith(index: 0);
      notifyListeners();

      if (pageController.hasClients) {
        // Direct jump karein taaki loop seamless lage
        pageController.jumpToPage(0);
      }

      // Dobara bolna shuru karein (Sequence guard handles the rest)
      if (!_state.isPaused) await _speakCurrent(restart: true);
    } else {
      // Normal next behavior
      final target = _state.index + 1;
      if (pageController.hasClients) {
        await pageController.nextPage(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      } else {
        _state = _state.copyWith(index: target);
        notifyListeners();
        if (!_state.isPaused) await _speakCurrent();
      }
    }
  }

  // ================= TIMER / PROGRESS =================
  void setSessionMinutes(int minutes) {
    maxTimeMinutes = minutes;
    _elapsedSeconds = 0;
    _state = _state.copyWith(progress: 0);
    notifyListeners();
    if (!_state.isPaused) _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();

    final totalSeconds = maxTimeMinutes * 60;
    if (totalSeconds <= 0 || affirmations.isEmpty) return;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_state.isPaused) return;

      _elapsedSeconds++;
      final progress = (_elapsedSeconds / totalSeconds).clamp(0.0, 1.0);

      _state = _state.copyWith(progress: progress);
      notifyListeners();

      if (_elapsedSeconds >= totalSeconds) {
        _elapsedSeconds = 0;
        _state = _state.copyWith(progress: 1);
        notifyListeners();
        await pause();
      }
    });
  }

  // ================= TTS (ROBUST) =================
  Future<void> _stopTtsInternal() async {
    _suppressCompletion = true;
    try {
      await tts.stop();
    } catch (_) {}
    _suppressCompletion = false;
  }

  Future<void> _speakCurrent({
    bool restart = true,
    bool retryIfNotStarted = false,
  }) async {
    if (affirmations.isEmpty || _state.isPaused) return;

    final text = currentText.trim();
    if (text.isEmpty) return;

    // ✅ Sequence Guard: Purane pending calls ko ignore karne ke liye
    _speakSeq++;
    _activeSpeakSeq = _speakSeq;
    final currentSeq = _activeSpeakSeq;

    _ttsRetryTimer?.cancel();
    _ttsStarted = false;

    if (restart) {
      await tts.stop();
      // ✅ Most Important: Engine ko reset hone ke liye saas lene ka waqt dein
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Check karein ki user ne delay ke beech mein pause toh nahi kar diya
    if (currentSeq != _activeSpeakSeq || _state.isPaused) return;

    try {
      await tts.setVolume(ttsVolume);
      // speak() trigger karein
      final result = await tts.speak(text);
      if (result == 1) _ttsStarted = true;
    } catch (e) {
      debugPrint("TTS Speak Error: $e");
    }

    // ✅ Fallback Retry: Agar engine ne 'start' signal nahi bheja toh 600ms baad fir koshish karein
    if (retryIfNotStarted) {
      _ttsRetryTimer = Timer(const Duration(milliseconds: 600), () async {
        if (!_ttsStarted && !_state.isPaused && currentSeq == _activeSpeakSeq) {
          debugPrint("TTS silent tha, retry kar raha hoon...");
          await tts.speak(text);
        }
      });
    }
  }

  // completion handler calls this sync method
  void _handleTtsComplete() {
    // ignore stop/cancel completions
    if (_suppressCompletion) return;
    if (_state.isPaused) return;

    final completedSeq = _activeSpeakSeq;

    // run async part
    Future.microtask(() async {
      // if state changed meanwhile, ignore
      if (_state.isPaused) return;
      if (completedSeq != _activeSpeakSeq) return;

      if (ttsDelaySeconds > 0) {
        await Future.delayed(
          Duration(milliseconds: (ttsDelaySeconds * 1000).round()),
        );
      }

      if (_state.isPaused) return;
      if (completedSeq != _activeSpeakSeq) return;

      await next();
    });
  }

  Future<void> toggleFavorite() async {
    if (affirmations.isEmpty) return;

    final Map<String, dynamic> cur = Map<String, dynamic>.from(
      affirmations[_state.index] as Map,
    );

    final bool oldValue = (cur['is_favorite'] == true);
    final bool nextValue = !oldValue;

    cur['is_favorite'] = nextValue;
    affirmations[_state.index] = cur;
    notifyListeners();
    try {
      final bool serverValue = await CommonHelper.toggleFavorite(
        item: cur,
        currentValue: oldValue,
        isAffimation: true
      );

      if (serverValue != nextValue) {
        cur['is_favorite'] = serverValue;
        affirmations[_state.index] = cur;
        notifyListeners();
      }
    } catch (e) {
      cur['is_favorite'] = oldValue;
      affirmations[_state.index] = cur;
      notifyListeners();
    }
  }


  String _getNameForVoice(String id) {
    if (_voiceNameMap.containsKey(id)) return _voiceNameMap[id]!;
    final used = _voiceNameMap.values.toSet();
    final available = _humanVoiceNames.where((n) => !used.contains(n)).toList();
    final picked = available.isNotEmpty
        ? available[_random.nextInt(available.length)]
        : _humanVoiceNames[_random.nextInt(_humanVoiceNames.length)];
    _voiceNameMap[id] = picked;
    return picked;
  }

  Future<void> loadVoices() async {
    try {
      final raw = await tts.getVoices;
      final options = <VoiceOption>[];

      for (final v in raw) {
        final map = (v as Map).map((k, val) => MapEntry(k.toString(), val));
        final locale = (map['locale'] ?? map['language'] ?? '').toString();
        final id = (map['name'] ?? map['id'] ?? '').toString();
        if (locale.isEmpty || id.isEmpty) continue;

        if (locale.toLowerCase().startsWith('en-in')) {
          options.add(
            VoiceOption(
              id: id,
              name: _getNameForVoice(id),
              locale: locale,
              avatarAsset: 'assets/profilepic/profile4.jpg',
            ),
          );
        }
      }

      if (options.isEmpty) {
        for (final v in raw) {
          final map = (v as Map).map((k, val) => MapEntry(k.toString(), val));
          final locale = (map['locale'] ?? map['language'] ?? '').toString();
          final id = (map['name'] ?? map['id'] ?? '').toString();
          if (locale.isEmpty || id.isEmpty) continue;

          options.add(
            VoiceOption(
              id: id,
              name: _getNameForVoice(id),
              locale: locale,
              avatarAsset: 'assets/profilepic/profile4.jpg',
            ),
          );
        }
      }

      voices = options;

      if (voices.isNotEmpty && selectedVoiceId == null) {
        await setVoice(voices.first, preview: false);
      }

      notifyListeners();
    } catch (_) {
      voices = const [];
      notifyListeners();
    }
  }

  Future<void> setVoice(VoiceOption voice, {bool preview = true}) async {
    selectedVoiceId = voice.id;
    try {
      await tts.setLanguage(voice.locale);
      await tts.setVoice({"name": voice.id, "locale": voice.locale});
    } catch (_) {}

    notifyListeners();

    if (preview && !_state.isPaused) {
      await _speakCurrent();
    }
  }

  // ================= SETTINGS =================
  Future<void> setTtsVolume(double v) async {
    ttsVolume = v.clamp(0.0, 1.0);
    try {
      await tts.setVolume(ttsVolume);
    } catch (_) {}
    notifyListeners();

    // if (!_state.isPaused) {
    //   await _speakCurrent(); // apply immediately
    // }
  }

  void setDelay(double seconds) {
    ttsDelaySeconds = seconds.clamp(0.0, 2.0);
    notifyListeners();
  }

  Future<void> setBgVolume(double v) async {
    bgVolume = v.clamp(0.0, 1.0);
    await _applyBgVolume();
    notifyListeners();
  }

  Future<void> setBgEnabled(bool enabled) async {
    bgEnabled = enabled;
    await _applyBgVolume();
    if (!_state.isPaused) {
      try {
        if (bgEnabled) {
          await bgPlayer.play();
        } else {
          await bgPlayer.pause();
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _applyBgVolume() async {
    try {
      await bgPlayer.setVolume(bgEnabled ? bgVolume : 0.0);
    } catch (_) {}
  }

  // ================= MUSIC DUMMY =================
  Future<void> fetchMusic() async {
    if (bgLoading) return;
    bgLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    bgCategories = const [
      BgCategory(id: '1', name: 'Focus'),
      BgCategory(id: '2', name: 'Relax'),
      BgCategory(id: '3', name: 'Sleep'),
    ];
    selectedBgCategoryId ??= bgCategories.first.id;

    bgSounds = const [
      BgSound(
        id: '1',
        name: 'Ocean',
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      ),
      BgSound(
        id: '2',
        name: 'Rain',
        imageUrl:
            'https://images.unsplash.com/photo-1444384851176-6e23071c6127',
        audioUrl:
            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      ),
    ];

    bgLoading = false;
    notifyListeners();
  }

  void selectBgCategory(String id) {
    selectedBgCategoryId = id;
    notifyListeners();
  }

  Future<void> playBgSound(BgSound sound) async {
    selectedBgSound = sound;
    try {
      await bgPlayer.setUrl(sound.audioUrl);
      await bgPlayer.setLoopMode(ja.LoopMode.one);
      await _applyBgVolume();
      if (!_state.isPaused && bgEnabled) await bgPlayer.play();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> useDefaultBgAsset() async {
    selectedBgSound = null;
    try {
      await bgPlayer.setAsset('assets/sound/affirmation.mp3');
      await bgPlayer.setLoopMode(ja.LoopMode.one);
      await _applyBgVolume();
      if (!_state.isPaused && bgEnabled) await bgPlayer.play();
    } catch (_) {}
    notifyListeners();
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    _sessionTimer?.cancel();
    try {
      bgPlayer.dispose();
      tts.stop();
    } catch (_) {}
    pageController.dispose();
    super.dispose();
  }
}
