//Valida el acceso a las rutas
const authorize = (allowedRoles) => (req, res, next) => {
    try {
      // Verificar si el rol del usuario está en el token JWT (ya decodificado por `authMiddleware`)
      const userRole = req.user?.roles; // Asumiendo que roles es un array en el token JWT
  
      if (!userRole || !allowedRoles.some((role) => userRole.includes(role))) {
        return res.status(403).json({ error: 'Acceso denegado. No tienes permiso para realizar esta acción.' });
      }
  
      next(); // Usuario autorizado, continuar al siguiente middleware/controlador
    } catch (error) {
      res.status(500).json({ error: 'Error en la autorización' });
    }
  };
  
  module.exports = authorize;
  