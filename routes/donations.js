const express = require('express');
const router = express.Router();
const db = require('../config/database');
const axios = require('axios');
const crypto = require('crypto');
const Razorpay = require('razorpay');
const { authenticateToken } = require('./admin');

// Initialize Razorpay
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || '',
  key_secret: process.env.RAZORPAY_KEY_SECRET || ''
});

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
      cycle VARCHAR(20) DEFAULT 'monthly',
      purpose VARCHAR(255) DEFAULT '',
      note VARCHAR(255) DEFAULT '',
      cf_order_id VARCHAR(100),
      cf_order_token VARCHAR(255),
      cf_payment_id VARCHAR(100),
      razorpay_subscription_id VARCHAR(100),
      razorpay_plan_id VARCHAR(100),
      razorpay_payment_id VARCHAR(100),
      status ENUM('created','paid','failed','refunded','active','paused','cancelled') DEFAULT 'created',
      metadata JSON,
      receipt_number VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX (donor_id),
      INDEX (razorpay_subscription_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  `);
  
  // Add cycle column if it doesn't exist
  try {
    await db.execute(`ALTER TABLE donations ADD COLUMN cycle VARCHAR(20) DEFAULT 'monthly'`);
  } catch (err) {
    // Column already exists, ignore
  }
  
  // Add Razorpay columns if they don't exist
  try {
    await db.execute(`ALTER TABLE donations ADD COLUMN razorpay_subscription_id VARCHAR(100)`);
  } catch (err) {
    // Column already exists, ignore
  }
  try {
    await db.execute(`ALTER TABLE donations ADD COLUMN razorpay_plan_id VARCHAR(100)`);
  } catch (err) {
    // Column already exists, ignore
  }
  try {
    await db.execute(`ALTER TABLE donations ADD COLUMN razorpay_payment_id VARCHAR(100)`);
  } catch (err) {
    // Column already exists, ignore
  }
  
  // Create payment_transactions table to track each recurring payment
  await db.execute(`
    CREATE TABLE IF NOT EXISTS payment_transactions (
      id INT AUTO_INCREMENT PRIMARY KEY,
      donation_id INT NOT NULL,
      razorpay_payment_id VARCHAR(100) NOT NULL,
      razorpay_subscription_id VARCHAR(100),
      amount INT NOT NULL,
      currency VARCHAR(10) DEFAULT 'INR',
      status ENUM('created','authorized','captured','failed','refunded') DEFAULT 'created',
      payment_method VARCHAR(50),
      payment_date TIMESTAMP NULL,
      metadata JSON,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX (donation_id),
      INDEX (razorpay_payment_id),
      INDEX (razorpay_subscription_id),
      FOREIGN KEY (donation_id) REFERENCES donations(id) ON DELETE CASCADE
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

// Update user details when cycle is selected
router.post('/update-user', async (req, res) => {
  try {
    await ensureTables();
    const { name, email, phone, address, cycle } = req.body;
    
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }
    
    // Upsert donor by email
    const [existing] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [email]);
    let donorId;
    if (existing.length) {
      donorId = existing[0].id;
      await db.execute('UPDATE donors SET name = ?, phone = ? WHERE id = ?', [name || '', phone || '', donorId]);
    } else {
      const [ins] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', [name || '', email, phone || '']);
      donorId = ins.insertId;
    }
    
    res.json({ success: true, donorId, message: 'User details updated' });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Failed to update user details' });
  }
});

// Get or create Razorpay plan
async function getOrCreatePlan(amount, cycle) {
  const planName = `Donation ${cycle.charAt(0).toUpperCase() + cycle.slice(1)} - ₹${amount}`;
  
  // Check if plan already exists in database
  try {
    const [existing] = await db.execute(
      'SELECT razorpay_plan_id FROM donations WHERE cycle = ? AND amount = ? AND razorpay_plan_id IS NOT NULL LIMIT 1',
      [cycle, Math.round(amount * 100)]
    );
    
    if (existing.length && existing[0].razorpay_plan_id) {
      try {
        const plan = await razorpay.plans.fetch(existing[0].razorpay_plan_id);
        return plan;
      } catch (error) {
        // Plan doesn't exist in Razorpay, create new one
      }
    }
  } catch (error) {
    console.error('Error checking existing plan:', error);
  }
  
  // Create new plan
  const periodMap = {
    weekly: 'weekly',
    monthly: 'monthly',
    yearly: 'yearly'
  };
  
  const plan = await razorpay.plans.create({
    period: periodMap[cycle],
    interval: 1,
    item: {
      name: planName,
      amount: Math.round(amount * 100), // Convert to paise
      currency: 'INR',
      description: `Recurring donation of ₹${amount} ${cycle}`
    },
    notes: {
      cycle: cycle,
      amount: amount.toString()
    }
  });
  
  return plan;
}

