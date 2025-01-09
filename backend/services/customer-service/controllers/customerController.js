const Customer = require('../models/customerModel');
const { createCustomerSchema, updateCustomerSchema } = require('../validations/customerValidation');


const CustomerController = {
  // Crear un cliente
  async create(req, res) {
    const { error } = createCustomerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    const cliente = {
      ...req.body,
      fechaCreacion: new Date(),
    };

    try {
      const response = await Customer.createCustomer(cliente);
      res.status(201).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al crear un cliente' });
    }
  },

  // Obtener todos los clientes por paginas
  async getAll(req, res) {
    const { page = 1, limit = 10 } = req.query;
    try {
      const customers = await Customer.getPaginatedCustomers(parseInt(page, 10), parseInt(limit, 10));
      res.status(200).json({ page, limit, total: customers.length, customers });
    } catch (error) {
      res.status(500).json({ error: 'Fallo al encontrar clientes' });
    }
  },

  // Obtener un cliente por ID
  async getById(req, res) {
    try {
      const customer = await Customer.getCustomerById(req.params.id);
      if (!customer) {
        return res.status(404).json({ error: 'Cliente no encontrado' });
      }
      res.status(200).json(customer);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al conseguir el cliente' });
    }
  },

  // Actualizar un cliente
  async update(req, res) {
    const { error } = updateCustomerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const response = await Customer.updateCustomer(req.params.id, req.body);
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al actualizar el cliente' });
    }
  },

  // ELiminar un cliente
  async delete(req, res) {
    try {
      const response = await Customer.deleteCustomer(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al eliminar un cliente' });
    }
  },

  // Buscar un cliente
  async search(req, res) {
    try {
      const customers = await Customer.searchCustomers(req.query);
      if (customers.length === 0) {
        return res.status(404).json({ message: 'Clientes no encontrados' });
      }
      res.status(200).json(customers);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al buscar clientes' });
    }
  },

};

module.exports = CustomerController;
