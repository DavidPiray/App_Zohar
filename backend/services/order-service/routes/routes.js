const express = require('express');
const OrderController = require('../controllers/orderController');

const router = express.Router();

router.post('/', OrderController.create);
router.get('/', OrderController.getAll);
router.get('/:id', OrderController.getById);
router.put('/:id', OrderController.update);
router.put('/:id/status', OrderController.updateStatus); 
router.delete('/:id', OrderController.delete);

module.exports = router;
