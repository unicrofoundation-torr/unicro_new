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

// Get all navigation links
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT nl.*, p.title as page_title, p.slug as page_slug 
      FROM navigation_links nl 
      LEFT JOIN pages p ON nl.page_id = p.id 
      WHERE nl.is_active = true 
      ORDER BY nl.sort_order ASC
    `);
    res.json(rows);
  } catch (error) {
    console.error('Error fetching navigation links:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new navigation link (admin only)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { title, url, page_id, is_external, sort_order } = req.body;
    
    if (!title || !url) {
      return res.status(400).json({ error: 'Title and URL are required' });
    }

    const [result] = await db.execute(
      'INSERT INTO navigation_links (title, url, page_id, is_external, sort_order) VALUES (?, ?, ?, ?, ?)',
      [title, url, page_id || null, is_external || false, sort_order || 0]
    );

    res.status(201).json({ id: result.insertId, message: 'Navigation link created successfully' });
  } catch (error) {
    console.error('Error creating navigation link:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update navigation link (admin only)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { title, url, page_id, is_external, sort_order, is_active } = req.body;
    const linkId = req.params.id;

    const [result] = await db.execute(
      'UPDATE navigation_links SET title = ?, url = ?, page_id = ?, is_external = ?, sort_order = ?, is_active = ? WHERE id = ?',
      [title, url, page_id, is_external, sort_order, is_active, linkId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Navigation link not found' });
    }

    res.json({ message: 'Navigation link updated successfully' });
  } catch (error) {
    console.error('Error updating navigation link:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete navigation link (admin only)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const linkId = req.params.id;

    const [result] = await db.execute('DELETE FROM navigation_links WHERE id = ?', [linkId]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Navigation link not found' });
    }

    res.json({ message: 'Navigation link deleted successfully' });
  } catch (error) {
    console.error('Error deleting navigation link:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update sort order for multiple links (admin only)
router.put('/sort/update', authenticateToken, async (req, res) => {
  try {
    const { links } = req.body; // Array of {id, sort_order}
    
    if (!Array.isArray(links)) {
      return res.status(400).json({ error: 'Links array is required' });
    }

    const promises = links.map(link => 
      db.execute('UPDATE navigation_links SET sort_order = ? WHERE id = ?', [link.sort_order, link.id])
    );

    await Promise.all(promises);

    res.json({ message: 'Sort order updated successfully' });
  } catch (error) {
    console.error('Error updating sort order:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
