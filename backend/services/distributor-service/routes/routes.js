const express = require('express');
const DistributorController = require('../controllers/distribuidorController');

const router = express.Router();

router.post('/', DistributorController.create);
router.get('/', DistributorController.getAll);
router.get('/:id', DistributorController.getById);
router.put('/:id', DistributorController.update);
router.delete('/:id', DistributorController.delete);
router.get('/zona/:zoneID', DistributorController.getByZone);

module.exports = router;
