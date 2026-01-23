import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/screens/main/libraries/playlist_tile.dart';
import 'package:weather_app/screens/main/user_plalist/create_edit_playlist_screen.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/widgets/custom_button.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final int affirmationId;

  const AddToPlaylistSheet({super.key, required this.affirmationId});

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<AddToPlaylistSheet> {
  List<Map<String, dynamic>> playlists = [];
  bool loading = true;
  int? selectedPlaylistId;

  @override
  void initState() {
    super.initState();
    getPlaylists();
  }

  /// 🔥 YOUR API
  Future<void> getPlaylists() async {
    try {
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
        loading = false;
      });
    } catch (e) {
      loading = false;
      debugPrint("Playlist error: $e");
    }
  }

  /// SAVE API
  Future<void> saveToPlaylist() async {
    if (selectedPlaylistId == null) {
      Fluttertoast.showToast(msg: "Please select any plalist");
      return;
    }

    try {
      await ApiService.postRequest(
        "/createPlayListItem",
        body: {
          "playlist_id": selectedPlaylistId,
          "affirmation_text_id": [widget.affirmationId],
        },
        contentType: "application/json",
      );

      if (!mounted) {
        return;
      }
      Fluttertoast.showToast(msg: "Added to playlist");
      Navigator.pop(context);
    } catch (err) {
      Fluttertoast.showToast(msg: "Something went wrong!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E), // iOS style dark sheet
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            /// Drag Handle
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Add to Playlist",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Create playlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomButton(
                title: "＋ Create new playlist",
                onPress: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavePlaylistScreen(
                        isEdit: false,
                        selectedIds: [(widget.affirmationId)],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// Playlist list
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFDEBA3),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = playlists[index];
                        final isSelected = selectedPlaylistId == item['id'];

                        return PlaylistTile(
                          title: item['title'],
                          subtitle: item['description'] ?? '',
                          isSelected: isSelected,
                          isAddPlaylist: true,
                          onTap: () {
                            setState(() {
                              selectedPlaylistId = item['id'];
                            });
                          },
                          onMore: () {
                            setState(() {
                              selectedPlaylistId = item['id'];
                            });
                          },
                        );
                      },
                    ),
            ),

            /// Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDEBA3),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: selectedPlaylistId == null ? null : saveToPlaylist,
                child: const Text(
                  "Save to Playlist",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
