import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/services/api_service.dart';

class CommonHelper {
  static Future<bool> toggleFavorite({
    required Map<String, dynamic> item,
    required bool currentValue,
    bool isAffimation = false,
  }) async {
    try {
      final token = await SecureStore.getToken();
      final userId = await SecureStore.getUserId();

      if (token == null || userId == null) {
        return currentValue;
      }

      final bool isPlaylist = item.containsKey('title');
      final payload = {
        'user_id': userId,
        if (!isPlaylist && !isAffimation) 'category_id': item['id'],
        if (isAffimation) "affirmation_text_id": item["id"],
      };

      if (!currentValue) {
        await ApiService.postWithToken(
          '/createFavoriteList',
          body: payload,
          token: token,
        );
        Fluttertoast.showToast(msg: "Added to favorites");
        return true;
      } else {
        await ApiService.getWithToken(
          '/removeFavoriteList',
          queryParameters: {
            'user_id': userId,
            if (isAffimation) "affirmation_text_id": item["id"],
            if (!isPlaylist && !isAffimation) 'category_id': item['id'],
          },
          token: token,
        );

        Fluttertoast.showToast(msg: "Removed from favorites");
        return false;
      }
    } catch (e) {
      debugPrint("toggleFavorite error: $e");
      Fluttertoast.showToast(msg: "Favorite action failed");
      return currentValue;
    }
  }
}
