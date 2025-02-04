import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  final List<LatLng> route;

  const MapScreen({Key? key, required this.route}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _distributorPosition;
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getDistributorLocation();
  }

  Future<void> _getDistributorLocation() async {
    try {
      final position = await locationService.getCurrentLocation();
      setState(() {
        _distributorPosition = LatLng(position.latitude, position.longitude);
      });
      _moveCameraToDistributor();
    } catch (e) {
      print("Error al obtener ubicación: $e");
    }
  }

  void _moveCameraToDistributor() {
    if (_mapController != null && _distributorPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_distributorPosition!, 15.0), // 🔹 Zoom centrado
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seguimiento de Pedido")),
      body: _distributorPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _distributorPosition!, // 🔹 Centrar en el distribuidor
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _moveCameraToDistributor(); // 🔹 Mover la cámara cuando el mapa esté listo
              },
              markers: {
                Marker(
                  markerId: const MarkerId('distributor'),
                  position: _distributorPosition!,
                  infoWindow: const InfoWindow(title: 'Ubicación Actual'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
                if (widget.route.isNotEmpty)
                  Marker(
                    markerId: const MarkerId('client'),
                    position: widget.route.last,
                    infoWindow: const InfoWindow(title: 'Destino'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: widget.route,
                  color: Colors.blue,
                  width: 5,
                ),
              },
            ),
    );
  }
}
