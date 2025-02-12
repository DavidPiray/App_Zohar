import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../../widgets/animated_alert.dart';
import '../services/client_service.dart';
import '../services/distributor_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Variables
  bool _isLoading = false;
  String _errorMessage = '';
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Función de Login
  Future<void> login(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      // Llamar al servicio de autenticación
      final result = await _authService.login(email, password);

      // Validar y decodificar el token
      final String? token = result as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Token inválido o vacío');
      }
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Obtener los roles del token
      final roles = decodedToken['roles'];
      if (roles == null || roles is! List || roles.isEmpty) {
        throw Exception('El token no contiene roles válidos');
      }

      // Obtener el primer rol del array
      final String role = roles.first;

      // Guardar el rol
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('rol', role);

      // Navegar según el rol
      if (role == 'admin') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'cliente') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/cliente');

        // Para guardar los datos escenciales del cliente
        final clientData = await ClientService().getClientData();
        await prefs.setString('clienteID', clientData['id_cliente']);

        await prefs.setString('distribuidorID', clientData['distribuidorID']);
      } else if (role == 'distribuidor') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/distribuidor');

        // Para guardar los datos escenciales del distribuidor
        final distribuidorData =
            await DistributorService().getDistributorByEmail();
        await prefs.setString(
            'DistribuidorID', distribuidorData['id_distribuidor']);
      } else if (role == 'gerente') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/gerente');
      } else {
        throw Exception('Rol no válido');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Error de Inicio de Sesión',
        e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
