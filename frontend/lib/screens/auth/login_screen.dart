import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Asegúrate de añadir esta dependencia
import '../../api/api_service.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    void _showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }

    void _showSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }

    void _login() async {
      try {
        // Llamar al servicio de login
        final result = await apiService.login(
          emailController.text,
          passwordController.text,
        );

        // Validar y decodificar el token
        final String token = result['token'];
        if (token.isNotEmpty) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
          print('Token decodificado: $decodedToken');

          // Manejar roles como un array
          final roles = decodedToken['roles'];
          if (roles == null || roles is! List || roles.isEmpty) {
            throw Exception('El token no contiene roles válidos');
          }

          // Obtener el primer rol del array
          final String role = roles.first;
          print('Rol detectado: $role');

          // Navegar según el rol
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/director');
          } else if (role == 'cliente') {
            Navigator.pushReplacementNamed(context, '/client');
          } else if (role == 'distribuidor') {
            Navigator.pushReplacementNamed(context, '/distributor');
          } else if (role == 'director') {
            Navigator.pushReplacementNamed(context, '/director');
          } else {
            _showSnackbar('Rol no válido');
          }
        } else {
          throw Exception('Token inválido o vacío');
        }
      } catch (e) {
        _showErrorDialog('Error: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3B945E), // Color acorde a main screen
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
      ),
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E994), // Light green
                  Color(0xFF6ABF69), // Medium green
                  Color(0xFF3B945E), // Dark green
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido a ZOHAR Agua Purificada',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle:
                        TextStyle(color: Colors.black), // Texto más oscuro
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8), // Fondo más opaco
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                      color: Colors.black), // Texto del usuario más oscuro
                ),
                SizedBox(height: 15.h),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle:
                        TextStyle(color: Colors.black), // Texto más oscuro
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8), // Fondo más opaco
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(
                      color: Colors.black), // Texto del usuario más oscuro
                ),
                SizedBox(height: 25.h),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B945E),
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 50.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
