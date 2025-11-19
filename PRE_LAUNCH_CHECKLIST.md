# 🚀 Pre-Launch Checklist - Payment Integration Ready

This checklist ensures your website is ready for production hosting with Razorpay payment integration.

## ✅ Code Implementation Status

### Payment Integration
- ✅ Razorpay subscription integration implemented
- ✅ Recurring donations (weekly/monthly/yearly) working
- ✅ Payment transaction tracking system
- ✅ Admin panel donations management
- ✅ Email and phone validation
- ✅ Webhook handler for recurring payments

### Frontend
- ✅ Donation form with cycle selection
- ✅ Custom amount input
- ✅ Form validation
- ✅ Success/error handling
- ✅ Responsive design

### Backend
- ✅ Razorpay API integration
- ✅ Subscription creation
- ✅ Payment transaction tracking
- ✅ Database schema for donations
- ✅ Webhook endpoint configured

---

## 🔧 Required Environment Variables

### Backend (cPanel Node.js App Environment Variables)

Add these in **cPanel → Node.js App → Your App → Environment Variables**:

```env
# Database
DB_HOST=localhost
DB_USER=theomkiq_charity
DB_PASSWORD=Unicro@001
DB_NAME=theomkiq_charity_website

# Server
NODE_ENV=production
PORT=5000

# Security
JWT_SECRET=your-strong-random-secret-key-here

# Razorpay (REQUIRED for payments)
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your_razorpay_secret_key
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

### Frontend (Build-time Environment Variables)

Add to your build process or `.env` file in `client/` directory:

```env
REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxx
REACT_APP_API_URL=/api
```

**Note:** For production builds, you can also set these during the build command:
```bash
REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxx npm run build
```

---

## 🔑 Razorpay Configuration Checklist

### 1. Get Razorpay Credentials

- [ ] **Razorpay Key ID** (starts with `rzp_live_` for production)
  - Location: Razorpay Dashboard → Settings → API Keys
  - Copy the **Key ID**

- [ ] **Razorpay Key Secret** 
  - Location: Razorpay Dashboard → Settings → API Keys
  - Click "Reveal" to see the secret key
  - Copy the **Key Secret**

- [ ] **Webhook Secret** (after creating webhook)
  - Location: Razorpay Dashboard → Settings → Webhooks
  - Copy the secret after creating webhook

### 2. Configure Webhook (CRITICAL!)

- [ ] Go to Razorpay Dashboard → Settings → Webhooks
- [ ] Click "Add New Webhook"
- [ ] **Webhook URL:** `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
- [ ] **Select Events:**
  - ✅ `subscription.charged` (MOST IMPORTANT)
  - ✅ `subscription.activated`
  - ✅ `subscription.cancelled`
  - ✅ `subscription.paused`
  - ✅ `payment.failed`
- [ ] Copy the **Webhook Secret** and add to environment variables
- [ ] Test the webhook using "Send Test Webhook" button

### 3. Verify Razorpay Account

- [ ] Account is in **Live Mode** (not Test Mode)
- [ ] Account is activated and verified
- [ ] Bank account is linked for settlements
- [ ] KYC documents are submitted (if required)

---

## 🗄️ Database Setup

- [ ] Database exists in cPanel
- [ ] Database user has proper permissions
- [ ] Tables will be created automatically on first API call
- [ ] Database credentials are correct in environment variables

**Tables that will be auto-created:**
- `donors`
- `donations`
- `payment_transactions`

---

## 🌐 Frontend Build Configuration

### Build Command

Make sure your build includes the Razorpay Key ID:

```bash
cd client
REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxx npm run build
```

Or update `package.json` build script:
```json
"build": "REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxx react-scripts build"
```

### API URL Configuration

- [ ] Frontend is configured to use `/api` in production
- [ ] Check `client/src/services/api.js` - should use `/api` for production

---

## 🔒 Security Checklist

- [ ] **JWT_SECRET** is a strong random string (not default)
- [ ] **RAZORPAY_KEY_SECRET** is kept secure (never commit to git)
- [ ] **RAZORPAY_WEBHOOK_SECRET** is kept secure
- [ ] Environment variables are set in cPanel (not in code)
- [ ] HTTPS is enabled on your domain
- [ ] Admin panel is password protected

---

## 📦 Deployment Steps

### 1. Build Frontend
```bash
cd client
REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxx npm run build
```

### 2. Deploy Files
- [ ] Frontend build (`client/build/`) → `public_html/`
- [ ] Backend files → `nodejs/`

