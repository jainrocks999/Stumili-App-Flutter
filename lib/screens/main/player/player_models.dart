// =============================
// lib/screens/main/player/player_models.dart
// =============================
class BgCategory {
  final String id;
  final String name;

  const BgCategory({required this.id, required this.name});
}

class BgSound {
  final String id;
  final String name;
  final String imageUrl; // network image
  final String audioUrl; // network audio

  const BgSound({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.audioUrl,
  });
}

class VoiceOption {
  final String id; // voice name/id
  final String name; // display
  final String locale; // e.g. en-IN
  final String avatarAsset;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.locale,
    required this.avatarAsset,
  });
}
