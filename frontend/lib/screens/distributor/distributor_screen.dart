import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class DistributorScreen extends StatefulWidget {
  @override
  _DistributorScreenState createState() => _DistributorScreenState();
}

class _DistributorScreenState extends State<DistributorScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _orders; // Pedidos asignados al distribuidor

  @override
  void initState() {
    super.initState();
    _orders = apiService.getOrdersByDistributor(
        "dist1"); // API para obtener pedidos del distribuidor
  }

  void _logout(BuildContext context) async {
    await apiService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _updateOrderStatus(String orderId) async {
    try {
      await apiService.updateOrderStatus(
          orderId, 'en progreso'); // Cambiar estado a 'en progreso'
      setState(() {
        _orders =
            apiService.getOrdersByDistributor("dist1"); // Actualizar pedidos
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido actualizado a "En Progreso"')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el pedido: $error')),
      );
    }
  }

  void _viewMap(String clientId) {
    // Navegar a la pantalla del mapa
    Navigator.pushNamed(context, '/map', arguments: clientId);
  }

  void _goToInventory() {
    Navigator.pushNamed(
        context, '/inventory_screen'); // Redirigir a la pantalla de inventario
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Distribuidor'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menú Distribuidor',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Inventario'),
              onTap: _goToInventory, // Navegar al inventario
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: FutureBuilder<List<dynamic>>(
          future: _orders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No tienes pedidos asignados.'));
            } else {
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  // Verifica si las claves existen
                  final clientId =
                      order['clienteID'] ?? 'ID de cliente no disponible';
                  final orderId =
                      order['id_pedido'] ?? 'ID de pedido no disponible';
                  final productsList =
                      order['productos'] as List<dynamic>? ?? [];

                  // Generar texto para productos
                  final products = productsList.isNotEmpty
                      ? productsList
                          .map((p) =>
                              '${p['id_producto'] ?? 'Producto desconocido'} (x${p['cantidad'] ?? 0})')
                          .join(', ')
                      : 'No hay productos';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.shopping_cart),
                      title: Text('Cliente: $clientId'),
                      subtitle: Text('Productos: $products'),
                      trailing: ElevatedButton(
                        onPressed: () =>
                            _updateOrderStatus(orderId), // Actualizar estado
                        child: Text('Entregar'),
                      ),
                      onTap: order['estado'] == 'en progreso'
                          ? () =>
                              _viewMap(clientId) // Ver mapa si está en progreso
                          : null,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
