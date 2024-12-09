const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const routes = require('./routes');

dotenv.config({ path: __dirname + '/.env' });
const app = express();

app.use(bodyParser.json());
app.use('/api/security', routes);
//console.log('JWT_SECRET:', process.env.JWT_SECRET);

const PORT = process.env.SECURITY_SERVICE_PORT || 3001;
app.listen(PORT, () => {
  console.log(`Security Service running on port ${PORT}`);
});
