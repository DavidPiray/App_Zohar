import 'package:flutter/material.dart';

class AppColors {
  static const Color lightGreen = Color(0xFFB8E994);
  static const Color mediumGreen = Color(0xFF6ABF69);
  static const Color darkGreen = Color.fromARGB(255, 59, 148, 94);
  static const Color bar = Color(0xFF375534);
  static const Color barra = Color(0xFF3B945E);
  static const Color barraLateral = Color(0xFF3B945E);
  static const Color form = Color(0xFFAEC380);
  static const Color back = Color(0xFFE3EED4);

  // Definir un gradiente global
  static const LinearGradient degradadoPrincipal = LinearGradient(
    colors: [
      lightGreen,  
      mediumGreen, 
      darkGreen,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
