const express = require('express');
const router = express.Router();
const customerController = require('../controllers/customerController');
const verifyToken = require('../middleware/auth');

/**
 * @swagger
 * tags:
 *   name: Customers
 *   description: Endpoints para la gestión de clientes
 */

// Ruta para obtener clientes
/**
 * @swagger
 * /api/customers:
 *   get:
 *     summary: Obtiene todos los clientes
 *     tags: [Customers]
 *     responses:
 *       200:
 *         description: Lista de clientes
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: string
 *                     description: ID del cliente
 *                   nombre:
 *                     type: string
 *                     description: Nombre del cliente
 *                   email:
 *                     type: string
 *                     description: Correo electrónico del cliente
 *                   celular:
 *                     type: string
 *                     description: Número de teléfono del cliente
 */
router.get('/', verifyToken, customerController.getAllCustomers);

// Ruta para búsqueda avanzada de clientes
/**
 * @swagger
 * /api/customers/search:
 *  get:
 *     summary: Buscar clientes por nombre, email o zona
 *     tags:
 *       - Clientes
 *     parameters:
 *       - in: query
 *         name: nombre
 *         schema:
 *           type: string
 *         description: Buscar clientes por nombre
 *       - in: query
 *         name: email
 *         schema:
 *           type: string
 *         description: Buscar clientes por email
 *       - in: query
 *         name: zona
 *         schema:
 *           type: string
 *         description: Buscar clientes por zona
 *     responses:
 *       200:
 *         description: Lista de clientes encontrados
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Cliente'
 *       404:
 *         description: No se encontraron clientes
 *       500:
 *         description: Error del servidor
 */
router.get('/search', verifyToken, customerController.searchCustomers);

// Ruta para crear clientes
/**
 * @swagger
 * /api/customers:
 *   post:
 *     summary: Crea un nuevo cliente
 *     tags: [Customers]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nombre:
 *                 type: string
 *               email:
 *                 type: string
 *               direccion:
 *                 type: string
 *               celular:
 *                 type: string
 *               zonaID:
 *                 type: string
 *               ubicacion:
 *                 type: object
 *                 properties:
 *                   latitude:
 *                     type: number
 *                   longitude:
 *                     type: number
 *     responses:
 *       201:
 *         description: Cliente creado exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 nombre:
 *                   type: string
 *                 email:
 *                   type: string
 *                 celular:
 *                   type: string
*/
router.post('/', verifyToken, customerController.createCustomer);

// Ruta para actualizar los clientes
/**
 * @swagger
 * /api/customers/{id}:
 *   put:
 *     summary: Actualiza un cliente existente
 *     tags: [Customers]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: ID del cliente
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               direccion:
 *                 type: string
 *               celular:
 *                 type: string
 *     responses:
 *       200:
 *         description: Cliente actualizado exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 direccion:
 *                   type: string
 *                 celular:
 *                   type: string
 */
router.put('/:id', verifyToken, customerController.updateCustomer);

// Ruta para borrar los clientes
/**
 * @swagger
 * /api/customers/{id}:
 *   delete:
 *     summary: Elimina un cliente existente
 *     tags: [Customers]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: ID del cliente
 *     responses:
 *       204:
 *         description: Cliente eliminado exitosamente
 */
router.delete('/:id', verifyToken, customerController.deleteCustomer);

module.exports = router;
