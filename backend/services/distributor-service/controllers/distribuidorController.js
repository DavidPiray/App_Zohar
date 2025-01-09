const { createDistributorSchema, updateDistributorSchema } = require('../validations/distribuidorValidation');
const Distributor = require('../models/distribuidorModel');
const axios = require('axios'); // Para consumir otros servicios
const { exist } = require('joi');

const DistributorController = {
  // Lógica para el producto
  // Agregar producto al inventario
  async addProductToInventory(req, res) {
    try {
      const { id_distribuidor } = req.params;
      const { id_producto, nombre, stock } = req.body;
      console.log('distribuidor: ',id_distribuidor);
      console.log('producto: ',id_producto);
      
      if (!id_producto || !nombre || typeof stock !== 'number') {
        return res.status(400).json({ error: 'Datos incompletos: id_producto, nombre y stock son obligatorios' });
      }
      const token = req.headers.authorization ;
      console.log(token);
      // Validar que el producto exista en el Product Service
      console.log('Entrando a recibir datos');
      const productResponse = await axios.get(`http://localhost:3006/api/productos/${id_producto}`,
        { headers: { Authorization: token } }
      );
      console.log('Respuesta: ', productResponse);
      if (!productResponse.data) {
        console.log('El producto no existe en el sistema');
        return res.status(404).json({ error: 'El producto no existe en el sistema' });
      }
      console.log('-------------------------------------------');
      const response = await Distributor.addProductToInventory(id_distribuidor, { id_producto, nombre, stock });
      res.status(201).json(response);
    } catch (error) {
      console.error(error.message);
      res.status(400).json({ error: error.message });
    }
  },

  // Obtener inventario del distribuidor
  async getInventory(req, res) {
    try {
      const { id_distribuidor } = req.params;
      const inventory = await Distributor.getInventory(id_distribuidor);
      res.status(200).json(inventory);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  },

  // Actualizar stock de producto
  async updateProductStock(req, res) {
    try {
      const { id_distribuidor, id_producto } = req.params;
      const { cantidad } = req.body;

      if (typeof cantidad !== 'number') {
        return res.status(400).json({ error: 'La cantidad debe ser un número' });
      }

      const response = await Distributor.updateProductStock(id_distribuidor, id_producto, cantidad);
      res.status(200).json(response);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  },

  // Eliminar producto del inventario
  async removeProductFromInventory(req, res) {
    try {
      const { id_distribuidor, id_producto } = req.params;
      const response = await Distributor.removeProductFromInventory(id_distribuidor, id_producto);
      res.status(200).json(response);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  },

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
