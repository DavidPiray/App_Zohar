const express = require('express');
const ProductController = require('../controllers/productController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Crear un producto
router.post('/', [authMiddleware,authorize(['admin'])], ProductController.create);

// Pbtener todos los productos
router.get('/', ProductController.getAll);

// Obtener prodcuto por ID
router.get('/:id',  [authMiddleware,authorize(['admin', 'distribuidor'])], ProductController.getById);

// Actualizar producto por ID
router.put('/:id',  [authMiddleware,authorize(['admin'])], ProductController.update);

// Actualizar el stock de un producto por ID
router.put('/:id/stock', [authMiddleware,authorize(['admin'])], ProductController.updateStock); 

// Eliminar un producto
router.delete('/:id', [authMiddleware,authorize(['admin'])], ProductController.delete);

module.exports = router;
