import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>{
  final ApiService apiService = ApiService();

  void _logout(BuildContext context) async {
    await apiService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
  void _goToInventory() {
    Navigator.pushNamed(
        context, '/inventory_screen'); // Redirigir a la pantalla de inventario
  }

  void _goToHome(){
    Navigator.pushNamed(
        context, '/distributor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario'),
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
              title: Text('Inicio'),
              onTap: _goToHome, // Navegar al inventario
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future:
            apiService.getDistributorInventory("dist1"), // API de inventario
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tienes productos en inventario.'));
          } else {
            final inventory = snapshot.data!;
            return ListView.builder(
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                final product = inventory[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.inventory),
                    title: Text(product['nombre']),
                    subtitle: Text('Cantidad: ${product['stock']}'),
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
