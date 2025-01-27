import 'package:flutter/material.dart';

class AdaptiveCustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color backgroundColor;
  final String? additionalInfo;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AdaptiveCustomCard({
    super.key,
    required this.icon,
    required this.title,
    this.backgroundColor = const Color(0xFF6ABF69),
    this.additionalInfo,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isWideScreen ? 400 : 150,
        height: isWideScreen ? 200 : 250,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB8E994), // Light green
              Color(0xFF3B945E), // Dark green
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isWideScreen
            ? Row(
                children: [
                  // Icono a la izquierda
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 60,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                  // Información a la derecha
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (additionalInfo != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              additionalInfo!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono central
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 40,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (additionalInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        additionalInfo!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: trailing!,
                    ),
                ],
              ),
      ),
    );
  }
}
