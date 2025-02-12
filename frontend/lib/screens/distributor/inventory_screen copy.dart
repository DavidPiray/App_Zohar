import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/distributor_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

//Variables de servicio
class _InventoryScreenState extends State<InventoryScreen> {
  final AuthService authService = AuthService();
  final DistributorService distributorService = DistributorService();

//Variables globales
  late Future<List<dynamic>> _inventory;
  bool isSidebarVisible = true;
  bool isAscending = true;
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

//Constructor -> Página de incio
  @override
  void initState() {
    super.initState();
    _inventory = distributorService.getDistributorInventory("dist1");

    // Actualiza la hora en tiempo real cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

//COnstructir de página de incio
  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleSidebar,
        ),
        actions: [
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen && isSidebarVisible) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTimeline(),
                Expanded(child: _buildInventoryList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

//Logout
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

//Stock
  void _toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      _inventory = distributorService
          .getDistributorInventory("dist1")
          .then((list) => list
            ..sort((a, b) {
              return isAscending
                  ? a['stock'].compareTo(b['stock'])
                  : b['stock'].compareTo(a['stock']);
            }));
    });
  }

//Recargar botellas
  void _showRestockForm(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recargar Botellones'),
          content: RestockForm(
            product: product,
            onSubmit: (quantity) {
              _restockProduct("dist1", product['id_producto'], quantity);
            },
          ),
        );
      },
    );
  }

  Future<void> _restockProduct(
      String distributorId, String productId, int quantity) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
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

//Hora de entrada/salida
  Widget _buildTimeline() {
    final openTime =
        DateTime(_currentTime.year, _currentTime.month, _currentTime.day, 8);
    final closeTime =
        DateTime(_currentTime.year, _currentTime.month, _currentTime.day, 18);
    final progress = (_currentTime.difference(openTime).inMinutes /
            closeTime.difference(openTime).inMinutes)
        .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Horario: ${DateFormat.Hm().format(openTime)} - ${DateFormat.Hm().format(closeTime)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 5),
          Text(
            "Hora actual: ${DateFormat.Hms().format(_currentTime)}",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

//Slider
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF3B945E),
      child: _buildSidebarContent(),
    );
  }

//Cosntructor de contenedor
  Widget _buildSidebarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

//Inventario
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
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: Text(product['nombre']),
                  subtitle: Text('Cantidad: ${product['stock']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.green),
                    onPressed: () => _showRestockForm(context, product),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

//Funcion de form
class RestockForm extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(int quantity) onSubmit;
  final TextEditingController quantityController = TextEditingController();

  RestockForm({Key? key, required this.product, required this.onSubmit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Recargar ${product['nombre']}"),
      content: TextField(
        controller: quantityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Cantidad'),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(quantityController.text) ?? 0;
            if (quantity > 0) {
              onSubmit(quantity);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Solicitar'),
        ),
      ],
    );
  }
}
