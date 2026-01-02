# How to Test Webhook Manually and View Logs

## Overview
This guide explains how to manually test your Razorpay webhook endpoint and view its logs.

---

## Method 1: Using Razorpay Dashboard (Easiest)

### Step 1: Access Razorpay Dashboard
1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com/)
2. Navigate to **Settings** → **Webhooks**
3. Find your webhook URL: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`

### Step 2: Send Test Webhook
1. Click on your webhook
2. Click **"Send Test Webhook"** or **"Test"** button
3. Select an event type (e.g., `subscription.activated`, `payment.captured`, `payment.failed`)
4. Click **"Send"**

### Step 3: View Results
- **Status**: Should show `200 OK` if successful
- **Response**: Should show `{"received":true,"processed":true,"event":"..."}`
- **Delivery History**: Shows all webhook attempts with timestamps

---

## Method 2: Using Bash Script (WSL/Ubuntu - Recommended)

### Step 1: Set Webhook Secret
```bash
export RAZORPAY_WEBHOOK_SECRET="your_webhook_secret_here"
```

### Step 2: Run the Script
```bash
# Make script executable (first time only)
chmod +x test-webhook.sh

# Run the script
./test-webhook.sh
```

The script will:
- Generate a test payload
- Create the HMAC signature automatically
- Send the webhook request
- Display the response with colored output

**Note:** This script is designed for WSL/Ubuntu (like your `deploy_full.sh` script).

---

## Method 3: Using cURL (Command Line)

### Step 1: Get Your Webhook Secret
```bash
# Your webhook secret is stored in environment variable
# On server: RAZORPAY_WEBHOOK_SECRET
```

### Step 2: Create Test Payload
Create a file `test-webhook.json`:
```json
{
  "event": "subscription.activated",
  "payload": {
    "subscription": {
      "entity": {
        "id": "sub_test123",
        "status": "active",
        "plan_id": "plan_test123",
        "customer_id": "cust_test123",
        "current_start": 1234567890,
        "current_end": 1234567890,
        "notes": {
          "donor_name": "Test Donor",
          "donor_email": "test@example.com",
          "donor_phone": "1234567890",
          "donor_address": "Test Address",
          "cycle": "monthly",
          "amount": "700"
        }
      }
    }
  }
}
```

### Step 3: Generate Signature
```bash
# On Linux/Mac/WSL
WEBHOOK_SECRET="your_webhook_secret_here"
PAYLOAD=$(cat test-webhook.json)
SIGNATURE=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | sed 's/^.* //')

echo "Signature: $SIGNATURE"
```

### Step 4: Send Webhook Request
```bash
curl -X POST https://theonerupeerevolution.org/api/donations/razorpay/webhook \
  -H "Content-Type: application/json" \
  -H "X-Razorpay-Signature: $SIGNATURE" \
  -d @test-webhook.json \
  -v
```

**Expected Response:**
```json
{
  "received": true,
  "processed": true,
  "event": "subscription.activated",
  "timestamp": "2025-01-02T12:00:00.000Z"
}
```

---

## Method 4: Using Postman

### Step 1: Create New Request
1. Open Postman
2. Create new **POST** request
3. URL: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`

### Step 2: Set Headers
```
Content-Type: application/json
X-Razorpay-Signature: [generated_signature]
```

### Step 3: Set Body
- Select **raw** → **JSON**
- Paste test payload:
```json
{
  "event": "payment.captured",
  "payload": {
    "payment": {
      "entity": {
        "id": "pay_test123",
        "status": "captured",
        "amount": 70000,
        "currency": "INR",
        "order_id": "order_test123",
        "method": "card"
      }
    }
  }
}
```

### Step 4: Generate Signature
Use a tool or script to generate the signature (see Method 2, Step 3)

### Step 5: Send Request
Click **Send** and check the response.

---

## Method 5: Using Node.js Script

