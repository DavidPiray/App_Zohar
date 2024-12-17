const { createOrderSchema, updateOrderSchema } = require('../validations/orderValidation');
const Order = require('../models/orderModel');
const axios = require('axios'); // Para consumir otros servicios

const OrderController = {
  // Crear pedido
  async create(req, res) {
    // Validar con el esquema
    const { error } = createOrderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const { id_pedido, clienteID, productos } = req.body;
      // Token de autenticación
      const token = req.headers.authorization || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJjbGllbnQiXSwiaWF0IjoxNzM0MzE3NDg2LCJleHAiOjE3MzQzMjEwODZ9.YABtxNpAVw4GTyEebgm9ulMCXjWf9XCyQJWfMgK-_c0';
      console.log(token);

      // 1. Verificar que el cliente exista en el microservicio de Clientes
      const customerResponse = await axios.get(`http://localhost:3002/api/clientes/${clienteID}`,
        { headers: { Authorization: token } }
      );
      if (!customerResponse.data) {
        return res.status(404).json({ error: 'Cliente no encontrado' });
      }
      const cliente = customerResponse.data;
      console.log(cliente);

      /*// 2. Verificar productos
      for (const item of productos) {
        const productResponse = await axios.get(
          `http://localhost:3006/api/productos/${item.id_producto}`,
          { headers: { Authorization: token } }
        );
        if (!productResponse.data) {
          return res.status(404).json({ error: `Producto no encontrado: ${item.id_producto}` });
        }
      }*/
      
      // 3. Determinar la zona del cliente utilizando el microservicio de Zonas
      const zoneResponse = await axios.get(
        `http://localhost:3003/api/zonas/location?latitude=${cliente.ubicacion.latitude}&longitude=${cliente.ubicacion.longitude}`,
        { headers: { Authorization: token } }
      );
      if (!zoneResponse.data) {
        console.log('No se encontro una zona:');
        return res.status(404).json({ error: 'No se encontró la zona del cliente' });
      }
      const zona = zoneResponse.data;

      // 4. Buscar un distribuidor activo en la zona utilizando el servicio de distribuidor
      const distributorResponse = await axios.get(`http://localhost:3004/api/distribuidor/zona/${zona.id_zona}`,
        { headers: { Authorization: token } });
      const distribuidores = distributorResponse.data.filter(d => d.estado === 'activo');
      if (distribuidores.length === 0) {
        console.log('No se encontro distribuidores en una zona:');
        return res.status(404).json({ error: 'No hay distribuidores disponibles en la zona del cliente' });
      }

      // 5. Asignar el primer distribuidor disponible
      const distribuidorAsignado = distribuidores[0];

      // 6. Crear el pedido con el distribuidor asignado
      const pedido = {
        ...req.body,
        distribuidorID: distribuidorAsignado.id_distribuidor,
        fechaCreacion: new Date(),
      };
      try{
        const response = await Order.createOrder(pedido);
        if (response.error){
          return res.status(404).json({error: response.error});
        }
        res.status(201).json({ ...response, distribuidorAsignado });
      }catch(error){
        res.status(500).json({ error: ' Fallo al crear un pedido '});
      }

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
