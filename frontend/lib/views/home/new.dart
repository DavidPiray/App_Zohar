import 'package:flutter/material.dart';
import 'dart:math';

class ResponsiveDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              "Water Distribution",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            CircularChart(),
            SizedBox(height: 40),
            MetricsSection(),
          ],
        ),
      ),
    );
  }
}

class CircularChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: CircularChartPainter(),
      ),
    );
  }
}

class CircularChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Gradiente para el fondo del círculo
    final gradient = Paint()
      ..shader = RadialGradient(
        colors: [Colors.green, Colors.blue],
        stops: [0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, gradient);

    // Líneas radiales
    paint.color = Colors.white;
    paint.strokeWidth = 2;
    for (int i = 0; i < 4; i++) {
      final double angle = radians(90.0 * i);
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Círculo central con "Z"
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.3, paint);

    // Texto "Z"
    final textPainter = TextPainter(
      text: TextSpan(
        text: "Z",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );

    // Círculos pequeños alrededor
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final double angle = radians(90.0 * i);
      final double x = center.dx + radius * 1.2 * cos(angle);
      final double y = center.dy + radius * 1.2 * sin(angle);

      canvas.drawCircle(Offset(x, y), 15, paint);

      // Números en los círculos
      final numberPainter = TextPainter(
        text: TextSpan(
          text: (20 + i).toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      numberPainter.layout();
      numberPainter.paint(
        canvas,
        Offset(x - numberPainter.width / 2, y - numberPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  double radians(double degrees) {
    return degrees * (pi / 180);
  }
}

class MetricsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double circleSize = screenWidth > 600 ? 150.0 : 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        physics: NeverScrollableScrollPhysics(),
        children: [
          MetricCard(label: "Clients", value: "24", size: circleSize),
          MetricCard(label: "Distributors", value: "22", size: circleSize),
          MetricCard(label: "Products", value: "23", size: circleSize),
          MetricCard(label: "Orders", value: "50", size: circleSize),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final double size;

  const MetricCard(
      {required this.label, required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.green, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop, size: size * 0.3, color: Colors.white),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: size * 0.12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