Create `test-webhook.js`:
```javascript
const crypto = require('crypto');
const axios = require('axios');

const WEBHOOK_SECRET = process.env.RAZORPAY_WEBHOOK_SECRET || 'your_webhook_secret';
const WEBHOOK_URL = 'https://theonerupeerevolution.org/api/donations/razorpay/webhook';

const testPayload = {
  event: 'subscription.activated',
  payload: {
    subscription: {
      entity: {
        id: 'sub_test123',
        status: 'active',
        plan_id: 'plan_test123',
        notes: {
          donor_name: 'Test Donor',
          donor_email: 'test@example.com',
          donor_phone: '1234567890',
          cycle: 'monthly',
          amount: '700'
        }
      }
    }
  }
};

// Generate signature
const payloadString = JSON.stringify(testPayload);
const signature = crypto
  .createHmac('sha256', WEBHOOK_SECRET)
  .update(payloadString)
  .digest('hex');

console.log('Payload:', payloadString);
console.log('Signature:', signature);

// Send webhook
axios.post(WEBHOOK_URL, testPayload, {
  headers: {
    'Content-Type': 'application/json',
    'X-Razorpay-Signature': signature
  }
})
.then(response => {
  console.log('✅ Webhook Response:', response.data);
  console.log('Status:', response.status);
})
.catch(error => {
  console.error('❌ Webhook Error:', error.response?.data || error.message);
  console.error('Status:', error.response?.status);
});
```

**Run the script:**
```bash
node test-webhook.js
```

---

## Viewing Webhook Logs

### 1. Server Logs (cPanel)

#### Option A: Via cPanel File Manager
1. Log in to cPanel
2. Go to **File Manager**
3. Navigate to `~/logs/` or `~/public_html/api/logs/`
4. Look for Node.js application logs

#### Option B: Via SSH
```bash
# SSH into your server
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# View Node.js application logs
tail -f ~/logs/nodejs.log
# OR
tail -f ~/public_html/api/logs/app.log
# OR check Passenger logs
tail -f ~/logs/passenger.log
```

#### Option C: Via cPanel Terminal
1. Log in to cPanel
2. Go to **Terminal** or **SSH Access**
3. Run:
```bash
tail -f ~/logs/nodejs.log
```

### 2. Application Console Logs

Your webhook handler logs to console. Check for:
- `📥 Webhook received: [event]`
- `✅ Webhook processed successfully: [event]`
- `❌ Webhook signature verification failed`
- `🔍 Webhook Debug - Body type: ...`

### 3. Razorpay Dashboard Logs

1. Go to **Settings** → **Webhooks**
2. Click on your webhook
3. Click **"Delivery History"** or **"Logs"**
4. You'll see:
   - Timestamp
   - Event type
   - Status (200 OK, 500, etc.)
   - Response body
   - Request payload

### 4. Database Logs

Check if webhook created/updated records:
```sql
-- Check recent donations
SELECT id, status, razorpay_status, razorpay_subscription_id, created_at 
FROM donations 
ORDER BY created_at DESC 
LIMIT 10;

-- Check payment transactions
SELECT * FROM payment_transactions 
ORDER BY payment_date DESC 
LIMIT 10;
```

---

## Test Webhook Events

### Common Events to Test:

#### 1. Subscription Activated
```json
{
  "event": "subscription.activated",
  "payload": {
    "subscription": {
      "entity": {
        "id": "sub_xxx",
        "status": "active",
        "plan_id": "plan_xxx",
        "notes": {
          "donor_name": "Test User",
          "donor_email": "test@example.com",
          "cycle": "monthly",
          "amount": "700"
        }
      }
    }
  }
}
```

#### 2. Payment Captured (One-Time)
```json
{
  "event": "payment.captured",
  "payload": {
    "payment": {
      "entity": {
        "id": "pay_xxx",
        "status": "captured",
        "amount": 70000,
        "currency": "INR",
        "order_id": "order_xxx"
      }
    }
  }
}
```

