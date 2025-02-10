const {db} = require('../shared/utils/firebase');

const ProductsModel = {
  // Obtener los productos más vendidos en un día
  async getTopProductsByDay(dia) {
    const doc = await db.collection('venta_productos').doc(dia).get();
    return doc.exists ? doc.data() : null;
  },

  // Obtener los productos más vendidos en una semana
  async getTopProductsByWeek(startDate, endDate) {
    const snapshot = await db.collection('venta_productos')
      .where('dia', '>=', startDate)
      .where('dia', '<=', endDate)
      .get();

    return snapshot.docs.map(doc => doc.data());
  },

  // Obtener los productos más vendidos en un mes
  async getTopProductsByMonth(year, month) {
    const startOfMonth = `${year}-${month.padStart(2, '0')}-01`;
    const endOfMonth = new Date(year, month, 0).toISOString().slice(0, 10);

    const snapshot = await db.collection('venta_productos')
      .where('dia', '>=', startOfMonth)
      .where('dia', '<=', endOfMonth)
      .get();

    return snapshot.docs.map(doc => doc.data());
  },

  // Obtener los productos más vendidos en un año
  async getTopProductsByYear(year) {
    const startOfYear = `${year}-01-01`;
    const endOfYear = `${year}-12-31`;

    const snapshot = await db.collection('venta_productos')
      .where('dia', '>=', startOfYear)
      .where('dia', '<=', endOfYear)
      .get();

    return snapshot.docs.map(doc => doc.data());
  }
};

module.exports = ProductsModel;
