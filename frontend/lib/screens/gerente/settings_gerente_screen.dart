import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/styles/colors.dart';
import '../../widgets/wrapper.dart';

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

  Future<void> _saveSettings() async {
    await _firestore.collection('configuracion').doc('horarios').set({
      'openingHour': _openingTime.hour,
      'openingMinute': _openingTime.minute,
      'closingHour': _closingTime.hour,
      'closingMinute': _closingTime.minute,
    });
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

  Future<void> _notifyDirectorScreen() async {
    await _firestore
        .collection('configuracion')
        .doc('horarios')
        .update({'lastUpdated': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "gerente",
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          color: AppColors.back,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "⚙ Configuración del Gerente",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
                      _buildExpandableItem(
                        "Horario de la Planta",
                        Icons.access_time,
                        _buildTimeSettings(),
                      ),
                      _buildExpandableItem(
                        "Notificaciones",
                        Icons.notifications,
                        Center(child: Text("Configuración de Notificaciones")),
                      ),
                      _buildExpandableItem(
                        "Soporte",
                        Icons.support,
                        _buildHelpContent(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableItem(String title, IconData icon, Widget content) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: content,
        ),
      ],
    );
  }

  Widget _buildTimeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildHelpContent() {
    return SizedBox(
      height: 400, // Establece una altura fija adecuada
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Evita conflictos de scroll
        children: [
          _buildHelpItem(
            icon: Icons.shopping_cart,
            title: 'Productos',
            description:
                'Administra el catálogo de productos, agrega nuevos, actualiza precios y controla el stock disponible.\n\n'
                '--> Para modificar un producto puede presionar cualquier producto de la lista y podrá modificarlo.\n\n'
                '--> Para agregar un producto puede dar clic en el botón de la parte inferior llamado Agregar producto.',
          ),
          _buildHelpItem(
            icon: Icons.people,
            title: 'Distribuidores',
            description:
                'Gestiona la información de los distribuidores y revisa su estado de actividad.\n\n'
                '--> Puede seleccionar a un distribuidor y podrá ver su información, además podrá modificarlo o eliminarlo.\n\n'
                '--> Podrá filtrar a los distribuidores con los filtros del lado izquierdo.',
          ),
          _buildHelpItem(
            icon: Icons.bar_chart,
            title: 'Reportes',
            description:
                'Genera informes de ventas, inventario y desempeño para tomar decisiones estratégicas.\n\n'
                '--> Podrá filtrar los reportes con la barra de filtro en el lado izquierdo.',
          ),
          _buildHelpItem(
            icon: Icons.info,
            title: '¿Quiénes somos?',
            description:
                'Zohar es una empresa especializada en la distribución de agua embotellada, '
                'ofreciendo productos de alta calidad en distintas presentaciones para satisfacer las necesidades de nuestros clientes. '
                'Nos comprometemos con la pureza, frescura y disponibilidad de nuestros productos, brindando un servicio confiable y eficiente. '
                'Si necesitas más información, no dudes en contactarnos. 💧✨',
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Para más detalles, consulta la documentación o contacta a los números de soporte. \n 099241179 o 0986250187',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
      {required IconData icon,
      required String title,
      required String description}) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 30),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            description,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
