import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/dio_config.dart';
import '../core/config/api_urls.dart';

class DistributorService {
  final Dio _dio = DioClient(ApiEndpoints.orderService).dio;
  final Dio _dio2 = DioClient(ApiEndpoints.securityService).dio;
  final Dio _dioDist = DioClient(ApiEndpoints.distributorService).dio;

  // Agregar distribuidor
  Future<void> addDistributor(Map<String, String> distributor) async {
    try {
      final response = await _dioDist.post('/', data: distributor);
      if (response.statusCode != 201) {
        throw Exception(
            'Error al agregar distribuidor: ${response.statusMessage}');
      }
      try {
        // Preparar datos para mapear a "users"
        final userData = {
          'email': distributor['email'], // Usar el email proporcionado
          'password': '12345678', // Contraseña básica
          'roles': ['distribuidor'], // Rol asignado
        };
        final userResponse = await _dio2.post('/register', data: userData);
        if (userResponse.statusCode != 201) {
          throw Exception(
              'Error al mapear distribuidor a usuarios: ${userResponse.data}');
        }
      } catch (error) {
        throw Exception('Error al mapear distribuidor a usuarios: $error');
      }
    } catch (error) {
      throw Exception('Error al agregar un distribuidor: $error');
    }
  }

  // Obtener datos del distribuidor
  Future<Map<String, dynamic>> getDistributorByEmail() async {
    try {
      // Obtener el correo del distribuidor desde SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('email');

      if (email == null || email.isEmpty) {
        throw Exception('El correo no se encontró en la sesión.');
      }

      // Traer todos los distribuidores
      final response = await _dioDist.get('/');
      if (response.statusCode == 200) {
        final List<dynamic> distributors = response.data;

        // Filtrar el distribuidor que coincide con el correo
        final distributor = distributors.firstWhere(
          (distributor) => distributor['email'] == email,
          orElse: () => null,
        );
        if (distributor == null) {
          throw Exception('Distribuidor no encontrado con el correo $email.');
        }
        final idDistribuidor = distributor['id_distribuidor'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'distributorID', idDistribuidor); // Guarda el correo
        return distributor;
      } else {
        throw Exception(
            'Error al obtener la lista de distribuidores: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener datos del distribuidor: $error');
    }
  }

  // Actualizar distribuidor
  Future<bool> updateDistributor({
    required String id_distribuidor, // ID único del cliente
    String? name,
    String? phone,
    String? state,
    File? image, // Foto opcional
  }) async {
    try {
      // Datos a enviar
      final Map<String, dynamic> data = {
        if (name != null) 'nombre': name,
        if (phone != null) 'celular': phone,
        if (state != null) 'estado': state,
      };

      // Enviar solicitud PUT al servidor
      final response = await _dioDist.put('/$id_distribuidor', data: data);

      // Verificar respuesta del servidor
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error en la actualización: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al actualizar datos del Distribuidor: $error');
    }
  }

  // Eliminar distribuidor
  Future<void> deleteDistributor(String id) async {
    try {
      final response = await _dio2.delete('/$id');
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar distribuidor: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al eliminar distribuidor: $error');
    }
  }

  // Método para obtener los pedidos de un distribuidor
  Future<List<dynamic>> getOrdersByDistributor(String distribuidorID) async {
    try {
      final response = await _dio.get('/lista_pedido/$distribuidorID');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Error al obtener pedidos del distribuidor: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener pedidos del distribuidor: $error');
    }
  }

  // Método para obtener distribuidores
  Future<List<dynamic>> getDistributors() async {
    try {
      final response = await _dioDist.get('/');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al obtener distribuidores: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener distribuidores: $error');
    }
  }

  // Método para obtener el inventario de un distribuidor
  Future<List<dynamic>> getDistributorInventory(String distribuidorID) async {
    try {
      final response = await _dioDist.get('/inventario/$distribuidorID/');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Error al obtener inventario del distribuidor: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener inventario del distribuidor: $error');
    }
  }

  // Obtener datos de un distribuidor por ID
  Future<Map<String, dynamic>> getDistributorData(String distributorId) async {
    try {
      final response = await _dioDist.get('/$distributorId');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al obtener datos del distribuidor: ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error al obtener datos del distribuidor: $error');
    }
  }

  // Actualizar el estado del distribuidor en Firestore
  Future<void> updateDistributorStatus(String distributorId, String newStatus) async {
    try {
      final response = await _dioDist.put('/$distributorId', data: {'estado': newStatus});
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar estado: ${response.statusMessage}');
      }
    } catch (error) {
      throw Exception('Error al actualizar estado del distribuidor: $error');
    }
  }

}
