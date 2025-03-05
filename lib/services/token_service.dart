// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter

class TokenService {
  // Secure storage for mobile (Android/iOS/desktop)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Save token (mobile → secure storage, web → localStorage)
  static Future<void> saveToken(String token) async {
    // if (kIsWeb) {
    //   html.window.localStorage['token'] = token;
    // } else {
    await _secureStorage.write(key: 'token', value: token);
    // }
  }

  /// Read token (returns null if no token found)
  static Future<String?> getToken() async {
    // if (kIsWeb) {
    //   return html.window.localStorage['token'];
    // } else {
    return await _secureStorage.read(key: 'token');
    // }
  }

  /// Delete token (logout)
  static Future<void> deleteToken() async {
    // if (kIsWeb) {
    //   html.window.localStorage.remove('token');
    // } else {
    await _secureStorage.delete(key: 'token');
    // }
  }
}
