const db = require('../../src/services/firebase');
const request = require('supertest');
const app = require('../../src/app'); // Asegúrate de exportar la app en app.js
const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmZDA3MmRmYTM4MDU2NzlmMTZmZTQxNzM4YzJhM2FkM2Y5MGIyMTQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYXBwem9oYXItNmU5M2MiLCJhdWQiOiJhcHB6b2hhci02ZTkzYyIsImF1dGhfdGltZSI6MTczMzIzNjE1OCwidXNlcl9pZCI6InNNdjNGRmNoSVBhb2czcmFGVDVKUHZVRlp3WDIiLCJzdWIiOiJzTXYzRkZjaElQYW9nM3JhRlQ1SlB2VUZad1gyIiwiaWF0IjoxNzMzMjM2MTU4LCJleHAiOjE3MzMyMzk3NTgsImVtYWlsIjoicHJ1ZWJhQGV4YW1wbGUuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInBydWViYUBleGFtcGxlLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.B7jRz6mLlLQwAiW6XwnHZf-CCFMmquSDRiLGIpFtpfOy5w5Qo39ZgHnGKcRYdPjgS7IcZkJ0uyGL0Rb9neh4JycMZ6EFCgh0KKQGtji8HbFFIut9doI1X71iXsTZALvTd-l5DCVOOEDefc2mI5RZw7R8tvwQRBBmLQIQJfxTw9mx_NvjXdu4nqPhyluoAkmWrJh3OfbsX5M2y513u24NGyLxix0Px3rbkHUxheF_YPXbAdBi_zqeN9ABJDkHgg6wlRQQQvj6Gp0WeJ6yIM2NYo9VHb5e-aQnZfmJfJVyvz6RxHZ7se3Wh-MQtgLv_BZdewX2dJyV5Nay8t7VMx5jUQ'
const userDelete = 'EEtQhiWZ5P9tz6JTW7tI'
const userUpdate = '4hhs02E9n5fZatuDquxB'

describe('Customer Service API', () => {

  // Prueba para obtener todos los clientes
  it('GET /api/customers retorna paginas de clientes', async () => {
    const response = await request(app)
      .get('/api/customers?page=1&limit=2')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body).toHaveProperty('page', 1);
    expect(response.body).toHaveProperty('limit', 2);
    expect(response.body.customers).toBeInstanceOf(Array); // Espera una lista de clientes
    expect(response.body.customers.length).toBeLessThanOrEqual(2); // Al menos un cliente
  });

  // Prueba para crear un cliente
  it('POST /api/customers should create a new customer', async () => {
    const newCustomer = {
      nombre: "Juan Pérez",
      email: "juan.perez@example.com",
      direccion: "Calle Ficticia 123",
      celular: "+593987654321",
      zonaID: "Zona Norte 1",
      ubicacion: { latitude: -1.670, longitude: -78.647 },
    };

    const response = await request(app).post('/api/customers')
      .set('Authorization', `Bearer ${token}`)
      .send(newCustomer)
      .expect(201);

    expect(response.body).toHaveProperty('id'); // Verifica que se haya creado un cliente con un ID
    expect(response.body.nombre).toBe(newCustomer.nombre); // Verifica que los datos coinciden
  });

  // Prueba para actualizar un cliente
  it('PUT /api/customers/:id should update an existing customer', async () => {
    const updatedData = { direccion: "Avenida Nueva 46", celular: "+593987654321" };

    const response = await request(app)
      .put(`/api/customers/${userUpdate}`)
      .set('Authorization', `Bearer ${token}`)
      .send(updatedData)
      .expect(200);  // Espera un código de estado 200 (OK)
  
    // Verifica que la respuesta contenga la dirección actualizada
    expect(response.body.direccion).toBe(updatedData.direccion);  // Verifica la dirección
    expect(response.body.celular).toBe(updatedData.celular);  // Verifica el celular si también fue actualizado
  });
  

  // Prueba para eliminar un cliente
  it('DELETE /api/customers/:id should delete a customer', async () => {

    await request(app).delete(`/api/customers/${userDelete}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(204); // 204 indica que la eliminación fue exitosa y no hay contenido en la respuesta
  });

  // Prueba para busqueda avanzada de cliente
  it('GET /api/customers/search should return matching customers', async () => {
    const queryParams = { nombre: 'Juan Pérez', zona: 'Zona Norte 1' };
  
    const response = await request(app)
      .get('/api/customers/search')
      .query(queryParams)
      .set('Authorization', `Bearer ${token}`) // Usa un token válido
      .expect(200);
  
    expect(response.body).toBeInstanceOf(Array);
    expect(response.body[0]).toHaveProperty('nombre', 'Juan Pérez');
    expect(response.body[0]).toHaveProperty('zonaID', 'Zona Norte 1');
  });
  
  it('GET /api/customers/search should return 404 if no customers match', async () => {
    const queryParams = { nombre: 'Cliente Inexistente' };
  
    const response = await request(app)
      .get('/api/customers/search')
      .query(queryParams)
      .set('Authorization', `Bearer ${token}`) // Usa un token válido
      .expect(404);
  
    expect(response.body).toHaveProperty('message', 'No se encontraron clientes');
  });

  afterAll(async () => {
    if (app && app.close) {
      await app.close();
    }
  
    if (db && typeof db.terminate === 'function') {
      await db.terminate();
    }
  });
  
  
});
