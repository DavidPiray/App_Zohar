import 'package:flutter/material.dart';
import '../core/constants/menu_items.dart';
import '../../core/styles/colors.dart';

class SidebarMenu extends StatefulWidget {
  final String userRole;
  final bool isWideScreen;
  final VoidCallback onToggle;

  const SidebarMenu({
    super.key,
    required this.userRole,
    required this.isWideScreen,
    required this.onToggle,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  String? _hoveredItem; // 🔹 Detectar hover en elementos del menú

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems =
        MenuItems.menuByRole[widget.userRole] ?? [];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isWideScreen ? 250 : 0, // Oculta en móvil
      color: AppColors.barraLateral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Menú',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...menuItems.map((item) => _buildSidebarItem(
                item['icon'],
                item['title'],
                () => _handleMenuAction(context, item['route']),
              )),
          const Spacer(),
          if (!widget.isWideScreen)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onToggle,
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String text, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _hoveredItem = text;
      }),
      onExit: (_) => setState(() {
        _hoveredItem = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _hoveredItem == text ? const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1) : Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(text, style: const TextStyle(color: Colors.white)),
          onTap: onTap,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String route) {
    if (route == '/logout') {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}
