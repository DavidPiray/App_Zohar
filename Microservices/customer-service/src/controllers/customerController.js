const db = require('../services/firebase');
const Joi = require('joi');
const redis = require('../services/redis');

// Esquema de validación para un cliente
const customerSchema = Joi.object({
  nombre: Joi.string().required(),
  email: Joi.string().email().required(),
  direccion: Joi.string().required(),
  celular: Joi.string().required(),
  zonaID: Joi.string().required(),
});

// Devolver todos los clientes
exports.getAllCustomers = async (req, res) => {
  try {
    const cacheKey = `customers_page_${req.query.page || 1}`;
    const cachedData = await redis.get(cacheKey);

    if (cachedData) {
      return res.status(200).json(JSON.parse(cachedData));
    }

    const { page = 1, limit = 10 } = req.query; // Parámetros de paginación con valores predeterminados
    const offset = (page - 1) * limit;

    const snapshot = await db.collection('clientes')
      .orderBy('createdAt') // Ordenar por fecha de creación
      .offset(offset) // Saltar registros según el offset
      .limit(Number(limit)) // Límite de registros
      .get();

    const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

    const response = {
      page: Number(page),
      limit: Number(limit),
      total: customers.length,
      customers,
    };

    // Guardar en Redis
    await redis.set(cacheKey, JSON.stringify(response), 'EX', 60); // Expira en 60 segundos
    res.status(200).json(response);
  }catch (error) {
    console.error("Error fetching paginated customers:", error);
    res.status(500).json({ error: "Error al obtener los clientes" });
  }
};

// Crear un nuevo cliente
exports.createCustomer = async (req, res) => {
  try {
    const { error } = customerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

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
    const { error } = customerSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }

    const { id } = req.params;
    await db.collection('clientes').doc(id).update(req.body);
    const updatedCustomer = await db.collection('clientes').doc(id).get();
    res.status(200).json(updatedCustomer.data());
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
