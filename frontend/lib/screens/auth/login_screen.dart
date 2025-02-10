import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/styles/colors.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/animated_title.dart';
import '../../widgets/login_form.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Altura personalizada
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.barra,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Sombrado sutil
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.degradadoPrincipal
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 600;

              return Row(
                children: [
                  if (isWideScreen) ...[
                    // Para pantallas grandes: logo y título a la izquierda
                    const Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedLogo(size: 150), // Logo grande
                          SizedBox(height: 20),
                          AnimatedTitle(),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: isWideScreen
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        if (!isWideScreen) ...[
                          // Para pantallas pequeñas: logo y título arriba
                          const SizedBox(height: 40),
                          const AnimatedLogo(size: 100), // Logo más pequeño
                          const SizedBox(height: 20),
                          const AnimatedTitle(),
                          const SizedBox(height: 40),
                        ],
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWideScreen ? 400 : 350,
                            ),
                            child: LoginForm(
                              emailController: emailController,
                              passwordController: passwordController,
                              authProvider: authProvider,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