// Create Razorpay subscription
router.post('/razorpay/create-subscription', async (req, res) => {
  try {
    await ensureTables();
    const { amount, name, email, phone, address, cycle } = req.body;
    
    if (!name || !email) {
      return res.status(400).json({ error: 'Name and email are required' });
    }
    
    if (!cycle || !['weekly', 'monthly', 'yearly'].includes(cycle)) {
      return res.status(400).json({ error: 'Valid cycle (weekly/monthly/yearly) is required' });
    }
    
    const amountNum = Number(amount);
    if (!amountNum || amountNum < 1) {
      return res.status(400).json({ error: 'Valid amount is required' });
    }
    
    // Check minimum amount for subscriptions (some gateways require minimum ₹1)
    const amountPaise = Math.round(amountNum * 100);
    if (amountPaise < 100) {
      return res.status(400).json({ error: 'Minimum amount for subscription is ₹1' });
    }
    
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
    
    // Get or create plan
    const plan = await getOrCreatePlan(amountNum, cycle);
    
    // Create subscription
    // Calculate safe total_count to ensure end_time doesn't exceed 30 years (for UPI compatibility)
    // UPI has a limit of 30 years maximum
    const maxYears = 30;
    const secondsIn30Years = maxYears * 365.25 * 24 * 60 * 60; // 30 years in seconds
    
    let safeTotalCount;
    if (cycle === 'weekly') {
      // Weekly: 7 days = 604800 seconds
      // 30 years = ~1565 weeks
      safeTotalCount = Math.floor((maxYears * 365.25) / 7);
    } else if (cycle === 'monthly') {
      // Monthly: 30 years = 360 months
      safeTotalCount = maxYears * 12;
    } else if (cycle === 'yearly') {
      // Yearly: 30 years = 30 payments
      safeTotalCount = maxYears;
    }
    
    // Ensure it's at least 1 and at most 5200 (Razorpay's limit) and doesn't exceed 30 years
    safeTotalCount = Math.max(1, Math.min(safeTotalCount || 100, 5200));
    
    // Use only total_count (Razorpay doesn't allow both end_at and total_count)
    const subscription = await razorpay.subscriptions.create({
      plan_id: plan.id,
      customer_notify: 1,
      total_count: safeTotalCount,
      notes: {
        donor_id: donorId.toString(),
        cycle: cycle,
        address: address || ''
      }
    });
    
    // Create donation record
    const [donIns] = await db.execute(
      'INSERT INTO donations (donor_id, amount, currency, cycle, note, status, razorpay_subscription_id, razorpay_plan_id, metadata) VALUES (?, ?, ?, ?, ?, "created", ?, ?, JSON_OBJECT("subscription", ?))',
      [donorId, Math.round(amountNum * 100), 'INR', cycle, address || '', subscription.id, plan.id, JSON.stringify(subscription)]
    );
    const donationId = donIns.insertId;
    
    res.json({
      success: true,
      donationId,
      subscriptionId: subscription.id,
      planId: plan.id,
      subscription: subscription
    });
  } catch (error) {
    console.error('Razorpay subscription error:', error);
    res.status(500).json({ error: 'Failed to create subscription', details: error.message });
  }
});

// Check if email exists
router.post('/check-email', async (req, res) => {
  try {
    await ensureTables();
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format', exists: false });
    }
    
    const [rows] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [email]);
    return res.json({ exists: rows.length > 0 });
  } catch (error) {
    console.error('Check email error:', error);
    res.status(500).json({ error: 'Failed to check email' });
  }
});

