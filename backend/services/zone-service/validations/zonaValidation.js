const Joi = require('joi');

//validación de crear zona
const createZoneSchema = Joi.object({
  id_zona: Joi.string().required(),
  descripcion: Joi.string().required(),
  distribuidor: Joi.string().optional(), // Relacionado con distribuidores
  limites: Joi.object({
    minLatitude: Joi.number().min(-90).max(90).required(), // Latitud mínima del sector
    maxLatitude: Joi.number().min(-90).max(90).required(), // Latitud máxima del sector
    minLongitude: Joi.number().min(-180).max(180).required(), // Longitud mínima del sector
    maxLongitude: Joi.number().min(-180).max(180).required(), // Longitud máxima del sector
  }).required(), // El objeto límites es obligatorio
});

//validación de actualizar zona
const updateZoneSchema = Joi.object({
  descripcion: Joi.string().optional(),
  distribuidor: Joi.string().optional(),
  limites: Joi.object({
    minLatitude: Joi.number().min(-90).max(90).optional(), // Latitud mínima
    maxLatitude: Joi.number().min(-90).max(90).optional(), // Latitud máxima
    minLongitude: Joi.number().min(-180).max(180).optional(), // Longitud mínima
    maxLongitude: Joi.number().min(-180).max(180).optional(), // Longitud máxima
  }).optional(), // El objeto límites es opcional
});

module.exports = {
  createZoneSchema,
  updateZoneSchema,
};
