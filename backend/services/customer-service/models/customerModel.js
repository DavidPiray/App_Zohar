const db = require('../../../utils/firebase');

const Customer = {
  async createCustomer(customerData) {
    const customerRef = db.collection('clientes').doc(customerData.id_cliente);
    await customerRef.set(customerData);
    return { message: 'Cliente creado con éxito!' };
  },

  async getPaginatedCustomers(page = 1, limit = 10) {
    const offset = (page - 1) * limit;

    const snapshot = await db.collection('clientes')
      .orderBy('createdAt')
      .offset(offset)
      .limit(limit)
      .get();

    const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return customers;
  },

  async searchCustomers(filters) {
    let query = db.collection('clientes');

    if (filters.nombre) {
      query = query.where('nombre', '==', filters.nombre);
    }
    if (filters.email) {
      query = query.where('email', '==', filters.email);
    }
    if (filters.zonaID) {
      query = query.where('zonaID', '==', filters.zonaID);
    }

    const snapshot = await query.get();
    const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    return customers;
  },

  async getCustomerById(id_cliente) {
    const customerRef = db.collection('clientes').doc(id_cliente);
    const customerDoc = await customerRef.get();
    return customerDoc.exists ? customerDoc.data() : null;
  },

  async getAllCustomers() {
    const snapshot = await db.collection('clientes').get();
    return snapshot.docs.map(doc => doc.data());
  },

  async updateCustomer(id_cliente, updatedData) {
    const customerRef = db.collection('clientes').doc(id_cliente);
    await customerRef.update(updatedData);
    return { message: 'Cliente actualizado con éxito!' };
  },

  async deleteCustomer(id_cliente) {
    const customerRef = db.collection('clientes').doc(id_cliente);
    const customerDoc = await customerRef.get();

    if (!customerDoc.exists) {
      return { error: 'Cliente No encontrado para eliminarlo' };
    }

    await customerRef.delete();
    return { message: 'Cliente elimando con éxito!' };
  },
};

module.exports = Customer;
