const { createOrderSchema, updateOrderSchema } = require('../validations/orderValidation');
const Order = require('../models/orderModel');
const axios = require('axios'); // Para consumir otros servicios

const OrderController = {
  async create(req, res) {
    console.log("calculando esquema");
    const { error } = createOrderSchema.validate(req.body);
    console.log("Esquema calculado");
    if (error) {
      console.log("Error en el esquema");
      return res.status(400).json({ error: error.details[0].message });
    }
    console.log("Entrando en try");
    try {
      const { clienteID, productos } = req.body;

      // Token de autenticación (reemplaza esto con tu lógica de obtener el token)
      const token = req.headers.authorization || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJjbGllbnQiXSwiaWF0IjoxNzMzOTIwMTE4LCJleHAiOjE3MzM5MjM3MTh9.-U09GZ3LhYrvJ20n2MMSPRnjT5qv6t8hyZSS25GnyAA';
      //console.log(token);
      // 1. Verificar que el cliente exista en el microservicio de Clientes
      const customerResponse = await axios.get(`http://localhost:3002/api/clientes/${clienteID}`,
        { headers: { Authorization: token } }
      );

      // console.log(customerResponse);

      if (!customerResponse.data) {
        console.log('Cliente no encontrado:');
        return res.status(404).json({ error: 'Cliente no encontrado' });
      }
      const cliente = customerResponse.data;

      console.log(cliente);

      // 2. Determinar la zona del cliente utilizando el microservicio de Zonas
      const zoneResponse = await axios.get(
        `http://localhost:3003/api/zonas/location?latitude=${cliente.ubicacion.latitude}&longitude=${cliente.ubicacion.longitude}`,
        { headers: { Authorization: token } }
      );

      if (!zoneResponse.data) {
        console.log('No se encontro una zona:');
        return res.status(404).json({ error: 'No se encontró la zona del cliente' });
      }

      const zona = zoneResponse.data;

      console.log(zona);

      // 3. Buscar un distribuidor activo en la zona utilizando el servicio de distribuidor
      const distributorResponse = await axios.get(`http://localhost:3004/api/distribuidor/zona/${zona.id_zona}`,
        { headers: { Authorization: token } });
      const distribuidores = distributorResponse.data.filter(d => d.estado === 'activo');

      if (distribuidores.length === 0) {
        console.log('No se encontro distribuidores en una zona:');
        return res.status(404).json({ error: 'No hay distribuidores disponibles en la zona del cliente' });
      }

      // 4. Asignar el primer distribuidor disponible
      const distribuidorAsignado = distribuidores[0];

      // 5. Crear el pedido con el distribuidor asignado
      const pedido = {
        ...req.body,
        distribuidorID: distribuidorAsignado.id_distribuidor,
        fechaCreacion: new Date(),
      };

      const response = await Order.createOrder(pedido);
      res.status(201).json({ ...response, distribuidorAsignado });

    } catch (error) {
      console.error('Fallo al crear el pedido:', error.message);
      res.status(500).json({ error: 'Fallo al crear el pedido' });
    }
  },

  async getAll(req, res) {
    try {
      const orders = await Order.getAllOrders();
      res.status(200).json(orders);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener los pedidos' });
    }
  },

  async getById(req, res) {
    try {
      const order = await Order.getOrderById(req.params.id);
      if (!order) {
        return res.status(404).json({ error: 'Pedido no encontrado' });
      }
      res.status(200).json(order);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al obtener el pedido' });
    }
  },

  async update(req, res) {
    const { error } = updateOrderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    try {
      const response = await Order.updateOrder(req.params.id, req.body);
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al actualizar el pedido' });
    }
  },

  async updateStatus(req, res) {
    const { estado } = req.body;

    if (!['pendiente', 'en progreso', 'completado', 'cancelado'].includes(estado)) {
      return res.status(400).json({ error: 'Estado inválido' });
    }

    try {
      const pedido = await Order.getOrderById(req.params.id);

      if (!pedido) {
        return res.status(404).json({ error: 'Pedido no encontrado' });
      }

      const response = await Order.updateOrder(req.params.id, { estado });
      res.status(200).json(response);
    } catch (error) {
      console.error('Error actualizando el estado del pedido:', error.message);
      res.status(500).json({ error: 'Error actualizando el estado del pedido' });
    }
  },

  async delete(req, res) {
    try {
      const response = await Order.deleteOrder(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al eliminar el pedido' });
    }
  },
};

module.exports = OrderController;
