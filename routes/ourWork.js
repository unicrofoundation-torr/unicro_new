const express = require('express');
const router = express.Router();
const db = require('../config/database');
const multer = require('multer');
const path = require('path');
const { authenticateToken } = require('./admin');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'client/public/uploads/our-work/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  }
});

// Get all our work entries (public)
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM our_work WHERE is_active = true ORDER BY sort_order, created_at DESC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching our work:', error);
    res.status(500).json({ error: 'Failed to fetch our work entries' });
  }
});

// Get all our work entries (admin)
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM our_work ORDER BY sort_order, created_at DESC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching our work:', error);
    res.status(500).json({ error: 'Failed to fetch our work entries' });
  }
});

// Get single our work entry
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.execute(
      'SELECT * FROM our_work WHERE id = ?',
      [id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Our work entry not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching our work entry:', error);
    res.status(500).json({ error: 'Failed to fetch our work entry' });
  }
});

// Create new our work entry
router.post('/', authenticateToken, upload.fields([
  { name: 'before_image', maxCount: 1 },
  { name: 'after_image', maxCount: 1 }
]), async (req, res) => {
  try {
    const { title, description, before_image_alt, after_image_alt, sort_order, is_active } = req.body;
    
    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }
    
    const beforeImageUrl = req.files?.before_image ? `/uploads/our-work/${req.files.before_image[0].filename}` : null;
    const afterImageUrl = req.files?.after_image ? `/uploads/our-work/${req.files.after_image[0].filename}` : null;
    
    const [result] = await db.execute(
      'INSERT INTO our_work (title, description, before_image_url, after_image_url, before_image_alt, after_image_alt, sort_order, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [title, description || '', beforeImageUrl, afterImageUrl, before_image_alt || '', after_image_alt || '', sort_order || 0, is_active !== 'false']
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Our work entry created successfully' 
    });
  } catch (error) {
    console.error('Error creating our work entry:', error);
    res.status(500).json({ error: 'Failed to create our work entry' });
  }
});

// Update our work entry
router.put('/:id', authenticateToken, upload.fields([
  { name: 'before_image', maxCount: 1 },
  { name: 'after_image', maxCount: 1 }
]), async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, before_image_alt, after_image_alt, sort_order, is_active } = req.body;
    
    // Get existing entry to preserve existing image URLs if new ones aren't uploaded
    const [existingRows] = await db.execute(
      'SELECT before_image_url, after_image_url FROM our_work WHERE id = ?',
      [id]
    );
    
    if (existingRows.length === 0) {
      return res.status(404).json({ error: 'Our work entry not found' });
    }
    
    const existingEntry = existingRows[0];
    
    const beforeImageUrl = req.files?.before_image ? 
      `/uploads/our-work/${req.files.before_image[0].filename}` : 
      existingEntry.before_image_url;
    
    const afterImageUrl = req.files?.after_image ? 
      `/uploads/our-work/${req.files.after_image[0].filename}` : 
      existingEntry.after_image_url;
    
    const [result] = await db.execute(
      'UPDATE our_work SET title = ?, description = ?, before_image_url = ?, after_image_url = ?, before_image_alt = ?, after_image_alt = ?, sort_order = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [title, description, beforeImageUrl, afterImageUrl, before_image_alt, after_image_alt, sort_order, is_active !== 'false', id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Our work entry not found' });
    }
    
    res.json({ message: 'Our work entry updated successfully' });
  } catch (error) {
    console.error('Error updating our work entry:', error);
    res.status(500).json({ error: 'Failed to update our work entry' });
  }
});

// Delete our work entry
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await db.execute(
      'DELETE FROM our_work WHERE id = ?',
      [id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Our work entry not found' });
    }
    
    res.json({ message: 'Our work entry deleted successfully' });
  } catch (error) {
    console.error('Error deleting our work entry:', error);
    res.status(500).json({ error: 'Failed to delete our work entry' });
  }
});

// Update sort order
router.put('/sort/update', authenticateToken, async (req, res) => {
  try {
    const { entries } = req.body;
    
    if (!Array.isArray(entries)) {
      return res.status(400).json({ error: 'Entries must be an array' });
    }
    
    const updatePromises = entries.map(entry => {
      return db.execute(
        'UPDATE our_work SET sort_order = ? WHERE id = ?',
        [entry.sort_order, entry.id]
      );
    });
    
    await Promise.all(updatePromises);
    
    res.json({ message: 'Sort order updated successfully' });
  } catch (error) {
    console.error('Error updating sort order:', error);
    res.status(500).json({ error: 'Failed to update sort order' });
  }
});

module.exports = router;
