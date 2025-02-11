class ApiEndpoints {
  static const String baseUrl = 'http://172.21.221.29:';

  // Endpoints específicos
  static const String securityService = '$baseUrl 3001/auth';
  static const String customerService = '$baseUrl 3002/clientes';
  static const String zoneService = '$baseUrl 3003/zonas';
  static const String distributorService = '$baseUrl 3004/distribuidor';
  static const String orderService = '$baseUrl 3005/pedidos';
  static const String productService = '$baseUrl 3006/productos';
}
