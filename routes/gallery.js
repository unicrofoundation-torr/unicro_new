const express = require('express');
const router = express.Router();
const db = require('../config/database');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { authenticateToken } = require('./admin');

// Determine upload directory based on environment
// In production (cPanel): files should go to ~/public_html/uploads/gallery/
// In development: files go to client/public/uploads/gallery/
const getUploadDir = () => {
  const os = require('os');
  const homeDir = process.env.HOME || process.env.USERPROFILE || os.homedir();
  const cwd = process.cwd();
  
  // Production path: ~/public_html/uploads/gallery (absolute path)
  const productionPath = path.join(homeDir, 'public_html/uploads/gallery');
  
  // Development path: client/public/uploads/gallery (relative to project)
  const devPath = path.join(cwd, 'client/public/uploads/gallery');
  
  // Check if we're in production
  // Criteria: 
  // 1. public_html exists in home directory, OR
  // 2. current working directory contains 'nodejs' (cPanel structure), OR
  // 3. NODE_ENV is production
  const isProduction = 
    fs.existsSync(path.join(homeDir, 'public_html')) ||
    cwd.includes('nodejs') ||
    process.env.NODE_ENV === 'production';
  
  if (isProduction) {
    // Production: use absolute path to public_html
    if (!fs.existsSync(productionPath)) {
      fs.mkdirSync(productionPath, { recursive: true });
    }
    console.log(`[Gallery] Using PRODUCTION upload directory: ${productionPath}`);
    return productionPath;
  } else {
    // Development: use relative path
    if (!fs.existsSync(devPath)) {
      fs.mkdirSync(devPath, { recursive: true });
    }
    console.log(`[Gallery] Using DEVELOPMENT upload directory: ${devPath}`);
    return devPath;
  }
};

const uploadDirPath = getUploadDir();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Ensure directory exists before saving
    try {
      if (!fs.existsSync(uploadDirPath)) {
        fs.mkdirSync(uploadDirPath, { recursive: true });
      }
      cb(null, uploadDirPath);
    } catch (error) {
      console.error('Error creating upload directory:', error);
      // Fallback - try to create parent directories
      try {
        fs.mkdirSync(uploadDirPath, { recursive: true });
        cb(null, uploadDirPath);
      } catch (err) {
        console.error('Failed to create upload directory:', err);
        cb(new Error('Failed to create upload directory'), null);
      }
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit for gallery images and videos
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image and video files are allowed'), false);
    }
  }
});

// Get all gallery images (public)
router.get('/', async (req, res) => {
  try {
    const { category } = req.query;
    let query = 'SELECT * FROM gallery WHERE is_active = true';
    let params = [];
    
    if (category && category !== 'all') {
      query += ' AND category = ?';
      params.push(category);
    }
    
    query += ' ORDER BY sort_order, created_at DESC';
    
    const [rows] = await db.execute(query, params);
    res.json(rows);
  } catch (error) {
    console.error('Error fetching gallery images:', error);
    res.status(500).json({ error: 'Failed to fetch gallery images' });
  }
});

// Get all gallery images (admin)
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM gallery ORDER BY sort_order, created_at DESC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching gallery images:', error);
    res.status(500).json({ error: 'Failed to fetch gallery images' });
  }
});

// Get single gallery image
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.execute(
      'SELECT * FROM gallery WHERE id = ?',
      [id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Gallery image not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching gallery image:', error);
    res.status(500).json({ error: 'Failed to fetch gallery image' });
  }
});

