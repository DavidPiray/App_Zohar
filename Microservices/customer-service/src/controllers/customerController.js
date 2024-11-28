const db = require('../services/firebase');


// Devolver todos los clientes
exports.getAllCustomers = async (req, res) => {
  try {
    const snapshot = await db.collection('clientes').get();
    const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(customers);
  } catch (error) {
    console.error("Error fetching customers:", error);
    res.status(500).json({ error: "Error al obtener los clientes" });
  }
};

// Crear un nuevo cliente
exports.createCustomer = async (req, res) => {
  try {
    const newCustomer = {
      ...req.body,
      createdAt: new Date(),
    };
    const docRef = await db.collection('clientes').add(newCustomer);
    res.status(201).json({ id: docRef.id, ...newCustomer });
  } catch (error) {
    console.error("Error creating customer:", error);
    res.status(400).json({ error: "Error al crear el cliente" });
  }
};

// Actualizar un cliente
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
    console.error("Error updating customer:", error);
    res.status(400).json({ error: "Error al actualizar el cliente" });
  }
};

// Buscar un cliente
exports.searchCustomers = async (req, res) => {
  try {
    const { nombre, email, zona } = req.query; // Parámetros de búsqueda
    let query = db.collection('clientes');

    // Filtrar por nombre
    if (nombre) {
      query = query.where('nombre', '==', nombre);
    }

    // Filtrar por email
    if (email) {
      query = query.where('email', '==', email);
    }

    // Filtrar por zona
    if (zona) {
      query = query.where('zonaID', '==', zona);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      return res.status(404).json({ message: 'No se encontraron clientes' });
    }

    const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    res.status(200).json(customers);
  } catch (error) {
    console.error("Error searching customers:", error);
    res.status(500).json({ error: "Error al realizar la búsqueda" });
  }
};


// Borrar un cliente
exports.deleteCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    await db.collection('clientes').doc(id).delete();
    res.status(204).send();
  } catch (error) {
    console.error("Error deleting customer:", error);
    res.status(400).json({ error: "Error al eliminar el cliente" });
  }
};
