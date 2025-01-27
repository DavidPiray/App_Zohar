import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/distributor_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AuthService authService = AuthService();
  final DistributorService distributorService = DistributorService();
  late Future<List<dynamic>> _inventory; // Inventario del distribuidor
  bool isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _inventory = distributorService.getDistributorInventory("dist1");
  }

  void _logout(BuildContext context) async {
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
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
      body: Row(
        children: [
          if (isWideScreen && isSidebarVisible) _buildSidebar(),
          Expanded(child: _buildInventoryList()),
        ],
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
          leading: const Icon(Icons.home, color: Colors.white),
          title: const Text('Inicio', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/distributor');
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

  Widget _buildInventoryList() {
    return FutureBuilder<List<dynamic>>(
      future: _inventory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tienes productos en inventario.'));
        } else {
          final inventory = snapshot.data!;
          return ListView.builder(
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final product = inventory[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: const Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: Text(product['nombre']),
                  subtitle: Text('Cantidad: ${product['stock']}'),
                ),
              );
            },
          );
        }
      },
    );
  }
}
