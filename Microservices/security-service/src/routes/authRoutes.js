const express = require('express');
const authController = require('../controllers/authController');

const router = express.Router();

router.post('/login', authController.login); // Ruta para iniciar sesión
router.post('/logout', authController.logout);

module.exports = router;
