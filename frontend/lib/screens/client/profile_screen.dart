import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../widgets/animated_alert.dart';
import '../../services/client_service.dart';
import '../../services/auth_service.dart';

class ProfileClientScreen extends StatefulWidget {
  const ProfileClientScreen({super.key});

  @override
  _ProfileClientScreenState createState() => _ProfileClientScreenState();
}

class _ProfileClientScreenState extends State<ProfileClientScreen> {
  final ClientService clientService = ClientService();
  final AuthService securityService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isChangingPassword = false;

  late Future<Map<String, dynamic>> _clientData;
  String? _name, _id, _email, _phone;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Campos para cambiar la contraseña
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
        final success = await clientService.updateClientData(
          clientId: _id!,
          name: _name!,
          phone: _phone!,
          photo: _selectedImage,
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
      } catch (e) {
        AnimatedAlert.show(
          context,
          'Error',
          'Hubo un error al guardar los cambios: $e',
          type: AnimatedAlertType.error,
        );
      }
    }
  }

  void _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      AnimatedAlert.show(
        context,
        'Error',
        'Las contraseñas no coinciden.',
        type: AnimatedAlertType.error,
      );
      return;
    }

    try {
      print('------------');
      print(_id);
      final success = await securityService.updatePassword(
        clientId: _id!,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        email: _email!,
      );
      print(_id);

      if (success) {
        setState(() {
          _isChangingPassword = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        AnimatedAlert.show(
          context,
          'Éxito',
          'Tu contraseña ha sido actualizada.',
          type: AnimatedAlertType.success,
        );
      }
    } catch (e) {
      AnimatedAlert.show(
        context,
        'Error',
        'No se pudo cambiar la contraseña: $e',
        type: AnimatedAlertType.error,
      );
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

                          TextFormField(
                            initialValue: _email,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

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

                          if (_isChangingPassword) ...[
                            TextFormField(
                              controller: _oldPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña Actual',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Nueva Contraseña',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Confirmar Nueva Contraseña',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _changePassword,
                              child: const Text('Actualizar Contraseña'),
                            ),
                          ],

                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isChangingPassword = !_isChangingPassword;
                              });
                            },
                            child: const Text('Cambiar Contraseña'),
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
