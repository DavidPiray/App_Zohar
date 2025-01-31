import 'package:flutter/material.dart';
import '../../services/orders_service.dart';
import '../../widgets/animated_alert.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/realtime_service.dart';
import 'package:intl/intl.dart';

class OrdersClientScreen extends StatefulWidget {
  const OrdersClientScreen({super.key});

  @override
  _OrdersClientScreenState createState() => _OrdersClientScreenState();
}

class _OrdersClientScreenState extends State<OrdersClientScreen> {
  final OrdersService ordersService = OrdersService();
  final RealtimeService realtimeService = RealtimeService();
  late Stream<DatabaseEvent> _realtimeStream;
  late Future<List<dynamic>> _orders;

  String clientId = 'client1';
  int currentPage = 1;
  final int itemsPerPage = 5;
  String selectedStatus = 'todos';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _listenToRealtimeUpdates();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.amber;
      case 'en progreso':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _fetchOrders() {
    setState(() {
      _orders = ordersService.getAllOrders(clientId);
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
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      orders = orders.where((order) {
        final rawTimestamp = order['fechaCreacion'];
        if (rawTimestamp == null) return false;
        final DateTime orderDate = DateTime.fromMillisecondsSinceEpoch(
            rawTimestamp['_seconds'] * 1000);
        return DateFormat('yyyy-MM-dd').format(orderDate) == formattedDate;
      }).toList();
    }
    orders.sort((a, b) {
      if (a['estado'] == 'en progreso' && b['estado'] != 'en progreso') {
        return -1;
      } else if (a['estado'] != 'en progreso' && b['estado'] == 'en progreso') {
        return 1;
      }
      final DateTime fechaA = DateTime.fromMillisecondsSinceEpoch(
          a['fechaCreacion']['_seconds'] * 1000);
      final DateTime fechaB = DateTime.fromMillisecondsSinceEpoch(
          b['fechaCreacion']['_seconds'] * 1000);
      return fechaB.compareTo(fechaA);
    });
    return orders;
  }

  void _resetFilters() {
    setState(() {
      selectedStatus = 'todos';
      selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos', style: TextStyle(fontSize: 18)),
      ),
      body: Row(
        children: [
          if (isWideScreen) _buildSidebar(),
          Expanded(
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
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No tienes pedidos disponibles.'));
                      } else {
                        final filteredOrders =
                            _filterAndSortOrders(snapshot.data!);
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
                                  final status = order['estado'];
                                  final formattedDate = ordersService
                                      .formatTimestamp(order['fechaCreacion']);
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _getStatusColor(status),
                                        child: const Icon(Icons.shopping_cart,
                                            color: Colors.white),
                                      ),
                                      title:
                                          Text('Pedido: ${order['id_pedido']}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Estado: $status'),
                                          Text('Fecha: $formattedDate'),
                                        ],
                                      ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF3B945E),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Opciones',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list, color: Colors.white),
            title: const Text('Pedidos', style: TextStyle(color: Colors.white)),
            onTap: () {},
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

   void _clearFilters() {
    setState(() {
      selectedStatus = 'todos';
      selectedDate = null;
      currentPage = 1;
    });
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                currentPage > 1 ? () => setState(() => currentPage--) : null),
        Text('Página $currentPage de $totalPages'),
        IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: currentPage < totalPages
                ? () => setState(() => currentPage++)
                : null),
      ],
    );
  }
}
