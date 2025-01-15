import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Métodos para manejo de tokens
class TokenManager {
  static const String _authTokenKey = 'auth_token';

  // Guardar el token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  // Obtener el token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Eliminar el token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }
}

class ApiService {
  final String baseUrl = 'http://localhost'; // Cambia según tu entorno

  // Método para registro
  Future<bool> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required LatLng location,
    File? photo,
  }) async {
    print("datos: ");
    print(name);
    print(email);
    print(password);
    print(phone);
    print(location);
    final url = Uri.parse(
        '$baseUrl:3001/api/auth/register'); // Cambia el endpoint si es necesario
    final token = await TokenManager.getToken();

    try {
      // Registrar el cliente en los microservicios
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'roles': ['cliente'],
        }),
      );

      if (response.statusCode == 201) {
        print('Cliente registrado exitosamente');
        return true;
      } else {
        print('Error al registrar cliente: ${response.body}');
        throw Exception('Error al registrar cliente: ${response.body}');
      }
    } catch (error) {
      print('Error en el registro del cliente: $error');
      throw Exception('Error en el registro del cliente: $error');
    }
  }

  // Método para Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl:3001/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('token') && data['token'] is String) {
          final String token = data['token'];
          await TokenManager.saveToken(token); // Guardar el token localmente
          print('Token guardado: $token');
          return data; // Retornar los datos
        } else {
          throw Exception(
              'Respuesta inesperada: Falta el token en la respuesta');
        }
      } else {
        throw Exception('Error al iniciar sesión: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de red o servidor: $e');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await TokenManager.clearToken(); // Eliminar el token localmente
    print('Token eliminado');
  }

  // Método de productos
  Future<List<dynamic>> getProducts() async {
    // Obtén el token almacenado usando TokenManager
    final token = await TokenManager.getToken();
    print('Token actual: $token'); // Verifica el token

    if (token == null || token.isEmpty) {
      throw Exception(
          'No se encontró un token válido. Por favor, inicia sesión.');
    }

    final url = Uri.parse('$baseUrl:3006/api/productos');
    print('Realizando solicitud a $url'); // Verifica la URL

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Respuesta del servidor: ${response.body}'); // Verifica la respuesta

    if (response.statusCode == 200) {
      final List<dynamic> products = jsonDecode(response.body);

      // Validar la estructura de los productos
      for (var product in products) {
        if (product['nombre'] == null || product['precio_cliente'] == null) {
          throw Exception('Datos del producto incompletos o incorrectos');
        }
      }

      return products;
    } else {
      throw Exception('Error al obtener productos: ${response.body}');
    }
  }

  // Método para obtener pedidos
  Future<List<dynamic>> getOrders() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }

    final url =
        Uri.parse('$baseUrl:3002/api/orders'); // Ajusta la URL según tu API
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Error al obtener el historial de pedidos: ${response.body}');
    }
  }

// Agregar producto
  Future<void> addProduct(Map<String, String> product) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl:3006/api/productos');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar producto: ${response.body}');
    }
  }

// Actualizar producto
  Future<void> updateProduct(String id, Map<String, String> updatedData) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl:3006/api/productos/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar producto: ${response.body}');
    }
  }

// Eliminar producto
  Future<void> deleteProduct(String id) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl:3006/api/productos/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar producto: ${response.body}');
    }
  }

  // Método para obtener datos del cliente
  Future<Map<String, dynamic>> getClientData() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }

    final url = Uri.parse(
        '$baseUrl:3002/api/clients/me'); // Endpoint para obtener datos del cliente
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Error al obtener los datos del cliente: ${response.body}');
    }
  }

  // Método para crear un pedido
  Future<void> createOrder(Map<String, dynamic> orderDetails) async {
    final url = Uri.parse('$baseUrl:3005/api/pedido');
    final token = await TokenManager.getToken();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(orderDetails),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al crear el pedido: ${response.body}');
    }

    print('Pedido creado con éxito');
  }

  // metodos para distribuidores
  Future<List<dynamic>> getOrdersByDistributor(String id) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }
    final url = Uri.parse('$baseUrl:3005/api/pedido/$id/pedido');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    // Imprimir respuesta para verificar
    print('Respuesta de la API: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener pedidos del distribuidor');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }
    final url = Uri.parse('$baseUrl:3005/api/pedido/$orderId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'estado': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el estado del pedido');
    }
  }

  Future<List<dynamic>> getDistributorInventory(String distribuidorID) async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl:3004/api/distribuidor/$distribuidorID/inventario/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener inventario del distribuidor');
    }
  }

  // Método para obtener distribuidores
  Future<List<dynamic>> getDistributors() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }
    final url = Uri.parse('$baseUrl:3004/api/distribuidor');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener distribuidores: ${response.body}');
    }
  }

  // Metodo para agregar distribuidor.
  // Agregar distribuidor
  Future<void> addDistributor(Map<String, String> distributor) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token no encontrado. Por favor, inicia sesión.');
    }
    final url = Uri.parse('$baseUrl:3004/api/distribuidor');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(distributor),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al agregar distribuidor: ${response.body}');
    }

    // Preparar datos para mapear a "users"
    final userData = {
      'email': distributor['email'], // Usar el email proporcionado
      'password': '12345678', // Contraseña básica
      'roles': ['distribuidor'], // Rol asignado
    };

    // Endpoint para agregar a users
    final usersUrl = Uri.parse(
        '$baseUrl:3001/api/auth/register'); // Endpoint de auth para registro

    // Intentar agregar a users
    final userResponse = await http.post(
      usersUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (userResponse.statusCode != 201) {
      throw Exception(
          'Error al mapear distribuidor a usuarios: ${userResponse.body}');
    }
  }

  // Actualizar distribuidor
  Future<void> updateDistributor(
      String id, Map<String, String> updatedData) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl:3004/api/distribuidor/$id');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar distribuidor: ${response.body}');
    }
  }

// Eliminar distribuidor
  Future<void> deleteDistributor(String id) async {
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl:3004/api/distribuidor/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar distribuidor: ${response.body}');
    }
  }
}
