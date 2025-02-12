import 'package:flutter/material.dart';

class MenuItems {
  static const Map<String, List<Map<String, dynamic>>> menuByRole = {
    'admin': [
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/dashboard'},
      {'title': 'Usuarios', 'icon': Icons.people, 'route': '/usuarios'},
      {'title': 'Pedidos', 'icon': Icons.list, 'route': '/pedidos'},
      {
        'title': 'Productos',
        'icon': Icons.shopping_cart,
        'route': '/productos'
      },
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
    'cliente': [
      {'title': 'Inicio', 'icon': Icons.home, 'route': '/cliente'},
      {'title': 'Perfil', 'icon': Icons.person, 'route': '/perfil-cliente'},
      {
        'title': 'Historial',
        'icon': Icons.history,
        'route': '/historial-cliente'
      },
      {
        'title': 'Configuraciones',
        'icon': Icons.settings,
        'route': '/configuracion-cliente'
      },
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
    'distribuidor': [
      {'title': 'Inicio', 'icon': Icons.home, 'route': '/distribuidor'},
      {
        'title': 'Perfil',
        'icon': Icons.person,
        'route': '/perfil-distribuidor'
      },
      {
        'title': 'Inventario',
        'icon': Icons.water_drop,
        'route': '/inventario-distribuidor'
      },
      {
        'title': 'Reportes',
        'icon': Icons.description,
        'route': '/reporte-distribuidor'
      },
      {
        'title': 'Configuraciones',
        'icon': Icons.settings,
        'route': '/configuracion-distribuidor'
      },
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
    'gerente': [
      {'title': 'Menu', 'icon': Icons.home, 'route': '/gerente'},
      {'title': 'Perfil', 'icon': Icons.person, 'route': '/perfil-gerente'},
      {
        'title': 'Distribuidores',
        'icon': Icons.local_shipping,
        'route': '/lista-distribuidores'
      },
      {'title': 'Mapa', 'icon': Icons.map, 'route': '/mapa-gerente'},
      {'title': 'Clientes', 'icon': Icons.groups, 'route': '/lista-clientes'},
      {
        'title': 'Productos',
        'icon': Icons.shopping_cart,
        'route': '/lista-productos'
      },
      {
        'title': 'Reportes',
        'icon': Icons.description,
        'route': '/reporte-gerente'
      },
      {
        'title': 'Configuraciones',
        'icon': Icons.settings,
        'route': '/configuracion-gerente'
      },
      {'title': 'Salir', 'icon': Icons.logout, 'route': '/logout'},
    ],
  };
}
