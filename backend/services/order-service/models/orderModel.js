const db = require('../../../utils/firebase');

const Order = {
  async createOrder(orderData) {
    const orderRef = db.collection('pedidos').doc(orderData.id_pedido);
    await orderRef.set(orderData);
    return { message: 'Pedido creado con éxito!' };
  },

  async getOrderById(id_pedido) {
    const orderRef = db.collection('pedidos').doc(id_pedido);
    const orderDoc = await orderRef.get();
    return orderDoc.exists ? orderDoc.data() : null;
  },

  async getAllOrders() {
    const snapshot = await db.collection('pedidos').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  async updateOrder(id_pedido, updatedData) {
    const orderRef = db.collection('pedidos').doc(id_pedido);
    await orderRef.update(updatedData);
    return { message: 'Pedido actualizado con éxito!' };
  },

  async deleteOrder(id_pedido) {
    const orderRef = db.collection('pedidos').doc(id_pedido);
    const orderDoc = await orderRef.get();
    if (!orderDoc.exists) {
      return { error: 'Pedido no encontrado' };
    }
    await orderRef.delete();
    return { message: 'Pedido eliminado con éxito' };
  },

  async getOrdersByClient(clientID) {
    const snapshot = await db.collection('pedidos').where('clienteID', '==', clientID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  async getOrdersByDistributor(distributorID) {
    const snapshot = await db.collection('pedidos').where('distribuidorID', '==', distributorID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },
};

module.exports = Order;
