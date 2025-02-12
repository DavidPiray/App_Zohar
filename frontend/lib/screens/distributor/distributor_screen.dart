import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:frontend/screens/distributor/map_screen.dart';
import 'package:frontend/services/client_service.dart';
import 'package:frontend/services/product_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/styles/colors.dart';
import '../../services/distributor_service.dart';
import '../../services/orders_service.dart';
import '../../services/auth_service.dart';
import '../../services/realtime_service.dart';
import '../../services/location_service.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';

class DistributorScreen extends StatefulWidget {
  const DistributorScreen({super.key});

  @override
  State<DistributorScreen> createState() => _DistributorScreenState();
}

//Variables de servicio
class _DistributorScreenState extends State<DistributorScreen> {
  final DistributorService distributorService = DistributorService();
  final ClientService clientService = ClientService();
  final OrdersService ordersService = OrdersService();
  final ProductService productService = ProductService();
  final AuthService authService = AuthService();
  final RealtimeService realtimeService = RealtimeService();
  final LocationService locationService = LocationService();

  // ignore: unused_field
  LatLng? _distributorPosition;
  // ignore: unused_field
  LatLng? _clientPosition;

  late Future<List<dynamic>> _orders;
  late Future<List<dynamic>> _products;
  late Stream<DatabaseEvent> _realtimeStream;

  Map<String, String> orderStatuses = {
    'pendiente': 'en progreso',
    'en progreso': 'completado'
  };

  //Mapeo de colores
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

  // Constructor -> Inicio de página
  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchProducts();
    _listenToRealtimeUpdates();
  }

//Constructor de la página de incio
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "distribuidor", // PASA EL ROL DEL USUARIO
      child: Row(
        children: [
          // Contenido principal
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
                      const Text(
                        "Pedidos Asignados",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _buildOrdersList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Para obtener los pedidos
  void _fetchOrders() {
    setState(() {
      _orders = distributorService.getOrdersByDistributor(distributorId);
    });
  }

  // Para obtener los productos
  void _fetchProducts() {
    setState(() {
      _products = productService.getProducts();
    });
  }

  // Para escuchar los pedidos nuevos en tiempor real
  void _listenToRealtimeUpdates() {
    _realtimeStream = realtimeService.listenToOrders();
    _realtimeStream.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        _fetchOrders();
      }
    });
  }

  // Para los filtros
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

  // Limpiar los filtros
  void _clearFilters() {
    setState(() {
      selectedStatus = 'todos';
      selectedDate = null;
      selectedProduct = null;
      currentPage = 1;
    });
  }

