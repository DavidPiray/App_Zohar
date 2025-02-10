import 'package:dio/dio.dart';
import 'package:frontend/core/config/api_urls.dart';
import 'package:frontend/core/config/dio_config.dart';

class DashboardService {
  final Dio _dio = DioClient(ApiEndpoints.orderService).dio;

  // 🔹 Obtener el reporte de ventas según el filtro seleccionado
  Future<Map<String, dynamic>> getSalesReport(
      String filter) async {
    try {
      print('url $filter');
      final response = await _dio.get(filter);
      print( response.data);
      return response.data;
    } catch (e) {
      return _handleDioError(e, "Error al obtener reporte de ventas");
    }
  }

  // 🔹 Obtener el reporte de productos más vendidos
  Future<Map<String, dynamic>> getTopProductsReport(
      String filter) async {
    try {
      final response = await _dio.get("/reports/top-products/$filter");

      return response.data;
    } catch (e) {
      return _handleDioError(e, "Error al obtener productos más vendidos");
    }
  }

  // 🔹 Manejo de errores de Dio
  static Map<String, dynamic> _handleDioError(
      dynamic error, String defaultMessage) {
    if (error is DioException) {
      if (error.response != null) {
        return {"error": error.response?.data ?? defaultMessage};
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return {"error": "Tiempo de espera agotado, revisa tu conexión."};
      } else {
        return {"error": defaultMessage};
      }
    }
    return {"error": defaultMessage};
  }
}
