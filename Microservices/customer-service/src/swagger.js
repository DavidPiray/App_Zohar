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
    components: {
      schemas: {
        Cliente: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              description: 'ID único del cliente',
            },
            nombre: {
              type: 'string',
              description: 'Nombre del cliente',
            },
            email: {
              type: 'string',
              description: 'Correo electrónico del cliente',
            },
            direccion: {
              type: 'string',
              description: 'Dirección del cliente',
            },
            celular: {
              type: 'string',
              description: 'Número de celular del cliente',
            },
            zonaID: {
              type: 'string',
              description: 'Zona asignada al cliente',
            },
            ubicacion: {
              type: 'object',
              properties: {
                latitude: {
                  type: 'number',
                  description: 'Latitud de la ubicación del cliente',
                },
                longitude: {
                  type: 'number',
                  description: 'Longitud de la ubicación del cliente',
                },
              },
              description: 'Ubicación geográfica del cliente',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Fecha de creación del cliente',
            },
          },
          required: ['nombre', 'email', 'direccion', 'celular', 'zonaID'],
        },
      },
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
