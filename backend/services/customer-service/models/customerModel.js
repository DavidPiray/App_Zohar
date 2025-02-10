const {db} = require('../shared/utils/firebase');

const Customer = {
  // Validar si un cliente existe por email o celular
  async existsByEmailOrPhone(email, celular) {
    const snapshot = await db.collection('clientes')
      .where('email', '==', email)
      .get();

    const phoneSnapshot = await db.collection('clientes')
      .where('celular', '==', celular)
      .get();

    return !snapshot.empty || !phoneSnapshot.empty;
  },

  // Crear un cliente
  async createCustomer(customerData) {
    const { email, celular } = customerData;
    const exists = await this.existsByEmailOrPhone(email, celular);
    const customerRef = db.collection('clientes');
    if (exists) {
      console.log( { error: 'Ya existe una cuenta vinculada al correo y/o celular ingresados.' });
      return { error: 'Ya existe una cuenta vinculada al correo y/o celular ingresados.' };
    }
    const newCustomerRef = customerRef.doc(); 
    const newCustomerData = { ...customerData, id_cliente: newCustomerRef.id }

    await newCustomerRef.set(newCustomerData);
    return { message: 'Cliente creado con éxito!' };
  },

  // Obtener clientes por paginas
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

  // Buscar clientes por Filtros
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

  // Obtener cliente por ID
  async getCustomerById(id_cliente) {
    const customerRef = db.collection('clientes').doc(id_cliente);
    const customerDoc = await customerRef.get();
    return customerDoc.exists ? customerDoc.data() : null;
  },

  // Obtener todos los clientes
  async getAllCustomers() {
    const snapshot = await db.collection('clientes').get();
    return snapshot.docs.map(doc => doc.data());
  },

  // Actualizar un cliente por ID
  async updateCustomer(id_cliente, updatedData) {
    const customerRef = db.collection('clientes').doc(id_cliente);
    await customerRef.update(updatedData);
    return { message: 'Cliente actualizado con éxito!' };
  },

  // Eliminar un cliente por ID
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
