class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu nombre.';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'El correo no puede estar vacío.';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) return 'El correo no es válido.';
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null ||password.isEmpty) return 'La contraseña no puede estar vacía.';
    if (password.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu número de teléfono.';
    }
    return null;
  }
}
