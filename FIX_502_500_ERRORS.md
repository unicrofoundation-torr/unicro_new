# Fix 502/500 Errors - Step by Step Guide

## Issues Found:
1. ❌ `server.js` is outdated on server (needs deployment)
2. ❌ Environment variables NOT SET in cPanel

## Step 1: Deploy Updated server.js

Run this in **WSL** (not PowerShell):

```bash
# In WSL terminal
cd "/mnt/e/kanishk data/projects/UNICRO"

# Deploy server.js
rsync -avz -e "ssh -i ~/.ssh/key_private -p 21098" \
  server.js \
  theomkiq@server357.web-hosting.com:~/nodejs/
```

## Step 2: Fix database.js on Server

Run this in **WSL**:

```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com << 'EOF'
cd ~/nodejs/config

# Backup
cp database.js database.js.backup.$(date +%Y%m%d_%H%M%S)

# Update
cat > database.js << 'DBEOF'
const mysql = require('mysql2');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'theomkiq_charity',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

module.exports = pool.promise();
DBEOF

echo "✅ database.js updated"
EOF
```

## Step 3: Set Environment Variables in cPanel ⚠️ CRITICAL

**This is the most important step!**

1. Go to **cPanel → Setup Node.js App**
2. Click on your app (or create one if it doesn't exist)
3. Scroll down to **"Environment Variables"** section
4. Click **"Add Variable"** for each of these:

```
NODE_ENV = production
PORT = 5000
DB_HOST = localhost
DB_USER = theomkiq_charity
DB_PASSWORD = Unicro@001
DB_NAME = theomkiq_charity
JWT_SECRET = your-secret-key-here
RAZORPAY_KEY_ID = rzp_live_RhWOsPuVUOT0Xx
RAZORPAY_KEY_SECRET = your_razorpay_secret_key
RAZORPAY_WEBHOOK_SECRET = whsec_xxxxxxxxxxxxx
```

**Important:** 
- Replace `your-secret-key-here` with a random secret string
- Replace `your_razorpay_secret_key` with your actual Razorpay secret key
- Replace `whsec_xxxxxxxxxxxxx` with your actual webhook secret

5. Click **"Save"** after adding all variables

## Step 4: Restart Node.js App

1. In cPanel → Setup Node.js App
2. Click **"Stop App"** (wait 10 seconds)
3. Click **"Start App"** / **"Restart App"**
4. Wait 30-60 seconds for the app to start

## Step 5: Verify

1. Check that environment variables are set:
   - In cPanel → Setup Node.js App → Your App
   - Scroll to "Environment Variables"
   - Verify all variables are listed

2. Test the API:
   - Visit: `https://theonerupeerevolution.org/api/settings`
   - Should return JSON data (not 502/500 error)

## Step 6: If Still Getting Errors

Run diagnostic again in WSL:

```bash
bash diagnose_server.sh
```

Check:
- ✅ Environment variables should now show values (not "NOT SET")
- ✅ server.js should show `module.exports = app` in last lines

## Common Issues:

### Issue: "Environment variables not persisting"
- Make sure you click "Save" after adding each variable
- Some cPanel versions require you to restart the app after adding variables

### Issue: "Still getting 502 error"
- Check that the app is actually running (green status in cPanel)
- Check "Application URL" is set correctly (should be `/` or `/api`)
- Wait 60 seconds after restart before testing

### Issue: "Still getting 500 error"
- Check database credentials are correct
- Verify database `theomkiq_charity` exists in cPanel → MySQL Databases
- Check that database user `theomkiq_charity` has permissions

## Quick Checklist:

- [ ] Deployed updated `server.js` to server
- [ ] Fixed `database.js` on server
- [ ] Set all environment variables in cPanel
- [ ] Restarted Node.js app
- [ ] Waited 60 seconds
- [ ] Tested API endpoint

