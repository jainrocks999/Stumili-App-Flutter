import 'package:flutter/material.dart';
import 'package:weather_app/core/playlist_action_handler.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/screens/main/user_plalist/edit_playlist_screen.dart';

class SearchList extends StatefulWidget {
  final List<dynamic> cate; // categories list
  final Function(dynamic item) onPress; // open details
  final Function(dynamic item)? onPressPlay; // optional play
  final void Function(dynamic item, bool isFav)? onFavoriteChanged; // optional

  const SearchList({
    super.key,
    required this.cate,
    required this.onPress,
    this.onPressPlay,
    this.onFavoriteChanged,
  });

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  // ✅ per-item loading for 3-dots modal actions
  final Set<int> _menuLoading = <int>{};
  bool _isLoading(int index) => _menuLoading.contains(index);

  Future<void> _openCategoryActionModal(dynamic category, int index) async {
    if (_isLoading(index)) return;

    setState(() => _menuLoading.add(index));

    try {
      final result = await PlaylistActionHandler.openActionModal(
        context: context,
        item: category,                 // ✅ category item
        affirmations: const [],         // search list me affirmations usually nahi hote
      );

      if (!mounted || result == null) return;

      // ✅ favorite toggle
      if (result['action'] == 'favorite') {
        final bool val = result['value'] == true;
        setState(() => category['is_favorite'] = val);
        widget.onFavoriteChanged?.call(category, val);
      }

      // ✅ delete (list se remove)
      if (result['action'] == 'delete') {
        setState(() => widget.cate.removeAt(index));
      }

      // ✅ play
      if (result['action'] == 'play') {
        if (widget.onPressPlay != null) {
          widget.onPressPlay!(category);
        } else {
          // fallback: open player without list (agar tumhare flow me allowed ho)
          Navigator.pushNamed(
            context,
            AppRoutes.player,
            arguments: {"affirmations": const []},
          );
        }
      }

      // ✅ edit playlist (agar tum category edit allow karte ho)
      if (result['action'] == 'edit_playlist') {
        final res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditPlaylistScreen(
              item: category,
              affirmations: const [],
            ),
          ),
        );

        // optional: agar edit se updated name/image aaye to update
        if (!mounted || res == null) return;
        if (res['updated'] == true) {
          setState(() {
            // agar tum res me updated category bhejte ho:
            // category.addAll(res['category']);
          });
        }
      }
    } finally {
      if (!mounted) return;
      setState(() => _menuLoading.remove(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cate.length,
      itemBuilder: (context, index) {
        final item = widget.cate[index];

        final image = item['caetgory_images'] ??
            'https://images.unsplash.com/photo-1616356607338-fd87169ecf1a';

        final loading = _isLoading(index);

        return InkWell(
          onTap: () => widget.onPress(item),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                /// IMAGE
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['categories_name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Buy Stimuli',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                /// ✅ SAME AS PlaylistDailtsScreen (3-dots -> PlaylistActionHandler modal)
                InkWell(
                  onTap: () => _openCategoryActionModal(item, index),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
