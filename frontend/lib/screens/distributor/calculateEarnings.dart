import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, double>> calculateEarnings(
    String distributorId, DateTime startDate, DateTime endDate) async {
  Map<String, double> dailyEarnings = {};

  // 1. Consulta los pedidos completados en el rango de fechas
  final ordersSnapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('distribuidorID', isEqualTo: distributorId)
      .where('estado', isEqualTo: 'completado')
      .where('fecha', isGreaterThanOrEqualTo: startDate.toIso8601String())
      .where('fecha', isLessThanOrEqualTo: endDate.toIso8601String())
      .get();

  // 2. Procesa cada pedido
  for (var orderDoc in ordersSnapshot.docs) {
    final orderData = orderDoc.data();
    final productList = orderData['productos'] as List;
    final orderDate = DateTime.parse(orderData['fecha']);
    final dayKey = "${orderDate.year}-${orderDate.month}-${orderDate.day}";

    // Inicializa el total del día si no existe
    dailyEarnings.putIfAbsent(dayKey, () => 0);

    // 3. Calcula ganancias para cada producto en el pedido
    for (var product in productList) {
      final productId = product['id_producto'];
      final quantity = product['cantidad'];

      // Consulta el precio del producto
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        final sellingPrice = productData['precio_cliente'];
        final costPrice = productData['precio_distribuidor'];

        // Calcula la ganancia del producto
        final productEarnings = (sellingPrice - costPrice) * quantity;

        // Suma las ganancias al total del día
        dailyEarnings[dayKey] = dailyEarnings[dayKey]! + productEarnings;
      }
    }
  }

  return dailyEarnings;
}
