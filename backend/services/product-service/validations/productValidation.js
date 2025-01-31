const Joi = require('joi');

const productSchema = Joi.object({
  id_producto: Joi.string().required(),
  nombre: Joi.string().required(),
  descripcion: Joi.string().optional(),
  precio_cliente: Joi.number().positive().required(),
  precio_distribuidor: Joi.number().positive().required(),
  stock: Joi.number().integer().min(0).required()
});

const updateProductSchema = Joi.object({
  nombre: Joi.string().optional(),
  descripcion: Joi.string().optional(),
  precio_cliente: Joi.number().positive().optional(),
  precio_distribuidor: Joi.number().positive().optional(),
  stock: Joi.number().integer().min(0).optional()
});

module.exports = { productSchema, updateProductSchema };
