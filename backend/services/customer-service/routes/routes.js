const express = require('express');
const CustomerController = require('../controllers/customerController');

const router = express.Router();

// Ruta para agregar un cliente
router.post('/', CustomerController.create);

// Ruta para obtener todos los clientes
router.get('/', CustomerController.getAll);

// Ruta para buscar clientes
router.get('/buscar', CustomerController.search);

// Ruta para obtener un cliente por ID
router.get('/:id', CustomerController.getById);

// Ruta para actualizar un cliente por ID
router.put('/:id', CustomerController.update);

// Ruta para eliminar un cliente por ID
router.delete('/:id', CustomerController.delete);

module.exports = router;
