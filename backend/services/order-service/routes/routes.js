const express = require('express');
const OrderController = require('../controllers/orderController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Crear pedidos
router.post('/', OrderController.create);

// Obtener todos los pedidos
router.get('/', [authMiddleware, authorize(['admin','distribuidor'])], OrderController.getAll);

// Obtener pedido por ID
router.get('/:id', [authMiddleware, authorize(['admin','distribuidor'])], OrderController.getById);

// Obtener pedidos por ID de distribuidor
router.get('/:id_distribuidor/pedido', OrderController.getByIdDistributor);

// Actualizar pedido por ID
router.put('/:id', OrderController.update);

// Actualizar el estado del pedido por ID
router.put('/:id/status', [authMiddleware, authorize(['admin','distribuidor'])], OrderController.updateStatus); 

// Eliminar un pedido
router.delete('/:id', [authMiddleware, authorize(['admin','distribuidor'])], OrderController.delete);

module.exports = router;
