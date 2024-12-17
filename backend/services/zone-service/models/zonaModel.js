const db = require('../../../utils/firebase');
const { existsById } = require('../../distributor-service/models/distribuidorModel');

const Zona = {
  // Verificar si ya existe un ID repetido
  async existsById(id_zona){
    const doc = await db.collection('zonas').doc(id_zona).get();
    return doc.exists;
  },

  // Crear zonas
  async createZone(zoneData) {
    const { id_zona } = zoneData;
    // Verificar duplicidad en ID
    const exists = await this.existsById(id_zona);
     console.log(exists);
    const zoneRef = db.collection('zonas').doc(id_zona);
    if(exists){
      return { error: 'Zona con ID repetido' };
    }
    // Crear el documento con ID manual
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
    const snapshot = await db.collection('zonas').get();
    
    if (snapshot.empty) {
      return null;
    }
    const zones = snapshot.docs.map(doc => doc.data());
    console.log("Calculando zonas");
    // Filtrar zonas por las coordenadas
    const matchingZone = zones.find(zone =>
      latitude >= zone.limites.minLatitude &&
      latitude <= zone.limites.maxLatitude &&
      longitude >= zone.limites.minLongitude &&
      longitude <= zone.limites.maxLongitude
    );
    
    console.log("Zonas Calculadas");
    return matchingZone || null;
  },
};

module.exports = Zona;
