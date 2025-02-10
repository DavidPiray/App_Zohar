import 'package:flutter/material.dart';
import '../../core/styles/colors.dart';
import 'sidebar_menu.dart';

class Wrapper extends StatefulWidget {
  final String userRole;
  final Widget child;
  final FloatingActionButton? floatingActionButton;

  const Wrapper({
    super.key,
    required this.userRole,
    required this.child,
    this.floatingActionButton,
  });

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isSidebarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
    if (!isSidebarVisible) {
      _scaffoldKey.currentState?.openDrawer(); // 🔹 Abre el Drawer en móviles
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.barra,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            title: const Text(
              'Zohar App',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(isSidebarVisible ? Icons.menu_open : Icons.menu,color: Colors.white,),
              onPressed: _toggleSidebar,
            ),
          ),
        ),
      ),
      drawer: !isWideScreen
          ? Drawer(
              child: SidebarMenu(
                userRole: widget.userRole,
                isWideScreen: false,
                onToggle: _toggleSidebar,
              ),
            )
          : null,
      body: Row(
        children: [
          if (isWideScreen && isSidebarVisible)
            SidebarMenu(
              userRole: widget.userRole,
              isWideScreen: true,
              onToggle: _toggleSidebar,
            ),
          Expanded(child: widget.child),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
