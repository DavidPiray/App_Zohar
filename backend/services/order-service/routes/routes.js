const express = require('express');
const OrderController = require('../controllers/orderController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Crear pedidos
router.post('/', OrderController.create);

// Obtener todos los pedidos
router.get('/', OrderController.getAll);

// Obtener pedido por ID
router.get('/:id', [authMiddleware, authorize(['admin','distribuidor'])], OrderController.getById);

// Obtener pedidos por ID de distribuidor
router.get('/lista_pedido/:distribuidorID', OrderController.getByIdDistributor);

// Obtener pedidos por ID de cliente
router.get('/lista_pedido_cli/:clienteID', OrderController.getByIdClient);

// Obtener los reportes de ventas
router.get('/reportes/ventas', OrderController.generateSalesReport);

// Actualizar pedido por ID
router.put('/:id', OrderController.update);

// Actualizar el estado del pedido por ID
router.put('/estado_pedido/:id', [authMiddleware, authorize(['admin','distribuidor','gerente'])], OrderController.updateStatus); 

// Eliminar un pedido
router.delete('/:id',  OrderController.delete);

module.exports = router;
