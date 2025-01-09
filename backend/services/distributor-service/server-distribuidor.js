const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const routes = require('./routes/routes');
const authMiddleware = require('./shared/utils/authMiddleware');
const cors = require('cors');
dotenv.config({ path: __dirname + '/.env' });

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(authMiddleware); // Protege todos los endpoints
app.use('/api/distribuidor', routes);

const PORT = process.env.DISTRIBUTOR_SERVICE_PORT || 3004;
app.listen(PORT, () => {
  console.log(`Servicio de Distribuidor corriendo en el puerto port ${PORT}`);
});
