import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/styles/colors.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';

class ManagerMapScreen extends StatefulWidget {
  const ManagerMapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManagerMapScreenState createState() => _ManagerMapScreenState();
}

class _ManagerMapScreenState extends State<ManagerMapScreen> {
  // Variables Globales
  // ignore: unused_field
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _loading = true;
  final LatLng _initialPosition = const LatLng(-1.658501, -78.654890);
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("distribuidores");
  final Map<String, BitmapDescriptor> _markerColors =
      {}; // Mapa para almacenar colores únicos por distribuidor

  @override
  void initState() {
    super.initState();
    _listenToDistributors();
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
              children: [
                const Text(
                  "📍 Distribuidores Activos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition,
                            zoom: 12,
                          ),
                          markers: _markers,
                          onMapCreated: (controller) =>
                              _mapController = controller,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Obtener distribuidores para cache
  Future<Map<String, dynamic>?> _getDistributorFromCache(String id) async {
    final docRef =
        FirebaseFirestore.instance.collection("distribuidor").doc(id);
    try {
      // obtener desde caché los datos
      final docSnapshot =
          await docRef.get(const GetOptions(source: Source.cache));

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      print(" Error al obtener desde caché: $e");
    }
    // Si no está en caché, intentamos obtenerlo desde el servidor
    try {
      final freshSnapshot =
          await docRef.get(); // Sin opciones → Obtiene de Firestore
      if (freshSnapshot.exists) {
        return freshSnapshot.data();
      }
    } catch (e) {
      print("Error al obtener desde Firestore: $e");
    }
    return null; // Si no encuentra datos, retorna `null`
  }

  // Escuchar en Realtime Database las ubicaciones
  void listenToDistributorLocations() {
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref("distribuidores");
    databaseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;
      Set<Marker> tempMarkers = {};
      data.forEach((key, location) async {
        // Solo procesamos la ubicación
        double? lat = double.tryParse(location['latitud'].toString());
        double? lng = double.tryParse(location['longitud'].toString());
        if (lat != null && lng != null) {
          // Asignar color único si no lo tiene
          if (!_markerColors.containsKey(key)) {
            _markerColors[key] = await _getRandomMarkerColor();
          }
          tempMarkers.add(
            Marker(
              markerId: MarkerId(key),
              position: LatLng(lat, lng),
              icon: _markerColors[key]!,
              infoWindow: InfoWindow(
                title: "Distribuidor $key",
                snippet: "Toca para ver detalles",
                onTap: () => _showDistributorInfo(key),
              ),
            ),
          );
        }
      });
      setState(() {
        _markers = tempMarkers;
        _loading = false;
      });
    });
  }

  // Escuchar cambios en Firebase Realtime Database
  void _listenToDistributors() {
    _databaseRef.onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;
      if (data == null || data is! Map<dynamic, dynamic>) {
        setState(() {
          _loading = false;
        });
        return;
      }
      Set<Marker> tempMarkers = {};
      for (var key in data.keys) {
        var location = data[key];
        double? lat = double.tryParse(location['latitude'].toString());
        double? lng = double.tryParse(location['longitude'].toString());
        if (lat != null && lng != null) {
          // Obtener información del distribuidor desde Firestore
          Map<String, dynamic>? distributorInfo =
              await _getDistributorFromCache(key);
          // Validar si se obtuvo correctamente la info
          String nombre = distributorInfo?['nombre'] ?? 'Distribuidor $key';
          String celular = distributorInfo?['celular'] ?? 'No disponible';
          String id = key;
          // Esperar el color del marcador antes de asignarlo
          BitmapDescriptor markerIcon = _markerColors[key] ??
              await _getRandomMarkerColor(); // Si no tiene color, lo asigna
          _markerColors[key] = markerIcon; // Guardar el color asignado
          tempMarkers.add(
            Marker(
              markerId: MarkerId(key),
              position: LatLng(lat, lng),
              icon: markerIcon, // Usar el color generado
              infoWindow: InfoWindow(
                title: nombre, // Mostrar nombre del distribuidor
                snippet: "📞 $celular\n🆔 ID: $id", // Mostrar celular y ID
                onTap: () => _showDistributorInfo(key),
              ),
            ),
          );
        }
      }
      setState(() {
        _markers = tempMarkers;
        _loading = false;
      });
    });
  }

  // Generar un color aleatorio para los marcadores
  Future<BitmapDescriptor> _getRandomMarkerColor() async {
    List<double> hues = [
      BitmapDescriptor.hueBlue,
      BitmapDescriptor.hueCyan,
      BitmapDescriptor.hueGreen,
      BitmapDescriptor.hueMagenta,
      BitmapDescriptor.hueOrange,
      BitmapDescriptor.hueRose,
      BitmapDescriptor.hueViolet,
      BitmapDescriptor.hueYellow
    ];
    double randomHue = hues[Random().nextInt(hues.length)];
    return BitmapDescriptor.defaultMarkerWithHue(randomHue);
  }

  // Mostrar información del distribuidor
  void _showDistributorInfo(String distributorId) async {
    final distributor = await _getDistributorFromCache(distributorId);
    if (distributor == null) {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        "Error",
        "No se encontraron datos del distribuidor.",
        type: AnimatedAlertType.error,
      );
      return;
    }
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(distributor['nombre']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 Zona: ${distributor['zonaAsignada']}'),
              Text('📞 Teléfono: ${distributor['celular'] ?? "No disponible"}'),
              Text('📧 Email: ${distributor['email'] ?? "No disponible"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
