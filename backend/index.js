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
const adminRoutes = require('./routes/adminRoutes');
app.use('/api/admin', adminRoutes);

const authRoutes = require('./routes/authRoutes');
app.use('/api/auth', authRoutes);

const hostRoutes = require('./routes/hostRoutes');
app.use('/api/host', hostRoutes);

// const slotRoutes = require('./routes/hostRoutes');///// these are also for host so hostRoutes should be merged with this
// app.use('/api/slots', slotRoutes);

// 404 handler
app.use((req, res, next) => {
  next(createError(404, 'Route Not Found'));
});

// Start server
const PORT = process.env.PORT || 5600;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
