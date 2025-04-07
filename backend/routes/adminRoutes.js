const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const authMiddleware = require('../middleware/authMiddleware');
const { createUser } = require('../models/userModel');

// Admin-only: Create a new host
router.post('/create-host', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden: Admins only' });
    }

    const { username, email, password, full_name, phone_number } = req.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    const newHost = await createUser({
      username,
      email,
      password: hashedPassword,
      full_name,
      phone_number,
      role: 'host',
    });

    res.status(201).json({ message: 'Host created successfully', host: newHost });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
