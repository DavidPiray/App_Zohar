import 'package:dio/dio.dart';
import '../core/config/dio_config.dart';
import '../core/config/api_urls.dart';

class ProductService {
  final Dio _dio = DioClient(ApiEndpoints.productService).dio;

  // Método para obtener productos
  Future<List<dynamic>> getProducts() async {
    try {
      // Realizar solicitud
      final response = await _dio.get('/');
      if (response.statusCode == 200) {
        final List<dynamic> products = response.data;
        // Validar la estructura de los productos
        for (var product in products) {
          if (product['nombre'] == null || product['precio_cliente'] == null) {
            throw Exception('Datos del producto incompletos o incorrectos');
          }
        }
        return products;
      } else {
        throw Exception('Error al obtener productos: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al obtener productos: $error');
    }
  }

  // Método para agregar producto
  Future<void> addProduct(Map<String, dynamic> product) async {
    try {
      final response = await _dio.post('/', data: product);
      if (response.statusCode == 201) {
        print('Producto agregado exitosamente');
      } else {
        throw Exception('Error al agregar producto: ${response.data}');
      }
    } catch (error) {
      print('Error al agregar producto: $error');
      throw Exception('Error al agregar producto: $error');
    }
  }

  // Actualizar producto
  Future<void> updateProduct(
      String id, Map<String, dynamic> updatedData) async {
    try {
      final response = await _dio.put('/$id', data: updatedData);
      if (response.statusCode == 200) {
        print('Producto actualizado exitosamente');
      } else {
        throw Exception('Error al actualizar producto: ${response.data}');
      }
    } catch (error) {
      print('Error en la actualización del producto: $error');
      throw Exception('Error al actualizar producto: $error');
    }
  }

  // Eliminar producto
  Future<void> deleteProduct(String id) async {
    try {
      // Realizar la solicitud DELETE al endpoint correspondiente
      final response = await _dio.delete('/$id');

      if (response.statusCode == 200) {
        print('Producto eliminado exitosamente');
      } else {
        throw Exception('Error al eliminar producto: ${response.data}');
      }
    } catch (error) {
      print('Error en la eliminación del producto: $error');
      throw Exception('Error al eliminar producto: $error');
    }
  }

  
}
