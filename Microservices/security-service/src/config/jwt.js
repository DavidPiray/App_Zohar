//Configuracion de jsonwebtoken
const jwt = require('jsonwebtoken');

const generateToken = (user) => {
  const payload = { id: user.id, roles: user.roles };
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
};

const verifyToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

module.exports = { generateToken, verifyToken };