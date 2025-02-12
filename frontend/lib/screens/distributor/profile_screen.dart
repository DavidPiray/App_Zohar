import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/styles/colors.dart';
import '../../widgets/animated_alert.dart';
import '../../services/distributor_service.dart';
import '../../widgets/wrapper.dart';

class ProfileDistributorScreen extends StatefulWidget {
  const ProfileDistributorScreen({Key? key}) : super(key: key);

  @override
  _ProfileDistributorScreenState createState() =>
      _ProfileDistributorScreenState();
}

class _ProfileDistributorScreenState extends State<ProfileDistributorScreen> {
  final DistributorService distributorService = DistributorService();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  late Future<Map<String, dynamic>> _distributorData;

  String? _name;
  String? _email;
  String? _phone;
  String? _zona;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

//Cosntructor de pagina de incio
  @override
  void initState() {
    super.initState();
    _distributorData = distributorService.getDistributorByEmail();
  }

//COnstructor de incio de página
  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Wrapper(
      userRole: "distribuidor",
      child: Row(
        children: [
          Expanded(
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
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _distributorData,
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
                        _zona ??= data['zonaAsignada'];

                        return SingleChildScrollView(
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
                                        : const AssetImage(
                                                'assets/images/Logo3.png')
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
                                  initialValue: _zona,
                                  enabled: false,
                                  decoration: const InputDecoration(
                                    labelText: 'Zona Asignada',
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
                                if (_isEditing)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

//Imágenes
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

//Guardar cambios
  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? idDistribuidor = prefs.getString('distributorID');
        if (idDistribuidor == null) {
          throw Exception(
              'No se encontró el ID del distribuidor en la sesión.');
        }
        final success = await distributorService.updateDistributor(
          id_distribuidor:
              idDistribuidor, // Reemplaza con el ID real del cliente
          name: _name!,
          phone: _phone!,
          image: _selectedImage, // Si la foto fue actualizada
        );

        if (success) {
          setState(() {
            _isEditing = false;
          });
          AnimatedAlert.show(
            context,
            'Precesando',
            'Los cambios se estan procesando.',
            type: AnimatedAlertType.success,
          );
        }

        // Simula un retraso para la operación de red
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isEditing = false;
          _distributorData =
              distributorService.getDistributorByEmail(); // Recargar datos
        });

        AnimatedAlert.show(
          context,
          'Éxito',
          'Los cambios han sido guardados con éxito.',
          type: AnimatedAlertType.success,
        );
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
}
