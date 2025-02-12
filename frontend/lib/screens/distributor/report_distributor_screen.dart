import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/dashboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/styles/colors.dart';
import '../../widgets/wrapper.dart';
import '../reports/ventas_card.dart';

class DistributorDashboard extends StatefulWidget {
  const DistributorDashboard({super.key});

  @override
  _DistributorDashboardState createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> {
  DateTime _selectedDate = DateTime.now();
  String distribuidorID = "";
  String _selectedFilter = "dia"; // Filtro predeterminado
  bool _loading = false;
  Map<String, dynamic>? _data;
  final DashboardService dashboardService = DashboardService();

//Constructor de incio de página
  @override
  void initState() {
    super.initState();
    _loadDistributorID();
  }

//constructor de incio de página
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "distribuidor", // PASA EL ROL DEL USUARIO
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📊 Dashboard del Distribuidor",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildFilters(), // 🔹 Filtros
                const SizedBox(height: 10),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _data == null
                        ? const Center(child: Text("No hay datos disponibles"))
                        : Expanded(
                            child: ListView(
                              children: [
                                _buildSummaryCard("📈 Ventas Totales",
                                    _data?['ventasTotales'] ?? 0),
                                _buildSummaryCard("💰 Ingresos Totales",
                                    "\$${_data?['ingresosTotales'] ?? 0}"),
                                const SizedBox(height: 20),
                                // 🔹 Gráfico de Ventas
                                SalesChart(data: _data),
                              ],
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cargar distribuidorID desde SharedPreferences
  Future<void> _loadDistributorID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      distribuidorID = prefs.getString("DistribuidorID") ?? "Planta";
    });
    _fetchSalesReport(); // Cargar datos al inicio
  }

  //Obtener datos del backend según filtro seleccionado
  Future<void> _fetchSalesReport() async {
    setState(() {
      _loading = true;
    });

    final year = _selectedDate.year;
    final month = _selectedDate.month.toString().padLeft(2, '0');
    final day = _selectedDate.day.toString().padLeft(2, '0');
    final week = (_selectedDate.day / 7).ceil().toString(); // Semana estimada

    String endpoint = "/ventas/dia/$year-$month-$day/$distribuidorID";

    switch (_selectedFilter) {
      case "semana":
        endpoint = "/ventas/semana/$year/$week/$distribuidorID";
        break;
      case "mes":
        endpoint = "/ventas/mes/$year/$month/$distribuidorID";
        break;
      case "anio":
        endpoint = "/ventas/anio/$year/$distribuidorID";
        break;
    }

    try {
      final result = await dashboardService.getSalesReport(endpoint);
      setState(() {
        _data = result;
        print('datos: $_data');
      });
    } catch (error) {
      print("Error cargando datos: $error");
    }

    setState(() {
      _loading = false;
    });
  }

  // Construcción de los Filtros
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          //  Selector de Filtro (Día, Semana, Mes, Año)
          DropdownButton<String>(
            value: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
              _fetchSalesReport();
            },
            items: const [
              DropdownMenuItem(value: "dia", child: Text("Día")),
              DropdownMenuItem(value: "semana", child: Text("Semana")),
              DropdownMenuItem(value: "mes", child: Text("Mes")),
              DropdownMenuItem(value: "anio", child: Text("Año")),
            ],
          ),

          const SizedBox(width: 8),

          // Selector de Fecha
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
                _fetchSalesReport();
              }
            },
          ),

          const Spacer(),

          // Botón de "Limpiar Filtros"
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _selectedFilter = "dia";
                _selectedDate = DateTime.now();
              });
              _fetchSalesReport();
            },
          ),
        ],
      ),
    );
  }

  // Tarjeta de resumen
  Widget _buildSummaryCard(String title, dynamic value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("$value",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
      ),
    );
  }

  // Gráfico de Ventas
  Widget _buildSalesChart(dynamic salesData) {
    if (salesData is! List || salesData.isEmpty) {
      return const Center(child: Text("No hay datos para mostrar"));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📊 Ventas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: salesData.map<FlSpot>((entry) {
                        if (entry is Map<String, dynamic> &&
                            entry.containsKey('fecha') &&
                            entry.containsKey('ventasTotales')) {
                          double index = double.tryParse(entry['fecha']
                                  .toString()
                                  .replaceAll('-', '')
                                  .substring(6)) ??
                              0;
                          return FlSpot(
                              index, (entry['ventasTotales'] ?? 0).toDouble());
                        }
                        return const FlSpot(0, 0);
                      }).toList(),
                      isCurved: true,
                      barWidth: 4,
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
