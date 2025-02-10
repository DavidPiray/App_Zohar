import 'package:dio/dio.dart';
import '../core/config/dio_config.dart';
import '../core/config/api_urls.dart';
import 'package:intl/intl.dart';

class OrdersService {
  final Dio _dio = DioClient(ApiEndpoints.orderService).dio;

  // Método para obtener pedidos
  Future<List<dynamic>> getOrders() async {
    try {
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        return (response.data);
      } else {
        throw Exception(
            'Error al obtener el historial de pedidos: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener productos: $error');
    }
  }

  // Método para obtener pedidos por id cliente
  Future<List<dynamic>> getAllOrders(String clientId) async {
    try {
      // Trae todos los pedidos
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        final orders = response.data as List<dynamic>;

        // Filtra los pedidos que coinciden con el cliente actual
        final filteredOrders =
            orders.where((order) => order['clienteID'] == clientId).toList();
        return filteredOrders;
      } else {
        throw Exception('Error al obtener los pedidos: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener pedidos: $error');
    }
  }

  // Método para crear pedidos
  Future<void> createOrder(Map<String, dynamic> orderDetails) async {
    try {
      final response = await _dio.post('/', data: orderDetails);
      if (response.statusCode != 201) {
        throw Exception('Error al crear el pedido: ${response.data}');
      }
    } catch (error) {
      print('Error al agregar producto: $error');
      throw Exception('Error al agregar producto: $error');
    }
  }

  // Formatear el tiempo
  String formatTimestamp(Map<String, dynamic> timestamp) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
    return DateFormat('dd/MM/yyyy hh:mm a')
        .format(date); // Cambia el formato según tu preferencia
  }

  // 🔹 Obtener pedidos filtrados por día, semana, mes o año
  Future<List<dynamic>> getOrdersByFilter(String filter, DateTime date) async {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final week = ((date.day - 1) ~/ 7 + 1).toString(); // Semana del mes

    String endpoint = "/ventas/dia/$year-$month-$day";

    switch (filter) {
      case "semana":
        endpoint = "/ventas/semana/$year/$week";
        break;
      case "mes":
        endpoint = "/ventas/mes/$year/$month";
        break;
      case "anio":
        endpoint = "/ventas/anio/$year";
        break;
    }

    try {
      final response = await _dio.get(endpoint);
      return response.data['pedidos'] ?? [];
    } catch (e) {
      print("Error al obtener pedidos: $e");
      return [];
    }
  }

  // Listener
  // Método para actualizar estado del pedido
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      // Envía el estado dentro de un objeto JSON
      final response = await _dio.put(
        '/estado_pedido/$orderId/',
        data: {'estado': status}, // Aquí se envía un JSON con la clave esperada
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al actualizar el estado del pedido: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al actualizar el estado del pedido: $error');
    }
  }
}
