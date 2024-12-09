const db = require('../../../utils/firebase');

const Zone = {
  async createZone(zoneData) {
    const zoneRef = db.collection('zonas').doc(zoneData.id_zona);
    await zoneRef.set(zoneData);
    return { message: 'Zona creada con éxito' };
  },

  async getZoneById(id_zona) {
    const zoneRef = db.collection('zonas').doc(id_zona);
    const zoneDoc = await zoneRef.get();
    return zoneDoc.exists ? zoneDoc.data() : null;
  },

  async getAllZones() {
    const snapshot = await db.collection('zonas').get();
    return snapshot.docs.map(doc => doc.data());
  },

  async updateZone(id_zona, updatedData) {
    const zoneRef = db.collection('zonas').doc(id_zona);
    await zoneRef.update(updatedData);
    return { message: 'Zona actualizada con éxito!' };
  },

  async deleteZone(id_zona) {
    const zoneRef = db.collection('zonas').doc(id_zona);
    await zoneRef.delete();
    return { message: 'Zona eliminada con éxito!' };
  },
};

module.exports = Zone;
