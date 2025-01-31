import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/recover_password_screen.dart';
import 'screens/admin/admin_screen.dart';
// Para clientes
import 'screens/client/client_screen.dart';
import 'screens/client/registration_screen.dart';
import 'screens/client/profile_screen.dart';
import 'screens/client/orders_history_screen.dart';
// Para distribuidores
import 'screens/distributor/distributor_screen.dart';
import 'screens/distributor/inventory_screen.dart';
import 'screens/distributor/profile_screen.dart';
import 'screens/reports/report_distributor_screen.dart';
// Para Director
import 'screens/director/listdistribuidor_screen.dart';
import 'screens/director/listproductos_screen.dart';
import 'screens/director/reports_screen.dart';
// Extras
import 'screens/utils/map_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/home/director_screen.dart';
import 'views/home/new.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginScreen(),
    '/admin': (context) => AdminScreen(),
    '/recuperar cuenta': (context) => const RecoverPasswordScreen(),
    // Cliente
    '/register': (context) => const RegisterScreen(),
    '/client': (context) => const ClientScreen(),
    '/profileClient': (context) => const ProfileClientScreen(),
    '/historyClient': (context) => const OrdersClientScreen(),

    // Distribuidor
    '/distributor': (context) => const DistributorScreen(),
    '/inventory_screen': (context) => const InventoryScreen(),
    '/profileDistributor': (context) => const ProfileDistributorScreen(),
    '/reporte-distribuidor': (context) {
      final distributorId =
          ModalRoute.of(context)?.settings.arguments as String;
      return ReportDistributorScreen(distributorId: distributorId);
    },

    // Director
    '/director': (context) => DirectorScreen(),
    '/listDistribuidor': (context) => ListdistribuidorScreen(),
    '/repote-director': (context) => ReportsScreen(),

    // Extras
    '/map': (context) => MapScreen(),
    '/main': (context) => const MainScreen(),
    '/listProductos': (context) => ListProductScreen(),
    '/new': (context) => ResponsiveDashboard(),
  };
}
