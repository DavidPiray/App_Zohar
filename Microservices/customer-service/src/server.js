const app = require('./app');
const dotenv = require('dotenv');

dotenv.config();

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`El servicio de clientes esta corriendo -> http://localhost:${PORT}`);
  console.log(`Para cerra el servidor presione CTRL + C`);
  console.log(`El servicio de Swagger para la documentación clientes esta corriendo -> http://localhost:${PORT}/api-docs`);
});