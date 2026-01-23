import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weather_app/widgets/add_to_playlist_sheet.dart';

class AffirmationMenuModal extends StatelessWidget {
  final Map<String, dynamic> affirmation;
  final bool loading;
  final VoidCallback onClose;
  final Function(bool isFavorite)? onFavoriteChanged;

  const AffirmationMenuModal({
    super.key,
    required this.affirmation,
    required this.loading,
    required this.onClose,
    required this.onFavoriteChanged,
  });

  List<Map<String, dynamic>> menuItems() {
    return [
      {
        "id": 1,
        "text": affirmation['is_favorite'] == true
            ? "Unlike Affirmation"
            : "Like Affirmation",
        "icon": Icons.favorite,
      },
      {"id": 2, "text": "Add to Playlist", "icon": Icons.add_circle_outline},
      {"id": 3, "text": "Share", "icon": Icons.share},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          /// Text
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Text(
              affirmation['affirmation_text'] ?? "",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          const SizedBox(height: 20),

          ...menuItems().map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                onTap: loading
                    ? null
                    : () async {
                        switch (item['id']) {
                          case 1:
                            final isFav = affirmation['is_favorite'] == true;
                            onFavoriteChanged?.call(isFav);
                            onClose();
                            break;
                          case 2:
                            onClose();
                            
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) {
                                    return AddToPlaylistSheet(
                                      affirmationId: affirmation['id'],
                                    );
                                  },
                                );
                              },
                            );
                            break;
                          case 3:
                            Share.share(affirmation['affirmation_text'] ?? "");
                            break;
                        }
                      },
                leading: Icon(
                  item['icon'],
                  color: item['id'] == 1 && affirmation['is_favorite'] == true
                      ? const Color(0xFFB72658)
                      : Colors.white,
                ),
                title: Text(
                  item['text'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          TextButton(
            onPressed: onClose,
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
