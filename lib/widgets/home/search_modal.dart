import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app/core/helper.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/widgets/affirmation_menu_modal.dart';
import 'package:weather_app/widgets/home/search_list.dart';

class SearchModal extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(dynamic item) onCategories;

  const SearchModal({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onCategories,
  });

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  String value = '';
  String searchType = 'All';
  Timer? _debounce;

  bool loading = false;
  List categories = [];
  List affirmations = [];

  Future<void> handleOnSearch(String input, String type) async {
    if (input.isEmpty) {
      setState(() {
        categories = [];
        affirmations = [];
      });
      return;
    }

    setState(() => loading = true);

    try {
      final userId = await SecureStore.getUserId();
      final token = await SecureStore.getToken();

      final response = await ApiService.getRequest(
        '/playListSearch',
        headers: {'Authorization': 'Bearer $token'},
        queryParameters: {
          'search_text': input,
          'search_type': type,
          'user_id': userId,
        },
      );

      final data = response.data['data'];

      setState(() {
        categories = data['categories'] ?? [];
        affirmations = data['affirmations'] ?? [];
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  /// 🔁 debounce (500ms)
  void onTextChanged(String val) {
    value = val;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      handleOnSearch(value, searchType);
    });
  }

  final Set<int> _favLoading = <int>{};
  bool _isFavLoading(int i) => _favLoading.contains(i);

  void _openAffirmationMenu(Map<String, dynamic> item, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return AffirmationMenuModal(
          affirmation: item,
          loading: _isFavLoading(index),
          onClose: () => Navigator.pop(context),
          onFavoriteChanged: (isFav) async {
            if (_favLoading.contains(index)) return;

            setState(() => _favLoading.add(index));

            try {
              final newValue = await CommonHelper.toggleFavorite(
                item: item,
                currentValue: isFav, // isFav = current value
                isAffimation: true,
              );

              if (!mounted) return;
              setState(() => item['is_favorite'] = newValue);
            } catch (_) {
              // optional toast/log
            } finally {
              if (!mounted) return;
              setState(() => _favLoading.remove(index));
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox();
    final bool showCategories =
        (searchType == 'All' || searchType == 'playlist');
    final bool showAffirmations =
        (searchType == 'All' || searchType == 'affirmation');

    return Scaffold(
      backgroundColor: const Color(0xff191919),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                /// 🔹 HEADER
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: onTextChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: widget.onClose,
                      ),
                    ),
                  ),
                ),

                /// 🔹 FILTER BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _filterBtn('All', Icons.star),
                      _filterBtn('playlist', Icons.playlist_play),
                      _filterBtn('affirmation', Icons.campaign),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔹 CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// PLAYLISTS
                        if (showCategories && categories.isNotEmpty) ...[
                          _title('Playlist'),
                          SearchList(
                            cate: categories,
                            onPress: (item) {
                              widget.onCategories(item);
                              widget.onClose();
                            },
                            onPressPlay: (item) {
                              widget.onCategories(item);
                              widget.onClose();
                            },
                          ),
                        ],

                        /// AFFIRMATIONS
                        if (showAffirmations && affirmations.isNotEmpty) ...[
                          _title('Affirmations'),
                          ...List.generate(affirmations.length, (index) {
                            final item =
                                affirmations[index] as Map<String, dynamic>;
                            final text = (item["affirmation_text"] ?? '')
                                .toString();
                            final display = text.length > 40
                                ? '${text.substring(0, 40)}...'
                                : text;

                            return GestureDetector(
                              onTap: () {
                                widget.onClose();
                                Navigator.pushNamed(
                                  context,
                                  'Playlistdetails2',
                                  arguments: {'isPlaylist': true},
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xff4A4949),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        display,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          _openAffirmationMenu(item, index),
                                      child: _isFavLoading(index)
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.more_horiz,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// 🔄 LOADER
            if (loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              ),
          ],
        ),
      ),
    );
  }

  /// 🔹 FILTER BUTTON
  Widget _filterBtn(String type, IconData icon) {
    final active = searchType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => searchType = type);
          handleOnSearch(value, type);
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xffD485D1) : Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? Colors.white : Colors.black),
              const SizedBox(width: 6),
              Text(
                type == 'playlist'
                    ? 'PlayList'
                    : type == 'affirmation'
                    ? 'Affirmations'
                    : 'All',
                style: TextStyle(color: active ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(String t) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
