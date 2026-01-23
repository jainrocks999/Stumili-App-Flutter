import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/screens/main/libraries/category_menu_modal.dart';
import 'package:weather_app/screens/main/libraries/category_tile.dart';
import 'package:weather_app/screens/main/libraries/playlist_tile.dart';
import 'package:weather_app/screens/main/user_plalist/edit_playlist_screen.dart';
import 'package:weather_app/services/api_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool loading = false;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> playlists = [];

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    setState(() => loading = true);
    await Future.wait([getCategories(), getPlaylists()]);
    setState(() => loading = false);
  }

  Future<void> getCategories() async {
    final token = await SecureStore.getToken();
    final userId = await SecureStore.getUserId();

    final res = await ApiService.getWithToken(
      "/likeCategories",
      token: token,
      queryParameters: {"user_id": userId},
    );

    setState(() {
      categories = List<Map<String, dynamic>>.from(res.data['data']);
    });
  }

  Future<void> getPlaylists() async {
    final token = await SecureStore.getToken();
    final userId = await SecureStore.getUserId();

    final res = await ApiService.getWithToken(
      "/playList",
      token: token,
      queryParameters: {"user_id": userId},
    );

    setState(() {
      playlists = List<Map<String, dynamic>>.from(
        res.data['data'][0]['playlist'],
      );
    });
  }

  Future<void> openCategory(Map<String, dynamic> item) async {
    try {
      final token = await SecureStore.getToken();
      final userId = await SecureStore.getUserId();

      if (token == null || userId == null) {
        Fluttertoast.showToast(msg: "User not authenticated");
        return;
      }

      final response = await ApiService.getWithToken(
        "/categoryByAffermation",
        token: token,
        queryParameters: {"user_id": userId, "category_id": item['id']},
      );

      if (response.data['status'] == true) {
        final List affirmations = List.from(response.data['data'] ?? []);
        if (!mounted) {
          return;
        }

        Navigator.pushNamed(
          context,
          AppRoutes.playlistdailts,
          arguments: {"affirmation": affirmations, "category": item},
        );
      } else {
        Fluttertoast.showToast(msg: "No affirmations found");
      }
    } catch (e) {
      debugPrint("openCategory error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  Future<void> openPlaylist(
    Map<String, dynamic> item, {
    bool isEdit = false,
  }) async {
    try {
      final token = await SecureStore.getToken();
      final userId = await SecureStore.getUserId();

      if (token == null || userId == null) {
        Fluttertoast.showToast(msg: "User not authenticated");
        return;
      }

      final response = await ApiService.getWithToken(
        "/playListItem",
        token: token,
        queryParameters: {"user_id": userId, "playlist_id": item['id']},
      );

      if (response.data['status'] == true) {
        final List playlistItems = List.from(response.data['data'] ?? []);
        if (!mounted) {
          return;
        }

        if (isEdit) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EditPlaylistScreen(item: item, affirmations: playlistItems),
            ),
          );
        } else {
          if (playlistItems.isEmpty) {
            Fluttertoast.showToast(msg: "Playlist is empty");
            return;
          }
          Navigator.pushNamed(
            context,
            AppRoutes.playlistdailts,
            arguments: {
              "category": {
                ...item,
                "categories_name": item['title'],
                "caetgory_images": null,
              },
              "affirmation": playlistItems,
              "isDefault": true,
            },
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Playlist is empty");
      }
    } catch (e) {
      debugPrint("openPlaylist error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  Future<void> removeFavoriteCategory(Map<String, dynamic> item) async {
    final token = await SecureStore.getToken();
    final userId = await SecureStore.getUserId();

    try {
      await ApiService.getWithToken(
        "/removeFavoriteList",
        token: token,
        queryParameters: {"user_id": userId, "category_id": item['id']},
      );

      setState(() {
        categories = categories.where((c) => c['id'] != item['id']).toList();
      });
    } catch (e) {
      debugPrint("Remove category error: $e");
    }
  }

  /// PLAYLIST DELETE (NO EXTRA FETCH)
  Future<void> deletePlaylist(Map<String, dynamic> item) async {
    final token = await SecureStore.getToken();
    final userId = await SecureStore.getUserId();

    try {
      await ApiService.getWithToken(
        "/playListDelete",
        token: token,
        queryParameters: {"user_id": userId, "playlist_id": item['id']},
      );

      setState(() {
        playlists = playlists.where((p) => p['id'] != item['id']).toList();
      });
    } catch (e) {
      debugPrint("Delete playlist error: $e");
    }
  }

  Future<void> openLikedAffirmations() async {
    final token = await SecureStore.getToken();
    final userId = await SecureStore.getUserId();
    try {
      final response = await ApiService.getWithToken(
        "/likeAffirmations",
        token: token,
        queryParameters: {"user_id": userId},
      );

      final data = response.data["data"];
    if (mounted && data != null && data is List && data.isNotEmpty)  {
        Navigator.pushNamed(
          context,
          AppRoutes.playlistdailts,
          arguments: {
            "category": {
              "categories_name": "Liked Affirmations",
              "caetgory_images": null,
            },
            "affirmation": data,
            "isDefault": true,
          },
        );
      }else{
          Fluttertoast.showToast(msg: "No Liked affirmation!");
      }
    } catch (errr) {
  
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  /* ---------------------------------- UI ----------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      body: Stack(
        children: [
          _body(),
          if (loading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "My Library",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),

          _likedAffirmationCard(),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Playlist",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          /// Categories
          ...categories.map(
            (Map<String, dynamic> item) => CategoryTile(
              title: item['categories_name'],
              imageUrl: item['caetgory_images'] ?? '',
              onTap: () => openCategory(item),
              onMore: () => showCategoryMenu(item),
            ),
          ),

          /// Playlists
          ...playlists.map(
            (Map<String, dynamic> item) => PlaylistTile(
              title: item['title'],
              subtitle: item['description'],
              onTap: () => openPlaylist(item),
              onMore: () => showPlaylistMenu(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _likedAffirmationCard() {
    return GestureDetector(
      onTap: openLikedAffirmations,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFFD485D1), Color(0xFFB72658)],
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Affirmation liked",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "90 affirmations",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* ----------------------------- Bottom Sheets ----------------------------- */

  void showCategoryMenu(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      builder: (_) => CategoryMenuModal(
        title: item['categories_name'],
        imageUrl: item['caetgory_images'],
        isPlaylist: false,
        onListen: () {
          Navigator.pop(context);
          openCategory(item);
        },
        onLikeUnlike: () {
          Navigator.pop(context);
          removeFavoriteCategory(item);
        },
        onShare: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void showPlaylistMenu(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      builder: (_) => CategoryMenuModal(
        title: item['title'],
        isPlaylist: true,
        onListen: () {
          Navigator.pop(context);
          openPlaylist(item);
        },
        onLikeUnlike: () {
          Navigator.pop(context);
          openPlaylist(item, isEdit: true);
        },
        onShare: () {
          Navigator.pop(context);
          deletePlaylist(item);
        },
      ),
    );
  }
}
