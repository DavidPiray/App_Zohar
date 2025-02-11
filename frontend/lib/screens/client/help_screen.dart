import 'package:flutter/material.dart';

import '../../core/styles/colors.dart';
import '../../widgets/wrapper.dart';

class AyudaClienteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "cliente", // 🔹 PASA EL ROL DEL USUARIO
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          color: AppColors.back,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Ayuda para Clientes",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildHelpContent(context),
                ),
              ],
            ),
          ),
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
            icon: Icons.shopping_cart,
            title: 'Perfil',
            description:
                'En este apartado podrá ver su información y podrá modificar su contraseña.\n\n'
                '--> Al entrar al apartado de pefil podrá ver su información.\n\n'
                '--> Al seleccionar la opción de cambiar contraseña, podrá cambiarla.',
          ),
          _buildHelpItem(
            context,
            icon: Icons.local_shipping,
            title: 'Estado de Pedidos',
            description:
                'Consulta el estado de tus pedidos en la sección "Mis Pedidos".\n\n'
                '--> Puedes ver el estado de cada pedido (Pendiente, Enviado, Entregado).\n\n'
                '--> Si tienes dudas sobre un pedido, puedes contactarnos desde la sección de soporte.',
          ),
          _buildHelpItem(
            context,
            icon: Icons.credit_card,
            title: 'Realizar pedido',
            description:
                'Podrá realizar el pedido de las botellas y su cantidad.\n\n'
                '--> Se mostrará en la pantalla de incio el producto en stock, podrá elegir la cantidad y podrá ver su precio.\n\n'
                '--> Podrá realizar el pedido en la parte inferior derecha, se abrirá la información y podrá confirmar el pedido',
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
}
