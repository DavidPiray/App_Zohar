import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _showRestockForm(BuildContext context) async {
    final inventory = await _inventory;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recargar Botellones'),
          content: RestockForm(
            inventory: inventory,
            onSubmit: (productId, quantity) {
              _restockProduct("dist1", productId, quantity);
            },
          ),
        );
      },
    );
  }

  Future<void> _restockProduct(
      String distributorId, String productId, int quantity) async {
    try {
      final ref = FirebaseFirestore.instance.collection('recargas');
      await ref.add({
        'distribuidorId': distributorId,
        'productoId': productId,
        'cantidad': quantity,
        'fecha': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solicitud de recarga enviada con éxito.')),
      );
    } catch (e) {
      debugPrint('Error al enviar la solicitud de recarga: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error al enviar la solicitud de recarga.')),
      );
    }
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
        actions: [
          TextButton(
            onPressed: () => _showRestockForm(context),
            child: const Text('Recargar Botellones',
                style: TextStyle(color: Colors.white)),
          ),
        ],
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
          return const Center(
              child: Text('No tienes productos en inventario.'));
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

class RestockForm extends StatefulWidget {
  final List<dynamic> inventory;
  final Function(String productId, int quantity) onSubmit;

  const RestockForm({
    Key? key,
    required this.inventory,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _RestockFormState createState() => _RestockFormState();
}

class _RestockFormState extends State<RestockForm> {
  String? selectedProduct;
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.inventory.isNotEmpty) {
      selectedProduct = widget.inventory.first['id']; // Selección por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: selectedProduct,
          onChanged: (value) {
            setState(() {
              selectedProduct = value;
            });
          },
          hint: const Text('Selecciona un producto'),
          items: widget.inventory.map<DropdownMenuItem<String>>((product) {
            return DropdownMenuItem<String>(
              value: product['id'],
              child: Text(product['nombre']),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (selectedProduct != null && quantityController.text.isNotEmpty) {
              try {
                final quantity = int.parse(quantityController.text);
                if (quantity > 0) {
                  widget.onSubmit(selectedProduct!, quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('La cantidad debe ser mayor a 0')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un número válido')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Selecciona un producto y una cantidad válida')),
              );
            }
          },
          child: const Text('Solicitar'),
        ),
      ],
    );
  }
}
