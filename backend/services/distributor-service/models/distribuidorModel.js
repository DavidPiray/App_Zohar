const db = require('../../../utils/firebase');

const Distributor = {
  async createDistributor(distributorData) {
    const distributorRef = db.collection('distribuidor').doc(distributorData.id_distribuidor);
    await distributorRef.set(distributorData);
    return { message: 'Distribuidor creado con éxito' };
  },

  async getDistributorById(id_distribuidor) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    const distributorDoc = await distributorRef.get();
    return distributorDoc.exists ? distributorDoc.data() : null;
  },

  async getAllDistributors() {
    const snapshot = await db.collection('distribuidor').get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  async updateDistributor(id_distribuidor, updatedData) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    await distributorRef.update(updatedData);
    return { message: 'Distribuidor actualizado con éxito' };
  },

  async deleteDistributor(id_distribuidor) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    const distributorDoc = await distributorRef.get();
    if (!distributorDoc.exists) {
      return { error: 'Distribuidor no encontrado' };
    }
    await distributorRef.delete();
    return { message: 'Distribuidor eliminado con éxito' };
  },

  async getDistributorsByZone(zoneID) {
    const snapshot = await db.collection('distribuidor').where('zonaAsignada', '==', zoneID).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },
};

module.exports = Distributor;
