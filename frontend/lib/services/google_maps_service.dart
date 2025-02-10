import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsService {
  final String apiKey = dotenv.env['API_GOOGLE_KEY'] ?? ""; // 🔹 Leer API Key
  final Dio _dio = Dio();
  GoogleMapsService() {
    if (apiKey.isEmpty) {
      print("⚠ ERROR: No se encontró la API Key. Verifica el archivo .env");
    } else {
      print("✅ API Key cargada correctamente: $apiKey");
    }
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    print("Apikey: $apiKey");
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address&components=country:EC&key=$apiKey";

    try {
      Response response = await _dio.get(url);
      print("🔹 Respuesta de Google API: ${response.data}");
      if (response.statusCode == 200 &&
          response.data["status"] == "OK" &&
          response.data["results"].isNotEmpty) {
        double lat = response.data["results"][0]["geometry"]["location"]["lat"];
        double lng = response.data["results"][0]["geometry"]["location"]["lng"];
        return LatLng(lat, lng);
      } else {
        print("Error en la respuesta de Google Maps: ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error al obtener coordenadas: $e");
      return null;
    }
  }

  Future<LatLng?> getCoordinatesFromText(String address,
      {String city = "Riobamba"}) async {
    try {
      String fullAddress =
          "$address, $city"; // Concatenar la ciudad para mayor precisión

      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "address": fullAddress,
          "key": apiKey,
          "region": "ec",
        },
      );

      if (response.statusCode == 200 &&
          response.data["status"] == "OK" &&
          response.data["results"].isNotEmpty) {
        final location = response.data["results"][0]["geometry"]["location"];
        return LatLng(location["lat"], location["lng"]);
      } else {
        print("❌ Error en la respuesta de Google Maps: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error en getCoordinatesFromText: $e");
      return null;
    }
  }
}
