/* import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // 🔹 Escuchar la ubicación en tiempo real del distribuidor
  Stream<Position> trackLocation(String distributorId) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Se actualiza cada 10 metros
      ),
    ).map((position) {
      _updateLocation(distributorId, position);
      return position;
    });
  }

  // 🔹 Guardar la ubicación en Realtime Database
  void _updateLocation(String distributorId, Position position) {
    _dbRef.child("ubicaciones_distribuidores/$distributorId").set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 🔹 Obtener la ubicación en tiempo real del distribuidor
  Stream<DatabaseEvent> getDistributorLocation(String distributorId) {
    return _dbRef.child("ubicaciones_distribuidores/$distributorId").onValue;
  }
}
 */
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Los servicios de ubicación están desactivados.");
    }
    // Verifica permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            "Los permisos de ubicación están permanentemente denegados.");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están denegados permanentemente.');
    }

    // Obtiene la ubicación actual
    return await Geolocator.getCurrentPosition();
  }
}
