const {db} = require('../shared/utils/firebase');

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
    if (exists){
      return {error: 'Producto con este ID o nombre ya existe'};
    } 
    const customerRef = db.collection('productos');
    await customerRef.doc(id_producto).set(productData);
    return { message: 'Producto creado con éxito!' };
  },

  // Obtener todos los productos
  async getAllProducts() {
    const snapshot = await db.collection('productos').get();
    return snapshot.docs.map(doc => doc.data());
  },

  // Obtener producto por ID
  async getProductById(id_producto) {
    const productRef = db.collection('productos').doc(id_producto);
    const productDoc = await productRef.get();
    return productDoc.exists ? productDoc.data() : null;
  },

  // Actualizar producto
  async updateProduct(id_producto, updatedData) {
    const productRef = db.collection('productos').doc(id_producto);
    const doc = await productRef.get();
    if (!doc.exists) return {error: 'Producto no encontrado'};
    await productRef.update(updatedData);
    return { message: 'Producto actualizado correctamente!' };
  },

  // Eliminar producto
  async deleteProduct(id_producto) {
    const productRef = db.collection('productos').doc(id_producto);
    const doc = await productRef.get();
    if (!doc.exists) return{error: 'Producto no encontrado'};
    await productRef.delete();
    return { message: 'Producto eliminado correctamente!' };
  },

  // Actualizar stock
  async updateStock(id_producto, cantidad) {
    const productRef = db.collection('productos').doc(id_producto);
    const doc = await productRef.get();
    if (!doc.exists) throw new Error ( 'Producto no encontrado');

    const currentStock = doc.data().stock || 0;
    const newStock = currentStock + cantidad;

    if (newStock < 0) throw new Error('Stock insuficiente');

    await productRef.update({ stock: newStock });
    return { message: `Stock actualizado: ${newStock} unidades` };
  },

  // Buscar un producto por filtros
  async searchProduct(filters) {
      let query = db.collection('productos');
      if (filters.nombre) {
        query = query.where('nombre', '==', filters.nombre);
      }
      if (filters.id_producto) {
        query = query.where('id_producto', '==', filters.id_producto);
      }
      if (filters.stock) {
        query = query.where('stock', '==', filters.stock);
      } 
      const snapshot = await query.get();
      const customers = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      return customers;
    },
};

module.exports = Product;
