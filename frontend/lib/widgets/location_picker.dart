import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/google_places_service.dart';

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;
  final String initialAddress;
  final Function(String, LatLng, String) onLocationSelected;

  const LocationPicker({
    super.key,
    required this.initialLocation,
    required this.initialAddress,
    required this.onLocationSelected,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng _selectedLocation;
  late TextEditingController _searchController;
  late TextEditingController _cityController;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _placePredictions = [];
  final GooglePlacesService _placesService = GooglePlacesService();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _searchController = TextEditingController(text: widget.initialAddress);
    _cityController = TextEditingController(text: "Riobamba");
    _updateMarker(_selectedLocation);
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId("selectedLocation"),
          position: position,
          draggable: true,
          onDragEnd: (LatLng newPos) {
            setState(() {
              _selectedLocation = newPos;
            });
          },
        ),
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _performSearch() async {
    String query = _searchController.text.trim();
    String city = _cityController.text.trim();

    if (query.isNotEmpty) {
      String fullQuery =
          "$query, $city"; // Agregar la ciudad para mayor precisión
      LatLng? location = await _placesService.getCoordinatesFromText(fullQuery);
      if (location != null) {
        _updateMarker(location);
      }
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      String city = _cityController.text.trim();
      String fullQuery = "$query, $city";
      List<Map<String, dynamic>> results =
          await _placesService.getPlaceAutocomplete(fullQuery);
      setState(() {
        _placePredictions = results;
      });
    } else {
      setState(() {
        _placePredictions = [];
      });
    }
  }

  void _onSelectPrediction(Map<String, dynamic> prediction) async {
    String placeId = prediction['place_id'];
    LatLng? location = await _placesService.getCoordinatesFromPlaceId(placeId);
    if (location != null) {
      _searchController.text = prediction['description'];
      _updateMarker(location);
      setState(() {
        _placePredictions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar Ubicación")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Buscar ubicación...",
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed:
                                _performSearch, // 🔍 Buscar al hacer clic en el ícono
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                        onSubmitted: (_) =>
                            _performSearch(), // 🔍 Buscar al presionar "Enter"
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: "Ciudad",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_placePredictions.isNotEmpty)
                  Container(
                    height: 200,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: _placePredictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_placePredictions[index]['description']),
                          onTap: () =>
                              _onSelectPrediction(_placePredictions[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: (LatLng position) {
                _updateMarker(position);
              },
            ),
          ),
          /* Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onLocationSelected(
                  _searchController.text,
                  _selectedLocation,
                  _cityController.text, // Enviar la ciudad también
                );
                Navigator.pop(context);
              },
              child: const Text("Confirmar Ubicación"),
            ),
          ), */
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "address": _searchController.text,
                  "location": _selectedLocation,
                  "city": _cityController.text,
                });
              },
              child: const Text("Confirmar Ubicación"),
            ),
          ),
        ],
      ),
    );
  }
}
