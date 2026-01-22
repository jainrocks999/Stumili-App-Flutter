import 'package:flutter/material.dart';

class CategoryMenuModal extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final VoidCallback onListen;
  final VoidCallback onLikeUnlike;
  final VoidCallback onShare;
  final bool isFav;

  // New flag to differentiate between Category and Playlist
  final bool isPlaylist;

  const CategoryMenuModal({
    super.key,
    required this.title,
    this.imageUrl,
    required this.onListen,
    required this.onLikeUnlike,
    required this.onShare,
    this.isPlaylist = false,
    this.isFav=true,
     // default false => Category
  });

  @override
  Widget build(BuildContext context) {
 
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl!, height: 80),
            ),
          const SizedBox(height: 12),
          Text(
            title.length > 15 ? '${title.substring(0, 15)}...' : title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Listen Playlist (common)
          _item(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            text: "Listen Playlist",
            onTap: onListen,
          ),

          // Like/Unlike for Category OR Edit for Playlist
          _item(
            icon: Icon(
              isPlaylist ? Icons.edit : Icons.favorite,
              color: isPlaylist||!isFav ? Colors.white : const Color(0xFFB72658),
            ),
            text: isPlaylist
                ? "Edit Playlist"
                : isFav
                ? "Unlike Plalist"
                : "Like Playlist",
            onTap: onLikeUnlike,
          ),

          // Share for Category OR Delete for Playlist
          _item(
            icon: Icon(
              isPlaylist ? Icons.delete : Icons.share,
              color: isPlaylist ? Colors.redAccent : Colors.white,
            ),
            text: isPlaylist ? "Delete Playlist" : "Share Playlist",
            onTap: onShare,
          ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required Icon icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
