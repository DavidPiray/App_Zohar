import 'package:flutter/material.dart';
import 'package:frontend/core/styles/colors.dart';
import 'package:frontend/services/auth_service.dart';
//import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:image_picker/image_picker.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/animated_title.dart';
import '../../widgets/animated_alert.dart';
import '../../widgets/location_picker.dart';
import '../../core/utils/validators.dart';
import '../../services/client_service.dart';
import '../../services/google_maps_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Variables
  final ClientService clientService = ClientService();
  final AuthService authService = AuthService();
  //final ImagePicker _picker = ImagePicker();
  GoogleMapsService mapsService = GoogleMapsService();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0; // Paginación
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  final TextEditingController _addressController = TextEditingController();

  // Variables para los datos
  String? _name,
      _email,
      _password,
      _confirmPassword,
      _phone,
      _address,
      _distribuidorID;
  LatLng? _selectedLocation;
  //File? _selectedImage;

  // Abrir el mapa para seleccionar ubicación
  Future<void> _openLocationPicker() async {
    _selectedLocation ??= const LatLng(-1.6635, -78.6547);
    await Navigator.push(
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
            setState(() {
              _address = address;
              _selectedLocation = location;
              _addressController.text = address;
            });
          },
        ),
      ),
    );
  }

  // Enviar los datos 
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_password != _confirmPassword) {
        AnimatedAlert.show(
          context,
          'Error',
          'Las contraseñas no coinciden.',
          type: AnimatedAlertType.error,
        );
        return;
      }
      _formKey.currentState!.save();
      try {
        final result = await clientService.registerClient(
          name: _name!,
          email: _email!,
          address: _address!,
          phone: _phone!,
          zonaID: 'zona1',
          distribuidorID: _distribuidorID!,
          //photoURL: _selectedImage,
          password: _password!,
          location: _selectedLocation ??
              const LatLng(48.858844, 2.294351), // Torre Eiffel (por defecto)
        );

        if (result) {
          await authService.registerUser(_email!, _password!);
          AnimatedAlert.show(
            // ignore: use_build_context_synchronously
            context,
            'Registro Exitoso',
            'El cliente se registró satisfactoriamente.',
            type: AnimatedAlertType.success,
            actionLabel: 'Continuar',
            action: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          );
        } else {
          AnimatedAlert.show(
            // ignore: use_build_context_synchronously
            context,
            'Error',
            'No se pudo completar el registro.',
          );
        }
      } catch (e) {
        AnimatedAlert.show(
          // ignore: use_build_context_synchronously
          context,
          'Error',
          e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Altura personalizada
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.barra,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  'Formulario de Registro de Cliente',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.degradadoPrincipal,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWideScreen = constraints.maxWidth > 600;
              return Row(
                children: [
                  if (isWideScreen)
                    const Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedLogo(size: 150),
                          SizedBox(height: 20),
                          AnimatedTitle(),
                        ],
                      ),
                    ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: isWideScreen
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        if (!isWideScreen)
                          const Column(
                            children: [
                              SizedBox(height: 10),
                              AnimatedLogo(size: 100),
                              SizedBox(height: 10),
                            ],
                          ),
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isWideScreen ? 400 : 350,
                            ),
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IndexedStack(
                                      index:
                                          _currentPage, // Muestra la página seleccionada
                                      children: [
                                        // Primera página del formulario
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 15),
                                            _buildTextField('Nombre',
                                                (value) => _name = value,
                                                validator:
                                                    Validators.validateName,
                                                prefixIcon: Icons.person),
                                            const SizedBox(height: 15),
                                            _buildTextField(
                                                'Correo Electrónico',
                                                (value) => _email = value,
                                                validator:
                                                    Validators.validateEmail,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                prefixIcon: Icons.email),
                                            const SizedBox(height: 15),
                                            _buildTextField(
                                              'Contraseña',
                                              (value) => _password = value,
                                              validator:
                                                  Validators.validatePassword,
                                              obscureText: true,
                                              prefixIcon: Icons.lock,
                                              isPasswordField: true,
                                            ),
                                            const SizedBox(height: 15),
                                            _buildTextField(
                                              'Confirmar Contraseña',
                                              (value) =>
                                                  _confirmPassword = value,
                                              obscureText: true,
                                              prefixIcon: Icons.lock,
                                              isPasswordConfirmField: true,
                                            ),
                                          ],
                                        ),
                                        // Segunda página del formulario
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 15),
                                            _buildTextField(
                                                'Código de Distribuidor (Opcional)',
                                                (value) =>
                                                    _distribuidorID = value,
                                                prefixIcon:
                                                    Icons.local_shipping),
                                            const SizedBox(height: 10),
                                            _buildTextField('Teléfono',
                                                (value) => _phone = value,
                                                validator:
                                                    Validators.validatePhone,
                                                keyboardType:
                                                    TextInputType.phone,
                                                prefixIcon: Icons.phone),
                                            const SizedBox(height: 10),
                                            _buildTextField(
                                              'Dirección',
                                              (value) {},
                                              keyboardType:
                                                  TextInputType.streetAddress,
                                              prefixIcon: Icons.place,
                                              isLocationField: true,
                                              onSuffixIconPressed:
                                                  _openLocationPicker,
                                            ),
                                            const SizedBox(height: 10),
                                            const SizedBox(height: 16),
                                            //_buildPhotoPicker(),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 25),
                                    // Botones de navegación
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (_currentPage >
                                            0) // Si no estamos en la primera página, mostramos "Atrás"
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _currentPage--; // Retrocede a la página anterior
                                              });
                                            },
                                            child: const Text("Atrás"),
                                          ),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_currentPage == 0) {
                                              // Si estamos en la primera página, pasamos a la segunda
                                              setState(() {
                                                _currentPage = 1;
                                              });
                                            } else {
                                              // Si estamos en la segunda página, enviamos el formulario
                                              _submitForm();
                                            }
                                          },
                                          child: Text(_currentPage == 0
                                              ? "Siguiente"
                                              : "Registrarse"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget para construir los espacios de texto
  Widget _buildTextField(
    String label,
    void Function(String?) onSave, {
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    bool isPasswordField = false,
    bool isPasswordConfirmField = false,
    bool isLocationField = false,
    VoidCallback? onSuffixIconPressed,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: isLocationField ? _addressController : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
        // Icono de mostrar/ocultar contraseña
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                        _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
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
      obscureText: isPasswordField
          ? !_isPasswordVisible
          : (isPasswordConfirmField ? !_isPasswordConfirmVisible : obscureText),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSave,
      enabled: enabled,
    );
  }
}
