import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onMore;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap, // 🔥 CATEGORY CLICK
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_,_,_) =>
              Container(width: 56, height: 56, color: Colors.grey),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Buy Stimuli",
        style: TextStyle(color: Colors.white60),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.white),
        onPressed: onMore,
      ),
    );
  }
}
