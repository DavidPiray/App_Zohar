import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({super.key});

  @override
  _ManagerSettingsScreenState createState() => _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState extends State<ManagerSettingsScreen> {
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 18, minute: 0);
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initNotifications();
  }

  /// 🔹 Cargar los horarios guardados en Firestore
  Future<void> _loadSettings() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('configuracion').doc('horarios').get();

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
    await _firestore.collection('configuracion').doc('horarios').set({
      'openingHour': _openingTime.hour,
      'openingMinute': _openingTime.minute,
      'closingHour': _closingTime.hour,
      'closingMinute': _closingTime.minute,
    });

    // 🔹 Notificar a la pantalla del gerente en tiempo real
    _notifyDirectorScreen();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
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
      _sendNotification(isOpening);
    }
  }

  Future<void> _sendNotification(bool isOpening) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'Plant Operations',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      'Horario de Planta',
      isOpening ? 'La planta ha abierto' : 'La planta ha cerrado',
      platformChannelSpecifics,
    );
  }

  // 🔹 Notifica cambios a DirectorScreen
  Future<void> _notifyDirectorScreen() async {
    await _firestore
        .collection('configuracion')
        .doc('horarios')
        .update({'lastUpdated': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⚙ Configuración del Gerente')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⏰ Horario de la Planta',
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
