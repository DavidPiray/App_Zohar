const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ error: 'Acceso Denegado, Token no proporcionado' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Agrega la información del usuario al objeto `req`
    next();
  } catch (error) {
    return res.status(400).json({ error: 'Token Inválido' });
  }
};

module.exports = authMiddleware;
