const express = require('express');
const ProductController = require('../controllers/productController');

const router = express.Router();

router.post('/', ProductController.create);
router.get('/', ProductController.getAll);
router.put('/:id', ProductController.update);
router.put('/:id/stock', ProductController.updateStock); // Endpoint para actualizar stock
router.delete('/:id', ProductController.delete);

module.exports = router;
