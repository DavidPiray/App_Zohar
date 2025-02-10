import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/config/dio_config.dart';
import '../core/config/token_manager.dart';
import '../core/config/api_urls.dart';

// Clase para autenticación
class AuthService {
  final Dio _dio = DioClient(ApiEndpoints.securityService).dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para Login
  Future<String> login(String email, String password) async {
    try {
      /* // 1️⃣ Autenticación en Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("Error al autenticar en Firebase.");
      }

      // 2️⃣ Verificar si el usuario existe en Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(email).get();

      if (!userDoc.exists) {
        await _auth
            .signOut(); // Cerrar sesión en Firebase si no está en Firestore
        throw Exception("Usuario no registrado en Firestore.");
      } */

      // 3️⃣ Enviar credenciales al backend
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final String token = response.data['token'];
        if (token.isEmpty) {
          throw Exception('El servidor no devolvió un token válido.');
        }

        // 4️⃣ Guardar el token en el almacenamiento local
        await TokenManager.saveToken(token);

        // 5️⃣ Guardar el correo en la sesión actual
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        print("✅ Login exitoso: Usuario autenticado en Firebase y Firestore.");
        return token;
      } else {
        throw Exception('Error del servidor: ${response.statusMessage}');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception("Error de autenticación en Firebase: ${e.message}");
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
      // 1️⃣ Cerrar sesión en Firebase Authentication
      await _auth.signOut();
      print("✅ Sesión cerrada en Firebase Auth.");
      // 3️⃣ Eliminar token local
      await TokenManager.clearToken();
      print("✅ Token eliminado localmente.");
      // 4️⃣ Limpiar datos de sesión en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      print("✅ SharedPreferences limpiado.");
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
      print('Token: $token');
      // Obtener usuario actual de Firebase
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado en Firebase.');
      }
      // Reautenticación del usuario con su contraseña actual
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword, // 🔥 Usa la contraseña anterior para validar
      );
      await user.reauthenticateWithCredential(credential);
// 🔹 1. Actualizar contraseña en Firebase Authentication
      await user.updatePassword(newPassword);
      print("✅ Contraseña cambiada en Firebase Authentiwcation");

      // Crear la solicitud para Actualizar en Firestore
      final response = await _dio.put(
        '/users/password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'email': email,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      // 🔹 Imprimir la respuesta del backend para verificar si devuelve error
      print("🔹 Respuesta del backend: ${response.data}");

      if (response.statusCode == 200) {
        return true; // Contraseña actualizada con éxito
      } else {
        await user.updatePassword(oldPassword);
        print('Error del servidor: ${response.statusMessage ?? 'Desconocido'}');
        throw Exception(
            'Error en el servidor al actualizar la contraseña, por favor intente nuevamente.');
      }
    } on FirebaseAuthException catch (e) {
      print('Error de autenticación en Firebase: ${e.message}');
      throw Exception(
          'No se ha podido autenticar su usuario, por favor ingrese nuevamente');
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
  Future<void> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Usuario registrado exitosamente: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      print("Error al registrar el usuario: ${e.message}");
    }
  }
}
