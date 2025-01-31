import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final String label;
  final String routeName;
  final Color backgroundColor;
  final double? maxWidth;
  final TextStyle? textStyle;

  const AnimatedButton({
    required this.label,
    required this.routeName,
    required this.backgroundColor,
    this.maxWidth,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? (screenWidth > 600 ? 300 : double.infinity),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, routeName);
          },
          borderRadius: BorderRadius.circular(30),
          splashColor: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.9),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 46, 46, 46).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: textStyle ?? const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

