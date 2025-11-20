# 🔧 Troubleshoot Backend Not Working in cPanel

## Quick Diagnosis Steps

### Step 1: Check Node.js App Status

1. **Go to cPanel → Setup Node.js App**
2. **Check your application status:**
   - ✅ **Running/Active** = App is running
   - ❌ **Stopped/Inactive** = App is NOT running

**If stopped:**
- Click **"Restart App"** button
- Wait 10-30 seconds
- Check status again

---

### Step 2: Check Application Status & Errors

**If "View Logs" button exists:**
1. **In cPanel → Setup Node.js App → Your App**
2. **Click "View Logs"** or **"Passenger Log File"**
3. **Look for errors:**

**If "View Logs" button doesn't exist (common):**
1. **Check app status** - Should show "Running" or "Stopped"
2. **Test API directly** (see Step 5 below)
3. **Check via SSH** (see alternative methods below)

**Good signs (✅):**
```
Server is running on port 5000
Database connection successful
```

**Bad signs (❌):**
```
Error: Cannot find module 'express'
Error: Cannot find module 'mysql2'
Error: EADDRINUSE: address already in use
Database connection failed
```

**Common errors and fixes:**

#### Error: "Cannot find module 'xxx'"
**Fix:** Dependencies not installed
```bash
# Via SSH
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
npm install --production
exit
```

**Or via cPanel:**
- Go to Setup Node.js App → Your App
- Click "NPM Install" button

#### Error: "Database connection failed"
**Fix:** Check environment variables
- Go to Setup Node.js App → Your App → Environment Variables
- Verify:
  ```
  DB_HOST=localhost
  DB_USER=theomkiq_charity
  DB_PASSWORD=Unicro@001
  DB_NAME=theomkiq_charity_website
  ```

#### Error: "EADDRINUSE: address already in use"
**Fix:** Port conflict
- Restart the app
- Or change PORT in environment variables

---

### Step 3: Verify Backend Files

1. **Go to cPanel → File Manager**
2. **Navigate to `~/nodejs/`** (or your app root)
3. **Check these files exist:**
   - ✅ `server.js`
   - ✅ `package.json`
   - ✅ `routes/` folder
   - ✅ `config/` folder
   - ✅ `node_modules/` folder (should exist after npm install)

**If files are missing:**
- Re-run deployment script
- Or manually upload missing files

---

### Step 4: Check Environment Variables

1. **Go to cPanel → Setup Node.js App → Your App**
2. **Scroll to "Environment Variables"**
3. **Verify these are set:**

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
JWT_SECRET=your-secret-key-here

# Razorpay (if using payments)
RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your_razorpay_secret_key
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

**Important:**
- No spaces around `=` sign
- No quotes around values
- Values must match your actual credentials

---

### Step 5: Test API Endpoints

Open these URLs in your browser:

- `https://theonerupeerevolution.org/api/settings`
- `https://theonerupeerevolution.org/api/slider`
- `https://theonerupeerevolution.org/api/gallery`

**Expected (✅ Working):**
```json
{
  "site_name": {...},
  "site_logo": {...},
  ...
}
```

**Wrong (❌ Not Working):**
- Empty page
- HTML page (React app)
- 404 error
- 500 error
- "No routes matched location /api/settings"

---

### Step 6: Check Application URL Configuration

1. **In cPanel → Setup Node.js App → Your App**
2. **Check "Application URL":**
   - Should be: `/api` or `/` or empty
   - This affects how API routes are accessed

**If Application URL is `/api`:**
- API should work at: `https://theonerupeerevolution.org/api/settings`
- Make sure `public_html/api/.htaccess` exists (see FIX_HTACCESS_ERROR_QUICK.md)

**If Application URL is `/` or empty:**
- API should work at: `https://theonerupeerevolution.org/api/settings`
- Backend handles all routes

---

## Common Issues & Solutions

### Issue 1: API Returns HTML Instead of JSON

