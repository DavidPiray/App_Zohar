import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../widgets/box.dart';
import '../../widgets/animated_alert.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/orders_service.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  _ClientScreenState createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  final AuthService authService = AuthService();
  final ProductService productService = ProductService();
  final OrdersService ordersService = OrdersService();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  late Future<List<dynamic>> _products;
  late Stream<DatabaseEvent> _orderStatusStream;

  Map<String, int> selectedQuantities = {};
  String currentOrderStatus = "pendiente"; // Estado inicial
  String orderId = "o1234567890"; // Reemplaza con el ID del pedido actual
  bool isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _setupOrderListener();
    _products = productService.getProducts();
  }

  // Configurar el listener para escuchar cambios en el estado del pedido
  void _setupOrderListener() {
    _orderStatusStream = _database.child("pedido/$orderId/estado").onValue;

    _orderStatusStream.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final newStatus = event.snapshot.value as String;
        if (newStatus != currentOrderStatus) {
          setState(() {
            currentOrderStatus = newStatus;
          });

          // Mostrar alerta al cliente sobre el cambio de estado
          AnimatedAlert.show(
            context,
            "Actualización de pedido",
            "El estado de tu pedido ha cambiado a: $newStatus",
            type: AnimatedAlertType.info,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Cancela el listener para evitar fugas de memoria
    _orderStatusStream.drain();
    super.dispose();
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

  void _buyProducts() {
    if (selectedQuantities.isEmpty ||
        selectedQuantities.values.every((quantity) => quantity == 0)) {
      AnimatedAlert.show(
        context,
        'Error',
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

              return AlertDialog(
                title: const Text('Resumen del Pedido'),
                content: SingleChildScrollView(
                  child: Column(
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

  void _confirmPurchase() async {
    try {
      final orderDetails = {
        'id_pedido': 'o${DateTime.now().millisecondsSinceEpoch}',
        'clienteID': 'client1',
        'distribuidorID': 'dist1',
        'estado': 'pendiente',
        'productos': selectedQuantities.entries
            .where((entry) => entry.value > 0)
            .map((entry) => {
                  'id_producto': entry.key,
                  'cantidad': entry.value,
                })
            .toList(),
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

  Widget _buildOrderStatus() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Estado actual del pedido: $currentOrderStatus",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
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
      body: Column(
        children: [
          _buildOrderStatus(),
          Expanded(child: _buildProductList(isWideScreen)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _buyProducts,
        child: const Icon(Icons.shopping_cart),
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
          onTap: () {
            Navigator.pushNamed(context, '/profileClient');
          },
        ),
        ListTile(
          leading: const Icon(Icons.list, color: Colors.white),
          title: const Text('Pedidos', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/historyClient');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Salir', style: TextStyle(color: Colors.white)),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

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
}
