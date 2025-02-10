import 'package:flutter/material.dart';

class AyudaDistribuidorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayuda para Distribuidores'),
        backgroundColor: Color(0xFF3B945E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: _buildHelpContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB8E994),
            Color(0xFF6ABF69),
            Color(0xFF3B945E),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildHelpContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '¿Cómo podemos ayudarte?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          _buildHelpItem(
            context,
            icon: Icons.person,
            title: 'Perfil y Configuración',
            description:
                'Desde este apartado puedes ver tu información personal y actualizar tu contraseña.\n\n'
                '--> En "Perfil" puedes ver y modificar tus datos personales.\n\n'
                '--> Si deseas cambiar tu contraseña, selecciona la opción "Cambiar Contraseña".',
          ),
          _buildHelpItem(context,
              icon: Icons.local_shipping,
              title: 'Inventario',
              description: 'Consulta el inventario que dispone.\n\n'
                  '--> Puedes ver la cantidad de productos en stock.\n\n'),
          _buildHelpItem(
            context,
            icon: Icons.add_shopping_cart,
            title: 'Reportes',
            description: 'Consulta la cantidad de producto vendido.\n\n'
                '--> En la sección "Productos", elige los artículos que necesitas y selecciona la cantidad.\n\n'
                '--> Al confirmar la solicitud, recibirás una notificación cuando el pedido esté aprobado.',
          ),
          _buildHelpItem(
            context,
            icon: Icons.add_shopping_cart,
            title: 'Entregar pedido',
            description:
                'Se podrá visualizar los pedidos qeu puede realizar.\n\n'
                '--> Podrá seleccionar entregar para comenzar la ruta hacia el cliente.\n\n'
                '--> Podrá seleccioanr completado cuando haya fianlizado la entrega.\n\n'
                '--> Podrá filtrar los pedidos con los filtros en la parte superior',
          ),
          _buildHelpItem(
            context,
            icon: Icons.info,
            title: '¿Quiénes somos?',
            description:
                'Zohar es una empresa especializada en la distribución de agua embotellada, '
                'ofreciendo productos de alta calidad en distintas presentaciones para satisfacer las necesidades de nuestros clientes. '
                'Nos comprometemos con la pureza, frescura y disponibilidad de nuestros productos, brindando un servicio confiable y eficiente. '
                'Si necesitas más información, no dudes en contactarnos. 💧✨',
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'Para más detalles, consulta la documentación o contacta soporte.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Center(child: _buildHomeButton(context)),
        ],
      ),
    );
  }

  /// 🔹 Crea un ListTile que solo muestra el título y el icono. La descripción se muestra en un modal al hacer clic.
  Widget _buildHelpItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 30),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () => _showHelpModal(context, title, description),
    );
  }

  void _showHelpModal(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(content, textAlign: TextAlign.justify),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(Icons.home),
      label: Text('Regresar a Inicio'),
      onPressed: () {
        Navigator.pushReplacementNamed(
            context, '/distributor'); // Redirige a la pantalla del distribuidor
      },
    );
  }
}
