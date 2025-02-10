import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:frontend/services/realtime_service.dart';
import '../../services/client_service.dart';
import '../../widgets/box.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/orders_service.dart';
import '../../core/styles/colors.dart';

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

  late Future<List<dynamic>> _products;
  late Stream<DatabaseEvent> _realtimeStream;

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
  }

  // Escucha cambios en los pedidos en Firebase
  void _listenToRealtimeUpdates() {
    _realtimeStream = realtimeService.listenToOrders();
    _realtimeStream.listen((event) {
      final data = event.snapshot.value;
      print("Datos de Firebase recibidos: $data"); // Verifica la estructura
      if (data != null && data is Map<dynamic, dynamic>) {
        // Se filtran pedidos en progreso
        // Verificar que data es un Map
        List<dynamic> pedidosEnProgreso = data.entries
            .where((entry) =>
                entry.value is Map &&
                entry.value.containsKey('estado') &&
                entry.value['estado'].toString().toUpperCase() == 'en progreso')
            .map((entry) => entry.value)
            .toList();
        print(
            "Pedidos en progreso encontrados: $pedidosEnProgreso"); // Verifica si hay pedidos filtrados
        setState(() {
          inProgressOrders = pedidosEnProgreso;
        });
        // Mostrar alerta si hay pedidos en progreso
        if (inProgressOrders.isNotEmpty) {
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
        } else {
          print(
              "Estructura de datos inesperada. No se encontraron pedidos en progreso.");
        }
      }
    });
  }

  @override
  void dispose() {
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
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;
    return Wrapper(
      userRole: "cliente", // 🔹 PASA EL ROL DEL USUARIO
      floatingActionButton: FloatingActionButton(
        onPressed: _buyProducts,
        child: const Icon(Icons.shopping_cart),
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // Tarjeta de Pedidos en Progreso (si hay pedidos en progreso)
                if (inProgressOrders.isNotEmpty) _buildInProgressOrderCard(),
                //Expanded(child: _buildProductList(isWideScreen)),
                // Tarjeta contenedora de productos
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
                              "Productos Disponibles",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: _buildProductList(isWideScreen),
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

  // Lista de Productos
  Widget _buildProductList(bool isWideScreen) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<dynamic>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          } else {
            final products = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWideScreen ? 1.8 : 1,
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
                return AdaptiveCustomCard(
                  icon: Icons.local_drink,
                  title: productName,
                  additionalInfo:
                      'Precio: \$${productPrice.toStringAsFixed(2)}',
                  onTap: () {},
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (selectedQuantities[productId]! > 0) {
                              selectedQuantities[productId] =
                                  selectedQuantities[productId]! - 1;
                            }
                          });
                        },
                      ),
                      Text('${selectedQuantities[productId]}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            selectedQuantities[productId] =
                                selectedQuantities[productId]! + 1;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // 📌 Tarjeta de Pedido en Progreso Mejorada
  Widget _buildInProgressOrderCard() {
    if (inProgressOrders.isEmpty)
      return const SizedBox.shrink(); // Evita errores

    final order = inProgressOrders[currentOrderIndex]; // 🔹 Pedido actual
    final String orderId = order['id_pedido'];
    final String estado = order['estado'];
    final List productos = order['productos'] ?? [];
    final double total = order['total'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColors[estado],
                child: const Icon(Icons.pending_actions, color: Colors.white),
              ),
              title: Text('Pedido: $orderId',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Estado: $estado'),
              trailing: IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                onPressed: () {
                  Navigator.pushNamed(context, '/map', arguments: order);
                },
              ),
            ),
            const Divider(),

            // 🔹 Productos del pedido
            Column(
              children: productos.map((producto) {
                return ListTile(
                  title: Text(producto['nombre'] ?? 'Producto'),
                  subtitle: Text('Cantidad: ${producto['cantidad']}'),
                  trailing: Text('\$${producto['precio_cliente'] ?? 0.0}'),
                );
              }).toList(),
            ),

            const Divider(),
            ListTile(
              title: const Text("Total",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text("\$${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16)),
            ),

            // 🔹 Navegación entre pedidos
            if (inProgressOrders.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentOrderIndex > 0
                        ? () => setState(() => currentOrderIndex--)
                        : null,
                  ),
                  Text(
                      "Pedido ${currentOrderIndex + 1} de ${inProgressOrders.length}"),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: currentOrderIndex < inProgressOrders.length - 1
                        ? () => setState(() => currentOrderIndex++)
                        : null,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
