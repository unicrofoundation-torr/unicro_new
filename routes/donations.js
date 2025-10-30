const express = require('express');
const router = express.Router();
const db = require('../config/database');
const axios = require('axios');
const crypto = require('crypto');
const { authenticateToken } = require('./admin');

// Helpers
async function ensureTables() {
  await db.execute(`
    CREATE TABLE IF NOT EXISTS donors (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL,
      phone VARCHAR(50) DEFAULT '',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  await db.execute(`
    CREATE TABLE IF NOT EXISTS donations (
      id INT AUTO_INCREMENT PRIMARY KEY,
      donor_id INT NOT NULL,
      amount INT NOT NULL,
      currency VARCHAR(10) DEFAULT 'INR',
      purpose VARCHAR(255) DEFAULT '',
      note VARCHAR(255) DEFAULT '',
      cf_order_id VARCHAR(100),
      cf_order_token VARCHAR(255),
      cf_payment_id VARCHAR(100),
      status ENUM('created','paid','failed','refunded') DEFAULT 'created',
      metadata JSON,
      receipt_number VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX (donor_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
}

function cfBaseUrl() {
  const env = (process.env.CASHFREE_ENV || 'TEST').toUpperCase();
  return env === 'PROD' ? 'https://api.cashfree.com/pg' : 'https://sandbox.cashfree.com/pg';
}

async function createCashfreeOrder({ orderId, amount, customer }) {
  const url = `${cfBaseUrl()}/orders`;
  const appId = process.env.CASHFREE_APP_ID;
  const secret = process.env.CASHFREE_SECRET_KEY;
  const headers = {
    'x-client-id': appId,
    'x-client-secret': secret,
    'x-api-version': '2022-09-01',
    'Content-Type': 'application/json'
  };
  const body = {
    order_id: orderId,
    order_amount: (amount / 100).toFixed(2),
    order_currency: 'INR',
    customer_details: {
      customer_id: `${customer.id}`,
      customer_email: customer.email,
      customer_phone: customer.phone || '9999999999',
      customer_name: customer.name
    },
    order_meta: {
      return_url: process.env.CASHFREE_RETURN_URL || 'http://localhost:3000/donate?cf_return=1&order_id={order_id}',
      notify_url: process.env.CASHFREE_NOTIFY_URL || 'http://localhost:5000/api/donations/cf/webhook'
    }
  };
  const { data } = await axios.post(url, body, { headers });
  return data; // contains order_token, order_id
}

// Create order
router.post('/cf/order', async (req, res) => {
  try {
    await ensureTables();
    const { amount, name, email, phone, purpose, note } = req.body;
    const amountPaise = Math.round(Number(amount) * 100);
    if (!amountPaise || amountPaise < 100) {
      return res.status(400).json({ error: 'Amount must be at least 1.00' });
    }
    if (!name || !email) return res.status(400).json({ error: 'Name and email are required' });

    // Upsert donor by email
    const [existing] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [email]);
    let donorId;
    if (existing.length) {
      donorId = existing[0].id;
      await db.execute('UPDATE donors SET name = ?, phone = ? WHERE id = ?', [name, phone || '', donorId]);
    } else {
      const [ins] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', [name, email, phone || '']);
      donorId = ins.insertId;
    }

    // Create donation row
    const [donIns] = await db.execute(
      'INSERT INTO donations (donor_id, amount, currency, purpose, note, status, metadata) VALUES (?, ?, ?, ?, ?, "created", JSON_OBJECT())',
      [donorId, amountPaise, 'INR', purpose || '', note || '']
    );
    const donationId = donIns.insertId;
    const orderId = `DON-${donationId}-${Date.now()}`;

    // Call Cashfree
    const order = await createCashfreeOrder({ orderId, amount: amountPaise, customer: { id: donorId, name, email, phone } });

    await db.execute('UPDATE donations SET cf_order_id = ?, cf_order_token = ? WHERE id = ?', [order.order_id || orderId, order.order_token, donationId]);

    res.json({ donationId, cfOrderId: order.order_id || orderId, orderToken: order.order_token, amount: amountPaise });
  } catch (error) {
    console.error('CF create order error:', error?.response?.data || error.message);
    res.status(500).json({ error: 'Failed to create order' });
  }
});

// Verify order (server-side status check)
router.post('/cf/verify', async (req, res) => {
  try {
    const { donationId, cfOrderId } = req.body;
    if (!donationId || !cfOrderId) return res.status(400).json({ error: 'donationId and cfOrderId are required' });

    const url = `${cfBaseUrl()}/orders/${cfOrderId}`;
    const headers = {
      'x-client-id': process.env.CASHFREE_APP_ID,
      'x-client-secret': process.env.CASHFREE_SECRET_KEY,
      'x-api-version': '2022-09-01'
    };
    const { data } = await axios.get(url, { headers });
    const status = (data.order_status || '').toLowerCase();

    if (status === 'paid') {
      await db.execute('UPDATE donations SET status = "paid", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
      return res.json({ status: 'paid' });
    }
    if (status === 'failed') {
      await db.execute('UPDATE donations SET status = "failed", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
      return res.json({ status: 'failed' });
    }
    return res.json({ status });
  } catch (error) {
    console.error('CF verify error:', error?.response?.data || error.message);
    res.status(500).json({ error: 'Verification failed' });
  }
});

// Webhook
router.post('/cf/webhook', express.raw({ type: '*/*' }), async (req, res) => {
  try {
    // Verify signature
    const signature = req.header('x-webhook-signature');
    const secret = process.env.CASHFREE_WEBHOOK_SECRET || '';
    const body = req.body instanceof Buffer ? req.body.toString('utf8') : JSON.stringify(req.body);
    const computed = crypto.createHmac('sha256', secret).update(body).digest('base64');
    if (signature !== computed) {
      return res.status(401).send('Invalid signature');
    }

    const payload = JSON.parse(body);
    const event = payload?.type || payload?.event;
    const orderId = payload?.data?.order?.order_id || payload?.data?.order_id;

    if (orderId) {
      const [rows] = await db.execute('SELECT id FROM donations WHERE cf_order_id = ? LIMIT 1', [orderId]);
      if (rows.length) {
        const donationId = rows[0].id;
        if (event && event.toLowerCase().includes('payment') && payload?.data?.payment?.payment_status) {
          const st = payload.data.payment.payment_status.toLowerCase();
          if (st === 'success' || st === 'paid') {
            await db.execute('UPDATE donations SET status = "paid", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
          } else if (st === 'failed') {
            await db.execute('UPDATE donations SET status = "failed", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
          }
        }
      }
    }
    res.json({ received: true });
  } catch (error) {
    console.error('CF webhook error:', error.message);
    res.status(500).json({ error: 'Webhook handling failed' });
  }
});

// Admin list
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const [rows] = await db.execute(`
      SELECT d.id, d.amount, d.currency, d.status, d.cf_order_id, d.created_at,
             r.name, r.email, r.phone
      FROM donations d JOIN donors r ON d.donor_id = r.id
      ORDER BY d.created_at DESC
      LIMIT 500
    `);
    res.json(rows);
  } catch (e) {
    console.error('Donations list error:', e.message);
    res.status(500).json({ error: 'Failed to fetch donations' });
  }
});

module.exports = router;


