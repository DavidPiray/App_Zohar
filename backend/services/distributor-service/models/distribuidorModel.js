const db = require('../shared/utils/firebase');

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

  // Lógica para el producto
  // Agregar un producto al inventario del distribuidor
  async addProductToInventory(id_distribuidor, productData) {
    const distributorRef = db.collection('distribuidor').doc(id_distribuidor);
    const productRef = distributorRef.collection('inventario').doc(productData.id_producto);

    // Verificar si el producto ya existe en el inventario
    const productDoc = await productRef.get();
    if (productDoc.exists) {
      console.log('El producto ya existe en el inventario del distribuidor');
      throw new Error('El producto ya existe en el inventario del distribuidor');
    }

    // Agregar producto al inventario
    await productRef.set(productData);
    return { message: 'Producto agregado al inventario', product: productData };
  },

  // Obtener todos los productos del inventario
  async getInventory(id_distribuidor) {
    const inventorySnapshot = await db.collection('distribuidor')
      .doc(id_distribuidor)
      .collection('inventario')
      .get();

    return inventorySnapshot.docs.map(doc => ({ id_producto: doc.id, ...doc.data() }));
  },

  // Actualizar el stock de un producto en el inventario
  async updateProductStock(id_distribuidor, id_producto, cantidad) {
    const productRef = db.collection('distribuidor')
      .doc(id_distribuidor)
      .collection('inventario')
      .doc(id_producto);

    const productDoc = await productRef.get();
    if (!productDoc.exists) {
      throw new Error('Producto no encontrado en el inventario del distribuidor');
    }

    const currentStock = productDoc.data().stock || 0;
    const newStock = currentStock + cantidad;

    if (newStock < 0) {
      throw new Error('Stock insuficiente');
    }

    await productRef.update({ stock: newStock });
    return { message: `Stock actualizado a ${newStock} unidades` };
  },

  // Eliminar un producto del inventario
  async removeProductFromInventory(id_distribuidor, id_producto) {
    const productRef = db.collection('distribuidor')
      .doc(id_distribuidor)
      .collection('inventario')
      .doc(id_producto);

    await productRef.delete();
    return { message: 'Producto eliminado del inventario' };
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
