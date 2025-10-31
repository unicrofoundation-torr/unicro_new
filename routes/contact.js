const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('./admin');

async function ensureTable() {
  await db.execute(`
    CREATE TABLE IF NOT EXISTS contact_messages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL,
      subject VARCHAR(255) DEFAULT '',
      message TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
}

// Public: submit contact form
router.post('/', async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;
    if (!name || !email || !message) {
      return res.status(400).json({ error: 'Name, email and message are required' });
    }
    if (!/^\S+@\S+\.\S+$/.test(email)) {
      return res.status(400).json({ error: 'Valid email is required' });
    }
    await ensureTable();
    await db.execute(
      'INSERT INTO contact_messages (name, email, subject, message) VALUES (?, ?, ?, ?)',
      [name.trim(), email.trim(), (subject || '').trim(), message.trim()]
    );
    res.json({ message: 'Message sent successfully' });
  } catch (error) {
    console.error('Contact submit error:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

// Admin: list messages
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute('SELECT id, name, email, subject, message, created_at FROM contact_messages ORDER BY created_at DESC');
    res.json(rows);
  } catch (error) {
    console.error('Contact list error:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Admin: delete message
router.delete('/admin/:id', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const { id } = req.params;
    const [result] = await db.execute('DELETE FROM contact_messages WHERE id = ?', [id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (error) {
    console.error('Contact delete error:', error);
    res.status(500).json({ error: 'Failed to delete message' });
  }
});

// Admin: export CSV
router.get('/admin/export', authenticateToken, async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await db.execute('SELECT name, email, subject, message, created_at FROM contact_messages ORDER BY created_at DESC');
    const header = 'name,email,subject,message,created_at\n';
    const escape = (s) => '"' + String(s ?? '').replace(/"/g, '""') + '"';
    const body = rows.map(r => [r.name, r.email, r.subject, r.message, new Date(r.created_at).toISOString()].map(escape).join(','));
    const csv = header + body.join('\n') + '\n';
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="contact_messages.csv"');
    res.send(csv);
  } catch (error) {
    console.error('Contact export error:', error);
    res.status(500).json({ error: 'Failed to export messages' });
  }
});

module.exports = router;


