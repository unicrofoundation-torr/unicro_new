const express = require('express');
const router = express.Router();
const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

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

// Get all pages
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM pages WHERE is_published = true ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching pages:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get page by slug
router.get('/:slug', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM pages WHERE slug = ? AND is_published = true', [req.params.slug]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Page not found' });
    }
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching page:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new page (admin only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { title, slug, content, meta_description } = req.body;
    
    if (!title || !slug) {
      return res.status(400).json({ error: 'Title and slug are required' });
    }

    const [result] = await db.execute(
      'INSERT INTO pages (title, slug, content, meta_description) VALUES (?, ?, ?, ?)',
      [title, slug, content || '', meta_description || '']
    );

    res.status(201).json({ id: result.insertId, message: 'Page created successfully' });
  } catch (error) {
    console.error('Error creating page:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(400).json({ error: 'Page with this slug already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// Update page (admin only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { title, slug, content, meta_description, is_published } = req.body;
    const pageId = req.params.id;

    const [result] = await db.execute(
      'UPDATE pages SET title = ?, slug = ?, content = ?, meta_description = ?, is_published = ? WHERE id = ?',
      [title, slug, content, meta_description, is_published, pageId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Page not found' });
    }

    res.json({ message: 'Page updated successfully' });
  } catch (error) {
    console.error('Error updating page:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(400).json({ error: 'Page with this slug already exists' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// Delete page (admin only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const pageId = req.params.id;

    const [result] = await db.execute('DELETE FROM pages WHERE id = ?', [pageId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Page not found' });
    }

    res.json({ message: 'Page deleted successfully' });
  } catch (error) {
    console.error('Error deleting page:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
