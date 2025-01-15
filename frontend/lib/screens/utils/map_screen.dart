// Selección de Ubicación
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isDenied) {
    // Muestra un diálogo o una advertencia
  }
}


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

  // Posición inicial del mapa
  static const LatLng _initialPosition = LatLng(-1.648920, -78.677108);

  // Marcadores dinámicos
  final Set<Marker> _markers = {};

  // Polilíneas dinámicas
  final Set<Polyline> _polylines = {};

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear(); // Limpiar marcadores previos
      _markers.add(Marker(
        markerId: MarkerId('selected-location'),
        position: position,
      ));
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una ubicación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            onTap: _onMapTapped,
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              child: Text('Confirmar Ubicación'),
            ),
          ),
        ],
      ),
    );
  }
}