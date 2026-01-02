# How to Check Webhook Logs & Verify Webhook is Being Called

## Method 1: Check Razorpay Dashboard (Easiest)

### Step 1: Log in to Razorpay Dashboard
1. Go to: https://dashboard.razorpay.com/
2. Log in with your credentials
3. Make sure you're in **Live Mode** (not Test Mode)

### Step 2: Navigate to Webhooks
1. Click **"Settings"** in the left sidebar
2. Click **"Webhooks"** from the settings menu
3. Find your webhook URL: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`

### Step 3: Check Delivery History
1. Click on your webhook to open details
2. Click on **"Delivery History"** or **"Logs"** tab
3. You'll see:
   - **Timestamp** - When webhook was sent
   - **Event** - What event triggered it (e.g., `subscription.charged`)
   - **Status** - Success (200) or Failed (4xx/5xx)
   - **Response Time** - How long it took
   - **Response Body** - What your server returned

### What to Look For:
- ✅ **Green/Success (200)** - Webhook is working
- ❌ **Red/Failed (401, 500, etc.)** - Webhook has issues
- ⏱️ **Response Time** - Should be < 5 seconds (if > 30s, Razorpay disables it)

---

## Method 2: Check Server Logs (cPanel/Node.js)

### Option A: Check cPanel Application Logs

1. **Log in to cPanel**
2. **Navigate to Node.js App**
   - Find your Node.js application
   - Click on it to open settings
3. **View Logs**
   - Look for "Logs" or "Application Logs" section
   - Click to view/download logs
4. **Search for Webhook Entries**
   - Look for: `📥 Webhook received:`
   - Look for: `✅ Webhook processed successfully:`
   - Look for: `❌ Webhook signature verification failed`

### Option B: Check via SSH (if you have access)

```bash
# SSH into your server
ssh your-username@your-server.com

# Navigate to your app directory
cd ~/public_html/api

# Check Node.js logs (if using PM2)
pm2 logs

# Or check application.log file
tail -f application.log

# Or check server output
# (depends on how your Node.js app is running)
```

### Option C: Check via File Manager

1. **Log in to cPanel**
2. **Open File Manager**
3. **Navigate to your app directory**
   - Usually: `public_html/api/` or `public_html/`
4. **Look for log files:**
   - `application.log`
   - `server.log`
   - `error.log`
   - `webhook.log` (if you create one)

---

## Method 3: Add Webhook Logging to Your Code

The webhook already has logging built in. You should see these in your logs:

### Log Messages You'll See:

```
📥 Webhook received: subscription.charged { subscriptionId: 'sub_xxx', paymentId: 'pay_xxx' }
✅ Webhook processed successfully: subscription.charged
✅ Created donation record #123 for successful payment (subscription: sub_xxx)
```

### Error Messages You Might See:

```
❌ Webhook signature verification failed
Expected: abc123...
Received: xyz789...
❌ Failed to parse webhook payload: [error details]
❌ Razorpay webhook error: [error details]
```

---

## Method 4: Test Webhook Manually

### Test 1: Check if Endpoint is Accessible

```bash
# Test if webhook URL is reachable
curl -X POST https://theonerupeerevolution.org/api/donations/razorpay/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Should return 200 OK (even with invalid signature)
# Response: {"received":true,"error":"Invalid signature (logged)"}
```

### Test 2: Use Razorpay Test Webhook Feature

1. **Go to Razorpay Dashboard → Webhooks**
2. **Click on your webhook**
3. **Click "Send Test Webhook"** or **"Test"** button
4. **Select an event** (e.g., `subscription.charged`)
5. **Click "Send"**
6. **Check Delivery History** to see if it was successful

### Test 3: Create a Test Donation

1. **Make a test donation** on your website
2. **Check Razorpay Dashboard → Webhooks → Delivery History**
3. **You should see webhook events** for:
   - `subscription.activated` (when subscription is created)
   - `subscription.charged` (when payment is processed)

---

## Method 5: Add Custom Webhook Logging

If you want more detailed logging, you can add a log file:

### Add to `routes/donations.js`:

```javascript
const fs = require('fs');
const path = require('path');

