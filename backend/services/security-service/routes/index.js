const express = require('express');
const AuthController = require('../controllers/authController');
const authorize = require('../middlewares/authorize');
const authMiddleware = require('../middlewares/authMiddleware');

const router = express.Router();

// Endpoints
router.post('/register', [authMiddleware, authorize(['admin','cliente'])], AuthController.register);
router.post('/login', AuthController.login);


module.exports = router;
