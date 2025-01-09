const express = require('express');
const CustomerController = require('../controllers/customerController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');
const router = express.Router();

// Ruta para agregar un cliente
router.post('/', CustomerController.create);

// Ruta para obtener todos los clientes
router.get('/', [authMiddleware, authorize(['admin','distribuidor'])], CustomerController.getAll);

// Ruta para buscar clientes
router.get('/buscar', [authMiddleware, authorize(['admin','distribuidor'])], CustomerController.search);

// Ruta para obtener un cliente por ID
router.get('/:id', CustomerController.getById);

// Ruta para actualizar un cliente por ID
router.put('/:id', CustomerController.update);

// Ruta para eliminar un cliente por ID
router.delete('/:id', [authMiddleware, authorize(['admin','distribuidor'])], CustomerController.delete);

module.exports = router;
