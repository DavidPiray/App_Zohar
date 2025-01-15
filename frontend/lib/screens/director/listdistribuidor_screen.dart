import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class ListdistribuidorScreen extends StatefulWidget {
  @override
  _ListdistribuidorScreenSate createState() => _ListdistribuidorScreenSate();
}

class _ListdistribuidorScreenSate extends State<ListdistribuidorScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> distributors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDistributors();
  }

  Future<void> _fetchDistributors() async {
    try {
      final result = await apiService.getDistributors();
      setState(() {
        distributors = result;
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

  void _showDistributorDetails(dynamic distributor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Distribuidor'),
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
                await apiService.deleteDistributor(distributor['id']);
                _fetchDistributors();
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showEditDistributorModal(distributor);
              },
              child: Text('Modificar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
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
          title: Text('Modificar Distribuidor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                controller: TextEditingController(text: name),
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                onChanged: (value) => zone = value,
                controller: TextEditingController(text: zone),
                decoration: InputDecoration(labelText: 'Zona'),
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
                decoration: InputDecoration(labelText: 'Estado'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await apiService.updateDistributor(distributor['id'], {
                  'nombre': name,
                  'zonaAsignada': zone,
                  'estado': state,
                });
                Navigator.of(context).pop();
                _fetchDistributors();
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

  void _showAddDistributorModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String id = '';
        String name = '';
        String celular = '';
        String email = '';
        String zone = '';
        String state = 'activo';

        return AlertDialog(
          title: Text('Agregar Distribuidor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => id = value,
                decoration: InputDecoration(labelText: 'ID Distribuidor'),
              ),
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                onChanged: (value) => celular = value,
                decoration: InputDecoration(labelText: 'Celular'),
              ),
              TextField(
                onChanged: (value) => email = value,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: (value) => zone = value,
                decoration: InputDecoration(labelText: 'Zona'),
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
                decoration: InputDecoration(labelText: 'Estado'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await apiService.addDistributor({
                  'id_distribuidor': id,
                  'nombre': name,
                  'celular': celular,
                  'email': email,
                  'zonaAsignada': zone,
                  'estado': state,
                });
                Navigator.of(context).pop();
                _fetchDistributors();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Distribuidores'),
        backgroundColor: Color(0xFF3B945E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E994),
                  Color(0xFF6ABF69),
                  Color(0xFF3B945E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : distributors.isEmpty
                        ? Center(
                            child: Text(
                              'No hay distribuidores disponibles.',
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          )
                        : ListView.builder(
                            itemCount: distributors.length,
                            itemBuilder: (context, index) {
                              final distributor = distributors[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: distributor['estado'] ==
                                            'activo'
                                        ? Colors.green
                                        : Colors.red,
                                    radius: 10,
                                  ),
                                  title: Text(
                                    distributor['nombre'] ?? 'Sin nombre',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                  subtitle: Text(
                                    distributor['zonaAsignada'] ??
                                        'Zona no especificada',
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () =>
                                      _showDistributorDetails(distributor),
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _showAddDistributorModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  ),
                  child: Text('Agregar Distribuidor'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
