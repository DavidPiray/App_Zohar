const express = require('express');
const cors = require('cors');
const customerRoutes = require('./routes/customerRoutes');
const { swaggerUi, specs } = require('./swagger');

const app = express();

app.use(cors());
app.use(express.json());

// Documentación Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// Rutas de clientes
app.use('/api/customers', customerRoutes);

app.get('/', (req, res) => {
  res.send('Customer Service API with secure access.');
});

module.exports = app;
