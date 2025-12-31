const express = require('express');
const router = express.Router();
const db = require('../config/database');
const axios = require('axios');
const crypto = require('crypto');
const Razorpay = require('razorpay');
const { authenticateToken } = require('./admin');

// Initialize Razorpay lazily (only when needed)
let razorpay = null;
function getRazorpayInstance() {
  if (!razorpay) {
    razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID || '',
      key_secret: process.env.RAZORPAY_KEY_SECRET || ''
    });
  }
  return razorpay;
}

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
      donor_id INT NULL,
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
  
  // Allow NULL for donor_id (for donations created before payment)
  // This migration is important - it allows creating donations before payment succeeds
  try {
    // Check if column allows NULL first
    const [columnInfo] = await db.execute(`
      SELECT IS_NULLABLE 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'donations' 
      AND COLUMN_NAME = 'donor_id'
    `);
    
    if (columnInfo.length > 0 && columnInfo[0].IS_NULLABLE === 'NO') {
      // Column doesn't allow NULL, modify it
      await db.execute(`ALTER TABLE donations MODIFY COLUMN donor_id INT NULL`);
      console.log('✅ Updated donations table to allow NULL for donor_id');
    }
  } catch (err) {
    // If INFORMATION_SCHEMA query fails, try direct alter (might work)
    try {
      await db.execute(`ALTER TABLE donations MODIFY COLUMN donor_id INT NULL`);
      console.log('✅ Updated donations table to allow NULL for donor_id');
    } catch (alterErr) {
      // Column might already allow NULL or table doesn't exist yet, ignore
      console.log('Note: donor_id column migration skipped (may already allow NULL)');
    }
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
    // Don't create or update donor before payment
    // Donor will be created only after successful payment via webhook
    // This endpoint is kept for backward compatibility but does nothing
    res.json({ success: true, message: 'User details will be saved after payment' });
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
        const plan = await getRazorpayInstance().plans.fetch(existing[0].razorpay_plan_id);
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
  
  const plan = await getRazorpayInstance().plans.create({
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
    
    // Store donor info in subscription notes (will create donation after payment succeeds)
    // Use only total_count (Razorpay doesn't allow both end_at and total_count)
    const subscription = await getRazorpayInstance().subscriptions.create({
      plan_id: plan.id,
      customer_notify: 1,
      total_count: safeTotalCount,
      notes: {
        donor_name: name,
        donor_email: email,
        donor_phone: phone || '',
        donor_address: address || '',
        cycle: cycle,
        amount: amountNum.toString()
      }
    });
    
    // DO NOT create donation record here - wait for payment success via webhook
    // This prevents junk data if user cancels payment
    // Donation record will be created in webhook when subscription.activated or subscription.charged
    
    res.json({
      success: true,
      subscriptionId: subscription.id,
      planId: plan.id,
      subscription: subscription
    });
  } catch (error) {
    console.error('Razorpay subscription error:', error);
    res.status(500).json({ error: 'Failed to create subscription', details: error.message });
  }
});

// Get Razorpay Key ID (public endpoint - key ID is safe to expose)
router.get('/razorpay/key-id', (req, res) => {
  try {
    const keyId = process.env.RAZORPAY_KEY_ID || '';
    if (!keyId) {
      return res.status(500).json({ error: 'Razorpay key not configured' });
    }
    res.json({ keyId });
  } catch (error) {
    console.error('Error getting Razorpay key:', error);
    res.status(500).json({ error: 'Failed to get Razorpay key' });
  }
});

