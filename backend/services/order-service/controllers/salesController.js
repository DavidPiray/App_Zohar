const SalesModel = require('../models/salesModel');

const SalesController = {
    // Reporte de ventas por día
    async getSalesByDay(req, res) {
        try {
            const { dia, distribuidorID } = req.params;
            print('dia: ',dia);
            const report = await SalesModel.getSalesReportByDay(dia, distribuidorID);
            res.json(report || { message: 'No hay datos para esta fecha.' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    // Reporte de ventas por semana
    async getSalesByWeek(req, res) {
        try {
            const { year, week, distribuidorID } = req.params;
            const startDate = new Date(year, 0, (week - 1) * 7 + 1).toISOString().slice(0, 10);
            const endDate = new Date(year, 0, (week - 1) * 7 + 7).toISOString().slice(0, 10);

            const report = await SalesModel.getSalesReportByWeek(startDate, endDate, distribuidorID);
            res.json({ semana: `${year}-W${week}`, ventas: report });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    // Reporte de ventas por mes
    async getSalesByMonth(req, res) {
        try {
            const { year, month, distribuidorID } = req.params;
            const report = await SalesModel.getSalesReportByMonth(year, month, distribuidorID);
            res.json({ mes: `${year}-${month}`, ventas: report });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    // Reporte de ventas por año
    async getSalesByYear(req, res) {
        try {
            const { year, distribuidorID } = req.params;
            const report = await SalesModel.getSalesReportByYear(year, distribuidorID);
            res.json({ anio: year, ventas: report });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    },

    // Productos más vendidos en un día
    async getTopProducts(req, res) {
        try {
            const { dia } = req.params;
            const report = await SalesModel.getTopProductsByDay(dia);
            res.json(report || { message: 'No hay datos para este día.' });
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    }
};

module.exports = SalesController;
