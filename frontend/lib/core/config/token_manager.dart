import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _key = 'auth_token';

  // Guardar el token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  // Obtener el token
  static Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  // Eliminar el token
  static Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}