// Create order
router.post('/cf/order', async (req, res) => {
  try {
    await ensureTables();
    const { amount, name, email, phone, purpose, note, cycle } = req.body;
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
      'INSERT INTO donations (donor_id, amount, currency, cycle, purpose, note, status, metadata) VALUES (?, ?, ?, ?, ?, ?, "created", JSON_OBJECT())',
      [donorId, amountPaise, 'INR', cycle || 'monthly', purpose || '', note || '']
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

// Razorpay webhook
router.post('/razorpay/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const signature = req.headers['x-razorpay-signature'];
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || '';
    
    // Verify signature
    const crypto = require('crypto');
    const hash = crypto.createHmac('sha256', webhookSecret).update(JSON.stringify(req.body)).digest('hex');
    
    if (hash !== signature) {
      return res.status(401).json({ error: 'Invalid signature' });
    }
    
    const payload = JSON.parse(req.body.toString());
    const event = payload.event;
    const subscription = payload.payload.subscription?.entity || payload.payload.subscription;
    const payment = payload.payload.payment?.entity || payload.payload.payment;
    
    if (subscription?.id) {
      const [rows] = await db.execute('SELECT id, donor_id FROM donations WHERE razorpay_subscription_id = ? LIMIT 1', [subscription.id]);
      if (rows.length) {
        const donationId = rows[0].id;
        
        if (event === 'subscription.activated' || event === 'subscription.charged') {
          await db.execute('UPDATE donations SET status = "active", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        } else if (event === 'subscription.paused') {
          await db.execute('UPDATE donations SET status = "paused", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        } else if (event === 'subscription.cancelled') {
          await db.execute('UPDATE donations SET status = "cancelled", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        } else if (event === 'payment.failed') {
          await db.execute('UPDATE donations SET status = "failed", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        }
        
        // Track each payment transaction for recurring payments
        if (payment?.id && event === 'subscription.charged') {
          // Check if this transaction already exists (to avoid duplicates)
          const [existingTx] = await db.execute(
            'SELECT id FROM payment_transactions WHERE razorpay_payment_id = ? LIMIT 1',
            [payment.id]
          );
          
          if (existingTx.length === 0) {
            // Create a new payment transaction record
            const paymentAmount = payment.amount || payment.amount_paid || 0;
            const paymentStatus = payment.status || 'captured';
            const paymentMethod = payment.method || payment.payment_method || 'unknown';
            const paymentDate = payment.created_at ? new Date(payment.created_at * 1000) : new Date();
            
            await db.execute(
              `INSERT INTO payment_transactions 
               (donation_id, razorpay_payment_id, razorpay_subscription_id, amount, currency, status, payment_method, payment_date, metadata) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
              [
                donationId,
                payment.id,
                subscription.id,
                paymentAmount,
                payment.currency || 'INR',
                paymentStatus,
                paymentMethod,
                paymentDate,
                JSON.stringify(payment)
              ]
            );
          }
          
          // Also update the donation record with the latest payment ID
          await db.execute('UPDATE donations SET razorpay_payment_id = ? WHERE id = ?', [payment.id, donationId]);
        }
      }
    }
    
    res.json({ received: true });
  } catch (error) {
    console.error('Razorpay webhook error:', error);
    res.status(500).json({ error: 'Webhook handling failed' });
  }
});

// Admin list
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const [rows] = await db.execute(`
      SELECT d.id, d.amount, d.currency, d.cycle, d.status, d.cf_order_id, d.razorpay_subscription_id, d.created_at,
             r.name, r.email, r.phone,
             (SELECT COUNT(*) FROM payment_transactions pt WHERE pt.donation_id = d.id) as transaction_count,
             (SELECT SUM(pt.amount) FROM payment_transactions pt WHERE pt.donation_id = d.id AND pt.status = 'captured') as total_paid
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

// Get payment transactions for a donation
router.get('/admin/transactions/:donationId', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const { donationId } = req.params;
    const [rows] = await db.execute(`
      SELECT pt.*, d.razorpay_subscription_id, r.name as donor_name, r.email as donor_email
      FROM payment_transactions pt
      JOIN donations d ON pt.donation_id = d.id
      JOIN donors r ON d.donor_id = r.id
      WHERE pt.donation_id = ?
      ORDER BY pt.payment_date DESC, pt.created_at DESC
    `, [donationId]);
    res.json(rows);
  } catch (e) {
    console.error('Transactions list error:', e.message);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

// Get all payment transactions
router.get('/admin/transactions', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const [rows] = await db.execute(`
      SELECT pt.*, d.razorpay_subscription_id, d.cycle, r.name as donor_name, r.email as donor_email
      FROM payment_transactions pt
      JOIN donations d ON pt.donation_id = d.id
      JOIN donors r ON d.donor_id = r.id
      ORDER BY pt.payment_date DESC, pt.created_at DESC
      LIMIT 1000
    `);
    res.json(rows);
  } catch (e) {
    console.error('All transactions list error:', e.message);
    res.status(500).json({ error: 'Failed to fetch transactions' });
  }
});

module.exports = router;



