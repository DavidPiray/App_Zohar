const AuditModel = require('../models/auditModel');

/**
 * Middleware para registrar eventos de auditoría.
 * @param {string} action - Acción realizada (crear, actualizar, eliminar, etc.).
 * @param {string} collection - Colección afectada.
 */
const auditLogger = (action, collection) => async (req, res, next) => {
  try {
    const user = req.user || {}; // Usuario autenticado (debe estar disponible en req.user)
    const documentId = req.params.id || 'N/A'; // ID del documento afectado (si aplica)
    const performedBy = user.email || 'Anónimo'; // Usuario que realizó la acción
    const details = {
      endpoint: req.originalUrl,
      method: req.method,
      params: req.params,
      body: req.body,
    };

    // Llama al método del modelo con los parámetros requeridos
    await AuditModel.logAuditEvent(action, collection, documentId, performedBy, details);

    next();
  } catch (error) {
    console.error('Error registrando auditoría:', error);
    next(); // No bloquear la operación si ocurre un error de auditoría
  }
};

module.exports = auditLogger;
