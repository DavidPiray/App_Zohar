const express = require('express');
const userController = require('../controllers/userController');

const router = express.Router();

router.post('/register', userController.registerUser);
router.get('/', userController.getAllUsers);
router.put('/:id/roles', userController.updateUserRoles);

module.exports = router;
