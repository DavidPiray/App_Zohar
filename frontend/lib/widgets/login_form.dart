import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../widgets/global_button.dart';
import '../../widgets/animated_alert.dart';
import '../../providers/auth_provider.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final AuthProvider authProvider;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth > 600 ? 400 : double.infinity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                labelStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 25),
            GlobalButton(
                label: 'Iniciar Sesión',
                backgroundColor: const Color(0xFF3B945E),
                onPressed: () async {
                  // Validación
                  final emailError =
                      Validators.validateEmail(emailController.text);
                  final passwordError =
                      Validators.validatePassword(passwordController.text);

                  if (emailError != null || passwordError != null) {
                    AnimatedAlert.show(
                      context,
                      'Error de Validación',
                      emailError ?? passwordError!,
                    );
                    return;
                  }

                  // Intentar iniciar sesión
                  try {
                    await authProvider.login(
                      emailController.text,
                      passwordController.text,
                      context,
                    );
                  } catch (e) {
                    // Mostrar alerta animada en caso de error
                    AnimatedAlert.show(
                      context,
                      'Error de Inicio de Sesión',
                      e.toString(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
