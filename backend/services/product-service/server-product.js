const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const routes = require('./routes/routes');
const authMiddleware = require('../../utils/authMiddleware');

dotenv.config({ path: __dirname + '/.env' });

const app = express();

// Middleware
app.use(bodyParser.json());
app.use(authMiddleware); // Protege todos los endpoints
app.use('/api/productos', routes);

const PORT = process.env.ORDER_SERVICE_PORT || 3006;
app.listen(PORT, () => {
  console.log(`El servicio de Productos esta corriendo en el puerto ${PORT}`);
});
