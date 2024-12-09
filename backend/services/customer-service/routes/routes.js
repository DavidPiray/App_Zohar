const express = require('express');
const CustomerController = require('../controllers/customerController');

const router = express.Router();

// Ruta para agregar un cliente
router.post('/clientes', CustomerController.create);

// Ruta para obtener todos los clientes
router.get('/clientes', CustomerController.getAll);

// Ruta para buscar clientes
router.get('/clientes/buscar', CustomerController.search);

// Ruta para obtener un cliente por ID
router.get('/clientes/:id', CustomerController.getById);

// Ruta para actualizar un cliente por ID
router.put('/clientes/:id', CustomerController.update);

// Ruta para eliminar un cliente por ID
router.delete('/clientes/:id', CustomerController.delete);

module.exports = router;
