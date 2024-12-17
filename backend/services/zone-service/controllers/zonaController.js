const { createZoneSchema, updateZoneSchema } = require('../validations/zonaValidation');
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
      if (response.error){
        return res.status(404).json({error: response.error});
      }
      res.status(201).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al crear la zona' });
    }
  },

  async getAll(req, res) {
    try {
      const zones = await Zone.getAllZones();
      res.status(200).json(zones);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener las zonas' });
    }
  },

  async getById(req, res) {
    try {
      const zone = await Zone.getZoneById(req.params.id);
      if (!zone) {
        return res.status(404).json({ error: 'Zona no encontrada' });
      }
      res.status(200).json(zone);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener la zona' });
    }
  },

  async update(req, res) {
    const { error } = updateZoneSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    try {
      const response = await Zone.updateZone(req.params.id, req.body);
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al actualizar la zona' });
    }
  },

  async delete(req, res) {
    try {
      const response = await Zone.deleteZone(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al eliminar la zona' });
    }
  },

  async getByLocation(req, res) {
    const { latitude, longitude } = req.query;

    try {
      console.log(`Buscando zona para latitud: ${latitude}, longitud: ${longitude}`);
      const zone = await Zone.getZoneByLocation(parseFloat(latitude), parseFloat(longitude));
      if (!zone) {
        console.log('Zona no encontrada para las coordenadas especificadas');
        return res.status(404).json({ error: 'Zona no encontrada para la ubicación' });
      }
      res.status(200).json(zone);
    } catch (error) {
      console.error('Error al obtener zona:', error);
      res.status(500).json({ error: 'Fallo al obtener una zona por Ubicación' });
    }
  },
};

module.exports = ZoneController;
