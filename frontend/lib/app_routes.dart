import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/recover_password_screen.dart';
import 'screens/admin/admin_screen.dart';
// Para clientes
import 'screens/client/client_screen.dart';
import 'screens/client/registration_screen.dart';
import 'screens/client/profile_screen.dart';
import 'screens/client/orders_history_screen.dart';
import 'screens/client/help_screen.dart';
// Para distribuidores
import 'screens/distributor/distributor_screen.dart';
import 'screens/distributor/inventory_screen.dart';
import 'screens/distributor/profile_screen.dart';
import 'screens/distributor/report_distributor_screen.dart';
import 'screens/distributor/settings_distributor_screen.dart';
import 'screens/distributor/help_screen.dart';
// Para Gerente
import 'screens/gerente/gerente_screen.dart';
import 'screens/gerente/listdistribuidor_screen.dart';
import 'screens/gerente/listproductos_screen.dart';
import 'screens/gerente/reports_screen.dart';
import 'screens/gerente/map_gerente.dart';
import 'screens/gerente/settings_gerente_screen.dart';
import 'screens/gerente/help_screen.dart';
// Extras
import 'screens/utils/map_screen.dart';
import 'screens/home/main_screen.dart';
import 'views/home/new.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginScreen(),
    '/admin': (context) => AdminScreen(),
    '/recuperar cuenta': (context) => const RecoverPasswordScreen(),
    // Cliente
    '/registro': (context) => const RegisterScreen(),
    '/cliente': (context) => const ClientScreen(),
    '/perfil-cliente': (context) => const ProfileClientScreen(),
    '/historial-cliente': (context) => const OrdersClientScreen(),
    '/ayuda-cliente': (context) => AyudaClienteScreen(),

    // Distribuidor
    '/distribuidor': (context) => const DistributorScreen(),
    '/inventario-distribuidor': (context) => const InventoryScreen(),
    '/perfil-distribuidor': (context) => const ProfileDistributorScreen(),
    '/reporte-distribuidor': (context) => const DistributorDashboard(),
    '/configuracion-distribuidor': (context) =>
        const DistributorSettingsScreen(),
    '/ayuda-distribuidor': (context) => AyudaDistribuidorScreen(),

    // Gerente
    '/gerente': (context) => DirectorScreen(),
    '/lista-distribuidores': (context) => ListdistribuidorScreen(),
    '/reporte-gerente': (context) => const ReportsScreen(),
    '/mapa-gerente': (context) => const ManagerMapScreen(),
    '/ayuda-gerente': (context) => AyudaGerenteScreen(),
    '/configuracion-gerente': (context) => const ManagerSettingsScreen(),

    // Extras
    '/map': (context) => MapScreen(),
    '/main': (context) => const MainScreen(),
    '/lista-productos': (context) => ListProductScreen(),
    '/new': (context) => ResponsiveDashboard(),
  };
}
