import 'package:firebase_database/firebase_database.dart';

class RealtimeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  FirebaseDatabase get database => _database;

  // Escuchar cambios en los pedidos
  Stream<DatabaseEvent> listenToOrders() {
    return _database.ref('pedido').onValue;
  }

  // Escuchar cambios específicos en un pedido
  Stream<DatabaseEvent> listenToOrder(String orderId) {
    return _database.ref('pedido/$orderId').onValue;
  }

  // Escuchar cambios en el inventario
  Stream<DatabaseEvent> listenToInventory(String distributorId) {
    return _database.ref('distribuidor/$distributorId/inventario').onValue;
  }

  Stream<DatabaseEvent> listenToStatus(String orderId) {
    return _database.ref('pedido/$orderId').onValue;
  }
}
