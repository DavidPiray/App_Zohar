import 'package:flutter/material.dart';
import '../../core/styles/colors.dart';
import '../../services/distributor_service.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/wrapper.dart';

class ListdistribuidorScreen extends StatefulWidget {
  const ListdistribuidorScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListdistribuidorScreenState createState() => _ListdistribuidorScreenState();
}

class _ListdistribuidorScreenState extends State<ListdistribuidorScreen> {
  // Variables para los servicios
  final DistributorService distributorService = DistributorService();
  // Variables GLobales
  List<dynamic> distributors = [];
  List<dynamic> filteredDistributors = [];
  bool isLoading = true;
  bool isSidebarVisible = true;
  String selectedState = 'Todos';
  String selectedZone = 'Todas';
  String searchQuery = '';
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPage = 0;
  final int _itemsPerPage = 5;

  // Constructor -> Inicio de página
  @override
  void initState() {
    super.initState();
    _fetchDistributors();
  }

  // Constructor de la Página Inicial
  @override
  Widget build(BuildContext context) {
    //final bool isWideScreen = MediaQuery.of(context).size.width > 800;
    return Wrapper(
      userRole: "gerente",
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
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
                          _buildSearchBar(),
                          Expanded(
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : filteredDistributors.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No hay distribuidores disponibles.',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      )
                                    : _buildDistributorList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Metodo para obtener los distribuidores
  Future<void> _fetchDistributors() async {
    try {
      final result = await distributorService.getDistributors();
      setState(() {
        distributors = result;
        filteredDistributors = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar distribuidores: $e')),
      );
    }
  }

  // Método para filtrar los distribuidores
  void _filterDistributors() {
    setState(() {
      filteredDistributors = distributors.where((d) {
        final matchesState =
            (selectedState == 'Todos' || d['estado'] == selectedState);
        final matchesZone =
            (selectedZone == 'Todas' || d['zonaAsignada'] == selectedZone);
        final matchesSearch = d['nombre']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());

        return matchesState && matchesZone && matchesSearch;
      }).toList();
    });
  }

  // Widget para los filtros
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            // Barra de busqueda
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar distribuidor',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterDistributors();
                });
              },
            ),
          ),
          const SizedBox(width: 16),

          // Filtro de Estado
          DropdownButton<String>(
            value: selectedState,
            onChanged: (value) {
              setState(() {
                selectedState = value!;
                _filterDistributors();
              });
            },
            items: ['Todos', 'activo', 'inactivo'].map((String estado) {
              return DropdownMenuItem<String>(
                value: estado,
                child: Text(estado),
              );
            }).toList(),
          ),

          const SizedBox(width: 16),

          // Botón de agregar distribuidor
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30, color: Colors.blue),
            onPressed: _showAddDistributorModal,
          ),
        ],
      ),
    );
  }

  // Para la paginación de distribuidores
  Widget _buildDistributorList() {
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    List<dynamic> paginatedDistributors = filteredDistributors.sublist(
        startIndex,
        endIndex > filteredDistributors.length
            ? filteredDistributors.length
            : endIndex);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: paginatedDistributors.length,
            itemBuilder: (context, index) {
              final distributor = paginatedDistributors[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: distributor['estado'] == 'activo'
                        ? Colors.green
                        : Colors.red,
                    radius: 10,
                  ),
                  title: Text(
                    distributor['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  subtitle: Text(
                      '📱 ${distributor['celular']} | ID: ${distributor['id']}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showDistributorDetails(distributor),
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
              'Página ${_currentPage + 1} de ${(filteredDistributors.length / _itemsPerPage).ceil()}',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentPage <
                      (filteredDistributors.length / _itemsPerPage).ceil() - 1
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

  // Para mostrar el modal de editar datos del distribuidor
  Future<void> _showEditDistributorModal(dynamic distributor) async {
    String name = distributor['nombre'];
    String phone = distributor['celular'];
    /* String email = distributor['email'];
    String zone = distributor['zonaAsignada']; */
    String state = distributor['estado'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modificar Distribuidor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => phone = value,
                controller: TextEditingController(text: phone),
                decoration: const InputDecoration(
                  labelText: 'Celular',
                  prefixIcon: Icon(Icons.phone, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: state,
                onChanged: (value) {
                  state = value!;
                },
                items: ['activo', 'inactivo']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Icon(
                                status == 'activo'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: status == 'activo'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Text(status),
                            ],
                          ),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await distributorService.updateDistributor(
                  id_distribuidor: distributor['id_distribuidor'],
                  name: name,
                  phone: phone,
                  state: state,
                );
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                _fetchDistributors();
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar detalles de un distribuidor
  void _showDistributorDetails(dynamic distributor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles del Distribuidor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text('Nombre: ${distributor['nombre']}'),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text('Celular: ${distributor['celular']}'),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.orange),
                title: Text('Email: ${distributor['email']}'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.confirmation_number, color: Colors.purple),
                title: Text('ID: ${distributor['id']}'),
              ),
              ListTile(
                leading: Icon(
                  distributor['estado'] == 'activo'
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: distributor['estado'] == 'activo'
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text('Estado: ${distributor['estado']}'),
              ),
            ],
          ),
          actions: [
            // Botón para eliminar
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el modal de detalles
                _confirmDelete(distributor['id']);
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),

            // Botón para modificar
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showEditDistributorModal(distributor);
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

// Función para mostrar confirmación antes de eliminar
  void _confirmDelete(String distributorId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este distribuidor? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal de confirmación
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el modal de confirmación
                await _deleteDistributor(distributorId);
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

// Función para eliminar el distribuidor y mostrar alerta animada
  Future<void> _deleteDistributor(String distributorId) async {
    try {
      await distributorService.deleteDistributor(distributorId);
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Éxito',
        'El distribuidor ha sido eliminado correctamente.',
        type: AnimatedAlertType.success,
      );
      _fetchDistributors(); // Recargar la lista después de eliminar
    } catch (e) {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'No se pudo eliminar el distribuidor: $e',
        type: AnimatedAlertType.error,
      );
    }
  }

// Mostrar modal para agregar un distribuidor
  void _showAddDistributorModal() {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String id_distribuidor = '';
        String name = '';
        String celular = '';
        String email = '';
        String state = 'activo';

        return AlertDialog(
          title: const Text('Agregar Distribuidor'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) => id_distribuidor = value,
                  decoration: const InputDecoration(
                    labelText: 'ID Distribuidor',
                    prefixIcon: Icon(Icons.local_shipping, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El ID del distribuidor es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => name = value,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => celular = value,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    prefixIcon: Icon(Icons.phone, color: Colors.green),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'El celular es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: (value) => email = value,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.orange),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty
                      ? 'El email es obligatorio'
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: state,
                  onChanged: (value) {
                    state = value!;
                  },
                  items: ['activo', 'inactivo']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Icon(
                                  status == 'activo'
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: status == 'activo'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 10),
                                Text(status),
                              ],
                            ),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
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
                  await distributorService.addDistributor({
                    'id_distribuidor': id_distribuidor,
                    'nombre': name,
                    'email': email,
                    'celular': celular,
                    'estado': state,
                  });
                  // Cerrar el modal
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();

                  // Recargar la lista de distribuidores
                  _fetchDistributors();

                  // ✅ Mostrar alerta de éxito
                  AnimatedAlert.show(
                    // ignore: use_build_context_synchronously
                    context,
                    'Éxito',
                    'Distribuidor agregado correctamente.',
                    type: AnimatedAlertType.success,
                  );
                } catch (e) {
                  AnimatedAlert.show(
                    // ignore: use_build_context_synchronously
                    context,
                    'Error',
                    'No se pudo agregar el distribuidor: $e',
                    type: AnimatedAlertType.error,
                  );
                }
              },
              child: const Text('Agregar'),
            ),
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

}
