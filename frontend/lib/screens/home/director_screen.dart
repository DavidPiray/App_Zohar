import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DirectorScreen extends StatefulWidget {
  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  final AuthService apiService = AuthService();
  bool isSidebarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _logout(BuildContext context) async {
    await apiService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Gerente'),
        backgroundColor: const Color(0xFF3B945E),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            if (!isWideScreen) {
              _scaffoldKey.currentState?.openDrawer();
            } else {
              _toggleSidebar();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: !isWideScreen ? _buildDrawer() : null,
      body: Row(
        children: [
          if (isWideScreen && isSidebarVisible) _buildSidebar(),
          Expanded(
            child: Stack(
              children: [
                _buildBackground(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: isWideScreen ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildOptionCard(
                              context,
                              title: 'Distribuidores',
                              imagePath: 'assets/images/distributors.png',
                              onTap: () {
                                Navigator.pushNamed(context, '/listDistribuidor');
                              },
                            ),
                            _buildOptionCard(
                              context,
                              title: 'Productos',
                              imagePath: 'assets/images/products.png',
                              onTap: () {
                                Navigator.pushNamed(context, '/listProductos');
                              },
                            ),
                            _buildOptionCard(
                              context,
                              title: 'Reportes',
                              imagePath: 'assets/images/reports.png',
                              onTap: () {
                                Navigator.pushNamed(context, '/reporte-director');
                              },
                            ),
                          ],
                        ),
                      ),
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
            'Menú',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.local_shipping, color: Colors.white),
          title: const Text('Distribuidores', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/listDistribuidor');
          },
        ),
        ListTile(
          leading: const Icon(Icons.inventory, color: Colors.white),
          title: const Text('Productos', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/listProductos');
          },
        ),
        ListTile(
          leading: const Icon(Icons.document_scanner, color: Colors.white),
          title: const Text('Reportes', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/repote-director');
          },
        ),
        ListTile(
          leading: const Icon(Icons.map, color: Colors.white),
          title: const Text('Mapa', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/map');
          },
        ),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFF3B945E),
        child: _buildSidebarContent(),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB8E994),
            Color(0xFF6ABF69),
            Color(0xFF3B945E),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
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
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title, required String imagePath, required VoidCallback onTap}) {
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
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
