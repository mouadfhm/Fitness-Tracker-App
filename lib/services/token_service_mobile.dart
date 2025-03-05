// token_service_mobile.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_service_interface.dart';

// Use the same class name (TokenServiceImpl) as in the web version.
class TokenServiceImpl implements TokenService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'token');
  }
}
