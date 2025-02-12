const Joi = require('joi');

//validadción de registro
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  roles: Joi.array().items(Joi.string().valid('admin', 'cliente', 'distribuidor','gerente')).required(),
});

//validación de incio de sesión
const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

//validación de actualización de password
const updatePasswordSchema = Joi.object({
  oldPassword: Joi.string().min(6).required(),
  newPassword: Joi.string().min(6).required(),
});

module.exports = { registerSchema, loginSchema, updatePasswordSchema };
