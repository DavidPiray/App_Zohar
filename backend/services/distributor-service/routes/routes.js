const express = require('express');
const DistributorController = require('../controllers/distribuidorController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Crear un distribuidor
router.post('/', [authMiddleware, authorize(['admin'])], DistributorController.create);

// Añadir un producto al inventario de un distribuidor
router.post('/:id_distribuidor/inventario',[authMiddleware, authorize(['admin','distribuidor'])], DistributorController.addProductToInventory);

// Obtener el inventario de un distribuidor
router.get('/:id_distribuidor/inventario', [authMiddleware, authorize(['admin','distribuidor'])], DistributorController.getInventory);

// Obtener todos los distribuidores
router.get('/', [authMiddleware, authorize(['admin','distribuidor'])],  DistributorController.getAll);

// Obtener un distribuidor por ID
router.get('/:id', [authMiddleware, authorize(['admin'])], DistributorController.getById);

// Actualizar un distribuidor por ID
router.put('/:id', [authMiddleware, authorize(['admin','distribuidor'])], DistributorController.update);

// Actualizar el stock de un producto del inventario de un distribuidor por id
router.put('/:id_distribuidor/inventario/:id_producto', [authMiddleware, authorize(['admin','distribuidor'])], DistributorController.updateProductStock);

// Eliminar el producto del inventario de un distribuidor por IDs
router.delete('/:id_distribuidor/inventario/:id_producto', [authMiddleware, authorize(['admin','distribuidor'])], DistributorController.removeProductFromInventory);

// Eliminar un distribuidor
router.delete('/:id', [authMiddleware, authorize(['admin','distribuidor'])], DistributorController.delete);

// Obtener la zona de un distribuidor
router.get('/zona/:zoneID', DistributorController.getByZone);

module.exports = router;
