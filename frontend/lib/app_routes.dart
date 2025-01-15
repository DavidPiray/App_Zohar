import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/client/client_screen.dart';
import 'screens/client/registration_screen.dart';
import 'screens/distributor/distributor_screen.dart';
import 'screens/distributor/inventory_screen.dart'; 
import 'screens/utils/map_screen.dart'; 
import 'screens/home/main_screen.dart'; 
import 'screens/home/director_screen.dart'; 
import 'screens/director/listdistribuidor_screen.dart'; 
import 'screens/director/listproductos_screen.dart'; 
import 'views/home/new.dart'; 

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginScreen(),
    '/admin': (context) => AdminScreen(),
    '/client': (context) => ClientScreen(),
    '/distributor': (context) => DistributorScreen(),
    '/inventory_screen': (context) => InventoryScreen(),
    '/register': (context) => RegisterScreen(),
    '/map': (context) => MapScreen(),
    '/main': (context) => MainScreen(),
    '/director': (context) => DirectorScreen(),
    '/listDistribuidor': (context) => ListdistribuidorScreen(),
    '/listProductos': (context) => ListProductScreen(),
    '/new': (context) => ResponsiveDashboard(),
  };
}
