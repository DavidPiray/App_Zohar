import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  String? _name;
  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _phone;
  LatLng? _selectedLocation;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  void _showSnackbar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo al tocar fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registro Exitoso'),
          content: Text('El cliente se registró satisfactoriamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.pushReplacementNamed(context, '/login'); // Ir a Login
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _showSnackbar('Foto seleccionada', backgroundColor: Colors.green);
    }
  }

  void _selectLocation() async {
    try {
      final LatLng? location =
          await Navigator.pushNamed(context, '/map') as LatLng?;
      if (location != null) {
        setState(() {
          _selectedLocation = location;
        });
        _showSnackbar('Ubicación seleccionada', backgroundColor: Colors.green);
      } else {
        _showSnackbar('No se seleccionó ninguna ubicación');
      }
    } catch (e) {
      _showSnackbar('Error al seleccionar la ubicación: $e');
    }
  }

  void _submitForm() async {
    // Validar el formulario antes de continuar
    if (_formKey.currentState!.validate()) {
      // Validar que las contraseñas coincidan
      if (_password != _confirmPassword) {
        _showSnackbar('Las contraseñas no coinciden');
        return; // Detener la ejecución si no coinciden
      }

      // Si no se seleccionó ubicación, usar una ubicación por defecto
      if (_selectedLocation == null) {
        _selectedLocation = LatLng(48.858844, 2.294351); // Torre Eiffel
      }

      _formKey.currentState!.save();

      try {
        final result = await apiService.registerClient(
          name: _name!,
          email: _email!,
          password: _password!,
          phone: _phone!,
          location: _selectedLocation!,
          photo: _selectedImage,
        );

        if (result) {
          _showSuccessDialog(); // Mostrar diálogo de éxito
        } else {
          _showSnackbar('Error al registrar: Registro fallido');
        }
      } catch (error) {
        _showSnackbar('Error al registrar: $error');
      }
    } else {
      _showSnackbar('Por favor completa todos los campos correctamente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8E994), // Light green
                  Color(0xFF6ABF69), // Medium green
                  Color(0xFF3B945E), // Dark green
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'La contraseña debe tener al menos 8 caracteres';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        
                        return null;
                      },
                      onSaved: (value) => _confirmPassword = value,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu teléfono';
                        }
                        return null;
                      },
                      onSaved: (value) => _phone = value,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectLocation,
                          child: Text('Seleccionar Ubicación'),
                        ),
                        SizedBox(width: 16),
                        if (_selectedLocation != null)
                          Text(
                            'Ubicación seleccionada',
                            style: TextStyle(color: Colors.green),
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Seleccionar Foto (Opcional)'),
                        ),
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text('Foto seleccionada'),
                          ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B945E),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.h, horizontal: 50.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
