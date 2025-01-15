import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Tamaño base de diseño
      minTextAdapt: true, // Adaptación de texto
      splitScreenMode: true, // Modo para pantalla dividida
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zohar',
          theme: ThemeData(primarySwatch: Colors.blue),
          initialRoute: '/main',
          routes: AppRoutes.routes,
          builder: (context, widget) {
            // Habilitar ScreenUtil para el texto
            ScreenUtil.init(context);
            return widget!;
          },
        );
      },
    );
  }
}
