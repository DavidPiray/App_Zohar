import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:frontend/services/product_service.dart';
import 'package:intl/intl.dart';
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
  final ProductService productService = ProductService();
  final AuthService authService = AuthService();
  final RealtimeService realtimeService = RealtimeService();

  late Future<List<dynamic>> _orders;
  late Future<List<dynamic>> _products;
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

  // Filtros
  String selectedStatus = 'todos';
  DateTime? selectedDate;
  String? selectedProduct;

  // Paginación
  int currentPage = 1;
  final int itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchProducts();
    _listenToRealtimeUpdates();
  }

  void _fetchOrders() {
    setState(() {
      _orders = distributorService.getOrdersByDistributor(distributorId);
    });
  }

  void _fetchProducts() {
    setState(() {
      _products = productService.getProducts();
    });
  }

  void _listenToRealtimeUpdates() {
    _realtimeStream = realtimeService.listenToOrders();
    _realtimeStream.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        _fetchOrders();
      }
    });
  }

  List<dynamic> _filterAndSortOrders(List<dynamic> orders) {
    orders = orders.where((order) => order['estado'] != 'completado').toList();

    if (selectedStatus != 'todos') {
      orders =
          orders.where((order) => order['estado'] == selectedStatus).toList();
    }
    if (selectedDate != null) {
      final formattedSelectedDate =
          DateFormat('yyyy-MM-dd').format(selectedDate!);
      orders = orders.where((order) {
        final rawTimestamp = order['fechaCreacion'];

        if (rawTimestamp == null) return false;

        final DateTime orderDate = DateTime.fromMillisecondsSinceEpoch(
            rawTimestamp['_seconds'] * 1000);

        final formattedOrderDate = DateFormat('yyyy-MM-dd').format(orderDate);
        return formattedOrderDate == formattedSelectedDate;
      }).toList();
    }
    if (selectedProduct != null) {
      orders = orders.where((order) {
        final products = order['productos'] as List<dynamic>? ?? [];
        return products.any((p) => p['id_producto'] == selectedProduct);
      }).toList();
    }

    orders.sort((a, b) => (b['fecha'] ?? '').compareTo(a['fecha'] ?? ''));
    return orders;
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = 'todos';
      selectedDate = null;
      selectedProduct = null;
      currentPage = 1;
    });
  }

  void _logout(BuildContext context) async {
    await authService.logout();
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

  void _goToReports() {
    Navigator.pushNamed(
      context,
      '/reporte-distribuidor',
      arguments: 'dist1',
    );
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
          leading: const Icon(Icons.report, color: Colors.white),
          title: const Text('Reportes', style: TextStyle(color: Colors.white)),
          onTap: _goToReports,
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
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
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
                  final filteredOrders = _filterAndSortOrders(snapshot.data!);
                  final totalPages =
                      (filteredOrders.length / itemsPerPage).ceil();
                  final paginatedOrders = filteredOrders
                      .skip((currentPage - 1) * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: paginatedOrders.length,
                          itemBuilder: (context, index) {
                            final order = paginatedOrders[index];
                            final clientId = order['clienteID'] ??
                                'ID de cliente no disponible';
                            final orderId = order['id_pedido'] ??
                                'ID de pedido no disponible';
                            final orderStatus =
                                order['estado'] ?? 'Desconocido';
                            final productsList =
                                order['productos'] as List<dynamic>? ?? [];

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
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        '${(currentPage - 1) * itemsPerPage + index + 1}.',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      backgroundColor:
                                          statusColors[orderStatus] ??
                                              Colors.grey,
                                      child: const Icon(Icons.shopping_cart,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                title: Text('Cliente: $clientId'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Productos: $products'),
                                    Text('Estado: $orderStatus'),
                                    /* Text('IdOrder: $orderId'), */
                                  ],
                                ),
                                trailing: orderStatuses.containsKey(orderStatus)
                                    ? ElevatedButton(
                                        onPressed: () => _updateOrderStatus(
                                            orderId, orderStatus),
                                        child: Text(orderStatus == 'pendiente'
                                            ? 'Entregar'
                                            : 'Completado'),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      _buildPaginationControls(totalPages),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(
                        value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(
                        value: 'en progreso', child: Text('En progreso')),
                    DropdownMenuItem(
                        value: 'cancelado', child: Text('Cancelado')),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : 'Selecciona una fecha',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _products,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final products = snapshot.data!;
                    return DropdownButton<String>(
                      value: selectedProduct,
                      onChanged: (value) {
                        setState(() {
                          selectedProduct = value;
                        });
                      },
                      hint: const Text('Selecciona un producto'),
                      items: products
                          .map<DropdownMenuItem<String>>((product) =>
                              DropdownMenuItem<String>(
                                value: product['id_producto'],
                                child: Text(
                                    product['nombre_producto'] ?? 'Sin nombre'),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _clearFilters,
              child: const Text('Limpiar filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
        ),
        Text('Página $currentPage de $totalPages'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }
}
