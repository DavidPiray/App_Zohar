const {db} = require('../utils/firebase');

/**
 * Registrar un evento de auditoría en Firebase.
 * @param {string} action - Acción realizada (crear, actualizar, eliminar, etc.).
 * @param {string} collection - Colección afectada.
 * @param {string} documentId - ID del documento afectado.
 * @param {string} performedBy - Usuario que realizó la acción.
 * @param {object} details - Información adicional sobre la solicitud (endpoint, método, etc.).
 */
async function logAuditEvent(action, collection, documentId, performedBy, details = {}) {
  try {
    const auditRef = db.collection('audit_logs'); // Referencia a la colección audit_logs
    await auditRef.add({
      timestamp: new Date(),
      action,
      collection,
      documentId,
      performedBy,
      details,
    });
    console.log('Evento de auditoría registrado exitosamente');
  } catch (error) {
    console.error('Error registrando evento de auditoría:', error);
  }
}

module.exports = {
  logAuditEvent,
};
