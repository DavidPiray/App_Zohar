const authorize = (allowedRoles) => (req, res, next) => {
    try {
      // Verificar si el rol del usuario está en el token JWT
      const userRole = req.user?.roles;
  
      if (!userRole || !allowedRoles.some((role) => userRole.includes(role))) {
        return res.status(403).json({ error: 'Acceso denegado. No tienes permiso para realizar esta acción.' });
      }
  
      next(); // Usuario autorizado, continuar al siguiente middleware/controlador
    } catch (error) {
      res.status(500).json({ error: 'Error en la autorización' });
    }
  };
  
  module.exports = authorize;
  