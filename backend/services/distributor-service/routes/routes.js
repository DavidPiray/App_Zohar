const express = require('express');
const DistributorController = require('../controllers/distribuidorController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');
const auditLogger = require('../shared/middlewares/auditLogger');
const router = express.Router();

// Crear un distribuidor
router.post('/', auditLogger('Crear Distribuidor', 'distribuidor'), [authMiddleware, authorize(['admin','gerente'])], DistributorController.create);

// Añadir un producto al inventario de un distribuidor
router.post('/inventario/:id_distribuidor',[authMiddleware, authorize(['admin','gerente','distribuidor'])], DistributorController.addProductToInventory);

// Obtener el inventario de un distribuidor
router.get('/inventario/:id_distribuidor', [authMiddleware, authorize(['admin','gerente','distribuidor'])], DistributorController.getInventory);

// Obtener un distribuidor por ID
router.get('/:id', DistributorController.getById);

// Ruta para buscar distribuidores por filtros
router.get('/buscar', DistributorController.search);

// Obtener todos los distribuidores
router.get('/', DistributorController.getAll);

// Obtener la zona de un distribuidor
router.get('/zona/:zonaID', DistributorController.getByZone);

// Actualizar un distribuidor por ID
router.put('/:id', auditLogger('Actualizar Distribuidor', 'distribuidor'), [authMiddleware, authorize(['admin','gerente','distribuidor'])], DistributorController.update);

// Actualizar el stock de un producto del inventario de un distribuidor por id
router.put('/inventario/:id_distribuidor/:id_producto', [authMiddleware, authorize(['admin','gerente','distribuidor'])], DistributorController.updateProductStock);

// Eliminar el producto del inventario de un distribuidor por IDs
router.delete('/inventario/:id_distribuidor/:id_producto', [authMiddleware, authorize(['admin','gerente','distribuidor'])], DistributorController.removeProductFromInventory);

// Eliminar un distribuidor
router.delete('/:id', auditLogger('Eliminar Distribuidor', 'distribuidor'), [authMiddleware, authorize(['admin','gerente','distribuidor'])], DistributorController.delete);


module.exports = router;
