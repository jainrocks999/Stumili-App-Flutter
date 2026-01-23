import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMore;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isAddPlaylist;

  const PlaylistTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onMore,
    required this.onTap,
    this.isSelected = false,
    this.isAddPlaylist = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap, // 🔥 LISTEN PLAYLIST
      leading: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: Color(0xFFB72658)),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: IconButton(
        icon: Icon(
          isAddPlaylist
              ? (isSelected ? Icons.check_circle : Icons.circle_outlined)
              : Icons.more_horiz,
          color: isSelected?Color(0xFFB72658): Colors.white,
        ),
        onPressed: onMore,
      ),
    );
  }
}
