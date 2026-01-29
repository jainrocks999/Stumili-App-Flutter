import 'package:flutter/material.dart';
import 'package:stumili/core/fonts.dart';
import 'package:stumili/core/helper.dart';
class HorizontalSection extends StatefulWidget {
  final String heading;
  final List<dynamic> data;
  final Function(dynamic item) onPress;

  const HorizontalSection({
    super.key,
    this.heading = '',
    required this.data,
    required this.onPress,
  });

  @override
  State<HorizontalSection> createState() => _HorizontalSectionState();
}

class _HorizontalSectionState extends State<HorizontalSection> {
  late List<dynamic> _items;
  final Set<int> _loadingItems = {}; // Keep track of items being updated

  @override
  void initState() {
    super.initState();
    _items = widget.data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> toggleFavorite(int index) async {
    if (_loadingItems.contains(index)) return;

    setState(() {
      _loadingItems.add(index);
    });

    final item = _items[index];
    final bool currentValue = item['is_favorite'] ?? false;

    final bool newValue = await CommonHelper.toggleFavorite(
      item: item,
      currentValue: currentValue,
    );

    if (!mounted) return;

    setState(() {
      _items[index]['is_favorite'] = newValue;
      _loadingItems.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double wp(double value) => width * value / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADING
        Text(
          widget.heading,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: AppFonts.medium,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: wp(60),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final image =
                  item['caetgory_images'] ??
                  'https://img.freepik.com/free-photo/outdoor-adventurers-hiking-towards-mountain-peak-sunrise-silhouette-generated-by-ai_188544-30928.jpg';
              final title = item['categories_name'] ?? '';
              final isFav = item['is_favorite'] ?? false;
              final isLoading = _loadingItems.contains(index);

              return GestureDetector(
                onTap: () => widget.onPress(item),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: wp(2.5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(wp(5)),
                            child: Image.network(
                              image,
                              height: wp(43),
                              width: wp(43),
                              fit: BoxFit.cover,
                            ),
                          ),

                          /// HEART ICON OR LOADER
                          Positioned(
                            top: 10,
                            left: 10,
                            child: GestureDetector(
                              onTap: () => toggleFavorite(index),
                              child: Container(
                                height: 28,
                                width: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFav
                                            ? const Color(0xFFB72658)
                                            : Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// TITLE
                      Padding(
                        padding: EdgeInsets.only(top: wp(2), left: wp(2)),
                        child: SizedBox(
                          width: wp(43),
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
