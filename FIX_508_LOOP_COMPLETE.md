# Complete Fix for 508 Loop Detected Error

## Root Cause Analysis

The **508 Loop Detected** error occurs when there's a redirect loop between:
1. cPanel's Application URL setting
2. `.htaccess` Passenger configuration
3. Route definitions in `server.js`

### Current Setup:
- **Routes in server.js**: `/api/settings`, `/api/slider`, etc.
- **Application URL in cPanel**: `/api` (from your screenshot)
- **PassengerBaseURI in .htaccess**: `/api`

This creates a conflict where Passenger and the routes are both trying to handle `/api`, causing a loop.

---

## Solution Options

### **OPTION 1: Change Application URL to '/' (RECOMMENDED)** ✅

This is the **easiest and safest** option.

#### Step 1: Run the fix script
```bash
# In WSL
bash fix_508_loop.sh
```

#### Step 2: Change Application URL in cPanel
1. Go to **cPanel → Setup Node.js App**
2. Click on your app
3. Find **"Application URL"** field
4. Change from `theonerupeerevolution.org/api` to `theonerupeerevolution.org/` (remove `/api`)
5. Click **"SAVE"**

#### Step 3: Remove or rename .htaccess
```bash
# In WSL
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/public_html
rm -f api/.htaccess  # Remove it completely
# OR rename it:
# mv api/.htaccess api/.htaccess.disabled
exit
```

#### Step 4: Restart the app
1. In cPanel → Setup Node.js App
2. Click **"STOP APP"** (wait 10 seconds)
3. Click **"RESTART"** (wait 60 seconds)

#### Step 5: Test
- Visit: `https://theonerupeerevolution.org/api/settings`
- Should return JSON (not 508 error)

**Why this works:**
- Application URL `/` means Passenger handles all requests
- Routes in `server.js` are `/api/...` so they work correctly
- No `.htaccess` conflict

---

### **OPTION 2: Keep Application URL as '/api' and Fix Routes**

If you want to keep Application URL as `/api`, you need to remove `/api` prefix from routes.

#### Step 1: Update server.js routes
Change all routes from `/api/...` to just `/...`:

```javascript
// OLD (current):
app.use('/api/pages', require('./routes/pages'));
app.use('/api/navigation', require('./routes/navigation'));
app.use('/api/settings', require('./routes/siteSettings'));
// ... etc

// NEW (fixed):
app.use('/pages', require('./routes/pages'));
app.use('/navigation', require('./routes/navigation'));
app.use('/settings', require('./routes/siteSettings'));
// ... etc
```

#### Step 2: Deploy updated server.js
```bash
# In WSL
rsync -avz -e "ssh -i ~/.ssh/key_private -p 21098" \
  server.js \
  theomkiq@server357.web-hosting.com:~/nodejs/
```

#### Step 3: Update frontend API calls
You'll also need to update the frontend to call `/settings` instead of `/api/settings`.

**This option is more complex and not recommended.**

---

## Recommended: Use Option 1

**Option 1 is simpler** because:
- ✅ No code changes needed
- ✅ Just change Application URL in cPanel
- ✅ Remove `.htaccess` file
- ✅ Routes work as-is

---

## Diagnostic Script

If you want to see detailed analysis:

```bash
# In WSL
bash diagnose_508_loop.sh
```

This will show:
- Current `.htaccess` content
- Route definitions
- Passenger configuration
- Potential conflicts

---

## Quick Fix Summary

1. **Run fix script**: `bash fix_508_loop.sh`
2. **Change Application URL** in cPanel from `/api` to `/`
3. **Remove `.htaccess`** file: `rm ~/public_html/api/.htaccess`
4. **Restart app** in cPanel
5. **Test**: `https://theonerupeerevolution.org/api/settings`

---

## If Still Getting 508 Error

1. **Check Application URL** in cPanel - must be `/` (not `/api`)
2. **Verify `.htaccess` is removed** or disabled
3. **Check app is running** (green status in cPanel)
4. **Wait 60 seconds** after restart before testing
5. **Clear browser cache** and try again

---

## Why This Happens

The loop occurs because:
- Browser requests: `https://domain.com/api/settings`
- If Application URL = `/api`, Passenger routes to Node.js
- Node.js receives path `/api/settings`
- Route is `/api/settings` → matches
- But Passenger might be adding `/api` again → loop!

**Solution**: Application URL = `/` means Passenger handles everything, routes work normally.

