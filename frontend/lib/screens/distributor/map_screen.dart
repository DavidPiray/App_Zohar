import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final String orderId;
  final LatLng clientLocation;

  const MapScreen(
      {super.key, required this.orderId, required this.clientLocation});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  StreamSubscription<Position>? positionStream;
  GoogleMapController? _mapController;
  LatLng? _distributorLocation;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

//Cosntructor de incio de pagina
  @override
  void initState() {
    super.initState();
    _listenToDistributorLocation();
    // Escuchar la ubicación en tiempo real
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      if (!mounted) return; // Evitar llamar setState() después de dispose()
      setState(() {
        print(
            " Actualizando posición: ${position.latitude}, ${position.longitude}");
      });
    });
  }

//Cosntructor de incio de página
  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId("client"),
        position: widget.clientLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      if (_distributorLocation != null)
        Marker(
          markerId: const MarkerId("distributor"),
          position: _distributorLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
    };
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa en Tiempo Real")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.clientLocation,
          zoom: 14,
        ),
        markers: markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openGoogleMapsNavigation,
        child: const Icon(Icons.navigation),
      ),
    );
  }

  @override
  void dispose() {
    positionStream?.cancel(); // 🔹 Cancelar la escucha al cerrar la pantalla
    super.dispose();
  }

//Localización del distribuidor
  void _listenToDistributorLocation() {
    _database.child('ubicaciones/${widget.orderId}').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _distributorLocation = LatLng(data['latitude'], data['longitude']);
        });

        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_distributorLocation!),
          );
        }
      }
    });
  }

//Navegación en el mapa
  Future<void> _openGoogleMapsNavigation() async {
    if (_distributorLocation == null) return;

    String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=${_distributorLocation!.latitude},${_distributorLocation!.longitude}&destination=${widget.clientLocation.latitude},${widget.clientLocation.longitude}&travelmode=driving";

    Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }
}
