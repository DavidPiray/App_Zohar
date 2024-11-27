const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

// Configuración básica de Swagger
const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Customer Service API',
      version: '1.0.0',
      description: 'API para la gestión de clientes en el proyecto Zohar.',
    },
    servers: [
      {
        url: 'http://localhost:3001',
        description: 'Servidor local',
      },
    ],
  },
  apis: ['./src/routes/*.js'], // Ruta de tus archivos con anotaciones Swagger
};

const specs = swaggerJsdoc(options);

module.exports = {
  swaggerUi,
  specs,
};
