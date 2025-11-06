const express = require('express');
const router = express.Router();
const db = require('../config/database');
const multer = require('multer');
const path = require('path');
const { authenticateToken } = require('./admin');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'client/public/uploads/blogs/');
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

// Ensure table exists
async function ensureTable() {
  await db.execute(`
    CREATE TABLE IF NOT EXISTS blogs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      slug VARCHAR(255) UNIQUE NOT NULL,
      excerpt TEXT,
      content TEXT NOT NULL,
      image_url VARCHAR(500),
      image_alt VARCHAR(255),
      author VARCHAR(100) DEFAULT 'Admin',
      is_published BOOLEAN DEFAULT TRUE,
      sort_order INT DEFAULT 0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
}

// Generate slug from title
function generateSlug(title) {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

// Get all published blogs (public)
router.get('/', async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute(
      'SELECT id, title, slug, excerpt, image_url, image_alt, author, created_at FROM blogs WHERE is_published = true ORDER BY sort_order, created_at DESC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching blogs:', error);
    res.status(500).json({ error: 'Failed to fetch blogs' });
  }
});

// Get single blog by slug (public)
router.get('/:slug', async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute(
      'SELECT * FROM blogs WHERE slug = ? AND is_published = true',
      [req.params.slug]
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Blog post not found' });
    }
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching blog:', error);
    res.status(500).json({ error: 'Failed to fetch blog' });
  }
});

// Get all blogs (admin)
router.get('/admin/all', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute(
      'SELECT * FROM blogs ORDER BY sort_order, created_at DESC'
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching blogs:', error);
    res.status(500).json({ error: 'Failed to fetch blogs' });
  }
});

// Get single blog by id (admin)
router.get('/admin/:id', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute('SELECT * FROM blogs WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Blog post not found' });
    }
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching blog:', error);
    res.status(500).json({ error: 'Failed to fetch blog' });
  }
});

// Create blog
router.post('/', authenticateToken, upload.single('image'), async (req, res) => {
  try {
    await ensureTable();
    const { title, excerpt, content, image_alt, author, is_published, sort_order } = req.body;
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    // Generate slug from title
    let slug = generateSlug(title);
    
    // Ensure slug is unique
    let slugExists = true;
    let counter = 1;
    let finalSlug = slug;
    while (slugExists) {
      const [existing] = await db.execute('SELECT id FROM blogs WHERE slug = ?', [finalSlug]);
      if (existing.length === 0) {
        slugExists = false;
      } else {
        finalSlug = `${slug}-${counter}`;
        counter++;
      }
    }

    const imageUrl = req.file ? `/uploads/blogs/${req.file.filename}` : null;

    const [result] = await db.execute(
      'INSERT INTO blogs (title, slug, excerpt, content, image_url, image_alt, author, is_published, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [title, finalSlug, excerpt || null, content, imageUrl, image_alt || null, author || 'Admin', is_published === 'true' || is_published === true, sort_order || 0]
    );

    const [newBlog] = await db.execute('SELECT * FROM blogs WHERE id = ?', [result.insertId]);
    res.status(201).json(newBlog[0]);
  } catch (error) {
    console.error('Error creating blog:', error);
    res.status(500).json({ error: 'Failed to create blog' });
  }
});

// Update blog
router.put('/:id', authenticateToken, upload.single('image'), async (req, res) => {
  try {
    await ensureTable();
    const { title, excerpt, content, image_alt, author, is_published, sort_order } = req.body;
    
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    // Get existing blog to preserve slug unless title changed
    const [existing] = await db.execute('SELECT * FROM blogs WHERE id = ?', [req.params.id]);
    if (existing.length === 0) {
      return res.status(404).json({ error: 'Blog post not found' });
    }

    let slug = existing[0].slug;
    // If title changed, generate new slug
    if (title !== existing[0].title) {
      slug = generateSlug(title);
      // Ensure slug is unique (excluding current blog)
      let slugExists = true;
      let counter = 1;
      let finalSlug = slug;
      while (slugExists) {
        const [check] = await db.execute('SELECT id FROM blogs WHERE slug = ? AND id != ?', [finalSlug, req.params.id]);
        if (check.length === 0) {
          slugExists = false;
        } else {
          finalSlug = `${slug}-${counter}`;
          counter++;
        }
      }
      slug = finalSlug;
    }

    let imageUrl = existing[0].image_url;
    if (req.file) {
      imageUrl = `/uploads/blogs/${req.file.filename}`;
    }

    await db.execute(
      'UPDATE blogs SET title = ?, slug = ?, excerpt = ?, content = ?, image_url = ?, image_alt = ?, author = ?, is_published = ?, sort_order = ? WHERE id = ?',
      [title, slug, excerpt || null, content, imageUrl, image_alt || null, author || 'Admin', is_published === 'true' || is_published === true, sort_order || 0, req.params.id]
    );

    const [updated] = await db.execute('SELECT * FROM blogs WHERE id = ?', [req.params.id]);
    res.json(updated[0]);
  } catch (error) {
    console.error('Error updating blog:', error);
    res.status(500).json({ error: 'Failed to update blog' });
  }
});

// Delete blog
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const [result] = await db.execute('DELETE FROM blogs WHERE id = ?', [req.params.id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Blog post not found' });
    }
    
    res.json({ message: 'Blog post deleted successfully' });
  } catch (error) {
    console.error('Error deleting blog:', error);
    res.status(500).json({ error: 'Failed to delete blog' });
  }
});

module.exports = router;

