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
app.use(authMiddleware); // Protege todos los endpoints
app.use('/distribuidor', routes);

const PORT = process.env.DISTRIBUTOR_SERVICE_PORT || 3004;
app.listen(PORT, () => {
  console.log(`El servicio de distribuidores esta corriendo -> http://localhost:${PORT}/distribuidor`);
});
