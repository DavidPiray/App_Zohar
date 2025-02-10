import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/distributor_service.dart';
import '../../services/product_service.dart';
import '../../services/orders_service.dart';

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DistributorService distributorService = DistributorService();
  final ProductService productService = ProductService();
  final OrdersService orderService = OrdersService();

  int totalDistributors = 0;
  int activeDistributors = 0;
  int inactiveDistributors = 0;
  Map<String, int> ordersByStatus = {};
  int totalProducts = 0;
  int totalStock = 0;
  List<ChartData> productData = [];
  List<ChartData> productDataLimited = [];
  List<ChartData> salesData = [];
  String selectedMonth = 'Enero';
  String selectedDashboard = 'Distribuidores'; // Opción por defecto
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final distributors = await distributorService.getDistributors();
    final products = await productService.getProducts();
    final orders = await orderService.getOrders();

    setState(() {
      totalDistributors = distributors.length;
      activeDistributors =
          distributors.where((d) => d['estado'] == 'activo').length;
      inactiveDistributors = totalDistributors - activeDistributors;

      totalProducts = products.length;
      totalStock = products.fold<int>(
          0, (sum, p) => sum + (int.tryParse(p['stock'].toString()) ?? 0));

      productData = products
          .map((p) => ChartData(
              p['nombre'].toString(), int.tryParse(p['stock'].toString()) ?? 0))
          .toList();

      productDataLimited = productData.take(5).toList();

      ordersByStatus = {};
      for (var order in orders) {
        String status = order['estado'];
        ordersByStatus[status] = (ordersByStatus[status] ?? 0) + 1;
      }

      salesData = orders
          .where((o) => o['mes'] == selectedMonth)
          .map((o) => ChartData(o['fecha'], o['total']))
          .toList();

      isLoading = false;
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Reporte de $selectedDashboard',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              _buildPdfTable(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildPdfTable() {
    List<List<String>> data = [];

    if (selectedDashboard == 'Distribuidores') {
      data.add(['Estado', 'Cantidad']);
      data.add(['Activos', activeDistributors.toString()]);
      data.add(['Inactivos', inactiveDistributors.toString()]);
    } else if (selectedDashboard == 'Productos') {
      data.add(['Nombre', 'Stock']);
      for (var product in productDataLimited) {
        data.add([product.label, product.value.toString()]);
      }
    } else if (selectedDashboard == 'Ventas') {
      data.add(['Fecha', 'Total']);
      for (var sale in salesData) {
        data.add([sale.label, sale.value.toString()]);
      }
    }

    return pw.Table.fromTextArray(
      headers: data.first,
      data: data.sublist(1),
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Row(
        children: [
          
          _buildFilterPanel(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDistributorDashboard(),
                        _buildProductDashboard(),
                        _buildSalesDashboard(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generatePdf,
                          child: const Text('Descargar Reporte en PDF'),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      width: 250,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Seleccionar Dashboard'),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedDashboard,
            items: ['Distribuidores', 'Productos', 'Ventas']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedDashboard = value!;
              });
            },
          ),
          const SizedBox(height: 10),
          Text('Seleccionar Mes'),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedMonth,
            items: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedMonth = value!;
                _fetchData();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDistributorDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Distribuidores',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SfCircularChart(
              legend:
                  const Legend(isVisible: true, position: LegendPosition.right),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Activos', activeDistributors),
                    ChartData('Inactivos', inactiveDistributors),
                  ],
                  xValueMapper: (data, _) => data.label,
                  yValueMapper: (data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Top 5 Productos con más Stock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: const NumericAxis(title: AxisTitle(text: 'Stock')),
              legend: const Legend(isVisible: true),
              series: <CartesianSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  name: 'Stock',
                  dataSource:
                      productDataLimited, // limitado a los primeros 5 productos
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSalesDashboard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Ventas - Mes: $selectedMonth',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              series: <CartesianSeries<ChartData, String>>[
                LineSeries<ChartData, String>(
                  dataSource:
                      salesData, // Se actualiza según el mes seleccionado
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
