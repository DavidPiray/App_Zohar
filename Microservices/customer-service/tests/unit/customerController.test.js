const customerController = require('../../src/controllers/customerController'); 
const db = require('../../src/services/firebase');

describe('Customer Controller', () => {

  it('should return a list of customers', async () => {
    const mockGet = jest.fn().mockResolvedValue({ docs: [{ id: '1', data: () => ({ nombre: 'Carlos Pérez' }) }] });
    db.collection = jest.fn().mockReturnValue({ get: mockGet });

    const req = {};
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn()
    };

    await customerController.getAllCustomers(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith([{ id: '1', nombre: 'Carlos Pérez' }]);
  });

  // Puedes agregar más pruebas unitarias según las funciones que necesites probar
});
