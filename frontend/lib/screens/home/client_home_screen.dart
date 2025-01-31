import 'package:flutter/material.dart';

class ClientHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio - Cliente')),
      body: Center(
        child: Text('Bienvenido Cliente'),
      ),
    );
  }
}
