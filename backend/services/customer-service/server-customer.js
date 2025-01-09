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
app.use(authMiddleware); // Protege todos los endpoints por defecto
app.use('/api/clientes', routes);

const PORT = process.env.CUSTOMER_SERVICE_PORT || 3002;
app.listen(PORT, () => {
  console.log(`El servicio de clientes esta corriendo -> http://localhost:${PORT}`);
  console.log(`Para cerra el servidor presione CTRL + C`);;
});