// Check if email exists
router.post('/check-email', async (req, res) => {
  try {
    // Email check removed - donors can donate multiple times
    // Always return false to allow multiple donations from same email
    return res.json({ exists: false });
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
      // Check if donation record already exists
      const [rows] = await db.execute('SELECT id, donor_id, metadata FROM donations WHERE razorpay_subscription_id = ? LIMIT 1', [subscription.id]);
      
      let donationId;
      let donorId = null;
      
      // If payment is successful, create donation record (if it doesn't exist)
      if (event === 'subscription.activated' || event === 'subscription.charged') {
        if (rows.length === 0) {
          // Donation record doesn't exist - create it now (payment was successful)
          try {
            // Get donor info from subscription notes
            const donorInfo = subscription.notes || {};
            const donorName = donorInfo.donor_name || subscription.customer?.name || '';
            const donorEmail = donorInfo.donor_email || subscription.customer?.email || '';
            const donorPhone = donorInfo.donor_phone || subscription.customer?.contact || '';
            const donorAddress = donorInfo.donor_address || '';
            const cycle = donorInfo.cycle || 'monthly';
            const amount = parseFloat(donorInfo.amount || '0');
            
            // Get plan details from subscription
            const planId = subscription.plan_id || '';
            
            if (donorName && donorEmail) {
              // Create or get donor
              const [existingDonor] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [donorEmail]);
              
              if (existingDonor.length) {
                donorId = existingDonor[0].id;
                await db.execute('UPDATE donors SET name = ?, phone = ? WHERE id = ?', [donorName, donorPhone || '', donorId]);
              } else {
                const [ins] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', [donorName, donorEmail, donorPhone || '']);
                donorId = ins.insertId;
              }
              
              // Create donation record with status 'active' (payment succeeded)
              const [donIns] = await db.execute(
                'INSERT INTO donations (donor_id, amount, currency, cycle, note, status, razorpay_subscription_id, razorpay_plan_id, metadata) VALUES (?, ?, ?, ?, ?, "active", ?, ?, JSON_OBJECT("subscription", ?, "donor_info", JSON_OBJECT("name", ?, "email", ?, "phone", ?, "address", ?)))',
                [
                  donorId,
                  Math.round(amount * 100), // Convert to paise
                  'INR',
                  cycle,
                  donorAddress || '',
                  subscription.id,
                  planId,
                  JSON.stringify(subscription),
                  donorName,
                  donorEmail,
                  donorPhone || '',
                  donorAddress || ''
                ]
              );
              donationId = donIns.insertId;
              console.log(`✅ Created donation record #${donationId} for successful payment (subscription: ${subscription.id})`);
            }
          } catch (createError) {
            console.error('Error creating donation record in webhook:', createError);
          }
        } else {
          // Donation record exists, just update status
          donationId = rows[0].id;
          donorId = rows[0].donor_id;
          await db.execute('UPDATE donations SET status = "active", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        }
      } else if (rows.length > 0) {
        // Donation exists, update status for other events
        donationId = rows[0].id;
        donorId = rows[0].donor_id;
        
        if (event === 'subscription.paused') {
          await db.execute('UPDATE donations SET status = "paused", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        } else if (event === 'subscription.cancelled') {
          await db.execute('UPDATE donations SET status = "cancelled", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        } else if (event === 'payment.failed') {
          await db.execute('UPDATE donations SET status = "failed", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donationId]);
        }
      }
      
      // Track each payment transaction for recurring payments
      if (donationId && payment?.id && event === 'subscription.charged') {
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
    
    res.json({ received: true });
  } catch (error) {
    console.error('Razorpay webhook error:', error);
    res.status(500).json({ error: 'Webhook handling failed' });
  }
});

// Test endpoint to verify routes are loaded (no auth needed for testing)
// Place this FIRST so it's loaded early
router.get('/admin/test-routes', (req, res) => {
  res.json({ 
    success: true, 
    message: 'Routes are loaded!',
    availableEndpoints: [
      'POST /api/donations/admin/sync-razorpay',
      'POST /api/donations/admin/verify-and-cleanup',
      'POST /api/donations/admin/sync-all'
    ]
  });
});

// Admin list
router.get('/admin', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    // Get filter parameter (default to 'all' to show all donations)
    const filter = req.query.filter || 'all'; // 'all', 'successful', 'active', 'paid', 'failed', etc.
    
    let statusFilter = '';
    if (filter === 'successful') {
      // Show only successful donations (active or paid)
      statusFilter = "AND d.status IN ('active', 'paid')";
    } else if (filter === 'active') {
      statusFilter = "AND d.status = 'active'";
    } else if (filter === 'paid') {
      statusFilter = "AND d.status = 'paid'";
    } else if (filter === 'failed') {
      statusFilter = "AND d.status IN ('failed', 'cancelled')";
    } else if (filter === 'pending') {
      statusFilter = "AND d.status = 'created'";
    }
    // If filter is 'all', no status filter is applied
    
    const [rows] = await db.execute(`
      SELECT d.id, d.amount, d.currency, d.cycle, d.status, d.cf_order_id, d.razorpay_subscription_id, d.created_at,
             COALESCE(r.name, JSON_EXTRACT(d.metadata, '$.donor_info.name')) as name,
             COALESCE(r.email, JSON_EXTRACT(d.metadata, '$.donor_info.email')) as email,
             COALESCE(r.phone, JSON_EXTRACT(d.metadata, '$.donor_info.phone')) as phone,
             (SELECT COUNT(*) FROM payment_transactions pt WHERE pt.donation_id = d.id) as transaction_count,
             (SELECT SUM(pt.amount) FROM payment_transactions pt WHERE pt.donation_id = d.id AND pt.status = 'captured') as total_paid
      FROM donations d 
      LEFT JOIN donors r ON d.donor_id = r.id
      WHERE 1=1 ${statusFilter}
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

// Sync subscription data from Razorpay
router.post('/admin/sync-razorpay', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const { subscriptionId } = req.body;
    
    if (!subscriptionId) {
      return res.status(400).json({ error: 'Subscription ID is required' });
    }
    
    const razorpay = getRazorpayInstance();
    
    // Fetch subscription details from Razorpay
    const subscription = await razorpay.subscriptions.fetch(subscriptionId);
    
    // Check if donation exists in database
    const [rows] = await db.execute(
      'SELECT id, donor_id, status FROM donations WHERE razorpay_subscription_id = ? LIMIT 1',
      [subscriptionId]
    );
    
    if (rows.length === 0) {
      // Subscription exists in Razorpay but not in database
      // Check if payment was successful
      if (subscription.status === 'active' || subscription.status === 'authenticated') {
        // Payment was successful, create donation record
        const donorInfo = subscription.notes || {};
        const donorName = donorInfo.donor_name || subscription.customer?.name || '';
        const donorEmail = donorInfo.donor_email || subscription.customer?.email || '';
        const donorPhone = donorInfo.donor_phone || subscription.customer?.contact || '';
        const donorAddress = donorInfo.donor_address || '';
        const cycle = donorInfo.cycle || 'monthly';
        const amount = parseFloat(donorInfo.amount || '0');
        
        if (donorName && donorEmail) {
          // Create or get donor
          const [existingDonor] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [donorEmail]);
          let donorId;
          
          if (existingDonor.length) {
            donorId = existingDonor[0].id;
            await db.execute('UPDATE donors SET name = ?, phone = ? WHERE id = ?', [donorName, donorPhone || '', donorId]);
          } else {
            const [ins] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', [donorName, donorEmail, donorPhone || '']);
            donorId = ins.insertId;
          }
          
          // Create donation record
          const [donIns] = await db.execute(
            'INSERT INTO donations (donor_id, amount, currency, cycle, note, status, razorpay_subscription_id, razorpay_plan_id, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              donorId,
              Math.round(amount * 100),
              'INR',
              cycle,
              donorAddress || '',
              subscription.status === 'active' ? 'active' : 'created',
              subscription.id,
              subscription.plan_id || '',
              JSON.stringify({ subscription, donor_info: { name: donorName, email: donorEmail, phone: donorPhone, address: donorAddress } })
            ]
          );
          
          return res.json({
            success: true,
            message: 'Donation record created from Razorpay',
            donationId: donIns.insertId,
            subscription: subscription
          });
        }
      } else {
        // Payment failed or cancelled, don't create record
        return res.json({
          success: true,
          message: 'Subscription found in Razorpay but payment not successful. No record created.',
          subscription: subscription
        });
      }
    } else {
      // Donation exists, update status from Razorpay
      const donationId = rows[0].id;
      const razorpayStatus = subscription.status;
      
      // Map Razorpay status to our status
      let dbStatus = 'created';
      if (razorpayStatus === 'active' || razorpayStatus === 'authenticated') {
        dbStatus = 'active';
      } else if (razorpayStatus === 'paused') {
        dbStatus = 'paused';
      } else if (razorpayStatus === 'cancelled' || razorpayStatus === 'expired') {
        dbStatus = 'cancelled';
      } else if (razorpayStatus === 'completed') {
        dbStatus = 'active'; // Keep as active even if completed
      }
      
      await db.execute('UPDATE donations SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [dbStatus, donationId]);
      
      // Fetch and sync payment transactions
      try {
        const payments = await razorpay.subscriptions.fetchAll(subscriptionId, { 'payment_id': subscription.id });
        // Note: Razorpay API might need different method to fetch payments
        // This is a placeholder - actual implementation depends on Razorpay API
      } catch (payError) {
        console.log('Could not fetch payment details:', payError.message);
      }
      
      return res.json({
        success: true,
        message: 'Donation record updated from Razorpay',
        donationId: donationId,
        status: dbStatus,
        subscription: subscription
      });
    }
  } catch (error) {
    console.error('Sync Razorpay error:', error);
    res.status(500).json({ error: 'Failed to sync with Razorpay', details: error.message });
  }
});

// Verify and clean up failed payments
router.post('/admin/verify-and-cleanup', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const razorpay = getRazorpayInstance();
    
    // Get all donations with subscription IDs that are in 'created' status (pending)
    // Also check donations older than 24 hours that are still in 'created' status
    const [pendingDonations] = await db.execute(`
      SELECT id, razorpay_subscription_id, created_at 
      FROM donations 
      WHERE razorpay_subscription_id IS NOT NULL 
      AND status = "created" 
      AND created_at < DATE_SUB(NOW(), INTERVAL 1 HOUR)
      ORDER BY created_at DESC 
      LIMIT 200
    `);
    
    let deleted = 0;
    let activated = 0;
    let errors = [];
    
    for (const donation of pendingDonations) {
      try {
        const subscriptionId = donation.razorpay_subscription_id;
        
        // Fetch subscription from Razorpay
        const subscription = await razorpay.subscriptions.fetch(subscriptionId);
        
        if (subscription.status === 'active' || subscription.status === 'authenticated') {
          // Payment was successful, activate the donation
          await db.execute('UPDATE donations SET status = "active", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donation.id]);
          activated++;
          
          // Create donor if needed (from subscription notes)
          const donorInfo = subscription.notes || {};
          const donorEmail = donorInfo.donor_email || subscription.customer?.email;
          
          if (donorEmail) {
            const [existingDonor] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [donorEmail]);
            let donorId;
            
            if (existingDonor.length) {
              donorId = existingDonor[0].id;
              const donorName = donorInfo.donor_name || subscription.customer?.name || '';
              const donorPhone = donorInfo.donor_phone || subscription.customer?.contact || '';
              await db.execute('UPDATE donors SET name = ?, phone = ? WHERE id = ?', [donorName, donorPhone || '', donorId]);
            } else {
              const donorName = donorInfo.donor_name || subscription.customer?.name || '';
              const donorPhone = donorInfo.donor_phone || subscription.customer?.contact || '';
              const [ins] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', [donorName, donorEmail, donorPhone || '']);
              donorId = ins.insertId;
            }
            
            // Update donation with donor_id if it's NULL
            await db.execute('UPDATE donations SET donor_id = ? WHERE id = ? AND donor_id IS NULL', [donorId, donation.id]);
          }
        } else if (subscription.status === 'cancelled' || subscription.status === 'expired' || subscription.status === 'halted' || subscription.status === 'completed') {
          // Payment failed, was cancelled, or subscription completed - delete the donation record if no payments were made
          // Check if there are any successful payments first
          const [payments] = await db.execute(
            'SELECT COUNT(*) as count FROM payment_transactions WHERE donation_id = ? AND status = "captured"',
            [donation.id]
          );
          
          if (payments[0].count === 0) {
            // No successful payments, safe to delete
            await db.execute('DELETE FROM donations WHERE id = ?', [donation.id]);
            deleted++;
          } else {
            // Has payments, just update status
            await db.execute('UPDATE donations SET status = "cancelled", updated_at = CURRENT_TIMESTAMP WHERE id = ?', [donation.id]);
          }
        } else if (subscription.status === 'created' || subscription.status === 'pending') {
          // Still pending, check if it's been more than 48 hours
          const donationAge = new Date() - new Date(donation.created_at);
          const hoursOld = donationAge / (1000 * 60 * 60);
          
          if (hoursOld > 48) {
            // More than 48 hours old and still pending, likely abandoned - delete
            await db.execute('DELETE FROM donations WHERE id = ?', [donation.id]);
            deleted++;
          }
        }
      } catch (error) {
        // Subscription might not exist in Razorpay (user cancelled before payment)
        if (error.statusCode === 404 || error.message?.includes('not found') || error.message?.includes('No such')) {
          // Subscription doesn't exist in Razorpay, delete the donation record
          await db.execute('DELETE FROM donations WHERE id = ?', [donation.id]);
          deleted++;
        } else {
          errors.push({ donationId: donation.id, error: error.message });
        }
      }
    }
    
    res.json({
      success: true,
      message: `Cleanup completed: ${deleted} deleted, ${activated} activated`,
      deleted,
      activated,
      errors: errors.length > 0 ? errors : undefined
    });
  } catch (error) {
    console.error('Verify and cleanup error:', error);
    res.status(500).json({ error: 'Failed to verify and cleanup', details: error.message });
  }
});

// Sync all donations with Razorpay (refresh data and create missing records)
router.post('/admin/sync-all', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    const razorpay = getRazorpayInstance();
    
    console.log('🔄 Starting sync-all: Fetching all subscriptions from Razorpay...');
    
    let created = 0;
    let updated = 0;
    let skipped = 0;
    let errors = [];
    
    // Fetch ALL subscriptions from Razorpay (recent ones first)
    try {
      console.log('📡 Fetching subscriptions from Razorpay...');
      const subscriptionsResponse = await razorpay.subscriptions.all({
        count: 100, // Get last 100 subscriptions
        skip: 0
      });
      
      if (!subscriptionsResponse || !subscriptionsResponse.items) {
        console.error('❌ Invalid response from Razorpay:', subscriptionsResponse);
        return res.status(500).json({ error: 'Invalid response from Razorpay API', details: 'No items in response' });
      }
      
      const subscriptions = subscriptionsResponse.items || [];
      console.log(`📊 Found ${subscriptions.length} subscriptions in Razorpay`);
      
      // Get all existing subscription IDs from database for quick lookup
      const [existingDonations] = await db.execute(
        'SELECT razorpay_subscription_id FROM donations WHERE razorpay_subscription_id IS NOT NULL'
      );
      const existingSubscriptionIds = new Set(
        existingDonations.map(d => d.razorpay_subscription_id)
      );
      console.log(`📊 Found ${existingSubscriptionIds.size} existing subscriptions in database`);
      
      // Process each subscription
      for (const subscription of subscriptions) {
        try {
          const subscriptionId = subscription.id;
          const isExisting = existingSubscriptionIds.has(subscriptionId);
          
          if (!isExisting) {
            // Subscription doesn't exist in database - create it if payment was successful or created
            if (subscription.status === 'active' || subscription.status === 'authenticated' || subscription.status === 'created' || subscription.status === 'pending') {
              console.log(`📊 Processing new subscription ${subscriptionId} with status: ${subscription.status}`);
              
              // Get donor info from subscription notes
              const donorInfo = subscription.notes || {};
              const donorName = donorInfo.donor_name || subscription.customer?.name || '';
              const donorEmail = donorInfo.donor_email || subscription.customer?.email || '';
              const donorPhone = donorInfo.donor_phone || subscription.customer?.contact || '';
              const donorAddress = donorInfo.donor_address || '';
              const cycle = donorInfo.cycle || 'monthly';
              const amount = parseFloat(donorInfo.amount || '0');
              
              if (donorName && donorEmail) {
                try {
                  // Create or get donor
                  const [existingDonor] = await db.execute('SELECT id FROM donors WHERE email = ? LIMIT 1', [donorEmail]);
                  let donorId;
                  
                  if (existingDonor.length) {
                    donorId = existingDonor[0].id;
                    await db.execute('UPDATE donors SET name = ?, phone = ? WHERE id = ?', [donorName, donorPhone || '', donorId]);
                    console.log(`📝 Updated existing donor #${donorId} for ${donorEmail}`);
                  } else {
                    const [ins] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', [donorName, donorEmail, donorPhone || '']);
                    donorId = ins.insertId;
                    console.log(`✅ Created new donor #${donorId} for ${donorEmail}`);
                  }
                  
                  // Determine status
                  const donationStatus = (subscription.status === 'active' || subscription.status === 'authenticated') ? 'active' : 'created';
                  
                  // Create donation record
                  const amountPaise = Math.round(amount * 100);
                  const metadataJson = JSON.stringify({
                    subscription: subscription,
                    donor_info: { name: donorName, email: donorEmail, phone: donorPhone, address: donorAddress }
                  });
                  
                  console.log(`📝 Creating donation: subscriptionId=${subscriptionId}, donorId=${donorId}, amount=${amountPaise}, status=${donationStatus}`);
                  
                  const [donIns] = await db.execute(
                    'INSERT INTO donations (donor_id, amount, currency, cycle, note, status, razorpay_subscription_id, razorpay_plan_id, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                    [
                      donorId,
                      amountPaise,
                      'INR',
                      cycle,
                      donorAddress || '',
                      donationStatus,
                      subscriptionId,
                      subscription.plan_id || '',
                      metadataJson
                    ]
                  );
                  
                  console.log(`✅ Successfully created donation #${donIns.insertId} for subscription ${subscriptionId}`);
                  created++;
                } catch (dbError) {
                  console.error(`❌ Database error creating donation for subscription ${subscriptionId}:`, dbError);
                  console.error('Error details:', dbError.message);
                  errors.push({ subscriptionId: subscriptionId, error: `Database error: ${dbError.message}` });
                }
              } else {
                console.log(`⚠️ Skipping subscription ${subscriptionId} - missing donor info (name: ${donorName || 'empty'}, email: ${donorEmail || 'empty'})`);
                skipped++;
              }
            } else {
              console.log(`⚠️ Skipping subscription ${subscriptionId} - status: ${subscription.status} (not successful)`);
              skipped++;
            }
          } else {
            // Subscription exists - update status
            const [donationRow] = await db.execute(
              'SELECT id FROM donations WHERE razorpay_subscription_id = ? LIMIT 1',
              [subscriptionId]
            );
            
            if (donationRow.length > 0) {
              // Map Razorpay status to our status
              let dbStatus = 'created';
              if (subscription.status === 'active' || subscription.status === 'authenticated') {
                dbStatus = 'active';
              } else if (subscription.status === 'paused') {
                dbStatus = 'paused';
              } else if (subscription.status === 'cancelled' || subscription.status === 'expired') {
                dbStatus = 'cancelled';
              }
              
              await db.execute('UPDATE donations SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?', [dbStatus, donationRow[0].id]);
              updated++;
            }
          }
        } catch (subError) {
          console.error(`❌ Error processing subscription ${subscription.id}:`, subError.message);
          errors.push({ subscriptionId: subscription.id, error: subError.message });
        }
      }
      
      console.log(`✅ Sync completed: ${created} created, ${updated} updated, ${skipped} skipped`);
      
      res.json({
        success: true,
        message: `Sync completed: ${created} new donations created, ${updated} existing donations updated, ${skipped} skipped`,
        created,
        updated,
        skipped,
        total: subscriptions.length,
        errors: errors.length > 0 ? errors : undefined
      });
    } catch (fetchError) {
      console.error('❌ Error fetching subscriptions from Razorpay:', fetchError);
      res.status(500).json({ 
        error: 'Failed to fetch subscriptions from Razorpay', 
        details: fetchError.message 
      });
    }
  } catch (error) {
    console.error('Sync all error:', error);
    res.status(500).json({ error: 'Failed to sync all donations', details: error.message });
  }
});

