import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AdminScreen extends StatelessWidget {
  final AuthService apiService = AuthService();

  void _logout(BuildContext context) async {
    await apiService.logout(); // Limpiar sesión
    Navigator.pushReplacementNamed(context, '/login'); // Redirigir al login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrador'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Botón de salir
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 64, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Administrador',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Clientes'),
              onTap: () {
                // Navegar a la pantalla de clientes
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Distribuidor'),
              onTap: () {
                // Navegar a la pantalla de distribuidores
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Productos'),
              onTap: () {
                // Navegar a la pantalla de productos
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Pedidos'),
              onTap: () {
                // Navegar a la pantalla de pedidos
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Espacio para banner o logo
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Banner o Logo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Sección de botones
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuButton(
                    context,
                    Icons.people,
                    'Clientes',
                    onTap: () {
                      // Navegar a la pantalla de clientes
                    },
                  ),
                  _buildMenuButton(
                    context,
                    Icons.group,
                    'Distribuidor',
                    onTap: () {
                      // Navegar a la pantalla de distribuidores
                    },
                  ),
                  _buildMenuButton(
                    context,
                    Icons.inventory,
                    'Producto',
                    onTap: () {
                      // Navegar a la pantalla de productos
                    },
                  ),
                  _buildMenuButton(
                    context,
                    Icons.shopping_bag,
                    'Pedidos',
                    onTap: () {
                      // Navegar a la pantalla de pedidos
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}