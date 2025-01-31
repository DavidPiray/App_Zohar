const { createZoneSchema, updateZoneSchema } = require('../validations/zonaValidation');
const { logAuditEvent } = require('../shared/models/auditModel');
const Zone = require('../models/zonaModel');

const ZoneController = {
  // Crear Zonas
  async create(req, res) {
    // Validar con el esquema
    const { error } = createZoneSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const response = await Zone.createZone(req.body);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(201).json(response);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Crear',
        'Zona',
        response.id,
        req.user.email,
      );
    } catch (error) {
      console.error('Fallo al crear la zona: ' + error.message);
      res.status(500).json({ error: 'Fallo al crear la zona: ' + error.message });
    }
  },

  // Obtener todas las zonas
  async getAll(req, res) {
    try {
      const zones = await Zone.getAllZones();
      res.status(200).json(zones);
    } catch (error) {
      console.error('Fallo al obtener las zonas: ' + error.message);
      res.status(500).json({ error: 'Fallo al obtener las zonas: ' + error.message });
    }
  },

  // Obtener una zona por ID
  async getById(req, res) {
    try {
      const zone = await Zone.getZoneById(req.params.id);
      if (!zone) {
        return res.status(404).json({ error: 'Zona no encontrada' });
      }
      res.status(200).json(zone);
    } catch (error) {
      console.error('Fallo al obtener la zona: ' + error.message);
      res.status(500).json({ error: 'Fallo al obtener la zona: ' + error.message });
    }
  },

  // Actualizar una zona por ID
  async update(req, res) {
    const { error } = updateZoneSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const oldData = await Zone.getZoneById(req.params.id);
      const response = await Zone.updateZone(req.params.id, req.body);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Actualizar',
        'Zona',
        req.params.id,
        req.user.email,
        {
          oldValue: oldData,
          newValue: req.body,
        }
      );
      res.status(200).json(response);
    } catch (error) {
      console.error('Fallo al actualizar la zona: ' + error.message);
      res.status(500).json({ error: 'Fallo al actualizar la zona: ' + error.message });
    }
  },

  // Eliminar una zona por ID
  async delete(req, res) {
    try {
      const response = await Zone.deleteZone(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(200).json(response);
      const oldData = await Zone.getZoneById(req.params.id);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Eliminar',
        'Zona',
        req.params.id,
        req.user.email,
        { oldValue: oldData }
      );
    } catch (error) {
      console.error('Fallo al eliminar la zona: ' + error.message);
      res.status(500).json({ error: 'Fallo al eliminar la zona: ' + error.message });
    }
  },

  // Buscar una zona por coordenadas
  async getByLocation(req, res) {
    const { latitude, longitude } = req.query;
    try {
      const zone = await Zone.getZoneByLocation(parseFloat(latitude), parseFloat(longitude));
      if (!zone) {
        return res.status(404).json({ error: 'Zona no encontrada para la ubicación' });
      }
      res.status(200).json(zone);
    } catch (error) {
      console.error('Error al obtener zona:', error.message);
      res.status(500).json({ error: 'Fallo al obtener una zona por Ubicación: ' + error.message });
    }
  },
};

module.exports = ZoneController;
