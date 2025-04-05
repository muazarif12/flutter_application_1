const pool = require('../config/db');

exports.findUserByEmail = async (email) => {
  const res = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
  return res.rows[0];
};

exports.createUser = async (email, hashedPassword) => {
  const res = await pool.query(
    'INSERT INTO users (email, password, role) VALUES ($1, $2, $3) RETURNING id, email, role',
    [email, hashedPassword, 'user']
  );
  return res.rows[0];
};
