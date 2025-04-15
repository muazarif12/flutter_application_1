const multer = require('multer');
const path = require('path');


// Create a new arena
exports.createArena = async (req, res) => {
    const {
        name,
        description,
        sport_offered,
        location,
        contact_number,
        pricing,
        additional_fee,
        facilities, // Facilities array
    } = req.body;
    // print 
    console.log(req.body);
    //console.log(req);
    const owner_id = req.user.id; // Get the user ID from the authenticated JWT token
    console.log('working till here');

    try {
        // Insert the arena details into the database
        const result = await pool.query(
            `INSERT INTO arenas (name, description, sport_offered, location, contact_number, pricing, additional_fee, owner_id, facilities)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
         RETURNING id, name, description, sport_offered, location, contact_number, pricing, additional_fee, owner_id, facilities, created_at`,
            [
                name,
                description,
                sport_offered,
                location,
                contact_number,
                pricing,
                additional_fee,
                owner_id, // owner_id comes from the authenticated user
                facilities,
            ]
        );

        const newArena = result.rows[0];

        // Respond with the newly created arena
        res.status(201).json({
            message: 'Arena created successfully',
            arena: newArena,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create arena' });
    }
};
// Get all arenas (optional, can be filtered by user)
exports.getAllArenas = async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM arenas');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch arenas' });
    }
};

// Configure multer for file upload
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/'); // Store uploaded files in the 'uploads' directory
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname)); // Name the file uniquely
    }
});

const upload = multer({ storage: storage });

// Route to upload media for an arena
exports.uploadArenaMedia = [
    upload.array('mediaFiles', 5), // Allow up to 5 files
    async (req, res) => {
        const arenaId = req.body.arena_id;
        const mediaFiles = req.files; // The uploaded files

        if (!mediaFiles || mediaFiles.length === 0) {
            return res.status(400).json({ error: 'No files uploaded' });
        }

        try {
            // Insert media file paths into the database
            const mediaPaths = mediaFiles.map(file => file.path);

            // Insert media file paths into the media table
            for (const path of mediaPaths) {
                await pool.query(
                    `INSERT INTO media (arena_id, media_type, file_path)
             VALUES ($1, $2, $3)`,
                    [arenaId, 'image', path] // Assuming the media type is 'image'
                );
            }

            res.status(200).json({ message: 'Media uploaded successfully', media: mediaPaths });
        } catch (err) {
            console.error(err);
            res.status(500).json({ error: 'Failed to upload media' });
        }
    }
];