// Create new gallery image/video
router.post('/', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    // Check for multer errors
    if (req.fileValidationError) {
      return res.status(400).json({ 
        error: 'File validation failed',
        details: req.fileValidationError
      });
    }
    
    const { title, description, image_alt, category, sort_order, is_active } = req.body;
    
    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }
    
    if (!req.file) {
      return res.status(400).json({ error: 'File is required. Please select a file to upload.' });
    }
    
    const fileUrl = `/uploads/gallery/${req.file.filename}`;
    const fileType = req.file.mimetype.startsWith('video/') ? 'video' : 'image';
    
    console.log(`[Gallery] Saving file to: ${uploadDirPath}`);
    console.log(`[Gallery] File saved as: ${req.file.filename}`);
    
    const [result] = await db.execute(
      'INSERT INTO gallery (title, description, image_url, image_alt, category, sort_order, is_active, file_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [title, description || '', fileUrl, image_alt || '', category || 'general', sort_order || 0, is_active !== 'false', fileType]
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Gallery item created successfully',
      filePath: uploadDirPath,
      fileUrl: fileUrl
    });
  } catch (error) {
    console.error('Error creating gallery item:', error);
    console.error('Error stack:', error.stack);
    // Return more detailed error message
    const errorMessage = error.message || 'Failed to create gallery item';
    res.status(500).json({ 
      error: 'Failed to create gallery item',
      details: process.env.NODE_ENV === 'development' ? errorMessage : 'Please check server logs for details'
    });
  }
});

// Error handler for multer
router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: 'File too large. Maximum size is 50MB.' });
    }
    return res.status(400).json({ error: 'File upload error', details: error.message });
  }
  if (error) {
    return res.status(400).json({ error: 'File upload failed', details: error.message });
  }
  next();
});

// Update gallery image/video
router.put('/:id', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    const { id } = req.params;
    const { title, description, image_alt, category, sort_order, is_active } = req.body;
    
    // Get existing entry to preserve existing file URL if new one isn't uploaded
    const [existingRows] = await db.execute(
      'SELECT image_url, file_type FROM gallery WHERE id = ?',
      [id]
    );
    
    if (existingRows.length === 0) {
      return res.status(404).json({ error: 'Gallery item not found' });
    }
    
    const existingEntry = existingRows[0];
    
    const fileUrl = req.file ? 
      `/uploads/gallery/${req.file.filename}` : 
      existingEntry.image_url;
    
    const fileType = req.file ? 
      (req.file.mimetype.startsWith('video/') ? 'video' : 'image') :
      existingEntry.file_type;
    
    const [result] = await db.execute(
      'UPDATE gallery SET title = ?, description = ?, image_url = ?, image_alt = ?, category = ?, sort_order = ?, is_active = ?, file_type = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [title, description, fileUrl, image_alt, category, sort_order, is_active !== 'false', fileType, id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Gallery item not found' });
    }
    
    res.json({ message: 'Gallery item updated successfully' });
  } catch (error) {
    console.error('Error updating gallery item:', error);
    res.status(500).json({ error: 'Failed to update gallery item' });
  }
});

// Delete gallery image
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await db.execute(
      'DELETE FROM gallery WHERE id = ?',
      [id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Gallery image not found' });
    }
    
    res.json({ message: 'Gallery image deleted successfully' });
  } catch (error) {
    console.error('Error deleting gallery image:', error);
    res.status(500).json({ error: 'Failed to delete gallery image' });
  }
});

// Update sort order
router.put('/sort/update', authenticateToken, async (req, res) => {
  try {
    const { images } = req.body;
    
    if (!Array.isArray(images)) {
      return res.status(400).json({ error: 'Images must be an array' });
    }
    
    const updatePromises = images.map(image => {
      return db.execute(
        'UPDATE gallery SET sort_order = ? WHERE id = ?',
        [image.sort_order, image.id]
      );
    });
    
    await Promise.all(updatePromises);
    
    res.json({ message: 'Sort order updated successfully' });
  } catch (error) {
    console.error('Error updating sort order:', error);
    res.status(500).json({ error: 'Failed to update sort order' });
  }
});

// Get gallery categories
router.get('/categories/list', async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT DISTINCT category FROM gallery WHERE is_active = true ORDER BY category'
    );
    const categories = rows.map(row => row.category);
    res.json(categories);
  } catch (error) {
    console.error('Error fetching gallery categories:', error);
    res.status(500).json({ error: 'Failed to fetch gallery categories' });
  }
});

module.exports = router;
