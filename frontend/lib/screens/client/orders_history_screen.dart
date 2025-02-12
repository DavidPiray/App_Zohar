import 'package:flutter/material.dart';
import 'package:frontend/services/client_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../core/styles/colors.dart';
import '../../services/orders_service.dart';
//import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';
import '../../services/realtime_service.dart';

class OrdersClientScreen extends StatefulWidget {
  const OrdersClientScreen({super.key});

  @override
  _OrdersClientScreenState createState() => _OrdersClientScreenState();
}

//variables de servicios
class _OrdersClientScreenState extends State<OrdersClientScreen> {
  final OrdersService ordersService = OrdersService();
  final ClientService clientService = ClientService();
  final RealtimeService realtimeService = RealtimeService();

  //variables globales
  late Stream<DatabaseEvent> _realtimeStream;
  late Future<List<dynamic>> _orders = Future.value([]);
  late String _clientID = '';
  int currentPage = 1;
  final int itemsPerPage = 5;
  String selectedStatus = 'todos';
  DateTime? selectedDate;

  void _initializeData() async {
    await _getClient(); // Asegura que el cliente se cargue antes de continuar
    if (_clientID.isNotEmpty) {
      _fetchOrders();
      _listenToRealtimeUpdates();
    }
  }

  Future<void> _getClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clienteID = prefs.getString('clienteID');
    setState(() {
      _clientID = clienteID ?? ''; // Evita errores si es null
    });
  }

// Constructor -> Inicio de página
  @override
  void initState() {
    super.initState();
    _orders = Future.value([]);
    _initializeData();
  }

  // Constructor de la Página Inicial
  @override
  Widget build(BuildContext context) {
    //final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Wrapper(
      userRole: "cliente", // 🔹 PASA EL ROL DEL USUARIO
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      color: AppColors.back,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            FutureBuilder<List<dynamic>>(
                              future: _orders,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text(
                                          'No tienes pedidos disponibles.'));
                                } else {
                                  final filteredOrders =
                                      _filterAndSortOrders(snapshot.data!);
                                  final totalPages =
                                      (filteredOrders.length / itemsPerPage)
                                          .ceil();
                                  final paginatedOrders = filteredOrders
                                      .skip((currentPage - 1) * itemsPerPage)
                                      .take(itemsPerPage)
                                      .toList();

                                  return Expanded(
                                    // 🔹 Solución: Expandir la lista dentro de un área definida
                                    child: SingleChildScrollView(
                                      // 🔹 Permitir desplazamiento si hay muchos pedidos
                                      child: Column(
                                        children: [
                                          _buildFilters(),
                                          ListView.builder(
                                            shrinkWrap:
                                                true, // 🔹 Importante: evita que tome altura infinita
                                            physics:
                                                const NeverScrollableScrollPhysics(), // 🔹 Deshabilita scroll interno
                                            itemCount: paginatedOrders.length,
                                            itemBuilder: (context, index) {
                                              final order =
                                                  paginatedOrders[index];
                                              final status = order['estado'];
                                              final formattedDate =
                                                  ordersService.formatTimestamp(
                                                      order['fechaCreacion']);
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor:
                                                        _getStatusColor(status),
                                                    child: const Icon(
                                                        Icons.shopping_cart,
                                                        color: Colors.white),
                                                  ),
                                                  title: Text(
                                                      'Pedido: ${order['id_pedido']}'),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Estado: $status'),
                                                      Text(
                                                          'Fecha: $formattedDate'),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildPaginationControls(totalPages),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Colores para el estado
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

  // Obtener los pedidos del cliente
  void _fetchOrders() {
    setState(() {
      _orders = ordersService.getAllOrders(_clientID);
    });
  }

  // Escuchar la actualización del estado en tiempo real
  void _listenToRealtimeUpdates() {
    _realtimeStream = realtimeService.listenToOrders();
    _realtimeStream.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        _fetchOrders();
      }
    });
  }

  // Filtrado y ordenado para los pedidos
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

  // Construcción de filtros
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          SizedBox(
            width: 150, // Ajusta el tamaño según sea necesario
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(
                    value: 'en progreso', child: Text('En progreso')),
                DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blue),
            onPressed: () async {
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
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: _clearFilters,
          ),
        ],
      ),
    );
  }

  // Para eliminar los filtros
  void _clearFilters() {
    setState(() {
      selectedStatus = 'todos';
      selectedDate = null;
      currentPage = 1;
    });
  }

  // Para crear la paginación de pedidos
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
