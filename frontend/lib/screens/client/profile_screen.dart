import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../widgets/animated_alert.dart';
import '../../services/client_service.dart';

class ProfileClientScreen extends StatefulWidget {
  const ProfileClientScreen({super.key});

  @override
  _ProfileClientScreenState createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen> {
  final ClientService clientService = ClientService();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  late Future<Map<String, dynamic>> _clientData;

  String? _name;
  String? _id;
  String? _email;
  String? _phone;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _clientData = clientService.getClientData();
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Foto seleccionada',
        'Se ha seleccionado una nueva foto de perfil.',
        type: AnimatedAlertType.success,
      );
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Llama al servicio para actualizar los datos
        final success = await clientService.updateClientData(
          clientId: _id!, // Reemplaza con el ID real del cliente
          name: _name!,
          phone: _phone!,
          photo: _selectedImage, // Si la foto fue actualizada
        );

        if (success) {
          setState(() {
            _isEditing = false;
          });

          AnimatedAlert.show(
            context,
            'Éxito',
            'Los cambios han sido guardados con éxito.',
            type: AnimatedAlertType.success,
          );
        }
        // Simula un retraso para la operación de red
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isEditing = false;
        });

        AnimatedAlert.show(
          // ignore: use_build_context_synchronously
          context,
          'Éxito',
          'Los cambios han sido guardados con éxito.',
          type: AnimatedAlertType.success,
        );
      } catch (e) {
        AnimatedAlert.show(
          // ignore: use_build_context_synchronously
          context,
          'Error',
          'Hubo un error al guardar los cambios: $e',
          type: AnimatedAlertType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Perfil', style: TextStyle(fontSize: 18)),
        ),
      ),
      body: Row(
        children: [
          if (isWideScreen) ...[
            Container(
              width: 250,
              color: const Color(0xFF3B945E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Opciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text('Perfil',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {},
                  ),
                  // Agrega más opciones según sea necesario
                ],
              ),
            ),
          ],
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _clientData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final data = snapshot.data!;
                  _name ??= data['nombre'];
                  _email ??= data['email'];
                  _phone ??= data['celular'];
                  _id ??= data['id_cliente'];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Foto de perfil
                          GestureDetector(
                            onTap: _isEditing ? _pickImage : null,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : const AssetImage('assets/images/Logo3.png')
                                      as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Nombre
                          TextFormField(
                            initialValue: _name,
                            enabled: _isEditing,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu nombre';
                              }
                              return null;
                            },
                            onSaved: (value) => _name = value,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            initialValue: _email,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Teléfono
                          TextFormField(
                            initialValue: _phone,
                            enabled: _isEditing,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu número de teléfono';
                              }
                              return null;
                            },
                            onSaved: (value) => _phone = value,
                          ),
                          const SizedBox(height: 16),

                          // Botones de acción
                          if (_isEditing)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                    });
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: _saveChanges,
                                  child: const Text('Guardar Cambios'),
                                ),
                              ],
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              child: const Text('Editar Perfil'),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
