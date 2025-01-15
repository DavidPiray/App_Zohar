class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000'; // Ajusta según tu configuración Docker

  // Endpoints específicos
  static const String customerService = '$baseUrl/customer-service';
  static const String productService = '$baseUrl/product-service';
  static const String securityService = '$baseUrl/security-service';
  static const String orderService = '$baseUrl/order-service';
}
