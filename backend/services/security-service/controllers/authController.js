const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

const AuthController = {
  async register(req, res) {
    const { email, password, roles } = req.body;
    try {
      const existingUser = await User.getUserByEmail(email);
      if (existingUser) return res.status(400).json({ error: 'El usuario ya existe' });

      const passwordHash = await bcrypt.hash(password, 10);
      await User.createUser({ email, passwordHash, roles });
      return res.status(201).json({ message: 'Usuario registrado con éxito' });
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
  async login(req, res) {
    const { email, password } = req.body;
    try {
      const user = await User.getUserByEmail(email);
      console.log('User fetched:', user);
      if (!user) return res.status(404).json({ error: 'Usuario no Encontrado' });

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      console.log('Password match:', isMatch);
      if (!isMatch) return res.status(401).json({ error: 'Usuario y/o contraseña incorrectos' });

      try {
        const token = jwt.sign({ email: user.email, roles: user.roles }, process.env.JWT_SECRET, {
          expiresIn: process.env.TOKEN_EXPIRATION,
        });
        console.log('Generated token:', token);
        return res.status(200).json({ token });
      } catch (error) {
        console.error('Error generating token:', error);
        return res.status(500).json({ error: 'Error generating token' });
      }
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
};

module.exports = AuthController;
