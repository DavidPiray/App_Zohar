const db = require('../../../utils/firebase');

const Product = {
  // Verificar si un producto existe por nombre o ID
  async existsByIdOrName(id_producto, nombre) {
    const snapshotById = await db.collection('productos').doc(id_producto).get();
    const snapshotByName = await db.collection('productos')
      .where('nombre', '==', nombre)
      .get();
    return snapshotById.exists || !snapshotByName.empty;
  },

  // Crear un nuevo producto
  async createProduct(productData) {
    const { id_producto, nombre } = productData;

    // Verificar duplicados
    const exists = await this.existsByIdOrName(id_producto, nombre);
    if (exists) throw new Error('Producto con este ID o nombre ya existe');

    await db.collection('productos').doc(id_producto).set(productData);
    return { id_producto, ...productData };
  },

  // Obtener todos los productos
  async getAllProducts() {
    const snapshot = await db.collection('productos').get();
    return snapshot.docs.map(doc => ({ id_producto: doc.id, ...doc.data() }));
  },

  // Obtener producto por ID
  async getProductById(id_producto) {
    const doc = await db.collection('productos').doc(id_producto).get();
    return doc.exists ? { id_producto, ...doc.data() } : null;
  },

  // Actualizar producto
  async updateProduct(id_producto, updatedData) {
    const productRef = db.collection('productos').doc(id_producto);
    const doc = await productRef.get();
    if (!doc.exists) throw new Error('Producto no encontrado');

    await productRef.update(updatedData);
    return { message: 'Producto actualizado correctamente' };
  },

  // Eliminar producto
  async deleteProduct(id_producto) {
    const productRef = db.collection('productos').doc(id_producto);
    const doc = await productRef.get();
    if (!doc.exists) throw new Error('Producto no encontrado');

    await productRef.delete();
    return { message: 'Producto eliminado correctamente' };
  },

  // Actualizar stock
  async updateStock(id_producto, cantidad) {
    const productRef = db.collection('productos').doc(id_producto);
    const doc = await productRef.get();
    if (!doc.exists) throw new Error('Producto no encontrado');

    const currentStock = doc.data().stock || 0;
    const newStock = currentStock + cantidad;

    if (newStock < 0) throw new Error('Stock insuficiente');

    await productRef.update({ stock: newStock });
    return { message: `Stock actualizado: ${newStock} unidades` };
  }
};

module.exports = Product;
