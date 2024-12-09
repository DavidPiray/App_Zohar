const db = require('../config/firebase');

// Registrar un evento de auditoría
exports.logEvent = async (event, userId, description) => {
  try {
    const auditLog = {
      event,
      userId,
      description,
      timestamp: new Date().toISOString(),
    };

    await db.collection('audit_logs').add(auditLog);
    console.log('Evento registrado en la auditoría:', auditLog);
  } catch (error) {
    console.error('Error al registrar evento de auditoría:', error);
  }
};