#### 3. Payment Failed
```json
{
  "event": "payment.failed",
  "payload": {
    "payment": {
      "entity": {
        "id": "pay_xxx",
        "status": "failed",
        "amount": 70000,
        "currency": "INR"
      }
    },
    "subscription": {
      "entity": {
        "id": "sub_xxx",
        "status": "active"
      }
    }
  }
}
```

#### 4. Subscription Charged
```json
{
  "event": "subscription.charged",
  "payload": {
    "subscription": {
      "entity": {
        "id": "sub_xxx",
        "status": "active"
      }
    },
    "payment": {
      "entity": {
        "id": "pay_xxx",
        "status": "captured",
        "amount": 70000
      }
    }
  }
}
```

---

## Troubleshooting

### Issue: Signature Verification Fails

**Solution:**
1. Ensure webhook secret matches in environment variables
2. Use raw JSON string (not parsed) for signature generation
3. Check that `X-Razorpay-Signature` header is set correctly

**Debug:**
```javascript
// In your webhook handler, check:
console.log('Expected signature:', hash);
console.log('Received signature:', signature);
console.log('Body type:', typeof req.body);
console.log('Body is Buffer:', Buffer.isBuffer(req.body));
```

### Issue: 404 Not Found

**Solution:**
1. Verify webhook URL is correct: `/api/donations/razorpay/webhook`
2. Ensure Node.js app is running
3. Check `.htaccess` file exists in `~/public_html/api/`

### Issue: 500 Internal Server Error

**Solution:**
1. Check server logs for error details
2. Verify database connection
3. Check that `ensureTables()` runs successfully
4. Verify environment variables are set

### Issue: No Logs Appearing

**Solution:**
1. Check if webhook is actually being called (check Razorpay dashboard)
2. Verify server logs location
3. Check Passenger/Node.js app is running
4. Try restarting Node.js app in cPanel

---

## Quick Test Checklist

- [ ] Webhook URL is accessible (returns 200 OK)
- [ ] Signature verification works
- [ ] Server logs show webhook receipt
- [ ] Database records are created/updated
- [ ] Razorpay dashboard shows successful delivery
- [ ] Response is `{"received":true,"processed":true}`

---

## Example: Complete Test Flow

### 1. Test Webhook Endpoint Accessibility
```bash
curl -X POST https://theonerupeerevolution.org/api/donations/razorpay/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}' \
  -v
```

**Expected:** `200 OK` with `{"received":true,"error":"Invalid signature (logged)"}`

### 2. Test with Valid Signature
```bash
# Generate signature and send (see Method 2)
```

**Expected:** `200 OK` with `{"received":true,"processed":true,"event":"..."}`

### 3. Check Logs
```bash
# SSH into server
tail -f ~/logs/nodejs.log | grep -i webhook
```

**Expected:** See `📥 Webhook received:` and `✅ Webhook processed successfully:`

### 4. Check Database
```sql
SELECT * FROM donations ORDER BY created_at DESC LIMIT 1;
```

**Expected:** New donation record created (if test payload had valid data)

### 5. Check Razorpay Dashboard
- Go to **Settings** → **Webhooks** → **Delivery History**
- Should see your test webhook with `200 OK` status

---

## Notes

- **Always return 200 OK**: Your webhook always returns 200 OK even on errors to prevent Razorpay from disabling it
- **Logs are key**: Check server logs for detailed error messages
- **Test in stages**: Test signature verification first, then payload processing
- **Use real data**: For best results, use actual subscription/payment IDs from Razorpay

---

## Additional Resources

- Razorpay Webhook Documentation: https://razorpay.com/docs/webhooks/
- Your webhook implementation: `routes/donations.js` (line ~892)
- Webhook troubleshooting guide: `TROUBLESHOOT-WEBHOOK-LOGS.md`

