import 'package:flutter/material.dart';

class AyudaGerenteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayuda para Administradores'),
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
              '¿Cómo puedo ayudar?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          _buildHelpItem(
            context,
            icon: Icons.shopping_cart,
            title: 'Productos',
            description:
                'Administra el catálogo de productos, agrega nuevos, actualiza precios y controla el stock disponible.\n\n'
                '--> Para lograr modificar un producto puede presionar cualquier producto de la lista y podrá modificarlo.\n\n'
                '--> Para agragar un producto puede dar clic en el botón de la parte inferior llamado Agregar producto.',
          ),
          _buildHelpItem(
            context,
            icon: Icons.people,
            title: 'Distribuidores',
            description:
                'Gestiona la información de los distribuidores y revisa su estado de actividad.\n\n'
                '--> Puede seleccionar a un distribuidor y podrá ver su información, además podrá modificarlo o eliminarlo.\n\n'
                '--> POdrá filtrar a los distribuidores con los filtros del lado izqueierdo',
          ),
          _buildHelpItem(
            context,
            icon: Icons.bar_chart,
            title: 'Reportes',
            description:
                'Genera informes de ventas, inventario y desempeño para tomar decisiones estratégicas.\n\n'
                '--> Podrá filtrar los reportes con la barra de filtro en el lado izquierdo',
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
        Navigator.pushReplacementNamed(context, '/director');
      },
    );
  }
}
