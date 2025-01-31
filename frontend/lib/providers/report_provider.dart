import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, double> dailyEarnings = {};

  // Calcular ganancias a partir de los pedidos
  Future<void> fetchDailyEarnings(String distributorId) async {
    try {
      final snapshot = await _firestore
          .collection('pedidos')
          .where('distribuidorID', isEqualTo: distributorId)
          .get();

      Map<String, double> earningsMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime date = (data['fechaCreacion'] as Timestamp).toDate(); // Asegúrate del formato de la fecha
        final String dateKey = '${date.year}-${date.month}-${date.day}';

        // Calcular las ganancias utilizando `calculateEarnings`
        final double earnings = calculateEarnings(data['productos']);

        // Sumar las ganancias al mapa
        if (earningsMap.containsKey(dateKey)) {
          earningsMap[dateKey] = earningsMap[dateKey]! + earnings;
        } else {
          earningsMap[dateKey] = earnings;
        }
      }

      dailyEarnings = earningsMap;
      notifyListeners();
    } catch (e) {
      print('Error al obtener ganancias: $e');
    }
  }

  // Función para calcular ganancias
  double calculateEarnings(List<dynamic> productos) {
    double total = 0.0;

    for (var producto in productos) {
      final double precio = producto['precio'] ?? 0.0;
      final int cantidad = producto['cantidad'] ?? 0;
      total += precio * cantidad;
    }

    return total;
  }

  // Datos para el gráfico
  List<BarChartGroupData> getBarChartData(String distributorId) {
    return dailyEarnings.entries.map((entry) {
      final DateTime date = DateTime.parse(entry.key);
      final int day = date.day; // Usa el día como índice

      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: entry.value, // Ganancias del día
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

  // Exportar a PDF
  Future<void> exportToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Reporte de Ganancias Diarias',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Table.fromTextArray(
                data: [
                  ['Fecha', 'Ganancias'],
                  ...dailyEarnings.entries.map((entry) =>
                      [entry.key, '\$${entry.value.toStringAsFixed(2)}']),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/reporte_ganancias.pdf');
    await file.writeAsBytes(await pdf.save());
    print('PDF generado en: ${file.path}');
  }
}
