import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class DirectorScreen extends StatefulWidget {
  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  final ApiService apiService = ApiService();
  void _logout(BuildContext context) async {
    await apiService.logout(); // Limpiar sesión
    Navigator.pushReplacementNamed(context, '/login'); // Redirigir al login
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Director'),
        backgroundColor: Color(0xFF3B945E), // Color acorde a los anteriores
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context), // Botón para cerrar sesión
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
      ),
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E994), // Light green
                  Color(0xFF6ABF69), // Medium green
                  Color(0xFF3B945E), // Dark green
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Encabezado
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ZOHAR Agua Purificada',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B945E),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Panel de Control del Gerente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // Opciones principales
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      /*_buildOptionCard(
                        context,
                        title: 'Clientes',
                        icon: Icons.people,
                        onTap: () {
                          // Acción para clientes
                          Navigator.pushNamed(context, '/client');
                        },
                      ),*/
                      _buildOptionCard(
                        context,
                        title: 'Distribuidores',
                        icon: Icons.local_shipping,
                        onTap: () {
                          // Acción para distribuidores
                          Navigator.pushNamed(context, '/listDistribuidor');
                        },
                      ),
                      _buildOptionCard(
                        context,
                        title: 'Productos',
                        icon: Icons.inventory,
                        onTap: () {
                          // Acción para productos
                          Navigator.pushNamed(context, '/listProductos');
                        },
                      ),/*
                      _buildOptionCard(
                        context,
                        title: 'Pedidos',
                        icon: Icons.receipt,
                        onTap: () {
                          // Acción para pedidos
                          Navigator.pushNamed(context, '/orders');
                        },
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Color(0xFF3B945E),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B945E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
