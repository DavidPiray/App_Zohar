import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';
import '../../widgets/animated_alert.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

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

      // Navegar según el rol
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'cliente') {
        Navigator.pushReplacementNamed(context, '/client');
      } else if (role == 'distribuidor') {
        Navigator.pushReplacementNamed(context, '/distributor');
      } else if (role == 'director') {
        Navigator.pushReplacementNamed(context, '/director');
      } else {
        throw Exception('Rol no válido');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      notifyListeners();
      AnimatedAlert.show(
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
