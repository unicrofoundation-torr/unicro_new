# Razorpay Webhook Configuration Guide

This guide will help you configure the Razorpay webhook to track recurring payment transactions automatically.

## Prerequisites

- Razorpay account (Live mode)
- Your website domain (e.g., `theonerupeerevolution.org`)
- Access to your server's environment variables

## Step 1: Get Your Webhook Secret

1. **Log in to Razorpay Dashboard**
   - Go to https://dashboard.razorpay.com/
   - Log in with your credentials

2. **Navigate to Settings → Webhooks**
   - Click on **Settings** in the left sidebar
   - Click on **Webhooks** from the settings menu

3. **Create a New Webhook**
   - Click **"Add New Webhook"** or **"Create Webhook"** button
   - You'll see a form to configure the webhook

## Step 2: Configure Webhook Details

Fill in the webhook configuration:

### Webhook URL
```
https://theonerupeerevolution.org/api/donations/razorpay/webhook
```

**Important:** 
- Replace `theonerupeerevolution.org` with your actual domain
- The URL must be accessible via HTTPS (not HTTP)
- The path `/api/donations/razorpay/webhook` must match exactly

### Active Events (Select these events)

Select the following events that you want to receive:

✅ **Subscription Events:**
- `subscription.activated` - When subscription is first activated
- `subscription.charged` - When a recurring payment is charged (IMPORTANT for tracking)
- `subscription.paused` - When subscription is paused
- `subscription.cancelled` - When subscription is cancelled
- `subscription.completed` - When subscription completes all payments

✅ **Payment Events:**
- `payment.failed` - When a payment fails
- `payment.captured` - When payment is captured (optional)

**Minimum Required Events:**
- `subscription.charged` (MOST IMPORTANT - tracks each recurring payment)
- `subscription.activated`
- `subscription.cancelled`
- `payment.failed`

### Webhook Secret

1. After creating the webhook, Razorpay will generate a **Webhook Secret**
2. **Copy this secret immediately** - you'll need it for your environment variables
3. The secret looks like: `whsec_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

## Step 3: Set Environment Variable

Add the webhook secret to your server's environment variables:

### For cPanel Node.js App:

1. Go to **cPanel → Node.js App**
2. Click on your application
3. Scroll to **"Environment Variables"** section
4. Add a new variable:
   - **Variable Name:** `RAZORPAY_WEBHOOK_SECRET`
   - **Variable Value:** (paste the webhook secret you copied)
5. Click **"Save"**
6. **Restart your Node.js application**

### For Local Development (.env file):

Add to your `.env` file:
```env
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Step 4: Test the Webhook

### Option 1: Test via Razorpay Dashboard

1. Go to **Settings → Webhooks** in Razorpay dashboard
2. Find your webhook
3. Click **"Send Test Webhook"** or **"Test"**
4. Select event: `subscription.charged`
5. Click **"Send Test Event"**
6. Check your server logs to see if the webhook was received

### Option 2: Test with Real Subscription

1. Create a test subscription on your donation page
2. Complete the payment
3. Check your admin panel → Donations section
4. You should see the transaction count increase
5. Click "View Payments" to see individual payment records

## Step 5: Verify Webhook is Working

### Check Server Logs

Look for these log messages:
- ✅ `Subscription charged: {subscription_id}` - Webhook received successfully
- ❌ `Razorpay webhook error:` - There's an issue

### Check Admin Panel

1. Go to **Admin Panel → Donations**
2. Find a donation with a subscription
3. Check the **"Payments"** column - should show count > 0
4. Click **"View Payments"** to see individual transactions
5. Each recurring charge should create a new transaction record

## Troubleshooting

### Webhook Not Receiving Events

1. **Check URL is correct:**
   - Must be HTTPS (not HTTP)
   - Must match exactly: `/api/donations/razorpay/webhook`
   - No trailing slash

2. **Check Webhook Secret:**
   - Must match exactly in environment variable
   - No extra spaces or quotes
   - Restart server after adding environment variable

3. **Check Server Logs:**
   ```bash
   # In cPanel, check application logs
   # Or check server.log file
   ```

4. **Test Webhook URL:**
   - Use a tool like Postman or curl to test if the endpoint is accessible
   - Should return 401 (Unauthorized) without proper signature (this is expected)

### Webhook Returns 401 Error

- **Invalid signature** - Check that `RAZORPAY_WEBHOOK_SECRET` matches the secret in Razorpay dashboard
- **Wrong secret** - Make sure you're using the webhook secret, not the API key secret

### Webhook Returns 500 Error

- Check server logs for detailed error messages
- Verify database connection
- Check if `payment_transactions` table exists

### Events Not Being Tracked

1. **Verify events are selected:**
   - Go to Razorpay dashboard → Webhooks
   - Check that `subscription.charged` is selected

2. **Check webhook status:**
   - Webhook should be **"Active"** (not paused or disabled)

3. **Check webhook delivery:**
   - In Razorpay dashboard, you can see webhook delivery history
   - Check if events are being sent and if they're successful

## Webhook URL Format

**Production:**
```
https://theonerupeerevolution.org/api/donations/razorpay/webhook
```

**Development/Testing:**
```
http://localhost:5000/api/donations/razorpay/webhook
```
(Note: Razorpay can't send webhooks to localhost. Use a service like ngrok for local testing)

## Important Notes

1. **HTTPS Required:** Razorpay only sends webhooks to HTTPS URLs in production
2. **Webhook Secret:** Keep this secret secure and never commit it to version control
3. **Idempotency:** The webhook handler prevents duplicate transactions by checking payment IDs
4. **Retry Logic:** Razorpay automatically retries failed webhook deliveries
5. **Event Order:** Events may arrive out of order, but the system handles this correctly

## Security

- The webhook endpoint verifies the signature using HMAC SHA256
- Only requests with valid signatures are processed
- Invalid signatures return 401 (Unauthorized)

## Support

If you encounter issues:
1. Check Razorpay dashboard → Webhooks → Delivery History
2. Check your server application logs
3. Verify environment variables are set correctly
4. Test the webhook URL accessibility

---

**Last Updated:** January 2025

