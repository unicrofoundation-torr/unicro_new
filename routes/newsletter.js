const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('./admin');

async function ensureTable() {
  await db.execute(`
    CREATE TABLE IF NOT EXISTS newsletter_subscribers (
      id INT AUTO_INCREMENT PRIMARY KEY,
      email VARCHAR(255) NOT NULL UNIQUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
}

// POST /api/newsletter/subscribe
router.post('/subscribe', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
      return res.status(400).json({ error: 'Valid email is required' });
    }

    await ensureTable();

    await db.execute(
      'INSERT INTO newsletter_subscribers (email) VALUES (?) ON DUPLICATE KEY UPDATE created_at = CURRENT_TIMESTAMP',
      [email]
    );

    return res.json({ message: 'Subscribed successfully' });
  } catch (error) {
    console.error('Newsletter subscribe error:', error);
    return res.status(500).json({ error: 'Failed to subscribe' });
  }
});

module.exports = router;
 
// Admin: list subscribers
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const limit = Math.min(parseInt(req.query.limit || '100', 10), 1000);
    const offset = Math.max(parseInt(req.query.offset || '0', 10), 0);
    const query = `SELECT id, email, created_at FROM newsletter_subscribers ORDER BY created_at DESC LIMIT ${limit} OFFSET ${offset}`;
    const [rows] = await db.execute(query);
    res.json({ items: rows, limit, offset });
  } catch (error) {
    console.error('List subscribers error:', error);
    res.status(500).json({ error: 'Failed to fetch subscribers' });
  }
});

// Admin: export CSV
router.get('/admin/export', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute('SELECT email, created_at FROM newsletter_subscribers ORDER BY created_at DESC');
    const header = 'email,created_at\n';
    const body = rows.map(r => `${r.email},${new Date(r.created_at).toISOString()}`).join('\n');
    const csv = header + body + '\n';
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="subscribers.csv"');
    res.send(csv);
  } catch (error) {
    console.error('Export subscribers error:', error);
    res.status(500).json({ error: 'Failed to export subscribers' });
  }
});


