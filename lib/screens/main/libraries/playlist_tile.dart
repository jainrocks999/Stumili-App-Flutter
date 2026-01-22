import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onMore;
  final VoidCallback onTap;

  const PlaylistTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onMore,
    required this.onTap,
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
        icon: const Icon(Icons.more_horiz, color: Colors.white),
        onPressed: onMore, // 🔥 OPEN MENU
      ),
    );
  }
}
