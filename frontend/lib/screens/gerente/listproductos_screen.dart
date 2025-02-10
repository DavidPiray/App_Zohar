import 'package:flutter/material.dart';
import '../../core/styles/colors.dart';
import '../../services/product_service.dart';
import '../../widgets/wrapper.dart';

class ListProductScreen extends StatefulWidget {
  @override
  _ListProductScreenState createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final ProductService productService = ProductService();
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final result = await productService.getProducts();
      setState(() {
        products = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  void _showEditProductModal(dynamic product) {
    String name = product['nombre'];
    String description = product['descripcion'];
    String priceClient = product['precio_cliente'].toString();
    String priceDistributor = product['precio_distribuidor'].toString();
    String stock = product['stock'].toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modificar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => name = value,
                  controller: TextEditingController(text: name),
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  onChanged: (value) => description = value,
                  controller: TextEditingController(text: description),
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  onChanged: (value) => priceClient = value,
                  controller: TextEditingController(text: priceClient),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Precio Cliente'),
                ),
                TextField(
                  onChanged: (value) => priceDistributor = value,
                  controller: TextEditingController(text: priceDistributor),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Precio Distribuidor'),
                ),
                TextField(
                  onChanged: (value) => stock = value,
                  controller: TextEditingController(text: stock),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Stock'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await productService.updateProduct(product['id_producto'], {
                  'nombre': name,
                  'descripcion': description,
                  'precio_cliente':
                      priceClient.toString(), // Convertir a String
                  'precio_distribuidor':
                      priceDistributor.toString(), // Convertir a String
                  'stock': stock.toString(), // Convertir a String
                });
                Navigator.of(context).pop();
                _fetchProducts();
              },
              child: Text('Actualizar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductModal() {
    String id = '';
    String name = '';
    String description = '';
    String priceClient = '';
    String priceDistributor = '';
    String stock = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) => id = value,
                  decoration: InputDecoration(labelText: 'ID Producto'),
                ),
                TextField(
                  onChanged: (value) => name = value,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  onChanged: (value) => description = value,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  onChanged: (value) => priceClient = value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Precio Cliente'),
                ),
                TextField(
                  onChanged: (value) => priceDistributor = value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Precio Distribuidor'),
                ),
                TextField(
                  onChanged: (value) => stock = value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Stock'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await productService.addProduct({
                  'id_producto': id,
                  'nombre': name,
                  'descripcion': description,
                  'precio_cliente':
                      priceClient.toString(), // Convertir a String
                  'precio_distribuidor':
                      priceDistributor.toString(), // Convertir a String
                  'stock': stock.toString(), // Convertir a String
                });
                Navigator.of(context).pop();
                _fetchProducts();
              },
              child: Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Wrapper(
    userRole: "gerente", // 🔹 PASA EL ROL DEL USUARIO
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
                "Lista de Productos",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay productos disponibles.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          )
                        : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.local_drink,
                                    color: Color(0xFF3B945E),
                                  ),
                                  title: Text(
                                    product['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                  subtitle: Text(
                                    'Precio: \$${product['precio_cliente']}',
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () => _showEditProductModal(product),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showAddProductModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B945E),
                  ),
                  child: const Text('Agregar Producto'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
