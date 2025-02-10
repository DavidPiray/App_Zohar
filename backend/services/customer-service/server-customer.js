const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const routes = require('./routes/routes');
const authMiddleware = require('./shared/utils/authMiddleware');
const cors = require('cors');
dotenv.config({ path: __dirname + '/.env' });
const app = express();

// Permitir solicitudes desde cualquier origen
app.use(cors());
app.use(bodyParser.json());
app.use('/clientes', routes); // Ruta inicial del endpoint

const PORT = process.env.CUSTOMER_SERVICE_PORT || 3002;
app.listen(PORT, () => {
  console.log(`El servicio de clientes esta corriendo -> http://localhost:${PORT}/clientes`);
});