// Test endpoint to verify database writes
router.post('/admin/test-db-write', authenticateToken, async (req, res) => {
  try {
    await ensureTables();
    
    // Test donor creation
    const testEmail = `test_${Date.now()}@test.com`;
    const [donorIns] = await db.execute('INSERT INTO donors (name, email, phone) VALUES (?, ?, ?)', ['Test Donor', testEmail, '1234567890']);
    const donorId = donorIns.insertId;
    
    // Test donation creation
    const [donIns] = await db.execute(
      'INSERT INTO donations (donor_id, amount, currency, cycle, status, razorpay_subscription_id) VALUES (?, ?, ?, ?, ?, ?)',
      [donorId, 100, 'INR', 'monthly', 'created', 'test_sub_' + Date.now()]
    );
    const donationId = donIns.insertId;
    
    // Clean up test data
    await db.execute('DELETE FROM donations WHERE id = ?', [donationId]);
    await db.execute('DELETE FROM donors WHERE id = ?', [donorId]);
    
    res.json({
      success: true,
      message: 'Database write test successful',
      testDonorId: donorId,
      testDonationId: donationId
    });
  } catch (error) {
    console.error('Database write test error:', error);
    res.status(500).json({ error: 'Database write test failed', details: error.message });
  }
});

module.exports = router;



