const express = require('express');
const ProductController = require('../controllers/productController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');
const auditLogger = require('../shared/middlewares/auditLogger');
const router = express.Router();

// Crear un producto
router.post('/', auditLogger('Crear Producto', 'productos'), [authMiddleware,authorize(['admin','gerente'])], ProductController.create);

// Obtener prodcuto por ID
router.get('/:id', ProductController.getById);

// Buscar un producto por filtros
router.get('/buscar',ProductController.search);

// Obtener todos los productos
router.get('/', ProductController.getAll);

// Actualizar producto por ID
router.put('/:id', auditLogger('Crear Producto', 'productos'),  [authMiddleware,authorize(['admin','gerente'])], ProductController.update);

// Actualizar el stock de un producto por ID
router.put('/stock/:id', [authMiddleware,authorize(['admin','gerente'])], ProductController.updateStock); 

// Eliminar un producto
router.delete('/:id', auditLogger('Crear Producto', 'productos'), [authMiddleware,authorize(['admin','gerente'])], ProductController.delete);

module.exports = router;