// At the start of webhook handler, add:
const logWebhook = (event, data) => {
  const logEntry = {
    timestamp: new Date().toISOString(),
    event: event,
    data: data
  };
  
  const logFile = path.join(__dirname, '../logs/webhook.log');
  fs.appendFileSync(logFile, JSON.stringify(logEntry) + '\n');
};

// Then in webhook handler:
console.log(`📥 Webhook received: ${event}`);
logWebhook(event, { subscriptionId: subscription?.id, paymentId: payment?.id });
```

---

## Quick Checklist: Is Webhook Working?

### ✅ Signs Webhook is Working:
- [ ] Razorpay Dashboard shows **"Active"** status
- [ ] Delivery History shows **200 OK** responses
- [ ] Server logs show `📥 Webhook received:` messages
- [ ] Donations are being created automatically
- [ ] Payment transactions are being tracked
- [ ] Status updates happen automatically

### ❌ Signs Webhook is NOT Working:
- [ ] Razorpay Dashboard shows **"Disabled"** or **"Failed"**
- [ ] Delivery History shows **401, 500, or timeout** errors
- [ ] No logs in server
- [ ] Donations not created automatically
- [ ] Status not updating
- [ ] Webhook keeps getting disabled

---

## Common Issues & Solutions

### Issue 1: No Webhook Calls in Logs

**Possible Causes:**
- Webhook is disabled in Razorpay
- Webhook URL is incorrect
- Events not selected in Razorpay

**Solution:**
1. Check Razorpay Dashboard → Webhooks → Status (should be "Active")
2. Verify webhook URL is correct
3. Make sure events are selected (especially `subscription.charged`)

### Issue 2: Webhook Returns 401 (Invalid Signature)

**Possible Causes:**
- `RAZORPAY_WEBHOOK_SECRET` is wrong or missing
- Webhook secret changed in Razorpay but not updated in server

**Solution:**
1. Check environment variable `RAZORPAY_WEBHOOK_SECRET`
2. Compare with webhook secret in Razorpay Dashboard
3. Restart Node.js app after updating secret

### Issue 3: Webhook Returns 500 (Server Error)

**Possible Causes:**
- Database connection issue
- Code error in webhook handler
- Missing tables

**Solution:**
1. Check server logs for error details
2. Verify database connection
3. Check if tables exist (`donors`, `donations`, `payment_transactions`)

### Issue 4: Webhook Times Out

**Possible Causes:**
- Slow database queries
- Server overloaded
- Network issues

**Solution:**
1. Optimize database queries
2. Check server resources
3. Consider processing webhook asynchronously

---

## Monitoring Webhook Health

### Daily Checks:
1. **Razorpay Dashboard** → Check delivery history for yesterday
2. **Server Logs** → Check for any error messages
3. **Admin Panel** → Verify donations are being created

### Weekly Checks:
1. **Review failed webhooks** in Razorpay Dashboard
2. **Check response times** (should be < 5 seconds)
3. **Verify all events are being received**

---

## Pro Tips

1. **Set up email alerts** (if Razorpay supports it) for webhook failures
2. **Monitor response times** - if consistently slow, optimize code
3. **Keep webhook secret secure** - never commit to git
4. **Test after code changes** - always test webhook after deploying updates
5. **Keep logs for 30 days** - helps with debugging issues

---

## Quick Commands Reference

```bash
# Check if webhook endpoint is accessible
curl -X POST https://theonerupeerevolution.org/api/donations/razorpay/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Check webhook logs (if using PM2)
pm2 logs | grep webhook

# Check recent webhook activity
tail -f application.log | grep "Webhook"
```

---

**Need Help?**
- Check Razorpay Dashboard → Webhooks → Delivery History (most reliable)
- Check server logs in cPanel
- Verify `RAZORPAY_WEBHOOK_SECRET` is set correctly
- Make sure webhook is "Active" in Razorpay Dashboard

