# 🚀 Quick Backend Fix - No Logs Available

If your cPanel doesn't have a "Logs" button, use these methods:

## Method 1: Check App Status (Easiest)

1. **Go to cPanel → Setup Node.js App**
2. **Find your application**
3. **Check the status:**
   - ✅ **"Running"** = App is active
   - ❌ **"Stopped"** = App is not running

**If stopped:**
- Click **"Restart App"** button
- Wait 10-30 seconds
- Check status again

---

## Method 2: Test API Directly (Best Way)

Open these URLs in your browser:

### Test 1: Settings API
```
https://theonerupeerevolution.org/api/settings
```

**✅ Working:** You see JSON data like:
```json
{
  "site_name": {...},
  "site_logo": {...}
}
```

**❌ Not Working:** You see:
- Empty page
- HTML page (your React app)
- 404 error
- 500 error
- "Cannot GET /api/settings"

### Test 2: Slider API
```
https://theonerupeerevolution.org/api/slider
```

**✅ Working:** JSON array with slider data  
**❌ Not Working:** HTML page or error

---

## Method 3: Most Common Fix (Try This First!)

### Install Dependencies

**Option A: Via cPanel**
1. Go to **Setup Node.js App → Your App**
2. Look for **"NPM Install"** button
3. Click it
4. Wait for completion (may take 1-2 minutes)
5. Click **"Restart App"**

**Option B: Via SSH (if NPM Install button doesn't work)**
```bash
# In WSL
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
npm install --production
exit
```

Then restart the app in cPanel.

---

## Method 4: Check Environment Variables

1. **Go to Setup Node.js App → Your App**
2. **Scroll down to "Environment Variables"** section
3. **Make sure these are set:**

```env
NODE_ENV=production
PORT=5000
DB_HOST=localhost
DB_USER=theomkiq_charity
DB_PASSWORD=Unicro@001
DB_NAME=theomkiq_charity_website
JWT_SECRET=your-secret-key-here
```

**Important:**
- No spaces around `=` sign
- No quotes around values
- Click "Save" after adding/editing

---

## Method 5: Check Files via File Manager

1. **Go to cPanel → File Manager**
2. **Navigate to `nodejs/` folder** (or your app root)
3. **Check these exist:**
   - ✅ `server.js`
   - ✅ `package.json`
   - ✅ `routes/` folder
   - ✅ `config/` folder
   - ✅ `node_modules/` folder (should exist after npm install)

**If `node_modules/` is missing:**
- Dependencies are not installed
- Run "NPM Install" in cPanel or via SSH

---

## Method 6: Check via SSH (Advanced)

If you have SSH access, you can check logs manually:

```bash
# Connect to server
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# Check if app process is running
ps aux | grep node

# Check if node_modules exists
ls -la ~/nodejs/node_modules/

# Check application files
ls -la ~/nodejs/

# Try to see errors (if any)
cd ~/nodejs
node server.js
# (Press Ctrl+C to stop)

# Exit
exit
```

---

## Quick Fix Checklist

Run through this in order:

1. [ ] **Check app status** - Is it "Running"?
   - If not, click "Restart App"

2. [ ] **Test API** - Visit `https://theonerupeerevolution.org/api/settings`
   - Does it return JSON or HTML/error?

3. [ ] **Install dependencies** - Click "NPM Install" in cPanel
   - Wait for completion
   - Restart app

4. [ ] **Check environment variables** - Are they all set?
   - Add missing ones
   - Save and restart

5. [ ] **Check files** - Do all files exist in `nodejs/` folder?
   - If missing, re-deploy

---

## Common Issues & Quick Fixes

### Issue: API Returns HTML (React App)
**Problem:** Backend not running or not accessible  
**Fix:** 
1. Check app is "Running"
2. Install dependencies
3. Restart app

### Issue: API Returns 404
**Problem:** Routes not configured or app not running  
**Fix:**
1. Check Application URL in cPanel (should be `/api` or `/`)
2. Restart app
3. Check `server.js` has `/api` routes

### Issue: API Returns 500 Error
**Problem:** Server error (database, dependencies, etc.)  
**Fix:**
1. Install dependencies
2. Check environment variables (especially database)
3. Restart app

### Issue: "Cannot find module" (if you see this in browser)
**Problem:** Dependencies not installed  
**Fix:**
1. Click "NPM Install" in cPanel
2. Wait for completion
3. Restart app

---

## Still Not Working?

### Re-deploy Backend

If nothing works, re-deploy the backend:

```bash
# In WSL
cd /mnt/e/kanishk\ data/projects/UNICRO
bash deploy_full.sh
```

This will:
- Upload backend files again
- Make sure all files are in place

Then:
1. Install dependencies (NPM Install)
2. Set environment variables
3. Restart app

---

## Test After Fix

After applying fixes, test:

1. **API Endpoint:**
   ```
   https://theonerupeerevolution.org/api/settings
   ```
   Should return JSON

2. **Frontend:**
   ```
   https://theonerupeerevolution.org
   ```
   Should load without console errors

3. **Admin Panel:**
   ```
   https://theonerupeerevolution.org/admin/login
   ```
   Should work

---

## What to Tell Me

If it's still not working, tell me:

1. **What do you see** when you visit `https://theonerupeerevolution.org/api/settings`?
   - JSON data? ✅
   - HTML page? ❌
   - 404 error? ❌
   - 500 error? ❌
   - Empty page? ❌

2. **What is the app status** in cPanel?
   - Running? ✅
   - Stopped? ❌

3. **Did you run "NPM Install"?**
   - Yes ✅
   - No ❌
   - Button doesn't exist ❌

4. **Are environment variables set?**
   - Yes ✅
   - No ❌
   - Not sure ❓

---

**Most Common Fix:** Install dependencies and restart! 🔄

