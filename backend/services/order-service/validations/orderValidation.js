const Joi = require('joi');

const createOrderSchema = Joi.object({
  id_pedido: Joi.string().required(),
  clienteID: Joi.string().required(),
  distribuidorID: Joi.string().required(),
  estado: Joi.string().valid('pendiente', 'en progreso', 'completado', 'cancelado','en cola').required(),
  productos: Joi.array()
    .items(
      Joi.object({
        id_producto: Joi.string().required(),
        cantidad: Joi.number().integer().min(1).positive().required()
      })
    ).min(1).required(),
    fecha: Joi.date().default(() => new Date()),
  total: Joi.number.required(),
});

const updateOrderSchema = Joi.object({
  distribuidorID: Joi.string().optional(),
  estado: Joi.string().valid('pendiente', 'en progreso', 'completado', 'cancelado','en cola').optional(),
  productos: Joi.array()
  .items(
    Joi.object({
      id_producto: Joi.string().optional(),
      cantidad: Joi.number().integer().min(1).positive().optional(),
    })
  )
  .optional(),
  total: Joi.number.optional(),
});

module.exports = {
  createOrderSchema,
  updateOrderSchema,
};
