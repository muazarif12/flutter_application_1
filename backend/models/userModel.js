const pool = require('../config/db');

exports.findUserByEmail = async (email) => {
  const res = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
  return res.rows[0];
};

exports.createUser = async ({ username, email, password, full_name, phone_number, role }) => {
  const res = await pool.query(
    `INSERT INTO users (username, email, password, full_name, phone_number, role)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, username, email, full_name, phone_number, role, created_at`,
    [username, email, password, full_name, phone_number, role]
  );
  return res.rows[0];
};