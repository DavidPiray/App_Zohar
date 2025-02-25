const Joi = require('joi');

// Esquema de validación para crear un cliente
const createCustomerSchema = Joi.object({
  nombre: Joi.string().required(),
  email: Joi.string().email().required(),
  direccion: Joi.string().required(),
  celular: Joi.string().required(),
  zonaID: Joi.string().required(),
  distribuidorID: Joi.string().optional(),
  foto: Joi.string().optional(),
  ubicacion: Joi.object({
    latitude: Joi.number().required(),
    longitude: Joi.number().required(),
  }).optional(),
});

// Esquema de validación para actualizar un cliente
const updateCustomerSchema = Joi.object({
  nombre: Joi.string().optional(),
  email: Joi.string().email().optional(),
  direccion: Joi.string().optional(),
  celular: Joi.string().optional(),
  zonaID: Joi.string().optional(),
  distribuidorID: Joi.string().optional(),
  foto: Joi.string().optional(),
  ubicacion: Joi.object({
    latitude: Joi.number().optional(),
    longitude: Joi.number().optional(),
  }).optional(),
});

module.exports = {
  createCustomerSchema,
  updateCustomerSchema,
};
