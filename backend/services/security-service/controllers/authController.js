const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const { registerSchema, loginSchema, updatePasswordSchema } = require('../validations/authValidation');

const AuthController = {
  async register(req, res) {
    const { email, password, roles } = req.body;

    const { error } = registerSchema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    try {
      const existingUser = await User.getUserByEmail(email);
      if (existingUser) return res.status(400).json({ error: 'El usuario ya existe' });

      const passwordHash = await bcrypt.hash(password, 10);
      await User.createUser({ email, passwordHash, roles });
      return res.status(201).json({ message: 'Usuario registrado con éxito!' });
    } catch (error) {
      console.error('Fallo al registrar el usuario:', error.message);
      return res.status(500).json({ error: 'Fallo al registrar el usuario' });
    }
  },

  async login(req, res) {
    const { email, password } = req.body;

    const { error } = loginSchema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    try {
      const user = await User.getUserByEmail(email);
      if (!user) return res.status(404).json({ error: 'Usuario no encontrado' });

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) return res.status(401).json({ error: 'Contraseña incorrecta' });

      const token = jwt.sign(
        { email: user.email, roles: user.roles },
        process.env.JWT_SECRET,
        { expiresIn: process.env.TOKEN_EXPIRATION }
      );

      return res.status(200).json({ token });
    } catch (error) {
      console.error('Fallo al iniciar sesión:', error.message);
      return res.status(500).json({ error: 'Fallo al iniciar sesión' });
    }
  },

  async updatePassword(req, res) {
    const { clientId } = req.params;
    const { oldPassword, newPassword } = req.body;
    const { email } = req.body

    const { error } = updatePasswordSchema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    try {
      const user = await User.getUserByEmail(email);
      if (!user) {
        console.error('Usuario no encontrado');
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }

      const isMatch = await bcrypt.compare(oldPassword, user.passwordHash);
      if (!isMatch) {
        console.error({ error: 'Contraseña antigua incorrecta' });
        return res.status(401).json({ error: 'Contraseña antigua incorrecta' });
      }

      const newPasswordHash = await bcrypt.hash(newPassword, 10);
      await User.updateUserPassword(email, newPasswordHash);

      return res.status(200).json({ message: 'Contraseña actualizada con éxito' });
    } catch (error) {
      console.error('Fallo al actualizar la contraseña:', error.message);
      return res.status(500).json({ error: 'Fallo al actualizar la contraseña' });
    }
  },
};

module.exports = AuthController;
