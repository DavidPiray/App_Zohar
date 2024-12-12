const Joi = require('joi');

const createOrderSchema = Joi.object({
  id_pedido: Joi.string().required(),
  clienteID: Joi.string().required(),
  distribuidorID: Joi.string().optional(),
  estado: Joi.string().valid('pendiente', 'en progreso', 'completado', 'cancelado').required(),
  productos: Joi.array()
    .items(
      Joi.object({
        id_producto: Joi.string().required(),
        cantidad: Joi.number().integer().min(1).required(),
      })
    )
    .required(),
    fechaCreacion: Joi.date().default(() => new Date()),
});

const updateOrderSchema = Joi.object({
  distribuidorID: Joi.string().optional(),
  estado: Joi.string().valid('pendiente', 'en progreso', 'completado', 'cancelado').optional(),
  productos: Joi.array()
    .items(
      Joi.object({
        id_producto: Joi.string().optional(),
        cantidad: Joi.number().integer().min(1).optional(),
      })
    )
    .optional(),
});

module.exports = {
  createOrderSchema,
  updateOrderSchema,
};
