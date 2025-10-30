const express = require('express');
const router = express.Router();
const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'client/public/uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
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

  jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Get all site settings (public)
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM site_settings ORDER BY setting_key');
    
    // Convert array to object for easier frontend usage
    const settings = {};
    rows.forEach(row => {
      settings[row.setting_key] = {
        value: row.setting_value,
        type: row.setting_type,
        description: row.description
      };
    });
    
    res.json(settings);
  } catch (error) {
    console.error('Error fetching site settings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all site settings (admin)
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM site_settings ORDER BY setting_key');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching site settings:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update site setting (admin only)
router.put('/:key', authenticateToken, async (req, res) => {
  try {
    const { key } = req.params;
    const { value } = req.body;

    if (!value) {
      return res.status(400).json({ error: 'Setting value is required' });
    }

    const [result] = await db.execute(
      'UPDATE site_settings SET setting_value = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?',
      [value, key]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Setting not found' });
    }

    res.json({ message: 'Setting updated successfully' });
  } catch (error) {
    console.error('Error updating site setting:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new site setting (admin only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { key, value, type, description } = req.body;

    if (!key || !value) {
      return res.status(400).json({ error: 'Setting key and value are required' });
    }

    const [result] = await db.execute(
      'INSERT INTO site_settings (setting_key, setting_value, setting_type, description) VALUES (?, ?, ?, ?)',
      [key, value, type || 'text', description || '']
    );

    res.status(201).json({ id: result.insertId, message: 'Setting created successfully' });
  } catch (error) {
    console.error('Error creating site setting:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(400).json({ error: 'Setting with this key already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// Delete site setting (admin only)
router.delete('/:key', authenticateToken, async (req, res) => {
  try {
    const { key } = req.params;

    const [result] = await db.execute('DELETE FROM site_settings WHERE setting_key = ?', [key]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Setting not found' });
    }

    res.json({ message: 'Setting deleted successfully' });
  } catch (error) {
    console.error('Error deleting site setting:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Upload logo image (admin only)
router.post('/upload-logo', authenticateToken, upload.single('logo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const filePath = `/uploads/${req.file.filename}`;

    // Update the site_logo setting
    const [result] = await db.execute(
      'UPDATE site_settings SET setting_value = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?',
      [filePath, 'site_logo']
    );

    if (result.affectedRows === 0) {
      // If setting doesn't exist, create it
      await db.execute(
        'INSERT INTO site_settings (setting_key, setting_value, setting_type, description) VALUES (?, ?, ?, ?)',
        ['site_logo', filePath, 'image', 'Main site logo image']
      );
    }

    res.json({ 
      message: 'Logo uploaded successfully',
      filePath: filePath,
      filename: req.file.filename
    });
  } catch (error) {
    console.error('Error uploading logo:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
