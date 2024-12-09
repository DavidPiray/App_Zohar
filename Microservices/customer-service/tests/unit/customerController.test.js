const customerController = require('../../src/controllers/customerController'); 
const db = require('../../src/services/firebase');

describe('Customer Controller', () => {

  it('should return a list of customers', async () => {
    const req = {
      query: { page: "1", limit: "2" },
    };
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    
    await customerController.getAllCustomers(req, res);
    
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith({
      page: 1,
      limit: 2,
      total: expect.any(Number),
      customers: expect.any(Array),
    });
  });

  // Puedes agregar más pruebas unitarias según las funciones que necesites probar
});
