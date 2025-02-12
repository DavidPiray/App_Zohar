const { createDistributorSchema, updateDistributorSchema } = require('../validations/distribuidorValidation');
const { logAuditEvent } = require('../shared/models/auditModel'); // para auditoria
const Distributor = require('../models/distribuidorModel');
const axios = require('axios'); // Para consumir otros servicios
const { updateOrderStatusRealtime } = require('../shared/utils/firebaseHelpers');

const DistributorController = {
  // Lógica para el producto
  // Agregar producto al inventario
  async addProductToInventory(req, res) {
    try {
      const { id_distribuidor } = req.params;
      const { id_producto, nombre, stock } = req.body;

      if (!id_producto || !nombre || typeof stock !== 'number') {
        return res.status(400).json({ error: 'Datos incompletos: id_producto, nombre y stock son obligatorios' });
      }
      const token = req.headers.authorization;
      // Validar que el producto exista en el Product Service
      const productResponse = await axios.get(`http://localhost:3006/api/productos/${id_producto}`,
        { headers: { Authorization: token } }
      );
      if (!productResponse.data) {
        return res.status(404).json({ error: 'El producto no existe en el sistema' });
      }
      const response = await Distributor.addProductToInventory(id_distribuidor, { id_producto, nombre, stock });
      res.status(201).json(response);
    } catch (error) {
      console.error('Error al añadir un producto al inventario del distribuidor: ', error.message);
      res.status(400).json({ error: 'Error al añadir un producto al inventario del distribuidor: ' + error.message });
    }
  },

  // Obtener inventario del distribuidor
  async getInventory(req, res) {
    try {
      const { id_distribuidor } = req.params;
      const inventory = await Distributor.getInventory(id_distribuidor);
      res.status(200).json(inventory);
    } catch (error) {
      console.error('Error al obtener el inventario del distribuidor: ' + error.message);
      res.status(400).json({ error: 'Error al obtener el inventario del distribuidor: ' + error.message });
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

      const response = await Distributor.updateProductStock(
        id_distribuidor,
        id_producto,
        cantidad
      );

      res.status(200).json(response);

    } catch (error) {
      console.error('Error al actualizar el stock del producto: ' + error.message);
      res.status(400).json({ error: 'Error al actualizar el stock del producto: ' + error.message });
    }
  },

  // Eliminar producto del inventario
  async removeProductFromInventory(req, res) {
    try {
      const { id_distribuidor, id_producto } = req.params;
      const response = await Distributor.removeProductFromInventory(id_distribuidor, id_producto);
      res.status(200).json(response);
    } catch (error) {
      console.error('Error al eliminar un producto del inventario: ' + error.message);
      res.status(400).json({ error: 'Error al eliminar un producto del inventario: ' + error.message });
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
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      // Registrar auditoría
      await logAuditEvent(
        'Crear',
        'Distribuidor',
        response.id,
        req.user.email,
        { newValue: response }
      );
      res.status(201).json(response);
    } catch (error) {
      console.error('Fallo al crear un distribuidor: ' + error.message);
      res.status(500).json({ error: 'Fallo al crear un distribuidor: ' + error.message });
    }
  },

  // Obtener todos los distribuidores
  async getAll(req, res) {
    try {
      const distributors = await Distributor.getAllDistributors();
      res.status(200).json(distributors);
    } catch (error) {
      console.error('Fallo al obtener los distribuidores: ' + error.message);
      res.status(500).json({ error: 'Fallo al obtener los distribuidores: ' + error.message });
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
      console.error('Fallo al obtener un distribuidor: ' + error.message);
      res.status(500).json({ error: 'Fallo al obtener un distribuidor: ' + error.message });
    }
  },

  // Actualizar la información de un distribuidor
  async update(req, res) {
    const { error } = updateDistributorSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const oldData = await Distributor.getDistributorById(req.params.id);
      const response = await Distributor.updateDistributor(req.params.id, req.body);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Actualizar',
        'Distribuidor',
        req.params.id,
        req.user.email,
        {
          oldValue: oldData,
          newValue: req.body,
        }
      );
      res.status(200).json(response);
    } catch (error) {
      console.error('Fallo al actualizar un distribuidor: ' + error.message);
      res.status(500).json({ error: 'Fallo al actualizar un distribuidor: ' + error.message });
    }
  },

  // Eliminar un distribuidor
  async delete(req, res) {
    try {
      const response = await Distributor.deleteDistributor(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      const oldData = await Distributor.getDistributorById(req.params.id);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Eliminar',
        'Distribuidor',
        req.params.id,
        req.user.email,
      );
      res.status(200).json(response);
    } catch (error) {
      console.error('Fallo al eliminar un distribuidor: ' + error.message);
      res.status(500).json({ error: 'Fallo al eliminar un distribuidor: ' + error.message });
    }
  },

  // Obtener una zona por distribuidor
  async getByZone(req, res) {
    try {
      const distributors = await Distributor.getDistributorsByZone(req.params.zoneID);
      res.status(200).json(distributors);
    } catch (error) {
      console.error('Fallo al obtener un distribuidor por la zona: ' + error.message);
      res.status(500).json({ error: 'Fallo al obtener un distribuidor por la zona: ' + error.message });
    }
  },

  // Buscar un distribuidor
  async search(req, res) {
    try {
      const distributor = await Distributor.searchDistributor(req.query);
      if (distributor.length === 0) {
        return res.status(404).json({ message: 'Distribuidor no encontrado' });
      }
      res.status(200).json(distributor);
    } catch (error) {
      console.error('Fallo al buscar el distribuidor: ' + error.message);
      res.status(500).json({ error: 'Fallo al buscar el distribuidor: ' + error.message });
    }
  },

};

module.exports = DistributorController;
