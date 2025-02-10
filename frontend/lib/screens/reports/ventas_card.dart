import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChart extends StatefulWidget {
  final Map<String, dynamic>? data;

  const SalesChart({super.key, required this.data});

  @override
  _SalesChartState createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  List<bool> _visibilityFilters = [true, true, true];

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) {
      return const Center(child: Text("No hay datos disponibles"));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📊 Reporte de Ventas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 🔹 Botones de Leyenda Interactiva
            Wrap(
              spacing: 8,
              children: [
                _buildLegendButton("Ventas", 0, Colors.blue),
                _buildLegendButton("Ingresos", 1, Colors.green),
                _buildLegendButton("Productos", 2, Colors.orange),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Gráfico de Barras
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipBorder: BorderSide(
                          color: Colors
                              .grey[800]!), // ✅ Borde de color gris oscuro
                      tooltipRoundedRadius:
                          8, // ✅ Redondeado para mejorar el diseño
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          "${rod.toY.toInt()}",
                          TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          List<String> labels = [
                            "Ventas",
                            "Ingresos",
                            "Productos"
                          ];
                          return Text(labels[value.toInt()],
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Botón de Leyenda Interactiva
  Widget _buildLegendButton(String text, int index, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _visibilityFilters[index] = !_visibilityFilters[index];
        });
      },
      child: Chip(
        label: Text(text,
            style: TextStyle(
                color: _visibilityFilters[index] ? Colors.white : Colors.grey)),
        backgroundColor: _visibilityFilters[index] ? color : Colors.grey[300],
      ),
    );
  }

  // 🔹 Crear Grupos de Barras
  List<BarChartGroupData> _buildBarGroups() {
    List<BarChartGroupData> bars = [];

    if (_visibilityFilters[0]) {
      bars.add(_buildBarGroup(
          0, widget.data?['ventasTotales'] ?? 0, Colors.blue, "Ventas"));
    }
    if (_visibilityFilters[1]) {
      bars.add(_buildBarGroup(
          1, widget.data?['ingresosTotales'] ?? 0, Colors.green, "Ingresos"));
    }
    if (_visibilityFilters[2]) {
      bars.add(_buildBarGroup(2, widget.data?['productosVendidos']?.length ?? 0,
          Colors.orange, "Productos"));
    }

    return bars;
  }

  // 🔹 Construcción de una Barra Individual
  BarChartGroupData _buildBarGroup(int x, double y, Color color, String title) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y * 1.2,
            color: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
