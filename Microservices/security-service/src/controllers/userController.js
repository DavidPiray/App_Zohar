const auditService = require('../services/auditService');
const bcrypt = require('bcrypt');
const db = require('../config/firebase');
const jwt = require('../config/jwt');

// Registrar nuevo usuario
const registerUser = async (req, res) => {
    try {
        const { email, password, roles } = req.body;

        // Validar que los datos requeridos estén presentes
        if (!email || !password) {
            return res.status(400).json({ message: 'El email y la contraseña son obligatorios' });
        }
        
        // Validar que el usuario no exista
        const snapshot = await db.collection('usuarios').where('email', '==', email).get();
        if (!snapshot.empty) {
            return res.status(400).json({ message: 'El usuario ya existe.' });
        }

        // Encriptar contraseña
        const passwordHash = await bcrypt.hash(password, 10);

        // Crear usuario
        const newUser = {
            email,
            passwordHash,
            roles: roles || ['user'], // Rol por defecto: user
            createdAt: new Date().toISOString(),
        };
        const userRef = await db.collection('usuarios').add(newUser);

        // Registrar evento de auditoría
        await auditService.logEvent('user_created', userRef.id, `Usuario registrado con email ${newUser.email}`);

        res.status(201).json({ id: userRef.id, email: newUser.email, roles: newUser.roles });
    } catch (error) {
        console.error('Error al registrar usuario:', error);
        res.status(500).json({ error: 'Error al registrar el usuario' });
    }
};

// Obtener lista de usuarios
const getAllUsers = async (req, res) => {
    try {
        const snapshot = await db.collection('usuarios').get();
        const users = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(users);
    } catch (error) {
        console.error('Error al obtener usuarios:', error);
        res.status(500).json({ error: 'Error al obtener usuarios' });
    }
};

// Actualizar roles de usuario
const updateUserRoles = async (req, res) => {
    try {
        const { id } = req.params;
        const { roles } = req.body;

        if (!roles || !Array.isArray(roles)) {
            return res.status(400).json({ error: 'Roles inválidos' });
        }

        const userRef = db.collection('usuarios').doc(id);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        await db.collection('usuarios').doc(id).update({ roles });

        // Registrar evento de auditoría
        await auditService.logEvent('roles_updated', id, `Roles actualizados: ${roles.join(', ')}`);

        res.status(200).json({ message: 'Roles actualizados exitosamente.' });
    } catch (error) {
        console.error('Error al actualizar roles:', error);
        res.status(500).json({ error: 'Error al actualizar roles' });
    }
};

// Exporta las funciones del controlador
module.exports = {
    registerUser,
    getAllUsers,
    updateUserRoles,
};
