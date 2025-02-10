const { db } = require('../shared/utils/firebase');

const Order = {
  // Verificar si un pedido existe
  async existsById(id_pedido) {
    const doc = await db.collection('pedidos').doc(id_pedido).get();
    return doc.exists;
  },

  // Crear un pedido
  async createOrder(orderData) {
    const { id_pedido } = orderData;
    // Verficiar duplicidad
    const exists = await this.existsById(id_pedido);
    const orderRef = db.collection('pedidos').doc(id_pedido);
    if (exists) {
      return { error: 'Pedido con ID Repetido' };
    }
    // Crear el documento con ID manual
    await orderRef.set(orderData);
    return { message: 'Pedido creado con éxito!' };
  },

  // Obtener un pedido por ID
  async getOrderById(id_pedido) {
    const orderRef = db.collection('pedidos').doc(id_pedido);
    const orderDoc = await orderRef.get();
    return orderDoc.exists ? orderDoc.data() : null;
  },

  // Obtener todos los pedidos
  async getAllOrders() {
    const snapshot = await db.collection('pedidos').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  // Actualizar un pedido
  async updateOrder(id_pedido, updatedData) {
    const orderRef = db.collection('pedidos').doc(id_pedido);
    await orderRef.update(updatedData);
    return { message: 'Pedido actualizado con éxito!' };
  },

  // Eliminar un pedido
  async deleteOrder(id_pedido) {
    const orderRef = db.collection('pedidos').doc(id_pedido);
    const orderDoc = await orderRef.get();
    if (!orderDoc.exists) {
      return { error: 'Pedido no encontrado' };
    }
    await orderRef.delete();
    return { message: 'Pedido eliminado con éxito!' };
  },

  // Obtener pedidos por cliente
  async getOrdersByClient(clientID) {
    const snapshot = await db.collection('pedidos').where('clienteID', '==', clientID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  // Obtener pedidos por Distribuidor
  async getOrdersByDistributor(distributorID) {
    const snapshot = await db.collection('pedidos').where('distribuidorID', '==', distributorID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  // Obtener reporte de ventas
  async getSalesReport(dia, distribuidorID) {
    const doc = await db.collection('ventas_mensuales').doc(`${dia}-${distribuidorID}`).get();
    return doc.exists ? doc.data() : null;
  },

  // Actualizar el reporte de ventas
  async updateSalesReport(distribuidorID, total, productos) {
    const fecha = new Date();
    const dia = fecha.toISOString().slice(0, 10); // Obtiene el formato YYYY-MM-DD
    const docRef = db.collection('ventas_mensuales').doc(`${dia}-${distribuidorID}`);

    const doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        fecha: dia,
        distribuidorID,
        ventasTotales: 1,
        ingresosTotales: total,
        productosVendidos: productos.map(p => ({ id_producto: p.id_producto, cantidad: p.cantidad })),
      });
    } else {
      await docRef.update({
        ventasTotales: doc.data().ventasTotales + 1,
        ingresosTotales: doc.data().ingresosTotales + total,
      });
    }
  },

  // Actualizar los productos mas vendidos
  async updateTopProducts(productos) {
    const dia = fecha.toISOString().slice(0, 10); // Obtiene el formato YYYY-MM-DD
    const docRef = db.collection('venta_productos').doc(dia);

    const doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({ dia, topProductos: productos });
    } else {
      await docRef.update({
        topProductos: [...doc.data().topProductos, ...productos],
      });
    }
  },
};

module.exports = Order;
