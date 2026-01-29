import 'package:flutter/material.dart';
import 'package:stumili/core/helper.dart';
import 'package:stumili/core/playlist_action_handler.dart';
import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/main/user_plalist/edit_playlist_screen.dart';
import 'package:stumili/widgets/affirmation_menu_modal.dart';
import 'package:stumili/widgets/custom_button.dart';

class PlaylistDailtsScreen extends StatefulWidget {
  const PlaylistDailtsScreen({super.key});

  @override
  State<PlaylistDailtsScreen> createState() => _PlaylistDailtsScreenState();
}

class _PlaylistDailtsScreenState extends State<PlaylistDailtsScreen> {
  bool isFavorite = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final category = args['category'];

    isFavorite = category['is_favorite'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final affirmations = args['affirmation'];
    final category = args['category'];
    final isDefault = args['isDefault']??false;
    final String title = category["categories_name"] ?? "Believe in Yourself";
    final String imageUrl =
        category["caetgory_images"] ??
        "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4";
    double hp(double percent) => size.height * percent / 100;
    double wp(double percent) => size.width * percent / 100;
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: hp(35),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: hp(35),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF000000),
                        Color(0x80000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: hp(2),
                  left: wp(4),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: hp(3),
                  left: wp(5),
                  width: wp(90),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: wp(6),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: wp(7), vertical: hp(2)),
              child: Column(
                children: [
                  SizedBox(
                    height: hp(8),
                    width: wp(45),
                    child: CustomButton(
                      title: "Play",
                      height: double.infinity,
                      width: double.infinity,
                      onPress: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.player,
                          arguments: {"affirmations": affirmations},
                        );
                      },
                    ),
                  ),
                  SizedBox(height: hp(2)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isDefault)
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFB72658)
                                : Colors.white,
                          ),
                          onPressed: () async {
                            final newValue = await CommonHelper.toggleFavorite(
                              item: category,
                              currentValue: isFavorite,
                            );

                            if (!mounted) return;

                            setState(() {
                              isFavorite = newValue;
                              category['is_favorite'] =
                                  newValue; // 🔥 shared state
                            });
                          },
                        ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () async {
                          final result =
                              await PlaylistActionHandler.openActionModal(
                                context: context,
                                item: category,
                                affirmations: affirmations,
                              );

                          if (!mounted || result == null) return;

                          if (result['action'] == 'favorite') {
                            setState(() {
                              isFavorite = result['value'];
                              category['is_favorite'] = result['value'];
                            });
                          }

                          if (result['action'] == 'delete') {
                            if (!mounted) {
                              return;
                            }
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          }
                          if (result['action'] == 'play') {
                            if (!mounted) {
                              return;
                            }
                            Navigator.pushNamed(
                              // ignore: use_build_context_synchronously
                              context,
                              AppRoutes.player,
                              arguments: {"affirmations": affirmations},
                            );
                          }
                          if (result['action'] == 'edit_playlist') {
                            if (!mounted) {
                              return;
                            }
                            final result = await Navigator.push(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditPlaylistScreen(
                                  item: category,
                                  affirmations: affirmations,
                                ),
                              ),
                            );
                            if (!mounted || result == null) return;

                            if (result['updated'] == true) {
                              setState(() {
                                affirmations.clear();
                                affirmations.addAll(result['affirmations']);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: wp(5)),
                itemCount: affirmations.length,
                itemBuilder: (context, index) {
                  final item = affirmations[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: hp(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A4949),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item["affirmation_text"]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: hp(2),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (_) {
                                return AffirmationMenuModal(
                                  affirmation: item,
                                  loading: false,
                                  onClose: () => Navigator.pop(context),
                                  onFavoriteChanged: (isFav) async {
                                    final newValue =
                                        await CommonHelper.toggleFavorite(
                                          item: item,
                                          currentValue: isFav,
                                          isAffimation: true,
                                        );

                                    setState(() {
                                      item['is_favorite'] = newValue;
                                    });
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
