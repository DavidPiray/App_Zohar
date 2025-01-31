const express = require('express');
const AuthController = require('../controllers/authController');
const router = express.Router();

// Endpoints
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.put('/users/:clientId/password', AuthController.updatePassword);


module.exports = router;
