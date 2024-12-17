const db = require('../../../utils/firebase');

const Distributor = {
  // Verificar si ya existe un ID repetido
  async existsById(id_distribuidor) {
    const doc = await db.collection('distribuidor').doc(id_distribuidor).get();
    return doc.exists;
  },

  // Crear un distribuidor
  async createDistributor(distributorData) {
    const { id_distribuidor } = distributorData;
    // Verificar duplicidad en ID
    const exists = await this.existsById(id_distribuidor);
    // console.log(exists);
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    if (exists) {
      return { error: 'Distribuidor con ID repetido' };
    }
    // Crear el documento con ID manual
    await distributorRef.set(distributorData);
    return { message: 'Distribuidor creado con éxito' };
  },

  // Obtener distribuidor por ID
  async getDistributorById(id_distribuidor) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    const distributorDoc = await distributorRef.get();
    return distributorDoc.exists ? distributorDoc.data() : null;
  },

  // Obtener todos los distribuidores
  async getAllDistributors() {
    const snapshot = await db.collection('distribuidor').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  // Actualizar la información de un distribuidor
  async updateDistributor(id_distribuidor, updatedData) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    await distributorRef.update(updatedData);
    return { message: 'Distribuidor actualizado con éxito' };
  },

  // Eliminar un distribuidor
  async deleteDistributor(id_distribuidor) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    const distributorDoc = await distributorRef.get();
    if (!distributorDoc.exists) {
      return { error: 'Distribuidor no encontrado' };
    }
    await distributorRef.delete();
    return { message: 'Distribuidor eliminado con éxito' };
  },

  // Obtener una zona por Distribuidor
  async getDistributorsByZone(zoneID) {
    const snapshot = await db.collection('distribuidor').where('zonaAsignada', '==', zoneID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },
};

module.exports = Distributor;
