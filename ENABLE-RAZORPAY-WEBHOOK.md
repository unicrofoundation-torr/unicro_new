# 🔧 Enable Razorpay Webhook - Quick Guide

## Your Webhook URL
```
https://theonerupeerevolution.org/api/donations/razorpay/webhook
```

---

## Step-by-Step: Enable Webhook in Razorpay

### Step 1: Log in to Razorpay Dashboard
1. Go to: https://dashboard.razorpay.com/
2. Log in with your credentials
3. Make sure you're in **Live Mode** (not Test Mode)

### Step 2: Navigate to Webhooks
1. Click **"Settings"** in the left sidebar
2. Click **"Webhooks"** from the settings menu
3. You'll see a list of webhooks (or empty if none exist)

### Step 3: Enable Existing Webhook OR Create New One

#### Option A: If Webhook Already Exists (Just Disabled)
1. Find your webhook in the list
2. Click on it to open details
3. Click **"Enable"** or **"Activate"** button
4. Make sure it shows **"Active"** status

#### Option B: Create New Webhook
1. Click **"Add New Webhook"** or **"Create Webhook"** button
2. Fill in the details:

### Step 4: Configure Webhook Details

**Webhook URL:**
```
https://theonerupeerevolution.org/api/donations/razorpay/webhook
```

**Active Events (Select ALL of these):**
- ✅ `subscription.activated` - When subscription is first activated
- ✅ `subscription.charged` - **MOST IMPORTANT** - Tracks each recurring payment
- ✅ `subscription.paused` - When subscription is paused
- ✅ `subscription.cancelled` - When subscription is cancelled
- ✅ `subscription.completed` - When subscription completes
- ✅ `payment.failed` - When a payment fails

**Minimum Required:**
- `subscription.charged` (CRITICAL - tracks recurring payments)
- `subscription.activated`
- `subscription.cancelled`
- `payment.failed`

### Step 5: Save and Get Webhook Secret
1. Click **"Save"** or **"Create Webhook"**
2. Razorpay will generate a **Webhook Secret**
3. **Copy this secret immediately** - it looks like: `whsec_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
4. You'll need this for Step 6

### Step 6: Add Webhook Secret to Server

#### In cPanel:
1. Go to **cPanel → Setup Node.js App**
2. Click on your application
3. Scroll to **"Environment Variables"** section
4. Add/Update variable:
   - **Variable Name:** `RAZORPAY_WEBHOOK_SECRET`
   - **Variable Value:** (paste the webhook secret you copied)
5. Click **"Save"**
6. **IMPORTANT:** Click **"Restart App"** to apply changes

### Step 7: Test the Webhook
1. In Razorpay dashboard → Webhooks
2. Find your webhook
3. Click **"Send Test Webhook"** or **"Test"** button
4. Select event: `subscription.charged`
5. Click **"Send Test Event"**
6. Check if it shows "Success" or "200 OK"

---

## ✅ Verify Webhook is Working

### Check Webhook Status:
- Go to Razorpay Dashboard → Settings → Webhooks
- Your webhook should show:
  - Status: **"Active"** (green)
  - Last delivery: Recent timestamp
  - Success rate: Should be high (90%+)

### Check Webhook Delivery History:
1. Click on your webhook
2. Go to **"Delivery History"** tab
3. You should see recent events being sent
4. Status should be **"Success"** (200 OK)

### Test with Real Payment:
1. Make a test donation on your website
2. Complete the payment
3. Check your admin dashboard → Donations
4. The donation should appear automatically
5. For recurring donations, each charge should create a new transaction

---

## 🔍 Troubleshooting

### Webhook Shows "Failed" or "Disabled"
- Check if the URL is correct (must be HTTPS)
- Verify the endpoint is accessible
- Check server logs for errors

### Webhook Not Receiving Events
1. **Verify URL is correct:**
   - Must be: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
   - No trailing slash
   - Must be HTTPS (not HTTP)

2. **Check Webhook Secret:**
   - Must match exactly in environment variable
   - No extra spaces
   - Restart server after adding

3. **Check Events Selected:**
   - Make sure `subscription.charged` is selected
   - Webhook must be "Active" (not paused)

### Webhook Returns 401 Error
- **Invalid signature** - Webhook secret doesn't match
- Check `RAZORPAY_WEBHOOK_SECRET` in environment variables
- Make sure you're using webhook secret, not API key secret

### Webhook Returns 500 Error
- Check server logs in cPanel
- Verify database connection
- Check if tables exist

---

## 📋 Quick Checklist

- [ ] Webhook URL is correct: `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
- [ ] Webhook status is **"Active"** (not disabled/paused)
- [ ] Events selected: `subscription.charged`, `subscription.activated`, `subscription.cancelled`, `payment.failed`
- [ ] Webhook secret copied from Razorpay dashboard
- [ ] `RAZORPAY_WEBHOOK_SECRET` added to cPanel environment variables
- [ ] Node.js app restarted after adding webhook secret
- [ ] Test webhook sent successfully
- [ ] Webhook delivery history shows successful deliveries

---

## 🎯 What Webhooks Do

When enabled, webhooks automatically:
- ✅ Create donor records when payment succeeds
- ✅ Update donation status automatically
- ✅ Track each recurring payment transaction
- ✅ Update status when subscription is cancelled/paused
- ✅ Handle payment failures

**Without webhooks:**
- You need to manually sync using "Sync with Razorpay" button
- Recurring payments won't be tracked automatically
- Status updates won't happen in real-time

---

## 💡 Pro Tip

After enabling the webhook:
1. Use "Sync with Razorpay" button to backfill any missing data
2. Monitor webhook delivery history for a few days
3. Check that recurring payments are being tracked automatically

---

**Need Help?**
- Check Razorpay Dashboard → Webhooks → Delivery History for detailed logs
- Check your server logs in cPanel for backend errors
- Verify environment variables are set correctly

