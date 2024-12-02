const request = require('supertest');
const app = require('../../src/app');

describe('Auth API', () => {
    it('POST /api/auth/login debe devolver un token para credenciales válidas', async () => {
        const response = await request(app)
            .post('/api/auth/login') // Ruta completa con prefijo
            .send({ email: 'test@example.com', password: 'password123' })
            .expect(200);

        expect(response.body).toHaveProperty('token');
    });

    it('POST /api/auth/logout debe cerrar sesión correctamente', async () => {
        const response = await request(app)
            .post('/api/auth/logout') // Ruta completa con prefijo
            .expect(200);

        expect(response.body).toHaveProperty('message', 'Cierre de sesión exitoso');
    });
});
