# 🚀 Deploy Website to cPanel via WSL - Complete Guide

This guide will help you deploy your website with Razorpay payment integration to cPanel using WSL (Windows Subsystem for Linux).

## 📋 Prerequisites

Before starting, make sure you have:

- ✅ **WSL installed** (Ubuntu recommended)
- ✅ **SSH key** configured for cPanel access
- ✅ **Razorpay credentials** ready:
  - Key ID (starts with `rzp_live_`)
  - Key Secret
  - Webhook Secret (after creating webhook)
- ✅ **cPanel access** with Node.js App created
- ✅ **Database credentials** from cPanel

---

## 🔧 Step 1: Update Deployment Script

### 1.1 Open the Script in WSL

```bash
# In WSL terminal
cd /mnt/e/kanishk\ data/projects/UNICRO
nano deploy_full.sh
```

### 1.2 Update Configuration

Find and update these variables at the top of the file:

```bash
# Database Credentials (cPanel)
REMOTE_DB_USER="theomkiq_charity"          # Your cPanel database user
REMOTE_DB_PASS="Unicro@001"                # Your cPanel database password
REMOTE_DB_NAME="theomkiq_charity_website"  # Your cPanel database name

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"        # Path to your SSH private key
CPANEL_USER="theomkiq"                     # Your cPanel username
CPANEL_HOST="server357.web-hosting.com"    # Your cPanel server
CPANEL_PORT=21098                          # Your SSH port

# Razorpay Key ID (IMPORTANT!)
RAZORPAY_KEY_ID="rzp_live_xxxxxxxxxxxxx"    # 👈 UPDATE THIS!
```

**Important:** Replace `RAZORPAY_KEY_ID` with your actual Razorpay Key ID from the dashboard!

### 1.3 Save and Exit

- Press `Ctrl + X`
- Press `Y` to confirm
- Press `Enter` to save

---

## 🔑 Step 2: Get Razorpay Credentials

### 2.1 Get Razorpay Key ID and Secret

1. Go to: https://dashboard.razorpay.com/
2. Navigate to: **Settings → API Keys**
3. Copy:
   - **Key ID** (starts with `rzp_live_`)
   - **Key Secret** (click "Reveal" to see it)

### 2.2 Create Webhook (for recurring payments)

1. Go to: **Settings → Webhooks**
2. Click: **"Add New Webhook"**
3. **Webhook URL:** `https://theonerupeerevolution.org/api/donations/razorpay/webhook`
4. **Select Events:**
   - ✅ `subscription.charged`
   - ✅ `subscription.activated`
   - ✅ `subscription.cancelled`
   - ✅ `subscription.paused`
   - ✅ `payment.failed`
5. Copy the **Webhook Secret** (starts with `whsec_`)

---

## 🚀 Step 3: Deploy via WSL

### 3.1 Open WSL Terminal

```bash
# Open WSL (Ubuntu) from Windows Start Menu
# Or press: Windows Key + R, type: wsl, press Enter
```

### 3.2 Navigate to Project

```bash
cd /mnt/e/kanishk\ data/projects/UNICRO
```

### 3.3 Make Script Executable (First Time Only)

```bash
chmod +x deploy_full.sh
```

### 3.4 Run Deployment

```bash
bash deploy_full.sh
```

The script will:
1. ✅ Backup local database
2. ✅ Install client dependencies
3. ✅ Build React frontend (with Razorpay Key ID)
4. ✅ Deploy frontend to `public_html/`
5. ✅ Deploy backend to `nodejs/`
6. ✅ Install backend dependencies

**Expected Time:** 3-5 minutes

---

## ⚙️ Step 4: Configure Environment Variables in cPanel

### 4.1 Access cPanel

1. Go to: https://your-cpanel-url.com:2083
2. Login with your credentials
3. Navigate to: **Setup Node.js App**

### 4.2 Add Environment Variables

Click on your Node.js application, then scroll to **"Environment Variables"** section.

Add these variables:

```env
# Server
NODE_ENV=production
PORT=5000

# Database
DB_HOST=localhost
DB_USER=theomkiq_charity
DB_PASSWORD=Unicro@001
DB_NAME=theomkiq_charity_website

# Security
JWT_SECRET=your-strong-random-secret-key-here

# Razorpay (REQUIRED for payments)
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your_razorpay_secret_key
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

**Important:**
- Replace all values with your actual credentials
- Use **Live Mode** keys (not test keys)
- Keep secrets secure (never commit to git)

### 4.3 Save and Restart

1. Click **"Save"** button
2. Click **"Restart App"** button
3. Wait 10-30 seconds for app to restart

---

## 📦 Step 5: Install Dependencies (if needed)

If dependencies weren't installed automatically:

### Option A: Using cPanel

1. Go to: **Setup Node.js App → Your App**
2. Click: **"NPM Install"** button
3. Wait for installation to complete

### Option B: Using SSH

```bash
# In WSL
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
npm install --production
exit
```

---

## ✅ Step 6: Verify Deployment

### 6.1 Test API Endpoints

Open these URLs in your browser:

- ✅ `https://theonerupeerevolution.org/api/settings`
- ✅ `https://theonerupeerevolution.org/api/slider`
- ✅ `https://theonerupeerevolution.org/api/gallery`
- ✅ `https://theonerupeerevolution.org/api/navigation`

