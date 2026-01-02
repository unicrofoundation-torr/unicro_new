# Troubleshooting: Can't See Webhook Logs in Razorpay Dashboard

## Common Reasons Why You Can't See Webhook Logs

### 1. Webhook Not Created/Configured
- Webhook might not exist in Razorpay dashboard
- Need to create it first

### 2. Webhook is Disabled
- Webhook exists but is disabled/paused
- Need to enable it

### 3. No Events Sent Yet
- Webhook is configured but no events have been triggered
- Need to trigger an event (make a donation)

### 4. Looking in Wrong Place
- Webhook logs are in a specific location
- Need to navigate correctly

### 5. Wrong Razorpay Account
- Checking test mode instead of live mode (or vice versa)
- Need to check the correct mode

---

## Step-by-Step: How to Find Webhook Logs

### Step 1: Log in to Razorpay Dashboard
1. Go to: https://dashboard.razorpay.com/
2. Log in with your credentials
3. **IMPORTANT:** Make sure you're in **Live Mode** (not Test Mode)
   - Check top-right corner for mode indicator
   - Switch if needed

### Step 2: Navigate to Webhooks
1. Click **"Settings"** in the left sidebar
2. Click **"Webhooks"** from the settings menu
3. You should see a list of webhooks (or empty if none exist)

### Step 3: Check if Webhook Exists

#### If Webhook EXISTS:
1. Find your webhook URL: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
2. Click on the webhook to open details
3. Check the **"Status"**:
   - ✅ **"Active"** = Webhook is enabled
   - ❌ **"Disabled"** = Webhook is disabled (needs to be enabled)
   - ⏸️ **"Paused"** = Webhook is paused

4. Click on **"Delivery History"** or **"Logs"** tab
   - This shows all webhook delivery attempts
   - If empty, no events have been sent yet

#### If Webhook DOES NOT EXIST:
1. Click **"Add New Webhook"** or **"Create Webhook"** button
2. Follow the setup instructions in `ENABLE-RAZORPAY-WEBHOOK.md`

---

## How to See Webhook Logs

### Option 1: Delivery History (Most Common)
1. Go to: **Settings → Webhooks**
2. Click on your webhook
3. Click **"Delivery History"** tab
4. You'll see:
   - Timestamp of each webhook call
   - Event type (e.g., `subscription.charged`)
   - Status (200 = success, 401/500 = failed)
   - Response time
   - Request/Response details

### Option 2: Activity Log
1. Go to: **Settings → Activity Log**
2. Filter by **"Webhook"**
3. See all webhook-related activities

### Option 3: Subscription Details
1. Go to: **Payments → Subscriptions**
2. Click on a specific subscription
3. Look for **"Webhook Events"** section
4. See webhook events for that subscription

---

## Why You Might Not See Logs

### Reason 1: Webhook Not Created
**Solution:** Create the webhook first
- Go to Settings → Webhooks
- Click "Add New Webhook"
- Use URL: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
- Select events: `subscription.charged`, `subscription.activated`, etc.

### Reason 2: Webhook is Disabled
**Solution:** Enable the webhook
- Go to Settings → Webhooks
- Click on your webhook
- Click "Enable" or "Activate" button
- Status should change to "Active"

### Reason 3: No Events Triggered
**Solution:** Trigger a webhook event
- Make a test donation
- Or use "Send Test Webhook" feature in Razorpay dashboard
- Then check Delivery History again

### Reason 4: Wrong Mode (Test vs Live)
**Solution:** Check the correct mode
- Make sure you're in **Live Mode** (top-right corner)
- Webhooks are separate for Test and Live modes
- Check both if unsure

### Reason 5: Webhook URL is Wrong
**Solution:** Verify webhook URL
- Should be: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
- Must be HTTPS (not HTTP)
- Must be accessible from internet

---

## Test Webhook to Generate Logs

### Method 1: Send Test Webhook (Easiest)
1. Go to: **Settings → Webhooks**
2. Click on your webhook
3. Click **"Send Test Webhook"** or **"Test"** button
4. Select an event (e.g., `subscription.charged`)
5. Click **"Send"**
6. Check **"Delivery History"** - you should see a new entry

### Method 2: Make a Test Donation
1. Go to your website: `https://theonerupeerevolution.org/donate`
2. Complete a test donation
3. Go back to Razorpay Dashboard → Webhooks → Delivery History
4. You should see webhook events appear

---

## Verify Webhook Endpoint is Working

### Test 1: Check if Endpoint is Accessible
```bash
curl -X POST https://theonerupeerevolution.org/api/donations/razorpay/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Should return: {"received":true,"error":"Invalid signature (logged)"}
# This means the endpoint is working!
```

### Test 2: Check Server Logs
1. Log in to cPanel
2. Go to Node.js App → Logs
3. Look for webhook-related messages:
   - `📥 Webhook received:`
   - `✅ Webhook processed successfully:`
   - `❌ Webhook signature verification failed`

---

## Quick Checklist

- [ ] Logged into Razorpay Dashboard
- [ ] In **Live Mode** (not Test Mode)
- [ ] Navigated to **Settings → Webhooks**
- [ ] Webhook exists with correct URL
- [ ] Webhook status is **"Active"**
- [ ] Clicked on webhook to see details
- [ ] Checked **"Delivery History"** tab
- [ ] Events are selected (especially `subscription.charged`)
- [ ] Made a test donation or sent test webhook
- [ ] Checked server logs in cPanel

---

## If Still No Logs Appear

### Check 1: Webhook Configuration
1. **URL:** Must be exactly: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
2. **Events:** Must include `subscription.charged` (most important)
3. **Status:** Must be "Active"

### Check 2: Server Accessibility
1. Test if endpoint is reachable (use curl command above)
2. Check if server is running
3. Verify `.htaccess` file exists in `public_html/api/`

### Check 3: Webhook Secret
1. Verify `RAZORPAY_WEBHOOK_SECRET` is set in cPanel environment variables
2. Must match the secret shown in Razorpay dashboard
3. Restart Node.js app after setting secret

### Check 4: Recent Activity
1. Webhook logs only appear after events are triggered
2. If you just created the webhook, there won't be logs yet
3. Make a test donation or send test webhook to generate logs

---

## Screenshot Guide: Where to Find Logs

1. **Razorpay Dashboard** → **Settings** (left sidebar)
2. **Webhooks** (in settings menu)
3. **Click on your webhook** (the URL)
4. **Delivery History** tab (or **Logs** tab)
5. **See list of webhook deliveries** with:
   - Timestamp
   - Event name
   - Status (200/401/500)
   - Response time
   - Click to see details

---

## Still Can't See Logs?

1. **Take a screenshot** of your Razorpay Webhooks page
2. **Check if webhook exists** - if not, create it
3. **Check webhook status** - if disabled, enable it
4. **Send a test webhook** - this will create a log entry immediately
5. **Check both Test and Live modes** - webhooks are separate

---

## Next Steps

1. **Verify webhook exists** in Razorpay dashboard
2. **Enable webhook** if it's disabled
3. **Send test webhook** to generate a log entry
4. **Check Delivery History** - you should see the test webhook
5. **Make a real donation** to see actual webhook events

If you still can't see logs after following these steps, the webhook might not be created yet. Follow the setup guide in `ENABLE-RAZORPAY-WEBHOOK.md` to create it.

