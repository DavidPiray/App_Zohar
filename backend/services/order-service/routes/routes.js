const express = require('express');
const OrderController = require('../controllers/orderController');
const SalesController = require('../controllers/salesController');
const ProductsController = require('../controllers/productsController');
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
// Para las ventas
router.get('/ventas/dia/:dia/:distribuidorID', SalesController.getSalesByDay);
router.get('/ventas/semana/:year/:week/:distribuidorID', SalesController.getSalesByWeek);
router.get('/ventas/mes/:year/:month/:distribuidorID', SalesController.getSalesByMonth);
router.get('/ventas/anio/:year/:distribuidorID', SalesController.getSalesByYear);
//Para los productos
router.get('/productos/dia/:dia', ProductsController.getTopProductsByDay);
router.get('/productos/semana/:year/:week', ProductsController.getTopProductsByWeek);
router.get('/productos/mes/:year/:month', ProductsController.getTopProductsByMonth);
router.get('/productos/anio/:year', ProductsController.getTopProductsByYear);

// Actualizar pedido por ID
router.put('/:id', OrderController.update);

// Actualizar el estado del pedido por ID
router.put('/estado_pedido/:id', [authMiddleware, authorize(['admin','distribuidor','gerente'])], OrderController.updateStatus); 

// Eliminar un pedido
router.delete('/:id',  OrderController.delete);

module.exports = router;
