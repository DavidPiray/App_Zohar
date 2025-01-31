import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/dio_config.dart';
import '../core/config/token_manager.dart';
import '../core/config/api_urls.dart';

// Clase para autenticación
class AuthService {
  final Dio _dio = DioClient(ApiEndpoints.securityService).dio;

  // Método para Login
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        final String token = response.data['token'];
        if (token.isEmpty) {
          throw Exception('El servidor no devolvió un token válido.');
        }
        await TokenManager.saveToken(token);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email); // Guarda el correo

        return token;
      } else {
        throw Exception('Error del servidor: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Error desconocido';
        throw Exception('Error del servidor: $errorMessage');
      } else {
        throw Exception('Error de red: Servidor no disponible actualmente');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  // Método para
  Future<void> logout() async {
    try {
      // Eliminar token local
      await TokenManager.clearToken();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Método para actualizar la contraseña
  Future<bool> updatePassword({
    required String clientId,
    required String oldPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      final String? token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No hay un token válido. Inicia sesión nuevamente.');
      }

      final response = await _dio.put(
        '/users/$clientId/password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'email': email,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return true; // Contraseña actualizada con éxito
      } else {
        throw Exception(
            'Error del servidor: ${response.statusMessage ?? 'Desconocido'}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Error desconocido';
        throw Exception('Error del servidor: $errorMessage');
      } else {
        throw Exception('Error de red: Servidor no disponible actualmente');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
