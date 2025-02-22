import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/report_provider.dart'; // Asegúrate de importar esto
import 'firebase_options.dart'; // Archivo generado por FlutterFire CLI
import 'app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    //ChangeNotifierProvider(create: (_) => RealtimeProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(720, 1280), // Tamaño base de diseño
      minTextAdapt: true, // Adaptación de texto
      splitScreenMode: true, // Modo para pantalla dividida
      builder: (_, child) {
        return LayoutBuilder(builder: (context, constraints) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zohar',
            theme: ThemeData(primarySwatch: Colors.blue),
            initialRoute: '/main',
            routes: AppRoutes.routes,
            builder: (context, widget) {
              // Habilitar ScreenUtil para el texto
              ScreenUtil.init(context);
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: widget!,
              );
            },
          );
        });
      },
    );
  }
}
