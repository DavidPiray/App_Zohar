const db = require('../../../utils/firebase');

const Zona = {
  // Crear zonas
  async createZone(zoneData) {
    const zoneRef = db.collection('zonas').doc(zoneData.id_zona);
    await zoneRef.set(zoneData);
    return { message: 'Zona creada con éxito' };
  },

  // Obtener zona por ID
  async getZoneById(id_zona) {
    const zoneRef = db.collection('zonas').doc(id_zona);
    const zoneDoc = await zoneRef.get();
    return zoneDoc.exists ? zoneDoc.data() : null;
  },

  // Obtener todas las zonas
  async getAllZones() {
    const snapshot = await db.collection('zonas').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  // Actualizar una zona
  async updateZone(id_zona, updatedData) {
    const zoneRef = db.collection('zonas').doc(id_zona);
    await zoneRef.update(updatedData);
    return { message: 'Zona actualizada con éxito!' };
  },

  // Eliminar una zona
  async deleteZone(id_zona) {
    const zoneRef = db.collection('zonas').doc(id_zona);
    const zonaDoc = await zoneRef.get();
    if (!zonaDoc.exists) {
      return { message: 'Zona no encontrada' };
    }
    await zoneRef.delete();
    return { message: 'Zona eliminada con éxito!' };
  },

  // Obtener zona por localización
  async getZoneByLocation(latitude, longitude) {
    const snapshot = await db.collection('zonas')
      .where('limites.minLatitude', '<=', latitude)
      .where('limites.maxLatitude', '>=', latitude)
      .where('limites.minLongitude', '<=', longitude)
      .where('limites.maxLongitude', '>=', longitude)
      .get();

    if (snapshot.empty) {
      return null;
    }

    return snapshot.docs.map(doc => doc.data())[0];
  },
};

module.exports = Zona;
