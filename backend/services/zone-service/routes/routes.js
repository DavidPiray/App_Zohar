const express = require('express');
const ZoneController = require('../controllers/zonaController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');
const auditLogger = require('../shared/middlewares/auditLogger');
const router = express.Router();

// Crear nueva zona
router.post('/', auditLogger('Crear Zona', 'zonas'), [authMiddleware, authorize(['admin'])], ZoneController.create);

// Obtener zona por ubicacion
router.get('/location', ZoneController.getByLocation); 

// Obtener todas las zonas
router.get('/', ZoneController.getAll);

// Obtener zona por ID
router.get('/:id', ZoneController.getById);

// Actualizar zona por ID
router.put('/:id', auditLogger('Actualizar Zona', 'zonas'), [authMiddleware, authorize(['admin'])], ZoneController.update);

// Eliminar zona por ID
router.delete('/:id', auditLogger('Eliminar Zona', 'zonas'), [authMiddleware, authorize(['admin'])], ZoneController.delete);

module.exports = router;
