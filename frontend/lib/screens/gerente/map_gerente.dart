import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/services/distributor_service.dart';

class ManagerMapScreen extends StatefulWidget {
  const ManagerMapScreen({super.key});

  @override
  _ManagerMapScreenState createState() => _ManagerMapScreenState();
}

class _ManagerMapScreenState extends State<ManagerMapScreen> {
  final DistributorService distributorService = DistributorService();
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  bool _loading = true;
  LatLng _initialPosition =
      const LatLng(-1.658501, -78.654890); // Centro del mapa

  @override
  void initState() {
    super.initState();
    _loadDistributors();
  }

  // 🔹 Obtener distribuidores activos
  Future<void> _loadDistributors() async {
    try {
      final distributors = await distributorService.getDistributors();
      final activeDistributors =
          distributors.where((d) => d['estado'] == 'activo').toList();

      Set<Marker> tempMarkers = {};

      for (var distributor in activeDistributors) {
        if (distributor.containsKey('ubicacion') &&
            distributor['ubicacion'].containsKey('latitud') &&
            distributor['ubicacion'].containsKey('longitud')) {
          double? lat =
              double.tryParse(distributor['ubicacion']['latitud'].toString());
          double? lng =
              double.tryParse(distributor['ubicacion']['longitud'].toString());

          if (lat != null && lng != null) {
            tempMarkers.add(
              Marker(
                markerId: MarkerId(distributor['id_distribuidor']),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: distributor['nombre'],
                  snippet:
                      '📦 Ventas: ${distributor['ventasTotales'] ?? 0} - 💰 Ingresos: \$${distributor['ingresosTotales'] ?? 0}',
                  onTap: () => _showDistributorInfo(distributor),
                ),
              ),
            );
          } else {
            print(
                "⚠ Error en coordenadas: ${distributor['id_distribuidor']} -> lat:$lat, lng:$lng");
          }
        } else {
          print(
              "⚠ Distribuidor sin ubicación: ${distributor['id_distribuidor']}");
        }
      }

      setState(() {
        _markers = tempMarkers;
        _loading = false;
      });
    } catch (error) {
      print("❌ Error cargando distribuidores: $error");
      setState(() => _loading = false);
    }
  }

  // 🔹 Mostrar información del distribuidor en un modal
  void _showDistributorInfo(Map<String, dynamic> distributor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(distributor['nombre']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📍 Ubicación: ${distributor['zonaAsignada']}'),
              Text('📦 Ventas Totales: ${distributor['ventasTotales'] ?? 0}'),
              Text(
                  '💰 Ingresos Totales: \$${distributor['ingresosTotales'] ?? 0}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📍 Distribuidores Activos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
            ),
    );
  }
}
