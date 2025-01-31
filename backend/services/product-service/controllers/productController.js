const Product = require('../models/productModel');
const { productSchema, updateProductSchema } = require('../validations/productValidation');
const { logAuditEvent } = require('../shared/models/auditModel');

const ProductController = {
  // Crear un producto
  async create(req, res) {
    const { error } = productSchema.validate(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });
    const producto = {
      ...req.body,
      fechaCreacion: new Date(),
    };
    try {
      const response = await Product.createProduct(producto);
      if (response.error) {
        return res.status(404).json({ error: response.error });
      }
      res.status(201).json(response);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Crear',
        'Producto',
        response.id,
        req.user.email,
      );
    } catch (err) {
      console.error('Fallo al crear un producto: ' + err.message);
      res.status(500).json({ error: 'Fallo al crear un producto: ' + err.message });
    }
  },

  // Obtener todos los productos
  async getAll(req, res) {
    try {
      const products = await Product.getAllProducts();
      res.status(200).json(products);
    } catch (err) {
      console.error('Fallo al obtener los productos: ' + err.message);
      res.status(500).json({ error: 'Fallo al obtener los productos: ' + err.message });
    }
  },

  // Actualizar un producto
  async update(req, res) {
    try {
      const { error } = updateProductSchema.validate(req.body);
      if (error) return res.status(400).json({ error: error.details[0].message });
      const oldData = await Product.getProductById(req.params.id);
      const response = await Product.updateProduct(req.params.id, req.body);
      res.status(200).json(response);
      // Registrar evento de auditoría
      await logAuditEvent(
        'Actualizar',
        'Producto',
        req.params.id,
        req.user.email,
        {
          oldValue: oldData,
          newValue: req.body,
        }
      );
    } catch (err) {
      console.error('Fallo al actualizar los datos de un producto: ' + err.message);
      res.status(400).json({ error: 'Fallo al actualizar los datos de un producto: ' + err.message });
    }
  },

  // Obtener un producto por ID
  async getById(req, res) {
    try {
      const product = await Product.getProductById(req.params.id);
      if (!product) {
        return res.status(404).json({ error: 'Producto no encontrado' });
      }
      res.status(200).json(product);
    } catch (error) {
      console.error('Fallo al obtener un producto: ' + error.message);
      res.status(500).json({ error: 'Fallo al obtener un producto: ' + error.message });
    }
  },

  // Actualzar un producto por ID
  async updateStock(req, res) {
    try {
      const { cantidad } = req.body;
      if (typeof cantidad !== 'number') {
        return res.status(400).json({ error: 'La cantidad debe ser un número' });
      }
      const response = await Product.updateStock(req.params.id, cantidad);
      res.status(200).json(response);
    } catch (err) {
      console.error('Fallo al actualizar el stock de un producto: ' + err.message);
      res.status(400).json({ error: 'Fallo al actualizar el stock de un producto: ' + err.message });
    }
  },

  // Eliminar un producto por ID
  async delete(req, res) {
    try {
      const oldData = await Product.getProductById(req.params.id);
      const response = await Product.deleteProduct(req.params.id);
      // Registrar evento de auditoría
      res.status(200).json(response);
      await logAuditEvent(
        'Eliminar',
        'Producto',
        req.params.id,
        req.user.email,
        { oldValue: oldData }
      );
    } catch (err) {
      console.error('Fallo al eliminar un producto: ' + err.message);
      res.status(400).json({ error: 'Fallo al eliminar un producto: ' + err.message });
    }
  },

  // Buscar un prodcuto por filtros
  async search(req, res) {
    try {
      const product = await Product.searchProduct(req.query);
      if (product.length === 0) {
        return res.status(404).json({ message: 'Producto no encontrado' });
      }
      res.status(200).json(product);
    } catch (error) {
      console.error('Error al buscar un producto:', error.message);
      res.status(500).json({ error: 'Fallo al buscar un producto: ' + error.message });
    }
  },
};

module.exports = ProductController;
