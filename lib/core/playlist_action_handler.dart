import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weather_app/core/helper.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/screens/main/libraries/category_menu_modal.dart';
import 'package:weather_app/services/api_service.dart';

class PlaylistActionHandler {
  static Future<Map<String, dynamic>?> openActionModal({
    required BuildContext context,
    required Map<String, dynamic> item,
    List<dynamic>? affirmations,
  }) {
    final bool isPlaylist = item.containsKey('title');
    final bool isFav = item['is_favorite'] == 1 || item['is_favorite'] == true;

    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      builder: (_) => CategoryMenuModal(
        title: isPlaylist ? item['title'] : item['categories_name'],
        isPlaylist: isPlaylist,
        isFav: isFav,

        /// ▶ PLAY
        onListen: () {
          Navigator.pop(context, {"action": "play"});
        },

        onLikeUnlike: () async {
          if (isPlaylist) {
            Navigator.pop(context, {"action": "edit_playlist"});
            return;
          }
          await CommonHelper.toggleFavorite(
            item: item,
            currentValue: item['is_favorite'] ?? false,
          );

          // ignore: use_build_context_synchronously
          Navigator.pop(context, {
            "action": "favorite",
            "value": !(item['is_favorite'] ?? false),
          });
        },

        onShare: item.containsKey('title')
            ? () async {
                await _delete(context, item);

                // ignore: use_build_context_synchronously
                Navigator.pop(context, {"action": "delete"});
              }
            : () {},
      ),
    );
  }

  static Future<void> _delete(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    try {
      final token = await SecureStore.getToken();
      final userId = await SecureStore.getUserId();

      await ApiService.getWithToken(
        "/playListDelete",
        token: token,
        queryParameters: {"user_id": userId, "playlist_id": item['id']},
      );

      Fluttertoast.showToast(msg: "Playlist deleted");
    } catch (e) {
      Fluttertoast.showToast(msg: "Delete failed");
    }
  }
}
