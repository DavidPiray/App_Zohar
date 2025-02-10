const ProductsModel = require('../models/productsModel');

const ProductsController = {
  async getTopProductsByDay(req, res) {
    try {
      const { dia } = req.params;
      const report = await ProductsModel.getTopProductsByDay(dia);
      res.json(report || { message: 'No hay datos para este día.' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  async getTopProductsByWeek(req, res) {
    try {
      const { year, week } = req.params;
      const startDate = new Date(year, 0, (week - 1) * 7 + 1).toISOString().slice(0, 10);
      const endDate = new Date(year, 0, (week - 1) * 7 + 7).toISOString().slice(0, 10);

      const report = await ProductsModel.getTopProductsByWeek(startDate, endDate);
      res.json({ semana: `${year}-W${week}`, productos: report });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  async getTopProductsByMonth(req, res) {
    try {
      const { year, month } = req.params;
      const report = await ProductsModel.getTopProductsByMonth(year, month);
      res.json({ mes: `${year}-${month}`, productos: report });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  async getTopProductsByYear(req, res) {
    try {
      const { year } = req.params;
      const report = await ProductsModel.getTopProductsByYear(year);
      res.json({ anio: year, productos: report });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
};

module.exports = ProductsController;
