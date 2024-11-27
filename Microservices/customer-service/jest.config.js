module.exports = {
    testEnvironment: 'node', // Usamos Node.js como entorno de pruebas
    transform: {
      '^.+\\.js$': 'babel-jest', // Si usas Babel para transpilar JS (si tienes ES Modules)
    },
    testTimeout: 10000, // Tiempo de espera máximo por prueba (ajustable)
  };
  