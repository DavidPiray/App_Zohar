import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:frontend/services/realtime_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/client_service.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/orders_service.dart';
import '../../core/styles/colors.dart';
import '../distributor/map_screen.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  // variables para los servicios
  final AuthService authService = AuthService();
  final ProductService productService = ProductService();
  final OrdersService ordersService = OrdersService();
  final RealtimeService realtimeService = RealtimeService();
  final ClientService clientService = ClientService();
  final ScrollController _scrollController = ScrollController();
  late Future<List<dynamic>> _products;
  late Stream<DatabaseEvent> _realtimeStream;
  List<String> previousInProgressOrders = [];
  LatLng? _distributorPosition;
  String? _currentOrderId;

  // Variables Globales de la pantalla
  double _total = 0.0; // Precio total del pedido
  int currentOrderIndex = 0; // Índice para la paginación de pedidos en progreso
  Map<String, int> selectedQuantities = {};
  List<dynamic> inProgressOrders = [];
  bool isSidebarVisible = true; // para la barra lateral

  // Constructor -> Inicio de página
  @override
  void initState() {
    super.initState();
    _products = productService.getProducts(); // Obtiene productos
    _listenToRealtimeUpdates(); // escucha cambios en los pedidos en tiempo real
    _listenToDistributorLocation(); // escucha la ubicación en tiempo real
  }

  // Escucha la ubicación en tiempo real
  void _listenToDistributorLocation([String? orderId]) {
    if (orderId == null) return;
    Stream<DatabaseEvent> distributorLocationStream =
        realtimeService.listenToDistributorLocation(
            orderId); // 🔹 Escucha la ubicación en tiempo real

    distributorLocationStream.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          _distributorPosition = LatLng(
            data['latitude'] as double,
            data['longitude'] as double,
          );
        });
        print("📌 Nueva ubicación del distribuidor: $_distributorPosition");
      }
    });
  }

  // Escucha cambios en los pedidos en Firebase
  void _listenToRealtimeUpdates() {
    _realtimeStream = realtimeService.listenToOrders();
    _realtimeStream.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        // Se filtran pedidos en progreso
        // Verificar que data es un Map
        List<dynamic> pedidosEnProgreso = data.entries
            .where((entry) =>
                entry.value is Map &&
                entry.value.containsKey('estado') &&
                entry.value['estado'].toString().trim().toLowerCase() ==
                    'en progreso')
            .map((entry) => entry.value)
            .toList();

        // Obtener los IDs de los pedidos actuales en progreso
        List<String> currentInProgressOrders = pedidosEnProgreso
            .map((order) => order['id_pedido'].toString())
            .toList();

        // Comprobar si hay un nuevo pedido que ha cambiado a "en progreso"
        bool hasNewOrderInProgress = currentInProgressOrders
            .any((id) => !previousInProgressOrders.contains(id));

        setState(() {
          inProgressOrders = pedidosEnProgreso;
          if (inProgressOrders.isNotEmpty) {
            _currentOrderId =
                inProgressOrders.first['id_pedido']; // ✅ Guarda el ID
            _listenToDistributorLocation(_currentOrderId!);
            previousInProgressOrders = currentInProgressOrders;
          }
        });

        // Mostrar alerta si hay pedidos en progreso
        if (hasNewOrderInProgress) {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Actualización de pedido"),
                content: const Text(
                    "Tu pedido ha pasado a EN PROGRESO. ¿Deseas ver el historial?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/historial-cliente");
                    },
                    child: const Text("Ver Pedidos"),
                  ),
                ],
              );
            },
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _realtimeStream.drain();
    super.dispose();
  }

  // Botón de Comprar Productos
  void _buyProducts() {
    if (selectedQuantities.isEmpty ||
        selectedQuantities.values.every((quantity) => quantity == 0)) {
      AnimatedAlert.show(
        context,
        'Error al realizar el pedido',
        'Por favor, selecciona al menos un producto.',
        type: AnimatedAlertType.error,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Ocurrió un error: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            } else {
              final products = snapshot.data ?? [];
              double total = 0.0;
              List<Widget> resumen = selectedQuantities.entries.map((entry) {
                final productId = entry.key;
                final quantity = entry.value;
                if (quantity > 0) {
                  final product =
                      products.firstWhere((p) => p['id_producto'] == productId);
                  total += product['precio_cliente'] * quantity;
                  return ListTile(
                    title: Text(product['nombre']),
                    subtitle: Text('Cantidad: $quantity'),
                    trailing: Text(
                      'Subtotal: \$${(product['precio_cliente'] * quantity).toStringAsFixed(2)}',
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList();
              _total = total;
              return AlertDialog(
                title: const Text('Resumen del Pedido'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...resumen,
                    const Divider(),
                    ListTile(
                      title: const Text('Total:'),
                      trailing: Text('\$${total.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmPurchase();
                    },
                    child: const Text('Confirmar Pedido'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  // Confirmar el pedido
  void _confirmPurchase() async {
    try {
      final userInfo = await clientService
          .getClientInfo(); // Obtiene datos del cliente autenticado
      final orderDetails = {
        'id_pedido': 'o${DateTime.now().millisecondsSinceEpoch}',
        'clienteID': userInfo['clienteID'],
        'distribuidorID': userInfo['distribuidorID'],
        'estado': 'pendiente',
        'productos': selectedQuantities.entries
            .where((entry) => entry.value > 0)
            .map((entry) => {
                  'id_producto': entry.key,
                  'cantidad': entry.value,
                })
            .toList(),
        'total': _total,
      };
      await ordersService.createOrder(orderDetails);
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Éxito',
        'Pedido realizado con éxito.',
        type: AnimatedAlertType.success,
      );
      setState(() {
        selectedQuantities.clear();
      });
    } catch (e) {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'Error al realizar el pedido: $e',
        type: AnimatedAlertType.error,
      );
    }
  }

  Map<String, Color> statusColors = {
    'pendiente': Colors.grey,
    'en progreso': Colors.amber,
    'completado': Colors.green,
    'cancelado': Colors.red,
  };
  // Constructor de la Página Inicial
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "cliente",
      floatingActionButton: FloatingActionButton(
        onPressed: _buyProducts,
        child: const Icon(Icons.shopping_cart),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          color: AppColors.back,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height *
                  0.8, // 🔹 Limita la altura del Card
            ),
            child: SingleChildScrollView(
              // 🔹 Activa scroll solo dentro del Card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (inProgressOrders.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildInProgressOrderCard(),
                      ),

                    const Text(
                      "Productos Disponibles",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildProductList(), // ✅ Productos con scroll dentro del Card
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Lista de Productos
  Widget _buildProductList() {
    return FutureBuilder<List<dynamic>>(
      future: _products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay productos disponibles'));
        } else {
          final List<dynamic> products = snapshot.data!;

          return ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400, // 🔹 Scroll solo dentro del Card
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    int crossAxisCount = (screenWidth / 220)
                        .floor()
                        .clamp(1, products.length); // 🔹 Evita columnas vacías

                    return Align(
                      alignment: Alignment.center,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final productId = product['id_producto'];
                          final productName = product['nombre'];
                          final productPrice = product['precio_cliente'];

                          if (!selectedQuantities.containsKey(productId)) {
                            selectedQuantities[productId] = 0;
                          }

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // ✅ Centra el contenido verticalmente
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // ✅ Centra el texto e iconos
                                children: [
                                  const Icon(Icons.local_drink,
                                      size: 60, color: Colors.blueAccent),
                                  Text(
                                    productName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Precio: \$${productPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (selectedQuantities[productId]! >
                                                0) {
                                              selectedQuantities[productId] =
                                                  selectedQuantities[
                                                          productId]! -
                                                      1;
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        '${selectedQuantities[productId]}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            selectedQuantities[productId] =
                                                selectedQuantities[productId]! +
                                                    1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // 📌 Tarjeta de Pedido en Progreso Mejorada
  Widget _buildInProgressOrderCard() {
    if (inProgressOrders.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController, // ✅ Asociar ScrollController
        child: SingleChildScrollView(
          controller: _scrollController, // ✅ Vincular con el ScrollView
          child: Column(
            children: inProgressOrders.map((order) {
              final String orderId = order['id_pedido'] ?? 'Sin ID';
              final String estado = order['estado'] ?? 'Desconocido';
              final List productos = order['productos'] ?? [];
              final double total = order['total'] ?? 0.0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColors[estado] ?? Colors.grey,
                    child:
                        const Icon(Icons.pending_actions, color: Colors.white),
                  ),
                  title: Text('Pedido: $orderId'),
                  subtitle: Text('Estado: $estado'),
                  trailing: IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      onPressed: () {
                        // 🔹 Mostrar un diálogo de carga mientras obtenemos las ubicaciones
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return FutureBuilder<LatLng?>(
                              future: _fetchLocations(order['id_pedido']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const AlertDialog(
                                    title: Text('Cargando ubicación...'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 10),
                                        Text('Obteniendo datos del mapa...')
                                      ],
                                    ),
                                  );
                                }

                                if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'No se pudo obtener la ubicación.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  );
                                }

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.pop(
                                      context); // 🔹 Cerrar el diálogo de carga
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(
                                        orderId: order['id_pedido'],
                                        clientLocation: snapshot.data!,
                                      ),
                                    ),
                                  );
                                });

                                return Container();
                              },
                            );
                          },
                        );
                      }),
                  children: [
                    Column(
                      children: productos.map((producto) {
                        return ListTile(
                          title: Text(producto['nombre'] ?? 'Producto'),
                          subtitle:
                              Text('Cantidad: ${producto['cantidad'] ?? 0}'),
                          trailing:
                              Text('\$${producto['precio_cliente'] ?? 0.0}'),
                        );
                      }).toList(),
                    ),
                    ListTile(
                      title: const Text("Total",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text("\$${total.toStringAsFixed(2)}"),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<LatLng?> _fetchLocations(String orderId) async {
    print(
        '📌 Buscando ubicación del distribuidor y del cliente para el pedido $orderId...');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
        String? clientID = prefs.getString('clienteID');
      // 🔹 Obtener la ubicación del cliente desde Firestore
      Map<String, dynamic>? clientLocation =
          await clientService.getCustomerLocation(clientID!);
      print(
          '📌 Datos obtenidos $clientID de Firestore para orderId $orderId: $clientLocation');
      if (clientLocation == null ||
          !clientLocation.containsKey('latitude') ||
          !clientLocation.containsKey('longitude')) {
        print('❌ No se encontró la ubicación del cliente.');
        return null;
      }

      double lat = clientLocation['latitude'] as double;
      double lng = clientLocation['longitude'] as double;
      LatLng clientLatLng = LatLng(lat, lng);

      print('✅ Cliente encontrado en: $clientLatLng');

      // 🔹 Obtener la ubicación del distribuidor en tiempo real desde Firebase
      Stream<DatabaseEvent> distributorLocationStream =
          realtimeService.listenToDistributorLocation(orderId);

      distributorLocationStream.listen((event) {
        final data = event.snapshot.value;
        print('📡 Datos de ubicación del distribuidor en Firebase: $data');

        if (data != null && data is Map<dynamic, dynamic>) {
          setState(() {
            _distributorPosition = LatLng(
              data['latitude'] as double,
              data['longitude'] as double,
            );
          });
        }
      });

      return clientLatLng; // 🔹 Retorna la ubicación del cliente
    } catch (e) {
      print('❌ Error al obtener las ubicaciones: $e');
      return null;
    }
  }
}
