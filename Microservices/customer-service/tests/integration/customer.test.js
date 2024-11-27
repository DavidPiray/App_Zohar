const request = require('supertest');
const app = require('../../src/app'); // Asegúrate de exportar la app en app.js
const token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmZDA3MmRmYTM4MDU2NzlmMTZmZTQxNzM4YzJhM2FkM2Y5MGIyMTQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYXBwem9oYXItNmU5M2MiLCJhdWQiOiJhcHB6b2hhci02ZTkzYyIsImF1dGhfdGltZSI6MTczMjczODY3MSwidXNlcl9pZCI6InNNdjNGRmNoSVBhb2czcmFGVDVKUHZVRlp3WDIiLCJzdWIiOiJzTXYzRkZjaElQYW9nM3JhRlQ1SlB2VUZad1gyIiwiaWF0IjoxNzMyNzM4NjcxLCJleHAiOjE3MzI3NDIyNzEsImVtYWlsIjoicHJ1ZWJhQGV4YW1wbGUuY29tIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7ImVtYWlsIjpbInBydWViYUBleGFtcGxlLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.DKkQ47wfI4-PLPOjsHKy04CqbA90P8SUOfLXhh2AuarxX2UNW3jZnTqAinGZmUJxY_5BVaTd8cZvYclW3LA0MtPGzpQk4Cxcpqqm3u4j5XQ9LCIM-fNqsuBE5_Rm5dRyWDYdZfvyj-ba5KdUBvlsCltAv1S-oR8G2zSWqzK7GZYIleRDTT7woH-7SwBA4frjux_OtZkjR4tC_NvgAP0Od9YaREyB4kFcYwv61S9KqBi4jU3zd3oWDrEuAPk3Wq0yQ1YH9WBeUO5KrGI1__iUqddhogywxLqFEX95Uu_yWzZtk11prvO7EovdzD0MzpEpP96AAkHJDV6cKvwKc3aFjQ'

describe('Customer Service API', () => {

  // Prueba para obtener todos los clientes
  it('GET /api/customers should return a list of customers', async () => {
    const response = await request(app).get('/api/customers')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body).toBeInstanceOf(Array); // Espera una lista de clientes
    expect(response.body.length).toBeGreaterThan(0); // Al menos un cliente
  });

  // Prueba para crear un cliente
  it('POST /api/customers should create a new customer', async () => {
    const newCustomer = {
      nombre: "Carlos Pérez",
      email: "carlos@example.com",
      direccion: "Calle Ficticia 123",
      celular: "+593987654321",
      zonaID: "Zona Sur",
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
    const customerId = '2ciJ6rc4atTm8ZuJnaCQ';

    const response = await request(app)
      .put(`/api/customers/${customerId}`)
      .set('Authorization', `Bearer ${token}`)
      .send(updatedData)
      .expect(200);  // Espera un código de estado 200 (OK)
  
    // Verifica que la respuesta contenga la dirección actualizada
    expect(response.body.direccion).toBe(updatedData.direccion);  // Verifica la dirección
    expect(response.body.celular).toBe(updatedData.celular);  // Verifica el celular si también fue actualizado
  });
  

  // Prueba para eliminar un cliente
  it('DELETE /api/customers/:id should delete a customer', async () => {
    const customerId = 'ItJT1HeXOdVoY4GUJWlU'; // Usa un cliente válido para esta prueba

    await request(app).delete(`/api/customers/${customerId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(204); // 204 indica que la eliminación fue exitosa y no hay contenido en la respuesta
  });
});
