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

  // Escuchar cambios en el estado de un pedido
  Stream<DatabaseEvent> listenToStatus(String orderId) {
    return _database.ref('pedido/$orderId').onValue;
  }

  // LÓGICA DE UBICACIÓN
  // Escuchar cambios en la ubicación del distribuidor
  Stream<DatabaseEvent> listenToDistributorLocation(String orderId) {
    return _database.ref('ubicaciones/$orderId').onValue;
  }

  // Guardar ubicación del distribuidor cuando el pedido está en progreso
  Future<void> saveDistributorLocation(
      String orderId, double lat, double lng) async {
    await _database.ref('ubicaciones/$orderId').set({
      'latitude': lat,
      'longitude': lng,
    });
  }

  // Guardar ubicación del distribuidor
  Future<void> saveDistributorPosition(
      String distribuidorID, double lat, double lng) async {
    await _database.ref('distribuidores/$distribuidorID').set({
      'latitude': lat,
      'longitude': lng,
    });
  }

  // Eliminar la ubicación del distribuidor
  Future<void> removeDistributorPosition(String distribuidorID) async {
    await _database.ref('distribuidores/$distribuidorID').remove();
  }

  // Actualizar la ubicación del distribuidor en Firebase Realtime Database
  Future<void> updateDistributorPosition(
      String distribuidorID, double lat, double lng) async {
    await _database.ref('distribuidores/$distribuidorID').update({
      'latitude': lat,
      'longitude': lng,
    });
    print("📍 Ubicación actualizada en Firebase: lat=$lat, lng=$lng");
  }

  // Actualizar ubicación en tiempo real
  Future<void> updateDistributorLocation(
      String orderId, double lat, double lng) async {
    await _database.ref('ubicaciones/$orderId').update({
      'latitude': lat,
      'longitude': lng,
    });
  }

  // Eliminar la ubicación del distribuidor cuando el pedido se completa
  Future<void> removeDistributorLocation(String orderId) async {
    await _database.ref('ubicaciones/$orderId').remove();
  }
}
