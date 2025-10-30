const express = require('express');
const router = express.Router();
const db = require('../config/database');
const multer = require('multer');
const path = require('path');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'client/public/uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'slider-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|gif|svg/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  const jwt = require('jsonwebtoken');
  jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Get all slider images (public)
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM slider_images WHERE is_active = TRUE ORDER BY sort_order ASC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching slider images:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all slider images (admin only)
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM slider_images ORDER BY sort_order ASC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching admin slider images:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single slider image
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.execute(
      'SELECT * FROM slider_images WHERE id = ?',
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Slider image not found' });
    }

    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching slider image:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new slider image (admin only)
router.post('/', authenticateToken, upload.single('image'), async (req, res) => {
  try {
    const { title, description, button_text, button_url, sort_order, is_active } = req.body;
    
    if (!title || !req.file) {
      return res.status(400).json({ error: 'Title and image are required' });
    }

    const image_url = `/uploads/${req.file.filename}`;

    const [result] = await db.execute(
      'INSERT INTO slider_images (title, description, image_url, button_text, button_url, sort_order, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [title, description || '', image_url, button_text || '', button_url || '', sort_order || 0, is_active !== 'false']
    );

    res.status(201).json({ 
      id: result.insertId, 
      message: 'Slider image created successfully',
      image_url: image_url
    });
  } catch (error) {
    console.error('Error creating slider image:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update slider image (admin only)
router.put('/:id', authenticateToken, upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, button_text, button_url, sort_order, is_active } = req.body;

    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }

    let updateQuery = 'UPDATE slider_images SET title = ?, description = ?, button_text = ?, button_url = ?, sort_order = ?, is_active = ?';
    let queryParams = [title, description || '', button_text || '', button_url || '', sort_order || 0, is_active !== 'false'];

    // If new image is uploaded, update image_url
    if (req.file) {
      updateQuery += ', image_url = ?';
      queryParams.push(`/uploads/${req.file.filename}`);
    }

    updateQuery += ' WHERE id = ?';
    queryParams.push(id);

    const [result] = await db.execute(updateQuery, queryParams);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Slider image not found' });
    }

    res.json({ message: 'Slider image updated successfully' });
  } catch (error) {
    console.error('Error updating slider image:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete slider image (admin only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await db.execute(
      'DELETE FROM slider_images WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Slider image not found' });
    }

    res.json({ message: 'Slider image deleted successfully' });
  } catch (error) {
    console.error('Error deleting slider image:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update sort order (admin only)
router.put('/sort/update', authenticateToken, async (req, res) => {
  try {
    const { images } = req.body;

    if (!Array.isArray(images)) {
      return res.status(400).json({ error: 'Images array is required' });
    }

    // Update sort order for each image
    for (const image of images) {
      await db.execute(
        'UPDATE slider_images SET sort_order = ? WHERE id = ?',
        [image.sort_order, image.id]
      );
    }

    res.json({ message: 'Sort order updated successfully' });
  } catch (error) {
    console.error('Error updating sort order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
