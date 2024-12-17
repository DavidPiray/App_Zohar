const Product = require('../models/productModel');
const { productSchema, updateProductSchema } = require('../validations/productValidation');

const ProductController = {
  async create(req, res) {
    try {
      const { error } = productSchema.validate(req.body);
      if (error) return res.status(400).json({ error: error.details[0].message });

      const response = await Product.createProduct(req.body);
      res.status(201).json(response);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  async getAll(req, res) {
    try {
      const products = await Product.getAllProducts();
      res.status(200).json(products);
    } catch (err) {
      res.status(500).json({ error: 'Error al obtener los productos' });
    }
  },

  async update(req, res) {
    try {
      const { error } = updateProductSchema.validate(req.body);
      if (error) return res.status(400).json({ error: error.details[0].message });

      const response = await Product.updateProduct(req.params.id, req.body);
      res.status(200).json(response);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  async updateStock(req, res) {
    try {
      const { cantidad } = req.body;

      if (typeof cantidad !== 'number') {
        return res.status(400).json({ error: 'La cantidad debe ser un número' });
      }

      const response = await Product.updateStock(req.params.id, cantidad);
      res.status(200).json(response);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  },

  async delete(req, res) {
    try {
      const response = await Product.deleteProduct(req.params.id);
      res.status(200).json(response);
    } catch (err) {
      res.status(400).json({ error: err.message });
    }
  }
};

module.exports = ProductController;
