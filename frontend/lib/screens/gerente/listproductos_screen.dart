import 'package:flutter/material.dart';
import '../../core/styles/colors.dart';
import '../../services/product_service.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListProductScreenState createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  // Variables para los servicios
  final ProductService productService = ProductService();
  // Variables Globales
  List<dynamic> products = [];
  bool isLoading = true;
  List<dynamic> filteredProducts = [];
  String searchQuery = '';
  String selectedStockFilter = 'Todos';
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  // Constructor -> Inicio de página
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Constructor de la pagina inicial
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      userRole: "gerente",
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

                // Barra de búsqueda con filtro de stock y botón de agregar
                _buildSearchBar(),

                const SizedBox(height: 10),

                // Lista de productos con paginación
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay productos disponibles.',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            )
                          : _buildProductList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funcion para obtener los productos
  Future<void> _fetchProducts() async {
    try {
      final result = await productService.getProducts();
      setState(() {
        products = result;
        filteredProducts = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    }
  }

  // Modal para mostrar los detalles del producto
  void _showProductDetails(dynamic product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles del Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.local_offer, color: Colors.blue),
                title: Text('Nombre: ${product['nombre']}'),
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.orange),
                title: Text('Descripción: ${product['descripcion']}'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: Text('Precio Cliente: \$${product['precio_cliente']}'),
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.teal),
                title: Text(
                    'Precio Distribuidor: \$${product['precio_distribuidor']}'),
              ),
              ListTile(
                leading: const Icon(Icons.inventory, color: Colors.purple),
                title: Text('Stock: ${product['stock']} unidades'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.confirmation_number, color: Colors.grey),
                title: Text('ID: ${product['id_producto']}'),
              ),
            ],
          ),
          actions: [
            // Botón para eliminar
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el modal de detalles
                _confirmDeleteProduct(product['id_producto']);
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),

            // Botón para modificar
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showEditProductModal(product);
              },
              child: const Text('Modificar'),
            ),

            // Botón para cerrar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Modal para editar
  Future<void> _showEditProductModal(dynamic product) async {
    String name = product['nombre'];
    String description = product['descripcion'];
    String priceClient = product['precio_cliente'].toString();
    String priceDistributor = product['precio_distribuidor'].toString();
    String stock = product['stock'].toString();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modificar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.local_offer, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => description = value,
                controller: TextEditingController(text: description),
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description, color: Colors.orange),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => priceClient = value,
                controller: TextEditingController(text: priceClient),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio Cliente',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => priceDistributor = value,
                controller: TextEditingController(text: priceDistributor),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio Distribuidor',
                  prefixIcon: Icon(Icons.monetization_on, color: Colors.teal),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => stock = value,
                controller: TextEditingController(text: stock),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  prefixIcon: Icon(Icons.inventory, color: Colors.purple),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            // Botón para cancelar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),

            // Botón para actualizar
            ElevatedButton(
              onPressed: () async {
                await productService.updateProduct(
                  product['id_producto'],
                  {
                    'nombre': name,
                    'descripcion': description,
                    'precio_cliente': priceClient.toString(),
                    'precio_distribuidor': priceDistributor.toString(),
                    'stock': stock.toString(),
                  },
                );
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                _fetchProducts();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  // Diálogo de confirmación para eliminar producto
  void _confirmDeleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra primero el modal

                try {
                  await productService.deleteProduct(productId);
                  _fetchProducts(); // Refresca la lista después de eliminar

                  // Esperar un pequeño tiempo antes de mostrar la alerta
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      // Verifica que el contexto aún es válido
                      if (context.mounted) {
                        AnimatedAlert.show(
                          context,
                          'Éxito',
                          'Producto eliminado correctamente.',
                          type: AnimatedAlertType.success,
                        );
                      }
                    }
                  });
                } catch (e) {
                  if (mounted) {
                    // Verifica el contexto antes de mostrar la alerta
                    if (context.mounted) {
                      AnimatedAlert.show(
                        context,
                        'Error',
                        'No se pudo eliminar el producto: $e',
                        type: AnimatedAlertType.error,
                      );
                    }
                  }
                }
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Ventana modal para añadir productos
  void _showAddProductModal() {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String id = '';
        String name = '';
        String description = '';
        String priceClient = '';
        String priceDistributor = '';
        String stock = '';

        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) => id = value,
                  decoration: const InputDecoration(
                    labelText: 'ID Producto',
                    prefixIcon: Icon(Icons.code, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El ID es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => name = value,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.local_offer, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => description = value,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description, color: Colors.orange),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'La descripción es obligatoria'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => priceClient = value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio Cliente',
                    prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El precio es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => priceDistributor = value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Precio Distribuidor',
                    prefixIcon: Icon(Icons.monetization_on, color: Colors.teal),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El precio es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => stock = value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: Icon(Icons.inventory, color: Colors.purple),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El stock es obligatorio'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            // Botón de agregar con validaciones
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  AnimatedAlert.show(
                    context,
                    'Error',
                    'Por favor, completa todos los campos obligatorios.',
                    type: AnimatedAlertType.error,
                  );
                  return;
                }
                try {
                  await productService.addProduct({
                    'id_producto': id,
                    'nombre': name,
                    'descripcion': description,
                    'precio_cliente': priceClient,
                    'precio_distribuidor': priceDistributor,
                    'stock': stock,
                  });

                  // Cerrar el modal
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();

                  // Recargar lista de productos
                  _fetchProducts();

                  // Mostrar alerta de éxito
                  AnimatedAlert.show(
                    // ignore: use_build_context_synchronously
                    context,
                    'Éxito',
                    'Producto agregado correctamente.',
                    type: AnimatedAlertType.success,
                  );
                } catch (e) {
                  AnimatedAlert.show(
                    // ignore: use_build_context_synchronously
                    context,
                    'Error',
                    'No se pudo agregar el producto: $e',
                    type: AnimatedAlertType.error,
                  );
                }
              },
              child: const Text('Agregar'),
            ),

            // Botón de cancelar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Widget para construir lal ista de productos
  Widget _buildProductList() {
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    List<dynamic> paginatedProducts = filteredProducts.sublist(
        startIndex,
        endIndex > filteredProducts.length
            ? filteredProducts.length
            : endIndex);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: paginatedProducts.length,
            itemBuilder: (context, index) {
              final product = paginatedProducts[index];

              // Convertir 'stock' a número
              final int stockValue =
                  int.tryParse(product['stock'].toString()) ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.local_drink,
                    color: stockValue > 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(product['nombre'] ?? 'Sin nombre'),
                  subtitle: Text('Precio: \$${product['precio_cliente']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showProductDetails(product),
                ),
              );
            },
          ),
        ),

        // Controles de paginación
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
            Text(
              'Página ${_currentPage + 1} de ${(filteredProducts.length / _itemsPerPage).ceil()}',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentPage <
                      (filteredProducts.length / _itemsPerPage).ceil() - 1
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  // Widget para los filtros
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterProducts();
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: selectedStockFilter,
            onChanged: (value) {
              setState(() {
                selectedStockFilter = value!;
                _filterProducts();
              });
            },
            items: ['Todos', 'En Stock', 'Agotado'].map((String stock) {
              return DropdownMenuItem<String>(
                value: stock,
                child: Text(stock),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30, color: Colors.blue),
            onPressed: _showAddProductModal,
          ),
        ],
      ),
    );
  }

  // Funcion para los filtros
  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((p) {
        final matchesSearch = p['nombre']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());

        // Asegurar que 'stock' sea un número
        final int stockValue = int.tryParse(p['stock'].toString()) ?? 0;

        final matchesStock = (selectedStockFilter == 'Todos') ||
            (selectedStockFilter == 'En Stock' && stockValue > 0) ||
            (selectedStockFilter == 'Agotado' && stockValue == 0);

        return matchesSearch && matchesStock;
      }).toList();
    });
  }

}
