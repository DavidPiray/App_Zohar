import 'package:flutter/material.dart';
import '../../services/orders_service.dart';
import '../../widgets/animated_alert.dart';

class OrdersClientScreen extends StatefulWidget {
  const OrdersClientScreen({super.key});

  @override
  _OrdersClientScreenState createState() => _OrdersClientScreenState();
}

class _OrdersClientScreenState extends State<OrdersClientScreen> {
  final OrdersService ordersService = OrdersService();
  late Future<List<dynamic>> _orders;

  @override
  void initState() {
    super.initState();

    // ID temporal del cliente, cámbialo por la lógica real
    const String clientId = 'client1';

    // Trae todos los pedidos y filtra por cliente
    _orders = ordersService.getAllOrders(clientId);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.amber;
      case 'en progreso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
/* 
  void _updateState() async{

    await ordersService.createOrder();
  }
 */
  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('Mis Pedidos', style: TextStyle(fontSize: 18))),
      ),
      body: Row(
        children: [
          if (isWideScreen)
            Container(
              width: 250,
              color: const Color(0xFF3B945E),
              child: Column(
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
                    leading: const Icon(Icons.list, color: Colors.white),
                    title: const Text('Pedidos',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
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
                      child: Text('No tienes pedidos disponibles.'));
                } else {
                  final orders = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final status = order['estado'];
                       final formattedDate = ordersService.formatTimestamp(order['fechaCreacion']);
                      //final total = order['total'] ?? 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(status),
                            child: const Icon(Icons.shopping_cart,
                                color: Colors.white),
                          ),
                          title: Text('Pedido: ${order['id_pedido']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Estado: $status'),
                              Text('Fecha: $formattedDate'),
                              //Text('Total: \$${total.toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: status.toLowerCase() == 'pendiente'
                              ? IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      // Simula cancelación
                                      await Future.delayed(
                                          const Duration(seconds: 2));

                                      setState(() {
                                        orders[index]['estado'] = 'cancelado';
                                      });

                                      AnimatedAlert.show(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        'Pedido Cancelado',
                                        'El pedido ha sido cancelado exitosamente.',
                                        type: AnimatedAlertType.success,
                                      );
                                    } catch (e) {
                                      AnimatedAlert.show(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        'Error',
                                        'No se pudo cancelar el pedido: $e',
                                        type: AnimatedAlertType.error,
                                      );
                                    }
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
