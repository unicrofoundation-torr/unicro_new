# Webhook Code Analysis - Potential Issues

## Code Analysis Results

After analyzing the webhook implementation, here are the findings:

---

## ✅ What's Working Correctly

1. **Route Registration**: ✅ Webhook route is properly registered
   - Route: `POST /api/donations/razorpay/webhook`
   - Registered in `server.js` via `app.use('/api/donations', require('./routes/donations'))`

2. **Error Handling**: ✅ Always returns 200 OK
   - Prevents Razorpay from disabling webhook
   - Errors are logged but don't fail the webhook

3. **Signature Verification**: ✅ Properly implemented
   - Uses raw body for signature verification
   - Correct HMAC SHA256 algorithm

4. **Logging**: ✅ Comprehensive logging
   - Logs webhook receipt
   - Logs processing success/failure
   - Logs errors with stack traces

---

## ⚠️ Potential Issues Found

### Issue 1: Body Parsing Order (CRITICAL)

**Problem:**
```javascript
// In server.js line 59:
app.use(express.json());

// But webhook uses:
router.post('/razorpay/webhook', express.raw({ type: 'application/json' }), ...)
```

**Issue:**
- `express.json()` middleware in `server.js` runs BEFORE the route-specific `express.raw()`
- This means the body might be parsed as JSON before the webhook route receives it
- Razorpay signature verification requires the RAW body, not parsed JSON

**Impact:**
- Signature verification will ALWAYS fail
- Webhook returns 200 OK (so Razorpay doesn't disable it)
- But webhook processing fails silently

**Solution:**
The route-specific `express.raw()` should work, but we need to ensure it's applied correctly.

---

### Issue 2: Missing `ensureTables()` Call

**Problem:**
The webhook handler doesn't call `ensureTables()` before database operations.

**Impact:**
- If tables don't exist, database operations will fail
- Webhook will return 200 OK but won't process anything

**Current Code:**
```javascript
// Line 950 - Direct database query without ensureTables()
const [rows] = await db.execute('SELECT id, donor_id, metadata FROM donations WHERE razorpay_subscription_id = ? LIMIT 1', [subscription.id]);
```

**Solution:**
Add `await ensureTables();` at the start of the webhook handler.

---

### Issue 3: One-Time Payment Events Not Handled

**Problem:**
The webhook only handles subscription events (`subscription.*`), but not one-time payment events (`payment.*`).

**Impact:**
- One-time donations won't be processed via webhook
- Only recurring subscriptions are handled

**Current Code:**
```javascript
if (subscription?.id) {
  // Only processes if subscription exists
}
// No handling for payment.id (one-time payments)
```

**Solution:**
Add handling for `payment.*` events for one-time donations.

---

### Issue 4: Missing Event Types

**Problem:**
The webhook only handles specific events:
- `subscription.activated`
- `subscription.charged`
- `subscription.paused`
- `subscription.cancelled`
- `payment.failed`

But Razorpay sends many more events that might be relevant.

**Impact:**
- Other events are received but ignored
- No error, but no processing either

---

## 🔧 Recommended Fixes

### Fix 1: Ensure Body Parsing Order

**Update `server.js`:**

```javascript
// Move express.json() AFTER webhook route, OR
// Exclude webhook path from express.json()

// Option 1: Exclude webhook from JSON parsing
app.use((req, res, next) => {
  if (req.path === '/api/donations/razorpay/webhook') {
    return next(); // Skip JSON parsing for webhook
  }
  express.json()(req, res, next);
});

// Option 2: Use express.json() with verify option
app.use(express.json({
  verify: (req, res, buf) => {
    if (req.path === '/api/donations/razorpay/webhook') {
      req.rawBody = buf; // Store raw body for webhook
    }
  }
}));
```

### Fix 2: Add `ensureTables()` Call

**Update webhook handler:**

```javascript
router.post('/razorpay/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  let webhookProcessed = false;
  
  try {
    // ADD THIS:
    await ensureTables(); // Ensure database tables exist
    
    const signature = req.headers['x-razorpay-signature'];
    // ... rest of code
```

### Fix 3: Handle One-Time Payments

**Add payment event handling:**

```javascript
// After subscription handling, add:
if (payment?.id && !subscription?.id) {
  // Handle one-time payment events
  const [existingDonation] = await db.execute(
    'SELECT id FROM donations WHERE razorpay_order_id = ? OR razorpay_payment_id = ? LIMIT 1',
    [payment.order_id, payment.id]
  );
  
  if (event === 'payment.captured' || event === 'payment.authorized') {
    // Update donation status to 'paid'
    if (existingDonation.length > 0) {
      await db.execute('UPDATE donations SET status = "paid", razorpay_payment_id = ? WHERE id = ?', 
        [payment.id, existingDonation[0].id]);
    }
  }
}
```

---

## 🧪 Testing the Webhook

### Test 1: Check if Endpoint is Accessible

```bash
curl -X POST https://theonerupeerevolution.org/api/donations/razorpay/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Should return: {"received":true,"error":"Invalid signature (logged)"}
```

### Test 2: Check Server Logs

Look for these log messages:
- `📥 Webhook received: [event]`
- `✅ Webhook processed successfully: [event]`
- `❌ Webhook signature verification failed`

### Test 3: Check Database

After a webhook event:
- Check if donation records are created
- Check if donor records are created
- Check if payment_transactions are created

---

## 📋 Checklist: Is Webhook Working?

- [ ] Endpoint is accessible (curl test returns 200)
- [ ] Server logs show webhook receipt messages
- [ ] Signature verification passes (check logs)
- [ ] Database records are created/updated
- [ ] Razorpay dashboard shows successful deliveries (200 OK)

---

## 🚨 Most Likely Issue

Based on the code analysis, the **most likely issue** is:

**Body parsing order** - The `express.json()` middleware in `server.js` might be parsing the body before the webhook route's `express.raw()` middleware can access it.

This would cause:
- Signature verification to always fail
- Webhook to return 200 OK (so Razorpay doesn't disable it)
- But no actual processing happens
- No logs in Razorpay dashboard because webhook "succeeds" but does nothing

---

## 🔍 How to Verify

1. **Check server logs** for webhook messages:
   - If you see `📥 Webhook received:` → Webhook is being called
   - If you see `❌ Webhook signature verification failed` → Signature issue
   - If you see `✅ Webhook processed successfully:` → Working correctly

2. **Check Razorpay dashboard**:
   - Go to Settings → Webhooks → Your webhook → Delivery History
   - Look for entries with status 200
   - Click on an entry to see the response body

3. **Test with real donation**:
   - Make a test donation
   - Check if donation appears in admin panel
   - Check server logs for webhook messages

---

## 💡 Quick Fix to Try

Add this at the start of the webhook handler to debug:

```javascript
router.post('/razorpay/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  console.log('🔍 Webhook Debug Info:');
  console.log('  - Body type:', typeof req.body);
  console.log('  - Body is Buffer:', Buffer.isBuffer(req.body));
  console.log('  - Body length:', req.body?.length);
  console.log('  - Headers:', req.headers);
  
  // ... rest of code
```

This will help identify if the body is being parsed correctly.

