const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const routes = require('./routes/routes');
const cors = require('cors');

dotenv.config({ path: __dirname + '/.env' });
const app = express();
// Permitir solicitudes desde cualquier origen
app.use(cors());
app.use(bodyParser.json());
app.use('/auth', routes);

const PORT = process.env.SECURITY_SERVICE_PORT || 3001;
app.listen(PORT, () => {
  console.log(`El servicio de Seguridad esta corriendo -> http://localhost:${PORT}/auth`);
});
