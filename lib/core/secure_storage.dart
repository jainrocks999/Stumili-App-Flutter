import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage();

  static const userId = "USER_ID";
  static const token = 'TOKEN';
  static const _fcmKey = "fcm_token";
  static const _kOneSignalId = "onesignal_id";

  // Save user info
  static Future<void> saveUser(String userIdValue, String tokenValue) async {
    await _storage.write(key: userId, value: userIdValue);
    await _storage.write(key: token, value: tokenValue);
  }

  // Get token
  static Future<String?> getToken() async {
    return _storage.read(key: token);
  }

  // Get userId
  static Future<String?> getUserId() async {
    return _storage.read(key: userId);
  }

  // Logout
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<void> saveFcmToken(String token) async {
    // flutter_secure_storage / shared_preferences jo use kar rahe ho usme save
    await _storage.write(key: _fcmKey, value: token);
  }

  static Future<String?> getFcmToken() async {
    return await _storage.read(key: _fcmKey);
  }

  static Future<void> saveOneSignalId(String id) async {
    // apne secure storage logic ke hisaab se
    await _storage.write(key: _kOneSignalId, value: id);
  }

  static Future<String?> getOneSignalId() async {
    return _storage.read(key: _kOneSignalId);
  }
}
