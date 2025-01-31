import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/animated_title.dart';
import '../../widgets/global_button.dart';
import '../../widgets/animated_alert.dart';
import '../../core/utils/validators.dart';
import '../../services/client_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientService clientService = ClientService();
  final ImagePicker _picker = ImagePicker();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registerUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Usuario registrado exitosamente: ${userCredential.user?.email}");
    } on FirebaseAuthException catch (e) {
      print("Error al registrar el usuario: ${e.message}");
    }
  }

  String? _name, _email, _password, _confirmPassword, _phone;
  LatLng? _selectedLocation;
  File? _selectedImage;

  void _handleImageSelection() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Foto seleccionada',
        'Se ha seleccionado una foto correctamente.',
        type: AnimatedAlertType.success,
      );
    }
  }

  void _handleLocationSelection() async {
    final LatLng? location =
        await Navigator.pushNamed(context, '/map') as LatLng?;
    if (location != null) {
      setState(() {
        _selectedLocation = location;
      });
    } else {
      AnimatedAlert.show(
        // ignore: use_build_context_synchronously
        context,
        'Error',
        'No se seleccionó ninguna ubicación.',
      );
    }
  }

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
          password: _password!,
          phone: _phone!,
          location: _selectedLocation ??
              LatLng(48.858844, 2.294351), // Torre Eiffel (por defecto)
          photo: _selectedImage,
        );

        if (result) {
          await registerUser(_email!,_password!);
          AnimatedAlert.show(
            context,
            'Registro Exitoso',
            'El cliente se registró satisfactoriamente.',
            type: AnimatedAlertType.success,
            actionLabel: 'Continuar',
            action: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pushReplacementNamed(context, '/login');
            },
          );
        } else {
          AnimatedAlert.show(
            context,
            'Error',
            'No se pudo completar el registro.',
          );
        }
      } catch (e) {
        AnimatedAlert.show(
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
            color: const Color(0xFF3B945E),
            boxShadow: [
              BoxShadow(
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
                                    _buildTextField(
                                        'Nombre', (value) => _name = value,
                                        validator: Validators.validateName),
                                    const SizedBox(height: 10),
                                    _buildTextField('Correo Electrónico',
                                        (value) => _email = value,
                                        validator: Validators.validateEmail,
                                        keyboardType:
                                            TextInputType.emailAddress),
                                    const SizedBox(height: 10),
                                    _buildTextField('Contraseña',
                                        (value) => _password = value,
                                        validator: Validators.validatePassword,
                                        obscureText: true),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                      'Confirmar Contraseña',
                                      (value) => _confirmPassword = value,
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                        'Teléfono', (value) => _phone = value,
                                        validator: Validators.validatePhone,
                                        keyboardType: TextInputType.phone),
                                    const SizedBox(height: 16),
                                    _buildLocationPicker(),
                                    const SizedBox(height: 16),
                                    _buildPhotoPicker(),
                                    const SizedBox(height: 25),
                                    GlobalButton(
                                      label: 'Registrarse',
                                      backgroundColor: const Color(0xFF3B945E),
                                      onPressed: _submitForm,
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

  Widget _buildTextField(
    String label,
    void Function(String?) onSave, {
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSave,
    );
  }

  Widget _buildLocationPicker() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar los botones
          children: [
            Expanded(
              flex: isWideScreen ? 0 : 1, // Para pantallas pequeñas expandir
              child: GlobalButton(
                label: 'Seleccionar Ubicación',
                backgroundColor: const Color.fromARGB(255, 86, 168, 84),
                onPressed: _handleLocationSelection,
                textStyle: TextStyle(
                    fontSize:
                        isWideScreen ? 18 : 16, // Tamaño de fuente dinámico
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            if (_selectedLocation != null)
              const Icon(Icons.check, color: Colors.white),
          ],
        );
      },
    );
  }

  Widget _buildPhotoPicker() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrar los botones
          children: [
            Expanded(
              flex: isWideScreen ? 0 : 1, // Para pantallas pequeñas expandir
              child: GlobalButton(
                label: 'Seleccionar Foto (Opcional)',
                backgroundColor: const Color.fromARGB(255, 86, 168, 84),
                onPressed: _handleImageSelection,
                textStyle: TextStyle(
                    fontSize:
                        isWideScreen ? 18 : 16, // Tamaño de fuente dinámico
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            if (_selectedImage != null)
              const Icon(Icons.check, color: Colors.white),
          ],
        );
      },
    );
  }
}
