const request = require('supertest');
const app = require('../../src/app');
const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmZDA3MmRmYTM4MDU2NzlmMTZmZTQxNzM4YzJhM2FkM2Y5MGIyMTQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYXBwem9oYXItNmU5M2MiLCJhdWQiOiJhcHB6b2hhci02ZTkzYyIsImF1dGhfdGltZSI6MTczMzE1MjU5MCwidXNlcl9pZCI6InNNdjNGRmNoSVBhb2czcmFGVDVKUHZVRlp3WDIiLCJzdWIiOiJzTXYzRkZjaElQYW9nM3JhRlQ1SlB2VUZad1gyIiwiaWF0IjoxNzMzMTUyNTkwLCJleHAiOjE3MzMxNTYxOTAsImVtYWlsIjoicHJ1ZWJhQGV4YW1wbGUuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInBydWViYUBleGFtcGxlLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.eQEymk6x7HrUkWK4FrGQuLLJQvsS-uG1BufRjKBGA4QI5o5xK6uC1NrSgGeunVHuf_fgqzbdOIGEIrDl_fC1yfbSIaOYngR3Q0cZUd39TWUH8GhR6pbG4yFDJoezixaFzs9DzkY_FIwFChM88khR8lcVmyg0eVgfDip5S--MNq3ie5BNkIZLCFt7csAeOWkmA8dYVpGYgZEVc0kx6T45r6nAwQQcNsV45mKn6IgMGbd8pE1rkkrs7RLvsUh48mwhK_PGuW-dvSOd7AxXklip79-FdbU48lKOhuSYuB3dRDhJpPFxTOAl_qoTFwVoodHls-e8oN16JOroEQQxThCbfA';

describe('User Service API', () => {
    it('POST /api/users/register debe registrar un usuario', async () => {
        const response = await request(app)
            .post('/api/users/register') // Ruta completa con prefijo
            .set('Authorization', `Bearer ${token}`)
            .send({ email: 'nuevo@example.com', password: 'password123', roles: ['user'] })
            .expect(201);

        expect(response.body).toHaveProperty('id');
        expect(response.body.email).toBe('nuevo@example.com');
    });

    it('GET /api/users debe devolver la lista de usuarios', async () => {
        const response = await request(app)
            .get('/api/users') // Ruta completa con prefijo
            .set('Authorization', `Bearer ${token}`)
            .expect(200);

        expect(response.body).toBeInstanceOf(Array);
    });

    it('PUT /api/users/:id/roles debe actualizar roles del usuario', async () => {
        const response = await request(app)
            .put('/api/users/y2wTmAuynI9jGqJEab2X/roles') // Ruta completa con prefijo
            .set('Authorization', `Bearer ${token}`)
            .send({ roles: ['admin'] })
            .expect(200);

        expect(response.body).toHaveProperty('message', 'Roles actualizados exitosamente.');
    });
});
