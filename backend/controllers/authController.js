const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { findUserByEmail, createUser, updateUserGoogleId } = require('../models/userModel');
const { OAuth2Client } = require('google-auth-library');
require('dotenv').config();

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

exports.registerUser = async (req, res) => {
  const { username, email, password, full_name, phone_number } = req.body;

  try {
    // Ensure email is unique
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Ensure password is provided for traditional registration
    if (!password) {
      return res.status(400).json({ error: 'Password is required for registration' });
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create the new user
    const newUser = await createUser({
      username,
      email,
      password: hashedPassword,
      full_name,
      phone_number,
      role: 'user',
    });

    res.status(201).json({
      message: 'Registration successful',
      user: {
        id: newUser.id,
        username: newUser.username,
        email: newUser.email,
        full_name: newUser.full_name,
        phone_number: newUser.phone_number,
        created_at: newUser.created_at,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Registration failed' });
  }
};

exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Check if the password is correct
    if (user.password) {
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({ error: 'Invalid credentials' });
      }
    }

    // Generate a JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({
      message: 'Login successful',
      token,
      role: user.role,
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Login failed' });
  }
};

// Google Sign-In
exports.googleSignIn = async (req, res) => {
  const { token1 } = req.body; // The token received from the client
 
  try {
    // Verify the Google ID token
    const ticket = await client.verifyIdToken({ // Verify the token
      idToken: token1,  // The token received from the client
      audience: process.env.GOOGLE_CLIENT_ID, // Specify the CLIENT_ID of the app that accesses the backend
    });

    const payload = ticket.getPayload(); // Get the payload from the token
    const email = payload.email;  
    const googleId = payload.sub;

    // Check if the user exists
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      // User exists, update with Google ID
      if (!existingUser.google_id) {
        await updateUserGoogleId(existingUser.id, googleId);
      }
      const token = jwt.sign(
        { id: existingUser.id, email: existingUser.email, role: existingUser.role },
        process.env.JWT_SECRET,
        { expiresIn: '1d' }
      );

      return res.json({
        message: 'Google login successful',
        token,
        user: {
          id: existingUser.id,
          email: existingUser.email,
          username: existingUser.username,
        },
      });
    }

    // Create a new user with Google login
    const newUser = await createUser({
      username: payload.name,
      email: email,
      password: null,  // No password needed for social logins
      full_name: payload.name,
      phone_number: '', // Optional
      role: 'user',
      google_id: googleId,  // Save the Google ID for future use
    });

    const token = jwt.sign(
      { id: newUser.id, email: newUser.email, role: newUser.role },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({
      message: 'Google login successful',
      token,
      user: {
        id: newUser.id,
        email: newUser.email,
        username: newUser.username,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Google login failed' });
  }
};
