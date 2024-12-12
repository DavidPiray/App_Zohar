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
app.use('/api/zonas', routes);

const PORT = process.env.ZONE_SERVICE_PORT || 3003;
app.listen(PORT, () => {
    console.log(`El servicio de zonas esta corriendo -> http://localhost:${PORT}`);
    console.log(`Para cerra el servidor presione CTRL + C`);;
});
