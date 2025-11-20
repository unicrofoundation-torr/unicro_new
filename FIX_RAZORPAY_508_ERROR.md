# 🔧 Fix: 508 Error After Adding Razorpay

## Problem

After adding Razorpay subscription, you're getting **Error 508 - Resource Limit Reached**.

**Root Cause:** The `razorpay` npm package is likely **not installed** on the server, causing the app to crash when it tries to load the module.

---

## Quick Fix

### Step 1: Stop the App

1. **Go to cPanel → Setup Node.js App**
2. **Click "Stop App"**
3. **Wait 30 seconds**

---

### Step 2: Install Razorpay Package

**Option A: Via cPanel (Easiest)**

1. **Go to Setup Node.js App → Your App**
2. **Click "NPM Install"** button
3. **Wait for completion** (1-2 minutes)
   - This will install ALL missing packages including `razorpay`

**Option B: Via SSH**

```bash
# In WSL
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
npm install razorpay
npm install --production
exit
```

---

### Step 3: Add Razorpay Environment Variables

Even if you're not using them yet, add them to prevent errors:

1. **Go to Setup Node.js App → Your App → Environment Variables**
2. **Add these:**

```env
RAZORPAY_KEY_ID=rzp_live_RhWOsPuVUOT0Xx
RAZORPAY_KEY_SECRET=your_razorpay_secret_key
RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
```

**Note:** 
- Use your actual Razorpay credentials
- If you don't have them yet, use empty strings temporarily:
  ```
  RAZORPAY_KEY_ID=
  RAZORPAY_KEY_SECRET=
  RAZORPAY_WEBHOOK_SECRET=
  ```

3. **Click "Save"**

---

### Step 4: Restart the App

1. **Click "Restart App"**
2. **Wait 30 seconds**
3. **Test:** `https://theonerupeerevolution.org/api/settings`

---

## Why This Happens

When the app starts, it loads `routes/donations.js` which has:

```javascript
const Razorpay = require('razorpay');
```

**If `razorpay` package is not installed:**
1. App tries to load the module
2. Module not found → Error
3. App crashes
4. cPanel restarts it
5. Same thing happens again
6. Crash loop → 508 error

---

## Verify Package is Installed

After running "NPM Install", verify:

**Via SSH:**
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
ls -la node_modules/ | grep razorpay
# Should show: razorpay/

# Or check package.json
cat package.json | grep razorpay
# Should show: "razorpay": "^2.9.6"

exit
```

**Via File Manager:**
1. Go to cPanel → File Manager
2. Navigate to `nodejs/node_modules/`
3. Look for `razorpay` folder
4. If it doesn't exist → package not installed

---

## Alternative: Make Razorpay Optional

If you want the app to work even without Razorpay configured, we can modify the code to handle missing Razorpay gracefully. But for now, the easiest fix is to install the package.

---

## After Fixing

Test these endpoints:

1. **Settings API:**
   ```
   https://theonerupeerevolution.org/api/settings
   ```
   Should return JSON ✅

2. **Donation API (if Razorpay vars are set):**
   ```
   POST https://theonerupeerevolution.org/api/donations/razorpay/create-subscription
   ```
   Should work if credentials are correct ✅

---

## Most Likely Solution

**90% chance this fixes it:**

1. ✅ Stop app
2. ✅ Click "NPM Install" in cPanel
3. ✅ Add Razorpay environment variables (even if empty)
4. ✅ Restart app
5. ✅ Test API

The `razorpay` package needs to be installed on the server, even if you're not using it yet!

---

## If Still Getting 508

1. **Check if package was installed:**
   - File Manager → `nodejs/node_modules/razorpay/` should exist

2. **Check environment variables:**
   - All should be set (even if empty)

3. **Re-deploy backend:**
   ```bash
   # In WSL
   cd /mnt/e/kanishk\ data/projects/UNICRO
   bash deploy_full.sh
   ```
   Then run "NPM Install" again

4. **Contact hosting support** if still not working

---

**The fix is simple: Install the `razorpay` npm package on the server!** 📦

