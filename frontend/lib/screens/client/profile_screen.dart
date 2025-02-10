import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'dart:io';
//import 'package:image_picker/image_picker.dart';
import '../../widgets/animated_alert.dart';
import '../../services/client_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/wrapper.dart';
import '../../widgets/location_picker.dart';

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
  String? _name, _id, _email, _phone, _address, _zonaID, _idDistribuidor;
  LatLng? _selectedLocation;
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  dynamic _selectedImage;
  //final ImagePicker _picker = ImagePicker();

  // Campos para cambiar la contraseña
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zonaController = TextEditingController();
  final TextEditingController _distribuidorController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientData = clientService.getClientData();
    _oldPasswordController.text = 'Contraseña Actual';
  }

  void _pickImage() async {
    final image = await clientService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image; // Ahora soporta tanto `File` como `Uint8List`
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
        /* String? photoURL;

        // 🔹 Subimos la imagen si el usuario seleccionó una nueva
        if (_selectedImage != null) {
          photoURL = await clientService.uploadImage(_selectedImage);
        } */
        _name = _nameController.text;
        _phone = _phoneController.text;
        _address = _addressController.text;
        final success = await clientService.updateClientData(
          clientId: _id!,
          name: _name!,
          phone: _phone!,
          direccion: _address!,
          ubicacion: _selectedLocation != null
              ? {
                  "latitude": _selectedLocation!.latitude,
                  "longitude": _selectedLocation!.longitude,
                }
              : null, // ✅ PASA LAS COORDENADAS SOLO SI EXISTEN
          //photoURL: photoURL, // Solo pasamos la URL, no el archivo
        );
        if (success) {
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
        }
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

  void _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      AnimatedAlert.show(
        context,
        'Error',
        'Las contraseñas no coinciden. Por favor verifique',
        type: AnimatedAlertType.error,
      );
      return;
    }

    try {
      final success = await securityService.updatePassword(
        clientId: _id!,
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        email: _email!,
      );
      if (success) {
        setState(() {
          _isChangingPassword = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });

        AnimatedAlert.show(
          // ignore: use_build_context_synchronously
          context,
          'Éxito',
          'Tu contraseña ha sido actualizada.',
          type: AnimatedAlertType.success,
        );
      }
    } catch (e) {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
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

    return Wrapper(
      userRole: "cliente",
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: isWideScreen ? 600 : double.infinity),
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
              if (_name == null) {
                _name = data['nombre'];
                _nameController.text = _name!;
              }
              if (_email == null) {
                _email = data['email'];
                _emailController.text = _email!;
              }
              if (_phone == null) {
                _phone = data['celular'];
                _phoneController.text = _phone!;
              }
              if (_address == null) {
                _address = data['direccion'];
                _addressController.text =
                    _address!; // 🔥 INICIALIZA EL CONTROLADOR SOLO SI ES NULL
              }
              _id ??= data['id_cliente'];
              if (_idDistribuidor == null) {
                _idDistribuidor = data['distribuidorID'];
                _distribuidorController.text = _idDistribuidor!;
              }
              if (_zonaID == null) {
                _zonaID = data['zonaID'];
                _zonaController.text = _zonaID!;
              }

              if (_selectedLocation == null &&
                  data['ubicacion'] != null &&
                  data['ubicacion'] is Map<String, dynamic>) {
                _selectedLocation = LatLng(
                  data['ubicacion']['latitude'],
                  data['ubicacion']['longitude'],
                );
              }
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

                        // 🔹 Reemplazo del Column tradicional por Wrap adaptativo
                        _buildFormFields(isWideScreen),

                        if (_isEditing)
                          ElevatedButton(
                            onPressed: _saveChanges,
                            child: const Text('Guardar Cambios'),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          },
                          child: const Text('Actualizar Datos'),
                        ),
                      ],
                    )),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Nueva Contraseña',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isPasswordConfirmVisible,
          decoration: InputDecoration(
            labelText: 'Confirmar Nueva Contraseña',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordConfirmVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMap() async {
    _selectedLocation ??= const LatLng(-1.6635, -78.6547);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          initialLocation: _selectedLocation!,
          initialAddress: _address ?? "",
          onLocationSelected: (
            String address,
            LatLng location,
            String city,
          ) {
            // ✅ Devuelve los datos en un mapa en lugar de hacer pop() aquí
            Navigator.pop(context, {
              "address": address,
              "location": location,
              "city": city,
            });
          },
        ),
      ),
    );

    // ✅ SOLO SI HAY RESULTADOS, ACTUALIZA LAS VARIABLES GLOBALES
    print('🔹 Datos recibidos del LocationPicker: $result');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _address = result["address"];
        _selectedLocation = result["location"];
        _addressController.text =
            _address!; // 🔥 ACTUALIZA EL CONTROLLER TAMBIÉN
      });

      print("✅ Dirección actualizada: $_address");
      print(
          "✅ Coordenadas actualizadas: ${_selectedLocation?.latitude}, ${_selectedLocation?.longitude}");
    } else {
      print("❌ Cancelaste la selección de ubicación.");
    }
  }

  void _togglePasswordEdit() {
    setState(() {
      _isChangingPassword = !_isChangingPassword;
    });
  }

  Widget _buildFormFields(bool isWideScreen) {
    return Wrap(
      spacing: 45.0, // Espaciado horizontal entre columnas
      runSpacing: 16.0, // Espaciado vertical entre filas
      children: [
        _buildTextField('Nombre', (value) => _name = value,
            controller: _nameController, prefixIcon: Icons.person),
        _buildTextField('Correo Electrónico', (value) => _email = value,
            controller: _emailController,
            enabled: false,
            prefixIcon: Icons.email),
        _buildTextField('Teléfono', (value) => _phone = value,
            controller: _phoneController, prefixIcon: Icons.phone),
        _buildTextField(
          'Dirección',
          (value) => _address = value,
          controller: _addressController,
          initialValue: _address,
          prefixIcon: Icons.place,
          isLocationField: true,
          onSuffixIconPressed: _isEditing
              ? _openMap
              : null, // Solo muestra el botón si está editando
        ),
        _buildTextField('Zona Asignada', (value) => {},
            controller: _zonaController,
            enabled: false,
            prefixIcon: Icons.location_city),
        _buildTextField('Distribuidor Asignado', (value) => {},
            controller: _distribuidorController,
            enabled: false,
            prefixIcon: Icons.local_shipping),
        _buildTextField(
          'Contraseña',
          (value) => {},
          controller: _oldPasswordController,
          prefixIcon: Icons.lock,
          isPasswordField: true,
          onSuffixIconPressed:
              _togglePasswordEdit, // Llama a la función para mostrar los campos de nueva contraseña
        ),
        if (_isChangingPassword) ...[
          _buildPasswordFields(), // ✅ Muestra los campos de cambio de contraseña
          ElevatedButton(
            onPressed: _changePassword,
            child: const Text('Cambiar Contraseña'),
          ),
        ]
      ].map((field) {
        return isWideScreen
            ? SizedBox(
                width: 250, child: field) // ✅ 2 columnas en pantallas grandes
            : field; // ✅ 1 columna en pantallas pequeñas
      }).toList(),
    );
  }

  Widget _buildTextField(
    String label,
    void Function(String?) onSave, {
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    IconData? prefixIcon,
    bool isPasswordField = false,
    bool isPasswordConfirmField = false,
    bool isLocationField = false,
    VoidCallback? onSuffixIconPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing && enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon:
              prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
          // Icono de mostrar/ocultar contraseña
          suffixIcon: onSuffixIconPressed != null
              ? IconButton(
                  icon: Icon(
                    isPasswordField
                        ? Icons.edit // 🔹 Icono de editar en la contraseña
                        : Icons.map, // 🔹 Icono de mapa en la dirección
                    color: Colors.grey,
                  ),
                  onPressed: onSuffixIconPressed, // ✅ Acción dinámica
                )
              : isPasswordField
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : isPasswordConfirmField
                      ? IconButton(
                          icon: Icon(
                            _isPasswordConfirmVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordConfirmVisible =
                                  !_isPasswordConfirmVisible;
                            });
                          },
                        )
                      : isLocationField
                          ? IconButton(
                              icon: const Icon(Icons.map, color: Colors.grey),
                              onPressed: onSuffixIconPressed, // Abre el mapa
                            )
                          : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa $label';
          }
          return null;
        },
        onSaved: onSave,
      ),
    );
  }
}
