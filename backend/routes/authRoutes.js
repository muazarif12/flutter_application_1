const express = require('express');
const router = express.Router();
const { registerUser, loginUser, googleSignIn } = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/google-sign-in', googleSignIn);

module.exports = router;
