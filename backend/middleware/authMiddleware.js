const jwt = require('jsonwebtoken');
require('dotenv').config();

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Authorization token missing or invalid' });
  }

  const token = authHeader.split(' ')[1]; // Extract the token from the "Bearer <token>"

  try {
    // Decode the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Check the decoded token structure
    console.log("Decoded Token:", decoded); // Debugging line, check the token structure in your console
    req.user = decoded; // Attach the decoded user data to req.user

    next();
  } catch (err) {
    console.error("Token verification error:", err); // Log error for debugging
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
};

module.exports = authMiddleware;
