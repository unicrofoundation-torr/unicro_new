const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('./admin');

// Get all footer settings (public)
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM footer_settings WHERE is_active = true ORDER BY section, sort_order'
    );
    
    // Group settings by section
    const groupedSettings = {};
    rows.forEach(setting => {
      if (!groupedSettings[setting.section]) {
        groupedSettings[setting.section] = {};
      }
      groupedSettings[setting.section][setting.setting_key] = {
        value: setting.setting_value,
        type: setting.setting_type,
        description: setting.description
      };
    });
    
    res.json(groupedSettings);
  } catch (error) {
    console.error('Error fetching footer settings:', error);
    res.status(500).json({ error: 'Failed to fetch footer settings' });
  }
});

// Get all footer settings (admin)
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT * FROM footer_settings ORDER BY section, sort_order'
    );
    
    // Group settings by section
    const groupedSettings = {};
    rows.forEach(setting => {
      if (!groupedSettings[setting.section]) {
        groupedSettings[setting.section] = {};
      }
      groupedSettings[setting.section][setting.setting_key] = {
        id: setting.id,
        value: setting.setting_value,
        type: setting.setting_type,
        section: setting.section,
        sort_order: setting.sort_order,
        is_active: setting.is_active,
        description: setting.description
      };
    });
    
    res.json(groupedSettings);
  } catch (error) {
    console.error('Error fetching footer settings:', error);
    res.status(500).json({ error: 'Failed to fetch footer settings' });
  }
});

// Get single footer setting
router.get('/:key', authenticateToken, async (req, res) => {
  try {
    const { key } = req.params;
    const [rows] = await db.execute(
      'SELECT * FROM footer_settings WHERE setting_key = ?',
      [key]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Footer setting not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    console.error('Error fetching footer setting:', error);
    res.status(500).json({ error: 'Failed to fetch footer setting' });
  }
});

// Create new footer setting
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { setting_key, setting_value, setting_type, section, sort_order, description } = req.body;
    
    if (!setting_key || !section) {
      return res.status(400).json({ error: 'Setting key and section are required' });
    }
    
    const [result] = await db.execute(
      'INSERT INTO footer_settings (setting_key, setting_value, setting_type, section, sort_order, description) VALUES (?, ?, ?, ?, ?, ?)',
      [setting_key, setting_value || '', setting_type || 'text', section, sort_order || 0, description || '']
    );
    
    res.status(201).json({ 
      id: result.insertId, 
      message: 'Footer setting created successfully' 
    });
  } catch (error) {
    console.error('Error creating footer setting:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      res.status(400).json({ error: 'Footer setting with this key already exists' });
    } else {
      res.status(500).json({ error: 'Failed to create footer setting' });
    }
  }
});

// Update footer setting
router.put('/:key', authenticateToken, async (req, res) => {
  try {
    const { key } = req.params;
    const { setting_value, setting_type, section, sort_order, is_active, description } = req.body;
    
    const [result] = await db.execute(
      'UPDATE footer_settings SET setting_value = ?, setting_type = ?, section = ?, sort_order = ?, is_active = ?, description = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?',
      [setting_value, setting_type, section, sort_order, is_active, description, key]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Footer setting not found' });
    }
    
    res.json({ message: 'Footer setting updated successfully' });
  } catch (error) {
    console.error('Error updating footer setting:', error);
    res.status(500).json({ error: 'Failed to update footer setting' });
  }
});

// Delete footer setting
router.delete('/:key', authenticateToken, async (req, res) => {
  try {
    const { key } = req.params;
    
    const [result] = await db.execute(
      'DELETE FROM footer_settings WHERE setting_key = ?',
      [key]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Footer setting not found' });
    }
    
    res.json({ message: 'Footer setting deleted successfully' });
  } catch (error) {
    console.error('Error deleting footer setting:', error);
    res.status(500).json({ error: 'Failed to delete footer setting' });
  }
});

// Bulk update footer settings
router.put('/bulk/update', authenticateToken, async (req, res) => {
  try {
    const { settings } = req.body;
    
    if (!Array.isArray(settings)) {
      return res.status(400).json({ error: 'Settings must be an array' });
    }
    
    const updatePromises = settings.map(setting => {
      return db.execute(
        'UPDATE footer_settings SET setting_value = ?, updated_at = CURRENT_TIMESTAMP WHERE setting_key = ?',
        [setting.value, setting.key]
      );
    });
    
    await Promise.all(updatePromises);
    
    res.json({ message: 'Footer settings updated successfully' });
  } catch (error) {
    console.error('Error bulk updating footer settings:', error);
    res.status(500).json({ error: 'Failed to update footer settings' });
  }
});

module.exports = router;
