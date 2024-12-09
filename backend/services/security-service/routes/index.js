const express = require('express');
const AuthController = require('../controllers/authController');

const router = express.Router();

// Endpoints
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);


module.exports = router;
