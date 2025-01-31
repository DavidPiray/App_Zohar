import 'package:flutter/material.dart';

enum AnimatedAlertType { success, error, info }

class AnimatedAlert {
  static void show(
    BuildContext context,
    String title,
    String message, {
    AnimatedAlertType type =
        AnimatedAlertType.info, // Tipo opcional con valor por defecto
    String actionLabel = 'Cerrar',
    VoidCallback? action,
  }) {
    // Determinar el color según el tipo
    Color backgroundColor;
    switch (type) {
      case AnimatedAlertType.success:
        backgroundColor = Colors.green;
        break;
      case AnimatedAlertType.error:
        backgroundColor = Colors.red;
        break;
      case AnimatedAlertType.info:
      default:
        backgroundColor = Colors.blue;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            child: Text(
              message.replaceAll('Exception:', '').trim(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                if (action != null) action(); // Ejecuta la acción, si existe
              },
              child: Text(
                actionLabel,
                style: TextStyle(color: backgroundColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
