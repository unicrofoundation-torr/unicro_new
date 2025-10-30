const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

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

// Admin login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    const [rows] = await db.execute('SELECT * FROM admin_users WHERE username = ?', [username]);
    
    if (rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = rows[0];
    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, username: user.username, role: user.role },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Error during login:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all pages (admin)
router.get('/pages', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM pages ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching pages:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all navigation links (admin)
router.get('/navigation', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT nl.*, p.title as page_title, p.slug as page_slug 
      FROM navigation_links nl 
      LEFT JOIN pages p ON nl.page_id = p.id 
      ORDER BY nl.sort_order ASC
    `);
    res.json(rows);
  } catch (error) {
    console.error('Error fetching navigation links:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get all pages for dropdown (admin)
router.get('/pages/dropdown', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT id, title, slug FROM pages WHERE is_published = true ORDER BY title');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching pages dropdown:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Verify token
router.get('/verify', authenticateToken, (req, res) => {
  res.json({ valid: true, user: req.user });
});

module.exports = { router, authenticateToken };
