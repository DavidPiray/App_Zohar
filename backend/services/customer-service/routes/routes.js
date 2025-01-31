const express = require('express');
const CustomerController = require('../controllers/customerController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');
const auditLogger = require('../shared/middlewares/auditLogger');
const router = express.Router();

// Ruta para agregar un cliente
router.post('/', auditLogger('Crear Cliente', 'clientes'), CustomerController.create);

// Ruta para obtener todos los clientes
router.get('/', CustomerController.getAll);

// Ruta para buscar clientes
router.get('/buscar', CustomerController.search);

// Ruta para obtener un cliente por ID
router.get('/:id', CustomerController.getById);

// Ruta para actualizar un cliente por ID
router.put('/:id', auditLogger('Actualizar Cliente', 'clientes'), CustomerController.update);

// Ruta para eliminar un cliente por ID
router.delete('/:id',auditLogger('Eliminar Cliente', 'clientes'), [authMiddleware, authorize(['admin','distribuidor'])], CustomerController.delete);

module.exports = router;
