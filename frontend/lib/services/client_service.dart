import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../core/config/dio_config.dart';
import '../core/config/api_urls.dart';

class ClientService {
  final Dio _dio = DioClient(ApiEndpoints.securityService).dio;
  final Dio _dio2 = DioClient(ApiEndpoints.customerService).dio;
  // Método para registro
  Future<bool> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required LatLng location,
    File? photo,
  }) async {
    try {
      // Registrar el cliente en los microservicios
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
        'roles': ['cliente'],
      });

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error al registrar cliente: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error en el registro del cliente: $error');
    }
  }

  // Método para obtener datos del cliente
  Future<Map<String, dynamic>> getClientData() async {
    try {
      // Obtiene el correo de la sesión actual
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email'); // Obtiene el email de la sesión
      if (email == null || email.isEmpty) {
        throw Exception('Correo del usuario no encontrado en la sesión.');
      }

      // Busca el cliente en la base de datos por correo
      final response = await _dio2.get('/buscar', queryParameters: {
        'email': email, // Filtra por correo
      });
      if (response.statusCode == 200) {
        final List<dynamic> customers = response.data;

        // Verifica que se hayan encontrado resultados
        if (customers.isEmpty) {
          throw Exception('Cliente no encontrado.');
        }

        // Retorna el primer cliente de la lista
        return customers.first as Map<String, dynamic>;
      } else {
        throw Exception(
            'Error al obtener los datos del cliente: ${response.data}');
      }
    } on DioException catch (dioError) {
      // Manejo de errores específicos de Dio
      if (dioError.response?.statusCode == 404) {
        throw Exception('Cliente no encontrado en el servidor.');
      }
      throw Exception(
          'Error en la comunicación con el servidor: ${dioError.message}');
    } catch (error) {
      throw Exception('Error al obtener los datos del cliente: $error');
    }
  }

  // Método para actualizar datos del cliente
  Future<bool> updateClientData({
    required String clientId, // ID único del cliente
    required String name,
    required String phone,
    File? photo, // Foto opcional
  }) async {
    try {
      // Datos a enviar
      final Map<String, dynamic> data = {
        'nombre': name,
        'celular': phone,
      };

      if (photo != null) {
        final String fileName = photo.path.split('/').last;
        final formData = FormData.fromMap({
          ...data,
          'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
        });

        data.clear();
        data.addAll(formData.fields as Map<String, dynamic>);
      }

      final response = await _dio2.put('/$clientId', data: data);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Error al actualizar los datos del cliente: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al actualizar datos del cliente: $error');
    }
  }
}
