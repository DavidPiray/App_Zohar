import 'package:dio/dio.dart';
import 'token_manager.dart';

class DioClient {
  final Dio _dio;

  // Constructor que recibe un Base URL dinámico
  DioClient(String baseUrl)
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl, // Base URL dinámico
          connectTimeout: const Duration(milliseconds: 5000),
          receiveTimeout: const Duration(milliseconds: 3000),
          headers: {'Content-Type': 'application/json'},
        )) {
    // Agregar el interceptor para manejar tokens y errores
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Omitir el token en rutas públicas
        if (options.path.contains('/register')|| options.path.contains('/clientes')) {
          return handler.next(options);
        }
        // Obtener el token almacenado
        final token = await TokenManager.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Manejar respuestas globalmente si es necesario
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Manejar errores globalmente si es necesario
        return handler.next(e);
      },
    ));
  }

  // Getter para acceder a la instancia de Dio
  Dio get dio => _dio;
}
