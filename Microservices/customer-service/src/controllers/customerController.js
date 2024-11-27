const db = require('../services/firebase');

exports.getAllCustomers = async (req, res) => {
  try {
    const snapshot = await db.collection('clientes').get();
    const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(customers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createCustomer = async (req, res) => {
  try {
    const newCustomer = {
      ...req.body,
      createdAt: new Date(),
    };
    const docRef = await db.collection('clientes').add(newCustomer);
    res.status(201).json({ id: docRef.id, ...newCustomer });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.updateCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Actualiza el cliente con los datos enviados
    await db.collection('clientes').doc(id).update(req.body);

    // Recupera el documento actualizado
    const updatedCustomer = await db.collection('clientes').doc(id).get();
    
    // Verifica si el cliente existe
    if (!updatedCustomer.exists) {
      return res.status(404).json({ error: 'Customer not found' });
    }

    // Devuelve los datos actualizados en la respuesta
    res.status(200).json(updatedCustomer.data());  // Envía los datos actualizados como respuesta
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

exports.deleteCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    await db.collection('clientes').doc(id).delete();
    res.status(204).send();
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};
