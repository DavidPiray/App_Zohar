import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/styles/colors.dart';
import '../../widgets/wrapper.dart';

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

  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "distribuidor",
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
                  "⚙ Configuración",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
                      _buildExpandableItem(
                        "Horario",
                        Icons.access_time,
                        _buildTimeSettings(),
                      ),
                      /* _buildExpandableItem(
                        "Notificaciones",
                        Icons.notifications,
                        Center(child: Text("Configuración de Notificaciones")),
                      ), */
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
        const Text(
          '⏰ Horario del Distribuidor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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

  Future<void> _loadDistributorID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      distribuidorID = prefs.getString("distribuidorID") ?? "default";
    });

    _loadSettings();
  }

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
      _saveSettings();
    }
  }

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
  }

  Widget _buildHelpContent() {
    return SizedBox(
      height: 400, // Ajusta la altura según necesidad
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildHelpItem(
            icon: Icons.person,
            title: 'Perfil y Configuración',
            description:
                'Desde este apartado puedes ver tu información personal y actualizar tu contraseña.\n\n'
                '--> En "Perfil" puedes ver y modificar tus datos personales.\n\n'
                '--> Si deseas cambiar tu contraseña, selecciona la opción "Cambiar Contraseña".',
          ),
          _buildHelpItem(
            icon: Icons.local_shipping,
            title: 'Inventario',
            description: 'Consulta el inventario que dispone.\n\n'
                '--> Puedes ver la cantidad de productos en stock.',
          ),
          _buildHelpItem(
            icon: Icons.add_shopping_cart,
            title: 'Reportes',
            description: 'Consulta la cantidad de producto vendido.\n\n'
                '--> En la sección "Productos", elige los artículos que necesitas y selecciona la cantidad.\n\n'
                '--> Al confirmar la solicitud, recibirás una notificación cuando el pedido esté aprobado.',
          ),
          _buildHelpItem(
            icon: Icons.delivery_dining,
            title: 'Entregar pedido',
            description:
                'Se podrá visualizar los pedidos que puede realizar.\n\n'
                '--> Podrá seleccionar entregar para comenzar la ruta hacia el cliente.\n\n'
                '--> Podrá seleccionar completado cuando haya finalizado la entrega.\n\n'
                '--> Podrá filtrar los pedidos con los filtros en la parte superior.',
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
