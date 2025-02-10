const { createOrderSchema, updateOrderSchema } = require('../validations/orderValidation');
const { addOrderToRealtime, deleteOrderFromRealtime, updateOrderStatusRealtime } = require('../shared/utils/firebaseHelpers');
//const { updateSalesReport, updateTopProducts } = require('../shared/utils/salesHelpers'); // NUEVAS FUNCIONES
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
      const { distribuidorID } = req.body;
      // Validar que distribuidorID esté presente
      if (!distribuidorID) {
        return res.status(400).json({ error: 'DistribuidorID es requerido en la ruta' });
      }
      const distributorResponse = await axios.get(`http://distributor-service:3004/distribuidor/${distribuidorID}`,
        { headers: { Authorization: req.headers.authorization } });
      if (!distributorResponse.data) {
        return res.status(404).json({ error: 'Distribuidor no encontrado' });
      }
      const distribuidor = distributorResponse.data;
      // Crear el pedido con el distribuidor asignado
      try {
        const pedido = {
          ...req.body,
          distribuidorID: distribuidorID,
          fechaCreacion: new Date(),
          estado: distribuidor.estado === 'activo' ? 'pendiente' : 'en cola',
        };
        const response = await Order.createOrder(pedido);
        if (response.error) {
          return res.status(404).json({ error: response.error });
        }
        await addOrderToRealtime(pedido.id_pedido, pedido); // Sincronizar con Firebase realtime

        // 5. Responder con el mensaje adecuado
        res.status(201).json({
          message: distribuidor.estado === 'activo'
            ? 'Pedido creado exitosamente!'
            : 'Pedido en cola hasta que el distribuidor esté activo',
          pedido: response,
          distribuidorID,
        });
      } catch (error) {
        console.error('Fallo al crear el pedido:', error.message);
        res.status(500).json({ error: ' Fallo al crear un pedido ' + error.message });
      }

    } catch (error) {
      console.error('Fallo general: ', error.message);
      res.status(500).json({ error: 'Fallo al crear el pedido' });
    }
  },

  // Obtener todos los pedidos
  async getAll(req, res) {
    try {
      const orders = await Order.getAllOrders();
      res.status(200).json(orders);
    } catch (error) {
      console.error('Fallo al obtener los pedidos: ' + error.mensaje);
      res.status(500).json({ error: 'Fallo al obtener los pedidos: ' + error.mensaje });
    }
  },

  // Obtener un pedido por ID
  async getById(req, res) {
    try {
      const order = await Order.getOrderById(req.params.id);
      if (!order) {
        return res.status(404).json({ error: 'Pedido no encontrado' });
      }
      res.status(200).json(order);
    } catch (error) {
      console.error('Fallo al obtener el pedido: ' + error.mensaje);
      res.status(500).json({ error: 'Fallo al obtener el pedido: ' + error.mensaje });
    }
  },

  // Actualizar un pedido
  async update(req, res) {
    const { error } = updateOrderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    try {
      const response = await Order.updateOrder(req.params.id, req.body);
      res.status(200).json(response);
    } catch (error) {
      console.error('Fallo al actualizar el pedido: ' + error.mensaje);
      res.status(500).json({ error: 'Fallo al actualizar el pedido: ' + error.mensaje });
    }
  },

  // Actualizar el estado de un pedido
  async updateStatus(req, res) {
    const { estado } = req.body;
    if (!['pendiente', 'en progreso', 'completado', 'cancelado', 'en cola'].includes(estado)) {
      return res.status(400).json({ error: 'Estado inválido' });
    }

    try {
      const { id } = req.params;
      const pedido = await Order.getOrderById(id);
      if (!pedido) {
        return res.status(404).json({ error: 'Pedido no encontrado' });
      }

      await Order.updateOrder(id, { estado });

      // Intentar sincronizar con Firebase Realtime Database
      try {
        await updateOrderStatusRealtime(id, estado);
      } catch (firebaseError) {
        console.error(`Error en Firebase Realtime: ${firebaseError.message}`);
        return res.status(500).json({ error: `Error en Firebase Realtime: ${firebaseError.message}` });
      }

      // Si el estado cambia a "completado", actualizar reportes y eliminar de Firestore
      if (estado === 'completado') {
        const { distribuidorID, productos, total } = pedido;

        for (const producto of productos) {
          const { id_producto, cantidad } = producto;
          try {
            await axios.put(
              `http://distributor-service:3004/distribuidor/inventario/${distribuidorID}/${id_producto}`,
              { cantidad: -cantidad },
              { headers: { Authorization: req.headers.authorization } }
            );
          } catch (error) {
            console.error(`Error al reducir inventario para el producto ${id_producto}: ${error.message}`);
            return res.status(500).json({ error: `Error al reducir inventario: ${error.message}` });
          }
        }
        // Eliminar pedido de Firebase Realtime Database cuando se completa
        try {
          await Order.updateSalesReport(distribuidorID, total, productos);
          await Order.updateTopProducts(productos);
          try {
            await deleteOrderFromRealtime(id);
          } catch (firebaseDeleteError) {
            console.error(`Error eliminando pedido de Firebase: ${firebaseDeleteError.message}`);
            // No retornamos 500 aquí para que no afecte la actualización del pedido
          }
        } catch (firebaseDeleteError) {
          console.error(`Error eliminando pedido de Firebase: ${firebaseDeleteError.message}`);
          return res.status(500).json({ error: `Error eliminando pedido de Firebase: ${firebaseDeleteError.message}` });
        }
      }

      res.status(200).json({ message: `Estado del pedido actualizado a ${estado}` });

    } catch (error) {
      console.error('Fallo actualizando el estado del pedido:', error.message);
      res.status(500).json({ error: `Fallo actualizando el estado del pedido: ${error.message}` });
    }
  },

  // Generar reporte de ventas
  async generateSalesReport(req, res) {
    try {
      const { mes, distribuidorID } = req.query;
      const report = await Order.getSalesReport(mes, distribuidorID);

      if (!report) {
        return res.status(404).json({ error: 'No hay datos de ventas para este periodo' });
      }

      res.status(200).json(report);
    } catch (error) {
      console.error('Error generando el reporte de ventas:', error.message);
      res.status(500).json({ error: 'Error generando el reporte de ventas' });
    }
  },

  // Eliminar un pedido
  async delete(req, res) {
    try {
      const response = await Order.deleteOrder(req.params.id);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(200).json(response);
    } catch (error) {
      console.error('Fallo al eliminar el pedido: ' + error.mensaje);
      res.status(500).json({ error: 'Fallo al eliminar el pedido: ' + error.mensaje });
    }
  },

  // Obtener pedidos asignados al distribuidor
  async getByIdDistributor(req, res) {
    try {
      const { distribuidorID } = req.params;
      // Obtener pedidos asignados al distribuidor
      const orders = await Order.getOrdersByDistributor(distribuidorID);
      if (!orders.length) {
        return res.status(404).json({ error: 'No se encontraron pedidos para este distribuidor' });
      }
      res.status(200).json(orders);
    } catch (error) {
      console.error('Fallo al obtener pedidos por distribuidor:', error.message);
      res.status(500).json({ error: 'Fallo al obtener pedidos por distribuidor: ' + error.mensaje });
    }
  },

  // Obtener pedidos por cliente
  async getByIdClient(req, res) {
    try {
      const { clienteID } = req.params;
      // Obtener pedidos asignados al distribuidor
      const orders = await Order.getOrdersByClient(clienteID);
      if (!orders.length) {
        return res.status(404).json({ error: 'No se encontraron pedidos para este cliente' });
      }
      res.status(200).json(orders);
    } catch (error) {
      console.error('Fallo al obtener pedidos por cliente:', error.message);
      res.status(500).json({ error: 'Fallo al obtener pedidos por Cliente: ' + error.mensaje });
    }
  },
};

module.exports = OrderController;
