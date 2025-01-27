import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/distributor_service.dart';
import '../../services/orders_service.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_service.dart';
import '../../widgets/animated_alert.dart';

class DistributorScreen extends StatefulWidget {
  const DistributorScreen({super.key});

  @override
  State<DistributorScreen> createState() => _DistributorScreenState();
}

class _DistributorScreenState extends State<DistributorScreen> {
  final DistributorService distributorService = DistributorService();
  final OrdersService ordersService = OrdersService();
  final AuthService authService = AuthService();
  final RealtimeService realtimeService = RealtimeService();

  late Future<List<dynamic>> _orders;
  late Stream<DatabaseEvent> _realtimeStream;

  Map<String, String> orderStatuses = {
    'pendiente': 'en progreso',
    'en progreso': 'completado'
  };
  Map<String, Color> statusColors = {
    'pendiente': Colors.grey,
    'en progreso': Colors.amber,
    'completado': Colors.green,
    'cancelado': Colors.red,
  };
  String distributorId = "dist1"; // Distribuidor asignado (temporal)
  bool isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _listenToRealtimeUpdates();
  }

  void _fetchOrders() {
    setState(() {
      _orders = distributorService.getOrdersByDistributor(distributorId);
    });
  }

  void _listenToRealtimeUpdates() {
    _realtimeStream = realtimeService
        .listenToOrders(); // Escucha los cambios en todos los pedidos
    _realtimeStream.listen((event) {
      final data = event.snapshot.value;
      // Si hay cambios en Firebase, vuelve a cargar los pedidos
      if (data != null) {
        _fetchOrders();
      }
    });
  }

  void _logout(BuildContext context) async {
    await authService.logout();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  void _updateOrderStatus(String orderId, String currentStatus) async {
    try {
      String? nextStatus = orderStatuses[currentStatus];
      if (nextStatus == null) return;
      await ordersService.updateOrderStatus(orderId, nextStatus);

      AnimatedAlert.show(
        context,
        'Éxito',
        'El pedido se ha actualizado a "$nextStatus".',
        type: AnimatedAlertType.success,
      );
      _fetchOrders();
    } catch (error) {
      AnimatedAlert.show(
        context,
        'Error',
        'No se pudo actualizar el pedido: $error',
        type: AnimatedAlertType.error,
      );
    }
  }

  void _goToInventory() {
    Navigator.pushNamed(context, '/inventory_screen');
  }

  void _goToProfile() {
    Navigator.pushNamed(context, '/profileDistributor');
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuidor'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                if (!isWideScreen) {
                  Scaffold.of(context).openDrawer();
                } else {
                  _toggleSidebar();
                }
              },
            );
          },
        ),
      ),
      drawer: !isWideScreen
          ? Drawer(
              child: Container(
                color: const Color(0xFF3B945E),
                child: _buildSidebarContent(),
              ),
            )
          : null,
      body: Row(
        children: [
          if (isWideScreen && isSidebarVisible) _buildSidebar(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF3B945E),
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Opciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.white),
          title: const Text('Perfil', style: TextStyle(color: Colors.white)),
          onTap: _goToProfile,
        ),
        ListTile(
          leading: const Icon(Icons.inventory, color: Colors.white),
          title:
              const Text('Inventario', style: TextStyle(color: Colors.white)),
          onTap: _goToInventory,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Salir', style: TextStyle(color: Colors.white)),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildOrdersList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<dynamic>>(
        future: _orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tienes pedidos asignados.'),
            );
          } else {
            final orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final clientId =
                    order['clienteID'] ?? 'ID de cliente no disponible';
                final orderId =
                    order['id_pedido'] ?? 'ID de pedido no disponible';
                final orderStatus = order['estado'] ?? 'Desconocido';
                final productsList = order['productos'] as List<dynamic>? ?? [];

                final products = productsList.isNotEmpty
                    ? productsList
                        .map((p) =>
                            '${p['id_producto'] ?? 'Producto desconocido'} (x${p['cantidad'] ?? 0})')
                        .join(', ')
                    : 'No hay productos';
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColors[orderStatus] ?? Colors.grey,
                      child:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                    title: Text('Cliente: $clientId'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Productos: $products'),
                        Text('Estado: $orderStatus'),
                        Text('IdOrder: $orderId'),
                      ],
                    ),
                    trailing: orderStatuses.containsKey(orderStatus)
                        ? ElevatedButton(
                            onPressed: () =>
                                _updateOrderStatus(orderId, orderStatus),
                            child: Text(orderStatus == 'pendiente'
                                ? 'Entregar'
                                : 'Completado'),
                          )
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
