const {db} = require('../shared/utils/firebase');

const SalesModel = {
    // Obtener reporte de ventas por día
    async getSalesReportByDay(dia, distribuidorID) {
        const doc = await db.collection('ventas_mensuales').doc(`${dia}-${distribuidorID}`).get();
        return doc.exists ? doc.data() : null;
    },

    // Obtener reporte de ventas por semana
    async getSalesReportByWeek(startDate, endDate, distribuidorID) {
        const salesSnapshot = await db.collection('ventas_mensuales')
            .where('fecha', '>=', startDate)
            .where('fecha', '<=', endDate)
            .where('distribuidorID', '==', distribuidorID)
            .get();

        return salesSnapshot.docs.map(doc => doc.data());
    },

    // Obtener reporte de ventas por mes
    async getSalesReportByMonth(year, month, distribuidorID) {
        const startOfMonth = `${year}-${month.padStart(2, '0')}-01`;
        const endOfMonth = new Date(year, month, 0).toISOString().slice(0, 10);

        const salesSnapshot = await db.collection('ventas_mensuales')
            .where('fecha', '>=', startOfMonth)
            .where('fecha', '<=', endOfMonth)
            .where('distribuidorID', '==', distribuidorID)
            .get();

        return salesSnapshot.docs.map(doc => doc.data());
    },

    // Obtener reporte de ventas por año
    async getSalesReportByYear(year, distribuidorID) {
        const startOfYear = `${year}-01-01`;
        const endOfYear = `${year}-12-31`;

        const salesSnapshot = await db.collection('ventas_mensuales')
            .where('fecha', '>=', startOfYear)
            .where('fecha', '<=', endOfYear)
            .where('distribuidorID', '==', distribuidorID)
            .get();

        return salesSnapshot.docs.map(doc => doc.data());
    },

    // Obtener los productos más vendidos en un día
    async getTopProductsByDay(dia) {
        const doc = await db.collection('venta_productos').doc(dia).get();
        return doc.exists ? doc.data() : null;
    }
};

module.exports = SalesModel;
