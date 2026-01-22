import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage();

  static const userId = "USER_ID";
  static const token = 'TOKEN';

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
}
