/*const admin = require('firebase-admin');

const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken; // Agregamos la información del usuario al request
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' });
  }
};

module.exports = verifyToken;*/

const admin = require('firebase-admin');

const verifyToken = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1]; // Extrae el token de los encabezados

  if (!token) {
    return res.status(401).json({ error: 'No token provided' }); // Si no hay token, responde con 401
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token); // Verifica el token con Firebase Admin SDK
    req.user = decodedToken; // Agrega la información del usuario decodificado al request
    next(); // Continua con la siguiente función
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' }); // Si el token es inválido, responde con 403
  }
};

module.exports = verifyToken;

