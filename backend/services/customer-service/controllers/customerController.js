const Customer = require('../models/customerModel');
const { createCustomerSchema, updateCustomerSchema } = require('../validations/customerValidation');
const { logAuditEvent } = require('../shared/models/auditModel');

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
      if (response.error){
        return res.status(404).json({error: response.error});    
      }
      res.status(201).json(response);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Crear',
        'Clientes',
        response.id, // ID del cliente creado
        req.user.email, // Usuario autenticado (de req.user)
      );
    } catch (error) {
      console.error('Fallo al crear un cliente:', error.message);
      res.status(500).json({ error: 'Fallo al crear el cliente: ' + error.message });
    }
  },

  // Obtener todos los clientes por paginas
  async getAll(req, res) {
    const { page = 1, limit = 10 } = req.query;
    try {
      const customers = await Customer.getPaginatedCustomers(parseInt(page, 10), parseInt(limit, 10));
      res.status(200).json({ page, limit, total: customers.length, customers });
    } catch (error) {
      console.error('Error al obtener todos los cliente:', error.message);
      res.status(500).json({ error: 'Fallo al obtener la lista de clientes: ' + error.message });
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
      console.error('Error al obtener un cliente por ID:', error.message);
      res.status(500).json({ error: 'Fallo al obtener la información el cliente: ' + error.message });
    }
  },

  // Actualizar un cliente
  async update(req, res) {
    const { error } = updateCustomerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const oldData = await Customer.getCustomerById(req.params.id);
      const response = await Customer.updateCustomer(req.params.id, req.body);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Actualizar',
        'Clientes',
        req.params.id,
        req.user.email,
        {
          oldValue: oldData,
          newValue: req.body,
        }
      );
      res.status(200).json(response);
    } catch (error) {
      console.error('Fallo al actualizar un cliente:', error.message);
      res.status(500).json({ error: 'Fallo al actualizar los datos del cliente: ' + error.message});
    }
  },

  // ELiminar un cliente
  async delete(req, res) {
    try {
      const oldData = await Customer.getCustomerById(req.params.id);
      const response = await Customer.deleteCustomer(req.params.id);
      res.status(200).json(response);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Eliminar',
        'Clientes',
        req.params.id,
        req.user.email,
        { oldValue: oldData }
      );
    } catch (error) {
      console.error('Error al eliminar un cliente:', error.message);
      res.status(500).json({ error: 'Fallo al eliminar un cliente: ' + error.message });
    }
  },

  // Buscar un cliente por filtro
  async search(req, res) {
    try {
      const customers = await Customer.searchCustomers(req.query);
      if (customers.length === 0) {
        return res.status(404).json({ message: 'Cliente no encontrado' });
      }
      res.status(200).json(customers);
    } catch (error) {
      console.error('Error al buscar un cliente:', error.message);
      res.status(500).json({ error: 'Fallo al buscar el cliente: ' + error.message });
    }
  },

};

module.exports = CustomerController;
