import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DistributorSettingsScreen extends StatefulWidget {
  const DistributorSettingsScreen({super.key});

  @override
  _DistributorSettingsScreenState createState() =>
      _DistributorSettingsScreenState();
}

class _DistributorSettingsScreenState extends State<DistributorSettingsScreen> {
  TimeOfDay _openingTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 20, minute: 0);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String distribuidorID = "";
  
  @override
  void initState() {
    super.initState();
    _loadDistributorID();
  }

  /// 🔹 Cargar el ID del distribuidor desde SharedPreferences
  Future<void> _loadDistributorID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      distribuidorID = prefs.getString("distribuidorID") ?? "default";
    });

    _loadSettings();
  }

  /// 🔹 Cargar horarios desde Firestore
  Future<void> _loadSettings() async {
    if (distribuidorID.isEmpty) return;

    DocumentSnapshot snapshot = await _firestore
        .collection('configuracion_distribuidores')
        .doc(distribuidorID)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _openingTime =
            TimeOfDay(hour: data['openingHour'], minute: data['openingMinute']);
        _closingTime =
            TimeOfDay(hour: data['closingHour'], minute: data['closingMinute']);
      });
    }
  }

  /// 🔹 Guardar horarios en Firestore
  Future<void> _saveSettings() async {
    if (distribuidorID.isEmpty) return;

    await _firestore
        .collection('configuracion_distribuidores')
        .doc(distribuidorID)
        .set({
      'openingHour': _openingTime.hour,
      'openingMinute': _openingTime.minute,
      'closingHour': _closingTime.hour,
      'closingMinute': _closingTime.minute,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // 🔹 Notificar a la pantalla del distribuidor en tiempo real
    _notifyDistributorScreen();
  }

  Future<void> _pickTime(bool isOpening) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTime : _closingTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isOpening) {
          _openingTime = pickedTime;
        } else {
          _closingTime = pickedTime;
        }
      });
      await _saveSettings();
    }
  }

  Future<void> _notifyDistributorScreen() async {
    await _firestore
        .collection('configuracion_distribuidores')
        .doc(distribuidorID)
        .update({'lastUpdated': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙ Configuración del Distribuidor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⏰ Horario del Distribuidor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Apertura: ${_openingTime.format(context)}'),
                ElevatedButton(
                  onPressed: () => _pickTime(true),
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cierre: ${_closingTime.format(context)}'),
                ElevatedButton(
                  onPressed: () => _pickTime(false),
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
