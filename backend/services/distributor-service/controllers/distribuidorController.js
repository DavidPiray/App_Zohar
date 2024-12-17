const { createDistributorSchema, updateDistributorSchema } = require('../validations/distribuidorValidation');
const Distributor = require('../models/distribuidorModel');
const { exist } = require('joi');

const DistributorController = {
  // Crear distribuidor
  async create(req, res) {
    // Validar con el esquema
    const { error } = createDistributorSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const response = await Distributor.createDistributor(req.body);
      if (response.error){
        return res.status(404).json({error: response.error});    
      }
      res.status(201).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al crear un distribuidor' });
    }
  },

  // Obtener todos los distribuidores
  async getAll(req, res) {
    try {
      const distributors = await Distributor.getAllDistributors();
      res.status(200).json(distributors);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener los distribuidores' });
    }
  },

  // Obtener un distribuidor por ID
  async getById(req, res) {
    try {
      const distributor = await Distributor.getDistributorById(req.params.id);
      if (!distributor) {
        return res.status(404).json({ error: 'Distribuidor no encontrado' });
      }
      res.status(200).json(distributor);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener un distribuidor' });
    }
  },

  // Actualizar la información de un distribuidor
  async update(req, res) {
    const { error } = updateDistributorSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    try {
      const response = await Distributor.updateDistributor(req.params.id, req.body);
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al actualizar un distribuidor' });
    }
  },

  // Eliminar un distribuidor
  async delete(req, res) {
    try {
      const response = await Distributor.deleteDistributor(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al eliminar un distribuidor' });
    }
  },

  // Obtener una zona por distribuidor
  async getByZone(req, res) {
    try {
      const distributors = await Distributor.getDistributorsByZone(req.params.zoneID);
      res.status(200).json(distributors);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener un distribuidor por la zona' });
    }
  },
};

module.exports = DistributorController;
