import 'package:flutter/material.dart';

class MenuItems {
  static const Map<String, List<Map<String, dynamic>>> menuByRole = {
    'admin': [
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/dashboard'},
      {'title': 'Usuarios', 'icon': Icons.people, 'route': '/usuarios'},
      {'title': 'Pedidos', 'icon': Icons.list, 'route': '/pedidos'},
      {'title': 'Productos', 'icon': Icons.shopping_cart, 'route': '/productos'},
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
    'cliente': [
      {'title': 'Inicio', 'icon': Icons.home, 'route': '/cliente'},
      {'title': 'Perfil', 'icon': Icons.person, 'route': '/perfil-cliente'},
      {'title': 'Historial', 'icon': Icons.history, 'route': '/historial-cliente'},
      {'title': 'Pedidos', 'icon': Icons.list, 'route': '/pedidos-cliente'},
      {'title': 'Ayuda', 'icon': Icons.help, 'route': '/ayuda-cliente'},
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
    'distribuidor': [
      {'title': 'Inicio', 'icon': Icons.home, 'route': '/distribuidor'},
      {'title': 'Rutas', 'icon': Icons.map, 'route': '/rutas'},
      {'title': 'Pedidos Asignados', 'icon': Icons.assignment, 'route': '/pedidos-distribuidor'},
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
  };
}
