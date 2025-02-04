import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsService {
  final String apiKey;

  GoogleMapsService({required this.apiKey});

  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    print('origen: $origin');
    print('destino: $destination');
    print('api: $apiKey');

    final url =
        "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";

    print('Solicitando ruta a: $url');

    final response = await http.get(Uri.parse(url));

    print('Código de respuesta: ${response.statusCode}');
    print('Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.containsKey("error_message")) {
        throw Exception("Google API Error: ${data["error_message"]}");
      }

      if ((data["routes"] as List).isEmpty) {
        throw Exception("No se encontró una ruta.");
      }

      List<LatLng> polylineCoordinates = [];
      var steps = data["routes"][0]["legs"][0]["steps"];

      for (var step in steps) {
        polylineCoordinates.add(
          LatLng(
            step["start_location"]["lat"],
            step["start_location"]["lng"],
          ),
        );
        polylineCoordinates.add(
          LatLng(
            step["end_location"]["lat"],
            step["end_location"]["lng"],
          ),
        );
      }

      return polylineCoordinates;
    } else {
      throw Exception("Error al obtener la ruta: ${response.body}");
    }
  }
}
