import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class DirectorScreen extends StatefulWidget {
  @override
  _DirectorScreenState createState() => _DirectorScreenState();
}

class _DirectorScreenState extends State<DirectorScreen> {
  final AuthService apiService = AuthService();
  bool isSidebarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  double _progress = 0.0;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _loadSavedTimes();
    _listenForSettingsChanges();
    _startTimer();
  }

  /// 🔹 Escuchar cambios en Firestore en tiempo real
  void _listenForSettingsChanges() {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('configuracion')
        .doc('horarios')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _openTime = TimeOfDay(
              hour: data['openingHour'], minute: data['openingMinute']);
          _closeTime = TimeOfDay(
              hour: data['closingHour'], minute: data['closingMinute']);
        });
        _updateProgress();
      }
    });
  }

  Future<void> _loadSavedTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _openTime = _parseTime(prefs.getString("openTime")) ??
          const TimeOfDay(hour: 8, minute: 0);
      _closeTime = _parseTime(prefs.getString("closeTime")) ??
          const TimeOfDay(hour: 18, minute: 0);
    });
    _updateProgress();
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null) return null;
    final parts = timeString.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateProgress();
    });
  }

  void _updateProgress() {
    if (_openTime == null || _closeTime == null) return;

    DateTime now = DateTime.now();
    setState(() {
      _currentTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    });

    DateTime startTime = DateTime(
        now.year, now.month, now.day, _openTime!.hour, _openTime!.minute);
    DateTime endTime = DateTime(
        now.year, now.month, now.day, _closeTime!.hour, _closeTime!.minute);

    if (now.isBefore(startTime)) {
      setState(() => _progress = 0.0);
    } else if (now.isAfter(endTime)) {
      setState(() => _progress = 1.0);
    } else {
      double totalMinutes = endTime.difference(startTime).inMinutes.toDouble();
      double elapsedMinutes = now.difference(startTime).inMinutes.toDouble();
      setState(() => _progress = elapsedMinutes / totalMinutes);
    }
  }

  void _logout(BuildContext context) async {
    await apiService.logout();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
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
                      _buildProgressIndicator(), // 🔹 Widget agregado aquí
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

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Progreso del Día",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B945E)),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            color: _progress < 0.5
                ? Colors.green
                : (_progress < 0.9 ? Colors.orange : Colors.red),
            minHeight: 10,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🕗 Apertura: ${_openTime?.format(context) ?? 'No Configurada'}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Text(
                "🕔 Cierre: ${_closeTime?.format(context) ?? 'No Configurada'}",
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "⏳ Hora Actual: $_currentTime",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
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
          title: const Text('Distribuidores',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/lista-distribuidores');
          },
        ),
        ListTile(
          leading: const Icon(Icons.inventory, color: Colors.white),
          title: const Text('Productos', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/lista-productos');
          },
        ),
        ListTile(
          leading: const Icon(Icons.document_scanner, color: Colors.white),
          title: const Text('Reportes', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/reporte-gerente');
          },
        ),
        ListTile(
          leading: const Icon(Icons.map, color: Colors.white),
          title: const Text('Mapa', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/mapa-gerente');
          },
        ),
        ListTile(
          leading: const Icon(Icons.map, color: Colors.white),
          title: const Text('Configuraciones',
              style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/configuracion-gerente');
          },
        ),
        const Spacer(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Cerrar sesión',
              style: TextStyle(color: Colors.white)),
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
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
}
