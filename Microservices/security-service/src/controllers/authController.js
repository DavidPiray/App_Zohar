const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const db = require('../config/firebase');

// Inicio de sesión
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Valida que el usuario exista
        const snapshot = await db.collection('usuarios').where('email', '==', email).get();
        if (snapshot.empty) {
            return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        const user = snapshot.docs[0].data();

        // Verificar contraseña
        const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
        }

        // Generar token JWT
        const token = jwt.sign({ id: snapshot.docs[0].id, email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

        res.status(200).json({ token });
    } catch (error) {
        console.error('Error en login:', error);
        res.status(500).json({ message: 'Error al iniciar sesión' });
    }
};

// Cierre de sesión
const logout = async (req, res) => {
    try {
        // Implementa el cierre de sesión si es necesario (ejemplo: invalidar tokens)
        res.status(200).json({ message: 'Cierre de sesión exitoso' });
    } catch (error) {
        console.error('Error en logout:', error);
        res.status(500).json({ message: 'Error al cerrar sesión' });
    }
};

module.exports = {
    login,
    logout,
};
