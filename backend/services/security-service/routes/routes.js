const express = require('express');
const AuthController = require('../controllers/authController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');
const router = express.Router();

// Endpoints
// Registrar un usuario
router.post('/register', AuthController.register);
// Iniciar sesion
router.post('/login', AuthController.login);
// Actualizar contraseña
router.put('/users/password', AuthController.updatePassword);
// Eliminar un usuario por ID
router.delete('/:id_distribuidor', [authMiddleware, authorize(['admin', 'gerente'])], AuthController.delete);

module.exports = router;