/*   void _updateOrderStatus(String orderId, String currentStatus,
      Map<String, dynamic> clientLocation) async {
    try {
      String? nextStatus = orderStatuses[currentStatus];
      if (nextStatus == null) return;
      await ordersService.updateOrderStatus(orderId, nextStatus);
      //
      if (nextStatus == "en progreso") {
        // Obtener la ubicación del distribuidor
        Position distributorLocation =
            await locationService.getCurrentLocation();
        _distributorPosition =
            LatLng(distributorLocation.latitude, distributorLocation.longitude);
        print('Primero $distributorLocation');
        print('Segundo $_distributorPosition');
        // Obtener la ruta entre el distribuidor y el cliente
        List<LatLng> route = await googleMapsService.getRoute(
          origin: _distributorPosition!,
          destination:
              LatLng(clientLocation['latitude'], clientLocation['longitude']),
        );
        print('Cliente $clientLocation');
//
        setState(() {
          _polylineCoordinates = route;
          print('poli: $_polylineCoordinates');
        });
      }
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Éxito',
        'El pedido se ha actualizado a "$nextStatus".',
        type: AnimatedAlertType.success,
      );
      _fetchOrders();
    } catch (error) {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'No se pudo actualizar el pedido: $error',
        type: AnimatedAlertType.error,
      );
    }
  }
 */

  // Actualizar las ubicaciones
  Future<LatLng?> _updateLocation(String customerId, String orderId) async {
    Map<String, dynamic>? clientLocation =
        await clientService.getCustomerLocation(customerId);

    if (clientLocation == null ||
        !clientLocation.containsKey('latitude') ||
        !clientLocation.containsKey('longitude')) {
      AnimatedAlert.show(
        context,
        'Error',
        'No se encontró la ubicación del cliente.',
        type: AnimatedAlertType.error,
      );
      return null;
    }

    Position distributorLocation = await locationService.getCurrentLocation();
    LatLng distributorLatLng =
        LatLng(distributorLocation.latitude, distributorLocation.longitude);

    // Guardar ubicación en Firebase
    await realtimeService.saveDistributorLocation(
        orderId, distributorLatLng.latitude, distributorLatLng.longitude);

    // Escuchar cambios en la ubicación del distribuidor
    Geolocator.getPositionStream().listen((Position newPosition) {
      if (mounted) {
        setState(() {
          _distributorPosition =
              LatLng(newPosition.latitude, newPosition.longitude);
        });
      }
      realtimeService.updateDistributorLocation(
          orderId, newPosition.latitude, newPosition.longitude);
    });

    return LatLng(
      clientLocation['latitude'] as double,
      clientLocation['longitude'] as double,
    );
  }

  // Para actualizar el estado y sincronizar ubicaciones
  void _updateOrderStatusAndTrackLocation(
      String orderId, String currentStatus, String customerId) async {
    try {
      String? nextStatus = orderStatuses[currentStatus];
      if (nextStatus == null) return;
      await ordersService.updateOrderStatus(
          orderId, nextStatus); // Actualiza el estado en Firestore
      if (nextStatus == "en progreso") {
        // Obtener la ubicación del cliente desde Firestore
        Map<String, dynamic>? clientLocation =
            await clientService.getCustomerLocation(customerId);
        if (clientLocation == null) {
          AnimatedAlert.show(
            // ignore: use_build_context_synchronously
            context,
            'Error',
            'No se encontró la ubicación del cliente.',
            type: AnimatedAlertType.error,
          );
          return;
        }
        _clientPosition = LatLng(clientLocation['latitude'] as double,
            clientLocation['longitude'] as double);
        // Obtener la ubicación del distribuidor
        Position distributorLocation =
            await locationService.getCurrentLocation();
        _distributorPosition =
            LatLng(distributorLocation.latitude, distributorLocation.longitude);
        // Guardar ubicación inicial en Firebase Realtime Database
        await realtimeService.saveDistributorLocation(orderId,
            distributorLocation.latitude, distributorLocation.longitude);

        // Escuchar cambios en la ubicación del distribuidor y actualizar Firebase en tiempo real
        Geolocator.getPositionStream().listen((Position newPosition) {
          realtimeService.updateDistributorLocation(
              orderId, newPosition.latitude, newPosition.longitude);
          setState(() {
            _distributorPosition =
                LatLng(newPosition.latitude, newPosition.longitude);
          });
        });
      } else if (nextStatus == "completado") {
        // Eliminar ubicación del distribuidor en Firebase
        await realtimeService.removeDistributorLocation(orderId);
      }
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Éxito',
        'El pedido se ha actualizado a "$nextStatus".',
        type: AnimatedAlertType.success,
      );
      _fetchOrders();
    } catch (error) {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'No se pudo actualizar el pedido: $error',
        type: AnimatedAlertType.error,
      );
    }
  }

  //Lsta de ordenes
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (orderStatuses.containsKey(orderStatus))
                                      ElevatedButton(
                                        onPressed: () =>
                                            _updateOrderStatusAndTrackLocation(
                                          orderId,
                                          orderStatus,
                                          order['clienteID'],
                                        ),
                                        child: Text(orderStatus == 'pendiente'
                                            ? 'Entregar'
                                            : 'Completado'),
                                      ),
                                    if (orderStatus == "en progreso")
                                      IconButton(
                                        icon: const Icon(Icons.map,
                                            color: Colors.blue),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              return FutureBuilder<LatLng?>(
                                                future: _updateLocation(
                                                    order['clienteID'],
                                                    orderId),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const AlertDialog(
                                                      title: Text(
                                                          'Cargando ubicación...'),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CircularProgressIndicator(),
                                                          SizedBox(height: 10),
                                                          Text(
                                                              'Obteniendo datos del mapa...')
                                                        ],
                                                      ),
                                                    );
                                                  }

                                                  if (snapshot.hasError ||
                                                      snapshot.data == null) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text('Error'),
                                                      content: const Text(
                                                          'No se pudo obtener la ubicación.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              'Cerrar'),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (_) {
                                                    Navigator.pop(
                                                        context); // Cerrar el diálogo de carga
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MapScreen(
                                                          orderId: orderId,
                                                          clientLocation:
                                                              snapshot.data!,
                                                        ),
                                                      ),
                                                    );
                                                  });

                                                  return Container(); // Evita mostrar algo innecesario
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
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
    );
  }

  // Constructor de los filtros
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

  // Controlador de Paginación
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
