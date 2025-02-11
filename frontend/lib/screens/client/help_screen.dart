import 'package:flutter/material.dart';

import '../../core/styles/colors.dart';
import '../../widgets/wrapper.dart';

class AyudaClienteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "cliente", // PASA EL ROL DEL USUARIO
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
    return ListView(
      children: [
        _buildHelpItem(
          icon: Icons.shopping_cart,
          title: 'Perfil',
          description:
              'En este apartado podrá ver su información y modificar su contraseña.\n\n'
              '--> Al entrar al apartado de perfil podrá ver su información.\n\n'
              '--> Al seleccionar la opción de cambiar contraseña, podrá cambiarla.',
        ),
        _buildHelpItem(
          icon: Icons.local_shipping,
          title: 'Estado de Pedidos',
          description:
              'Consulta el estado de tus pedidos en la sección "Mis Pedidos".\n\n'
              '--> Puedes ver el estado de cada pedido (Pendiente, Enviado, Entregado).\n\n'
              '--> Si tienes dudas sobre un pedido, puedes contactarnos desde la sección de soporte.',
        ),
        _buildHelpItem(
          icon: Icons.credit_card,
          title: 'Realizar pedido',
          description:
              'Podrá realizar el pedido de las botellas y su cantidad.\n\n'
              '--> Se mostrará en la pantalla de inicio el producto en stock, podrá elegir la cantidad y ver su precio.\n\n'
              '--> Podrá realizar el pedido en la parte inferior derecha, se abrirá la información y podrá confirmar el pedido.',
        ),
        _buildHelpItem(
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
            'Para más detalles, consulta la documentación o contacta a los número de soporte. \n 099241179 o 0986250187',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(
      {required IconData icon,
      required String title,
      required String description}) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.blueAccent, size: 30),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            description,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
