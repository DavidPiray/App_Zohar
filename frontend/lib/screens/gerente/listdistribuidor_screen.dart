import 'package:flutter/material.dart';
import '../../core/styles/colors.dart';
import '../../services/distributor_service.dart';
import '../../widgets/wrapper.dart';

class ListdistribuidorScreen extends StatefulWidget {
  @override
  _ListdistribuidorScreenState createState() => _ListdistribuidorScreenState();
}

class _ListdistribuidorScreenState extends State<ListdistribuidorScreen> {
  final DistributorService distributorService = DistributorService();
  List<dynamic> distributors = [];
  List<dynamic> filteredDistributors = [];
  bool isLoading = true;
  bool isSidebarVisible = true;
  String selectedState = 'Todos';
  String selectedZone = 'Todas';
  String searchQuery = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchDistributors();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

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
                          _buildAddDistributorButton(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar distribuidores: $e')),
      );
    }
  }

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


  Widget _buildSidebarContent() {
    return Column(
      children: [
        /* const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Menú',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ), */
        ListTile(
          leading: const Icon(Icons.home, color: Colors.white),
          title: const Text('Inicio', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.pushNamed(context, '/director');
          },
        ),
        const ListTile(
          title: Text('Filtros', style: TextStyle(color: Colors.white)),
        ),
        _buildDropdownFilter(
          label: 'Estado',
          value: selectedState,
          items: ['Todos', 'activo', 'inactivo'],
          onChanged: (value) {
            setState(() {
              selectedState = value!;
              _filterDistributors();
            });
          },
        ),
        _buildDropdownFilter(
          label: 'Zona',
          value: selectedZone,
          items: [
            'Todas',
            ...distributors.map((d) => d['zonaAsignada']).toSet()
          ],
          onChanged: (value) {
            setState(() {
              selectedZone = value!;
              _filterDistributors();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((e) {
          return DropdownMenuItem(value: e, child: Text(e));
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
    );
  }

  Widget _buildDistributorList() {
    return ListView.builder(
      itemCount: filteredDistributors.length,
      itemBuilder: (context, index) {
        final distributor = filteredDistributors[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  distributor['estado'] == 'activo' ? Colors.green : Colors.red,
              radius: 10,
            ),
            title: Text(
              distributor['nombre'] ?? 'Sin nombre',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            subtitle:
                Text(distributor['zonaAsignada'] ?? 'Zona no especificada'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showDistributorDetails(distributor),
          ),
        );
      },
    );
  }

  Future<void> _showEditDistributorModal(dynamic distributor) async {
    String name = distributor['nombre'];
    String zone = distributor['zonaAsignada'];
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
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                onChanged: (value) => zone = value,
                controller: TextEditingController(text: zone),
                decoration: const InputDecoration(labelText: 'Zona'),
              ),
              DropdownButtonFormField<String>(
                value: state,
                onChanged: (value) {
                  state = value!;
                },
                items: ['activo', 'inactivo']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Estado'),
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
            TextButton(
              onPressed: () async {
                await distributorService.updateDistributor(
                  idDistribuidor: distributor['id'],
                  name: name,
                  phone: distributor['celular'], // Mantenemos el celular
                );
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
              Text('Nombre: ${distributor['nombre']}'),
              Text('Celular: ${distributor['celular']}'),
              Text('Email: ${distributor['email']}'),
              Text('Zona: ${distributor['zonaAsignada']}'),
              Text('Estado: ${distributor['estado']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await distributorService.deleteDistributor(distributor['id']);
                _fetchDistributors();
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showEditDistributorModal(distributor);
              },
              child: const Text('Modificar'),
            ),
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

// Mostrar modal para agregar un distribuidor
  void _showAddDistributorModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String celular = '';
        String email = '';
        String zone = '';
        String state = 'activo';

        return AlertDialog(
          title: const Text('Agregar Distribuidor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                onChanged: (value) => celular = value,
                decoration: const InputDecoration(labelText: 'Celular'),
              ),
              TextField(
                onChanged: (value) => email = value,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: (value) => zone = value,
                decoration: const InputDecoration(labelText: 'Zona'),
              ),
              DropdownButtonFormField<String>(
                value: state,
                onChanged: (value) {
                  state = value!;
                },
                items: ['activo', 'inactivo']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await distributorService.addDistributor({
                  'nombre': name,
                  'email': email,
                  'celular': celular,
                  'estado': state,
                  'zonaAsignada': zone,
                });
                Navigator.of(context).pop();
                _fetchDistributors();
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

  Widget _buildAddDistributorButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _showAddDistributorModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        child: const Text('Agregar Distribuidor'),
      ),
    );
  }
}
