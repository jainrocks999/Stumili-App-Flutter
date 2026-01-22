import 'package:flutter/material.dart';

class SearchList extends StatefulWidget {
  final List<dynamic> cate;
  final Function(dynamic item) onPress;
  final Function(dynamic item)? onPressPlay;

  const SearchList({
    super.key,
    required this.cate,
    required this.onPress,
    this.onPressPlay,
  });

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  int modalIndex = -1;
  bool loading = false;

  void getFavorite(dynamic item) async {
  
    debugPrint('Add favorite: ${item['id']}');
  }

  void removeFavorite(dynamic item) async {
 
    debugPrint('Remove favorite: ${item['id']}');
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

        return Stack(
          children: [
            /// CATEGORY ITEM
            InkWell(
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

                    /// MENU DOTS
                    InkWell(
                      onTap: () {
                        setState(() {
                          modalIndex =
                              modalIndex == index ? -1 : index;
                        });
                      },
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// MENU OVERLAY (Equivalent of Categores_menu)
            if (modalIndex == index)
              Positioned(
                right: 20,
                top: 10,
                child: Material(
                  color: const Color(0xff2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          item['is_favorite'] == true
                              ? 'Remove Favorite'
                              : 'Add Favorite',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() => modalIndex = -1);
                          item['is_favorite'] == true
                              ? removeFavorite(item)
                              : getFavorite(item);
                        },
                      ),
                      ListTile(
                        title: const Text(
                          'Listen',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() => modalIndex = -1);
                          widget.onPressPlay?.call(item);
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
