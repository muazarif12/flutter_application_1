const express = require('express');
const router = express.Router();
const { createArena, getAllArenas, uploadArenaMedia } = require('../controllers/arenaController');
const { createArenaSlot, getSlotsByArena } = require('../controllers/slotController');

// Create a new arena (host only)
router.post('/createArena', createArena);

// Get all arenas (optional, can be filtered by user)
router.get('/getAllArenas', getAllArenas);

// Upload media for an arena
router.post('/upload-media', uploadArenaMedia);

// Create a new slot for an arena
router.post('/:arena_id/create', createArenaSlot);

// Get slots for a specific arena
router.get('/:arena_id/slots', getSlotsByArena);

module.exports = router;
