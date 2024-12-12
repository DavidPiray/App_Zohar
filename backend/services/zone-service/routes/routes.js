const express = require('express');
const ZoneController = require('../controllers/zonaController');

const router = express.Router();

router.post('/', ZoneController.create);
router.get('/location', ZoneController.getByLocation); // Consulta por ubicación
router.get('/', ZoneController.getAll);
router.get('/:id', ZoneController.getById);
router.put('/:id', ZoneController.update);
router.delete('/:id', ZoneController.delete);

module.exports = router;