### 3. Set Environment Variables
- [ ] Add all required environment variables in cPanel
- [ ] Double-check Razorpay credentials

### 4. Install Dependencies
- [ ] Run `npm install --production` in `nodejs/` directory

### 5. Restart Application
- [ ] Restart Node.js app in cPanel
- [ ] Check application logs for errors

---

## 🧪 Testing Checklist

### Before Going Live

#### 1. Test API Endpoints
- [ ] `https://yourdomain.com/api/settings` - Returns JSON
- [ ] `https://yourdomain.com/api/donations/admin` - Requires auth
- [ ] `https://yourdomain.com/api/donations/razorpay/webhook` - Returns 401 (expected without signature)

#### 2. Test Donation Flow
- [ ] Visit donation page
- [ ] Select a cycle (weekly/monthly/yearly)
- [ ] Enter donor details
- [ ] Submit donation
- [ ] Razorpay checkout opens
- [ ] Complete test payment (use Razorpay test cards)
- [ ] Check admin panel - donation appears
- [ ] Check payment transactions appear

#### 3. Test Recurring Payments
- [ ] Create a test subscription
- [ ] Wait for first charge (or use Razorpay dashboard to trigger)
- [ ] Check webhook receives event
- [ ] Check admin panel - transaction count increases
- [ ] View individual payment transactions

#### 4. Test Admin Panel
- [ ] Login works
- [ ] Donations section shows donations
- [ ] Payment transactions are visible
- [ ] "View Payments" button works

#### 5. Test Webhook
- [ ] Use Razorpay dashboard "Send Test Webhook"
- [ ] Check server logs - webhook received
- [ ] Check database - transaction created

---

## 🚨 Common Issues & Solutions

### Payment Not Working
- ✅ Check `REACT_APP_RAZORPAY_KEY_ID` is set in frontend build
- ✅ Check Razorpay keys are in **Live Mode** (not test)
- ✅ Check browser console for errors
- ✅ Verify Razorpay account is activated

### Webhook Not Receiving Events
- ✅ Check webhook URL is correct and HTTPS
- ✅ Check `RAZORPAY_WEBHOOK_SECRET` matches Razorpay dashboard
- ✅ Check webhook is "Active" in Razorpay dashboard
- ✅ Check server logs for webhook errors

### Transactions Not Appearing
- ✅ Check webhook is configured correctly
- ✅ Check `payment_transactions` table exists
- ✅ Check webhook events are selected in Razorpay
- ✅ Verify webhook secret is correct

### Build Errors
- ✅ Check all environment variables are set
- ✅ Check Node.js version compatibility
- ✅ Check npm dependencies are installed

---

## 📋 Final Pre-Launch Checklist

### Must Have (Critical)
- [ ] Razorpay account in Live Mode
- [ ] Razorpay Key ID and Secret configured
- [ ] Webhook configured and tested
- [ ] Webhook Secret in environment variables
- [ ] Frontend built with `REACT_APP_RAZORPAY_KEY_ID`
- [ ] Database credentials correct
- [ ] HTTPS enabled on domain
- [ ] Test payment completed successfully

### Should Have (Important)
- [ ] Admin panel tested
- [ ] Donation form tested
- [ ] Email validation working
- [ ] Phone validation working
- [ ] Error handling tested
- [ ] Success messages working

### Nice to Have (Optional)
- [ ] Analytics tracking
- [ ] Email notifications
- [ ] Receipt generation
- [ ] Donor dashboard

---

## 🎯 Quick Start Commands

### Build for Production
```bash
cd client
REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxx npm run build
```

### Test Webhook Locally (using ngrok)
```bash
# Install ngrok
ngrok http 5000

# Use ngrok URL in Razorpay webhook:
# https://xxxxx.ngrok.io/api/donations/razorpay/webhook
```

### Check Environment Variables
```bash
# In cPanel Node.js App, verify all variables are set
```

---

## ✅ Ready to Launch?

Once all items above are checked:

1. ✅ **Deploy** your code
2. ✅ **Configure** environment variables
3. ✅ **Test** a real payment (small amount)
4. ✅ **Monitor** webhook deliveries in Razorpay dashboard
5. ✅ **Check** admin panel for transactions
6. ✅ **Go Live!** 🚀

---

## 📞 Support Resources

- **Razorpay Dashboard:** https://dashboard.razorpay.com/
- **Razorpay Docs:** https://razorpay.com/docs/
- **Webhook Setup Guide:** See `RAZORPAY_WEBHOOK_SETUP.md`
- **Server Logs:** Check cPanel → Node.js App → Logs

---

**Last Updated:** January 2025