**Problem:** Backend not running or not accessible

**Solution:**
1. Check Node.js app is **Running** in cPanel
2. Check environment variables are set
3. Check application logs for errors
4. Restart the app

---

### Issue 2: "Cannot find module" Errors

**Problem:** Dependencies not installed

**Solution:**

**Option A: Via cPanel**
1. Go to Setup Node.js App → Your App
2. Click **"NPM Install"** button
3. Wait for installation to complete

**Option B: Via SSH**
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
npm install --production
exit
```

---

### Issue 3: Database Connection Failed

**Problem:** Wrong database credentials or database doesn't exist

**Solution:**
1. Check environment variables match your cPanel database
2. Verify database exists in cPanel → MySQL Databases
3. Check database user has proper permissions
4. Test connection via phpMyAdmin

---

### Issue 4: Port Already in Use

**Problem:** Another process using port 5000

**Solution:**
1. Restart the Node.js app
2. Or change PORT in environment variables (e.g., `PORT=5001`)
3. Update Application URL if needed

---

### Issue 5: Application URL Mismatch

**Problem:** Application URL doesn't match API routes

**Solution:**
- If Application URL is `/api`, API routes work at `/api/*`
- If Application URL is `/`, API routes work at `/api/*` (backend handles all)
- Make sure `server.js` has routes defined as `/api/*`

---

### Issue 6: Files Not Uploaded

**Problem:** Backend files missing on server

**Solution:**
1. Re-run deployment script: `bash deploy_full.sh`
2. Or manually upload files via File Manager
3. Check `~/nodejs/` directory has all files

---

## Quick Fix Checklist

Run through this checklist:

- [ ] Node.js app status is **"Running"**
- [ ] Environment variables are set correctly
- [ ] `node_modules/` folder exists in `~/nodejs/`
- [ ] `server.js` exists in `~/nodejs/`
- [ ] Application logs show no errors
- [ ] API endpoint returns JSON (not HTML)
- [ ] Database credentials are correct
- [ ] Application URL is configured correctly

---

## Manual Restart Steps

If nothing works, try this:

1. **Stop the app:**
   - Go to Setup Node.js App
   - Click "Stop App"

2. **Install dependencies:**
   - Click "NPM Install"
   - Wait for completion

3. **Check environment variables:**
   - Verify all are set correctly
   - Save if you made changes

4. **Start the app:**
   - Click "Restart App"
   - Wait 10-30 seconds

5. **Check logs:**
   - Click "View Logs"
   - Look for errors

6. **Test API:**
   - Visit: `https://theonerupeerevolution.org/api/settings`
   - Should return JSON

---

## Get Detailed Error Information

### Via SSH

```bash
# Connect to server
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# Check if app is running
cd ~/nodejs
ps aux | grep node

# Check application logs
tail -f ~/nodejs/logs/*.log

# Or check Passenger logs
tail -f ~/logs/passenger.log

# Check if dependencies are installed
ls -la ~/nodejs/node_modules/

# Try running manually (to see errors)
cd ~/nodejs
node server.js
```

---

## Still Not Working?

If backend still doesn't work after trying everything:

1. **Check deployment logs:**
   - Look in `logs/deploy_full_*.log`
   - See if files were uploaded correctly

2. **Check cPanel error logs:**
   - cPanel → Errors
   - Look for recent errors

3. **Contact hosting support:**
   - Provide them with:
     - Application logs
     - Error messages
     - What you've tried

---

## Test Commands

### Test API from Command Line

```bash
# Test API endpoint
curl https://theonerupeerevolution.org/api/settings

# Should return JSON, not HTML
```

### Test Database Connection

```bash
# Via SSH
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
node -e "const db = require('./config/database'); db.execute('SELECT 1').then(() => console.log('DB OK')).catch(e => console.error('DB Error:', e));"
```

---

**Most Common Fix:** Install dependencies and restart the app! 🔄

