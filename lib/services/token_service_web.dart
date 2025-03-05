// token_service_web.dart
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'token_service_interface.dart';

// Use the same class name (TokenServiceImpl) in every implementation
class TokenServiceImpl implements TokenService {
  @override
  Future<void> saveToken(String token) async {
    html.window.localStorage['token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return html.window.localStorage['token'];
  }

  @override
  Future<void> deleteToken() async {
    html.window.localStorage.remove('token');
  }
}
