import 'package:flutter/material.dart';

class CustomCardStyleTwo extends StatelessWidget {
  final String title;
  final List<String> states;
  final Color backgroundColor;
  final int currentIndex;

  const CustomCardStyleTwo({
    super.key,
    required this.title,
    required this.states,
    this.backgroundColor = const Color(0xFF3B945E),
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB8E994), // Light green
            Color(0xFF3B945E), // Dark green
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Título dinámico
          Text(
            states[currentIndex],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          // Icono del centro
          const Icon(
            Icons.menu,
            size: 50,
            color: Colors.white,
          ),
          // Título fijo
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
