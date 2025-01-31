import 'package:flutter/material.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/animated_title.dart';
import '../../core/styles/typography.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E994),
                  Color(0xFF6ABF69),
                  Color(0xFF3B945E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 600;

              return Row(
                children: [
                  if (isWideScreen) ...[
                    // Diseño para pantallas grandes
                    const Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedLogo(size: 150),
                          SizedBox(height: 30),
                          AnimatedTitle(),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isWideScreen) ...[
                          const AnimatedLogo(size: 100),
                          const SizedBox(height: 25),
                          const AnimatedTitle(),
                          const SizedBox(height: 25),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 52.0),
                          child: Column(
                            children: [
                              AnimatedButton(
                                label: 'Iniciar Sesión',
                                routeName: '/login',
                                backgroundColor: const Color(0xFF3B945E),
                                maxWidth: isWideScreen ? 300 : double.infinity,
                                textStyle: AppTypography.buttonText.copyWith(
                                  fontSize: isWideScreen ? 20 : 18,
                                ),
                              ),
                              const SizedBox(height: 26),
                              AnimatedButton(
                                label: 'Registrate',
                                routeName: '/register',
                                backgroundColor: const Color.fromARGB(255, 86, 168, 84),
                                maxWidth: isWideScreen ? 300 : double.infinity,
                                textStyle: AppTypography.buttonText.copyWith(
                                  fontSize: isWideScreen ? 20 : 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
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
