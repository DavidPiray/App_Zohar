const Joi = require('joi');

//Validación para crear distribuidor
const createDistributorSchema = Joi.object({
  id_distribuidor: Joi.string().required(),
  nombre: Joi.string().required(),
  email: Joi.string().email().required(),
  celular: Joi.string().required(),
  estado: Joi.string().valid('activo', 'inactivo').required(),
  zonaAsignada: Joi.string().optional(),
});

//validación para actualizar distribuidor
const updateDistributorSchema = Joi.object({
  nombre: Joi.string().optional(),
  email: Joi.string().email().optional(),
  celular: Joi.string().optional(),
  estado: Joi.string().valid('activo', 'inactivo').optional(),
  zonaAsignada: Joi.string().optional(),
});

module.exports = {
  createDistributorSchema,
  updateDistributorSchema,
};
