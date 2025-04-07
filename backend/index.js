const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const createError = require('http-errors');

// Load environment variables
dotenv.config();

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cors());

// Routes
const authRoutes = require('./routes/authRoutes');
app.use('/api/auth', authRoutes);

// 404 handler
app.use((req, res, next) => {
  next(createError(404, 'Route Not Found'));
});

// Start server
const PORT = process.env.PORT || 5600;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
