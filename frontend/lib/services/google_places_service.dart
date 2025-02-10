import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GooglePlacesService {
  final Dio _dio = Dio();
  final String apiKey = dotenv.env['API_GOOGLE_KEY'] ?? "";

  GooglePlacesService() {
    print(
        "🔑 API Key: $apiKey"); // Agrega este print antes de hacer la solicitud
    _dio.options.baseUrl =
        "https://maps.googleapis.com/maps/api/place/";
  }

  /// 📌 Obtiene sugerencias de direcciones en base a un texto
  Future<List<Map<String, dynamic>>> getPlaceAutocomplete(String input) async {
    try {
      final response = await _dio.get(
        "autocomplete/json",
        queryParameters: {
          "input": input,
          "types": "geocode",
          "key": apiKey,
          "components": "country:EC", // Filtra solo direcciones de Ecuador
        },
      );

      if (response.statusCode == 200 && response.data["status"] == "OK") {
        return List<Map<String, dynamic>>.from(response.data["predictions"]);
      } else {
        print("❌ Error en autocompletado: ${response.data}");
        return [];
      }
    } catch (e) {
      print("❌ Error en getPlaceAutocomplete: $e");
      return [];
    }
  }

  /// 📌 Obtiene detalles de una ubicación a partir de su `place_id`
  Future<LatLng?> getCoordinatesFromPlaceId(String placeId) async {
    try {
      final response = await _dio.get(
        "details/json",
        queryParameters: {
          "place_id": placeId,
          "key": apiKey,
        },
      );

      if (response.statusCode == 200 &&
          response.data["status"] == "OK" &&
          response.data["result"] != null) {
        final location = response.data["result"]["geometry"]["location"];
        return LatLng(location["lat"], location["lng"]);
      } else {
        print("❌ Error obteniendo coordenadas: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error en getCoordinatesFromPlaceId: $e");
      return null;
    }
  }

  Future<LatLng?> getCoordinatesFromText(String address) async {
    try {
      print("🔍 Buscando coordenadas para: $address");
      print("🔑 API Key: $apiKey");

      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/geocode/json",
        queryParameters: {
          "address": address,
          "key": apiKey,
          "region": "ec", // 🔹 Restringe búsqueda a Ecuador
        },
      );

      print("🔹 Respuesta de Google API: ${response.data}");

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