**Expected:** JSON data like `[{...}]` or `{...}`  
**Wrong:** HTML page or 404/500 error

### 6.2 Test Frontend

1. Visit: `https://theonerupeerevolution.org`
2. Open **DevTools** (F12)
3. Check **Console** tab - should have no errors
4. Check **Network** tab - API calls should return JSON

### 6.3 Test Payment Integration

1. Visit: `https://theonerupeerevolution.org/donate`
2. Fill in donation form:
   - Select cycle (weekly/monthly/yearly)
   - Enter donor details
   - Submit donation
3. Razorpay checkout should open
4. Complete test payment
5. Check admin panel → Donations section
6. Verify donation appears with transaction count

### 6.4 Test Admin Panel

1. Visit: `https://theonerupeerevolution.org/admin/login`
2. Login with admin credentials
3. Go to: **Donations** section
4. Verify donations are visible
5. Click **"View Payments"** to see transactions

---

## 🔧 Troubleshooting

### Issue 1: SSH Connection Failed

**Error:** `Permission denied (publickey)`

**Solution:**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/key_private

# Test SSH connection
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
```

### Issue 2: Build Fails

**Error:** `npm run build` fails

**Solution:**
```bash
# Check if Razorpay Key ID is set
echo $RAZORPAY_KEY_ID

# Install dependencies
cd client
npm install --legacy-peer-deps
npm run build
```

### Issue 3: Payment Not Working

**Problem:** Razorpay checkout doesn't open

**Solution:**
- ✅ Check `REACT_APP_RAZORPAY_KEY_ID` is set in build
- ✅ Check Razorpay keys are in **Live Mode**
- ✅ Check browser console for errors
- ✅ Verify Razorpay account is activated

### Issue 4: Webhook Not Working

**Problem:** Recurring payments not tracked

**Solution:**
- ✅ Check webhook URL is correct in Razorpay dashboard
- ✅ Check `RAZORPAY_WEBHOOK_SECRET` matches dashboard
- ✅ Check webhook is "Active" in Razorpay dashboard
- ✅ Test webhook using "Send Test Webhook" button

### Issue 5: API Returns HTML

**Problem:** API endpoints return React app instead of JSON

**Solution:**
1. Check Node.js app is **Running** in cPanel
2. Check environment variables are set correctly
3. Check application logs for errors
4. Verify API routes are configured

---

## 📋 Quick Reference Commands

### Deploy Website
```bash
cd /mnt/e/kanishk\ data/projects/UNICRO
bash deploy_full.sh
```

### Check Deployment Logs
```bash
cd /mnt/e/kanishk\ data/projects/UNICRO
ls -la logs/
tail -f logs/deploy_full_*.log
```

### Test SSH Connection
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
```

### Build Frontend Manually
```bash
cd /mnt/e/kanishk\ data/projects/UNICRO/client
export REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxx
npm run build
```

---

## ✅ Pre-Launch Checklist

Before going live, verify:

- [ ] Razorpay Key ID updated in `deploy_full.sh`
- [ ] Razorpay account is in **Live Mode**
- [ ] Webhook configured in Razorpay dashboard
- [ ] All environment variables set in cPanel
- [ ] Node.js app is **Running** in cPanel
- [ ] API endpoints return JSON (not HTML)
- [ ] Frontend loads without errors
- [ ] Test payment completed successfully
- [ ] Admin panel shows donations
- [ ] Webhook test successful

---

## 🎯 Next Steps After Deployment

1. **Monitor Logs:**
   - Check cPanel → Node.js App → Logs
   - Monitor for errors or warnings

2. **Test Everything:**
   - Test donation flow
   - Test admin panel
   - Test recurring payments

3. **Configure Webhook:**
   - Follow `RAZORPAY_WEBHOOK_SETUP.md` guide
   - Test webhook delivery

4. **Go Live!** 🚀

---

## 📞 Need Help?

If you encounter issues:

1. **Check Logs:**
   - Deployment logs: `logs/deploy_full_*.log`
   - Application logs: cPanel → Node.js App → Logs

2. **Verify Configuration:**
   - SSH credentials
   - Database credentials
   - Razorpay credentials
   - Environment variables

3. **Test Components:**
   - SSH connection
   - API endpoints
   - Frontend build
   - Payment integration

---

**Happy Deploying! 🚀**

