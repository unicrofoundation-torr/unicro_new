# 🐌 Fix: API Taking Too Long to Load

## Problem

`https://theonerupeerevolution.org/api/settings` is taking too long to respond.

## Possible Causes

### 1. Razorpay Initialization Blocking (Most Likely)

The Razorpay module is initialized when `routes/donations.js` loads, which might be causing delays if:
- Razorpay keys are invalid
- Network timeout trying to connect to Razorpay
- Module loading issues

### 2. Database Connection Slow

Database connection might be slow or timing out.

### 3. App Still Restarting

App might still be in a restart loop from the 508 error.

---

## Quick Fixes

### Fix 1: Make Razorpay Initialization Lazy (Recommended)

Instead of initializing Razorpay at module load, initialize it only when needed.

**Current code (slow):**
```javascript
// This runs when module loads
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || '',
  key_secret: process.env.RAZORPAY_KEY_SECRET || ''
});
```

**Better approach:** Initialize only when creating subscriptions.

### Fix 2: Check App Status

1. **Go to cPanel → Setup Node.js App**
2. **Check if app is "Running"** (not restarting)
3. **If it keeps restarting**, there's still a crash loop

### Fix 3: Test Database Connection

The slow response might be due to database connection timeout.

**Check via SSH:**
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
node -e "const db = require('./config/database'); db.execute('SELECT 1').then(() => console.log('DB OK')).catch(e => console.error('DB Error:', e));"
```

---

## Immediate Steps

### Step 1: Check App Status

1. **cPanel → Setup Node.js App**
2. **Is it "Running" or constantly restarting?**
   - If restarting → Still in crash loop
   - If running → Continue to Step 2

### Step 2: Test Direct Database Query

**Via phpMyAdmin:**
1. Go to cPanel → phpMyAdmin
2. Select database: `theomkiq_charity_website`
3. Run: `SELECT * FROM site_settings LIMIT 1;`
4. **How long does it take?**
   - Fast (< 1 second) → Database is fine
   - Slow (> 5 seconds) → Database issue

### Step 3: Check if Razorpay is Causing Issues

**Temporarily disable Razorpay initialization:**

We can modify the code to only initialize Razorpay when actually needed, not at module load.

---

## Quick Test

### Test 1: Simple API Endpoint

Try a simpler endpoint:
```
https://theonerupeerevolution.org/api/pages
```

**If this is also slow:**
- Database connection issue
- App restarting
- Server resources exhausted

**If this is fast:**
- Issue is specific to `/api/settings` route
- Check the query in `siteSettings.js`

### Test 2: Check Response Time

Open browser DevTools (F12):
1. Go to **Network** tab
2. Visit: `https://theonerupeerevolution.org/api/settings`
3. Check **Time** column
   - **< 1 second** = Normal
   - **1-5 seconds** = Slow but working
   - **> 5 seconds** = Problem
   - **Timeout** = App crashed or not responding

---

## Most Likely Issues

### Issue 1: App Still Restarting

**Symptom:** Response takes 30+ seconds or times out

**Fix:**
1. Stop app
2. Install dependencies (NPM Install)
3. Add all environment variables
4. Restart app
5. Wait 1-2 minutes
6. Test again

### Issue 2: Database Connection Slow

**Symptom:** Response takes 5-10 seconds

**Fix:**
1. Check database credentials
2. Check database server status
3. Optimize queries (add indexes if needed)

### Issue 3: Razorpay Initialization Blocking

**Symptom:** Response takes 10-30 seconds, then works

**Fix:**
- Make Razorpay initialization lazy (only when needed)
- Or ensure Razorpay keys are valid

---

## Quick Diagnostic

**Tell me:**
1. **How long does it take?** (5 seconds? 30 seconds? Timeout?)
2. **Does it eventually return JSON or error?**
3. **What's the app status in cPanel?** (Running/Stopped/Restarting)
4. **Do other API endpoints work?** (Try `/api/pages`)

---

## Temporary Workaround

If you need the site working immediately:

1. **Stop the app**
2. **Comment out Razorpay routes temporarily** (if not needed right now)
3. **Restart app**
4. **Test `/api/settings`**

This will help identify if Razorpay is the cause.

---

**Most likely:** App is still restarting from the 508 error, or Razorpay initialization is blocking. Let me know the response time and I can provide a more specific fix!

