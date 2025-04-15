const pool = require('../config/db');
// Create a new slot for a specific arena
exports.createArenaSlot = async (req, res) => {
    const { arena_id } = req.params;  // `arena_id` comes from the URL parameter
    const {
      day_of_week,
      start_time,
      end_time,
      duration,  // Duration in minutes (either 30 or 60 minutes)
    } = req.body;
  
    try {
      // Check for overlap before creating the slot
      const overlapCheck = await pool.query(
        `SELECT * FROM arena_slots
         WHERE arena_id = $1 AND day_of_week = $2 AND (
           (start_time <= $3 AND end_time > $3) OR
           (start_time < $4 AND end_time >= $4)
         )`,
        [arena_id, day_of_week, start_time, end_time]
      );
  
      if (overlapCheck.rows.length > 0) {
        return res.status(400).json({ error: 'Slot overlap detected' });
      }
  
      // Create the new slot
      const result = await pool.query(
        `INSERT INTO arena_slots (arena_id, day_of_week, start_time, end_time, duration)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING id, arena_id, day_of_week, start_time, end_time, duration`,
        [arena_id, day_of_week, start_time, end_time, duration]
      );
  
      const newSlot = result.rows[0];
  
      res.status(201).json({
        message: 'Slot created successfully',
        slot: newSlot,
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to create slot' });
    }
  };
  
// Get slots for a specific arena
exports.getSlotsByArena = async (req, res) => {
  const { arena_id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM arena_slots WHERE arena_id = $1', [arena_id]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch slots' });
  }
};
