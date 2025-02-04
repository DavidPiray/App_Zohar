import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Importa kIsWeb
import '../core/config/dio_config.dart';
import '../core/config/api_urls.dart';

class ClientService {
  final Dio _dio = DioClient(ApiEndpoints.securityService).dio;
  final Dio _dio2 = DioClient(ApiEndpoints.customerService).dio;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para registro
  Future<bool> registerClient({
    required String name,
    required String email,
    required String address,
    required String phone,
    required String zonaID,
    String? distribuidorID,
    String? photoURL,
    required String password,
    required LatLng location,
  }) async {
    try {
      // Registrar el cliente
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
        'roles': ['cliente'],
      });

      if (response.statusCode == 201) {
        try {
          print("Intentando registrar en: ${_dio2.options.baseUrl}");

          final response2 = await _dio2.post('/', data: {
            'nombre': name,
            'email': email,
            'direccion': address,
            'celular': phone,
            'zonaID': zonaID,
            'distribuidorID': distribuidorID,
            'ubicacion': {
              'latitude': location.latitude.toDouble(),
              'longitude': location.longitude.toDouble(),
            },
          });

          print(
              "Código de estado del segundo request: ${response2.statusCode}");
          print("Datos enviados");

          if (response2.statusCode == 201) {
            print("Registro segundo exitoso");
            return true;
          } else {
            print("Error en el segundo registro: ${response2.data}");
            throw Exception('Error al registrar cliente: ${response2.data}');
          }
        } catch (e) {
          print("❌ Error al hacer la segunda solicitud: $e");
          return false;
        }
      } else {
        throw Exception('Error al registrar cliente: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error en el registro del cliente: $error');
    }
  }

  // Método para obtener datos del cliente
  Future<Map<String, dynamic>> getClientData() async {
    try {
      // Obtiene el correo de la sesión actual
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email'); // Obtiene el email de la sesión
      if (email == null || email.isEmpty) {
        throw Exception('Correo del usuario no encontrado en la sesión.');
      }
      // Busca el cliente en la base de datos por correo
      final response = await _dio2.get('/buscar', queryParameters: {
        'email': email, // Filtra por correo
      });
      if (response.statusCode == 200) {
        final List<dynamic> customers = response.data;
        // Verifica que se hayan encontrado resultados
        if (customers.isEmpty) {
          throw Exception('Cliente no encontrado.');
        }
        return customers.first as Map<String, dynamic>;
      } else {
        throw Exception(
            'Error al obtener los datos del cliente: ${response.data}');
      }
    } on DioException catch (dioError) {
      // Manejo de errores específicos de Dio
      if (dioError.response?.statusCode == 404) {
        throw Exception('Cliente no encontrado en el servidor.');
      }
      throw Exception(
          'Error en la comunicación con el servidor: ${dioError.message}');
    } catch (error) {
      throw Exception('Error al obtener los datos del cliente: $error');
    }
  }

  // Metodo para buscar cliente
  Future<Map<String, dynamic>> searchClientData(String clientID) async {
    try {
      // Busca el cliente en la base de datos por correo
      final response = await _dio2.get('/$clientID');
      if (response.statusCode == 200) {
        final List<dynamic> customers = response.data;
        // Verifica que se hayan encontrado resultados
        if (customers.isEmpty) {
          throw Exception('Cliente no encontrado.');
        }
        return customers.first as Map<String, dynamic>;
      } else {
        throw Exception(
            'Error al obtener los datos del cliente: ${response.data}');
      }
    } on DioException catch (dioError) {
      // Manejo de errores específicos de Dio
      if (dioError.response?.statusCode == 404) {
        throw Exception('Cliente no encontrado en el servidor.');
      }
      throw Exception(
          'Error en la comunicación con el servidor: ${dioError.message}');
    } catch (error) {
      throw Exception('Error al obtener los datos del cliente: $error');
    }
  }

  // Obtener ubicacion
  Future<Map<String, dynamic>?> getCustomerLocation(String customerId) async {
    try {
      DocumentSnapshot customerDoc =
          await _firestore.collection('clientes').doc(customerId).get();

      if (customerDoc.exists && customerDoc.data() != null) {
        var customerData = customerDoc.data() as Map<String, dynamic>;
        if (customerData.containsKey('ubicacion')) {
          return {
            'latitude': customerData['ubicacion']['latitude'],
            'longitude': customerData['ubicacion']['longitude'],
          };
        }
      }
      return null;
    } catch (e) {
      print("Error al obtener la ubicación del cliente: $e");
      return null;
    }
  }

  // Método para actualizar datos del cliente
  Future<bool> updateClientData({
    required String clientId, // ID único del cliente
    String? name,
    String? phone,
    String? direccion,
    dynamic photo, // Puede ser `File` (Móvil) o `Uint8List` (Web)
    String? photoURL, // URL de la imagen en Firebase
  }) async {
    try {
      // Si el usuario ha seleccionado una nueva imagen, súbela a Firebase Storage
      if (photo != null) {
        photoURL = await uploadImage(photo);
      }

      // Datos a enviar
      final Map<String, dynamic> data = {
        'nombre': name,
        'celular': phone,
        'direccion': direccion,
        if (photoURL != null)
          'foto': photoURL, // Solo envía si hay una nueva foto
      };

      // Enviar actualización al servidor
      final response = await _dio2.put('/$clientId', data: data);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Error al actualizar los datos del cliente: ${response.data}');
      }
    } catch (error) {
      throw Exception('Error al actualizar datos del cliente: $error');
    }
  }

  Future<Map<String, String>> getClientInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? clienteID = prefs.getString('clienteID');
    String? distribuidorID = prefs.getString('distribuidorID') ?? 'Planta';

    if (clienteID == null) {
      throw Exception('No se encontró el ID del cliente en la sesión.');
    }

    return {'clienteID': clienteID, 'distribuidorID': distribuidorID};
  }

  // Método para subir imagen
  Future<String?> uploadImage(dynamic image) async {
    if (image == null) return null;

    try {
      String fileName = 'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask;

      if (kIsWeb) {
        // 🔹 Web usa `Uint8List`, subimos con `putData()`
        Uint8List bytes = image as Uint8List;
        uploadTask = storageRef.putData(bytes);
      } else {
        // 🔹 Android/iOS usa `File`, subimos con `putFile()`
        File file = image as File;
        uploadTask = storageRef.putFile(file);
      }

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  // Método para seleccionar imagen compatible con Web y móviles
  Future<dynamic> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    if (kIsWeb) {
      Uint8List bytes = await pickedFile.readAsBytes();
      return bytes; // Web usa `Uint8List`
    } else {
      return File(pickedFile.path); // Android/iOS usa archivo `File`
    }
  }
}
