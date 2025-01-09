const db = require('../shared/utils/firebase');

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
    // console.log(exists);
    const orderRef = db.collection('pedidos').doc(id_pedido);
    if (exists){
      return { error: 'Pedido con ID Repetido' };
    }
    // Crear el documento con ID manual
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

  async getOrdersByDistributor(distributorID) {
    const snapshot = await db.collection('pedidos').where('distribuidorID', '==', distributorID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },
  
};

module.exports = Order;
