# Fix: "No routes matched location /api/settings" Error

## Problem
React Router is intercepting API calls (`/api/settings`, `/api/slider`, etc.) instead of letting them go to the backend.

## Root Cause
The backend Node.js server is **NOT accessible** at `/api/*` routes. When API calls fail, React Router tries to handle them as navigation routes.

## Solution

### Step 1: Verify Backend is Running

1. **Go to cPanel → Setup Node.js App**
2. **Check your application status**:
   - ✅ **Running/Active** = Backend is running
   - ❌ **Stopped/Inactive** = Backend is NOT running

3. **If stopped, click "Restart App"**

### Step 2: Check Application URL Configuration

1. **In cPanel → Setup Node.js App → Your App**
2. **Check "Application URL"**:
   - Should be: `/api` or `/` or empty
   - This affects how API routes are accessed

3. **If Application URL is `/api`**:
   - API should work at: `https://theonerupeerevolution.org/api/settings`
   - Backend handles: `/api/*` routes

4. **If Application URL is `/` or empty**:
   - API should work at: `https://theonerupeerevolution.org/api/settings`
   - Backend handles: All routes, including `/api/*`

### Step 3: Test API Directly

Open these URLs in your browser:

- `https://theonerupeerevolution.org/api/settings`
- `https://theonerupeerevolution.org/api/slider`
- `https://theonerupeerevolution.org/api/gallery`

**Expected** (✅ Working):
```json
{
  "site_name": {...},
  "site_logo": {...},
  ...
}
```

**Wrong** (❌ Not Working):
- Empty page
- HTML page (React app)
- 404 error
- 500 error

### Step 4: Check Application Logs

1. **In cPanel → Setup Node.js App → Your App**
2. **Click "View Logs"** or **"Passenger Log File"**
3. **Look for**:
   - ✅ `Server is running on port 5000` = Working
   - ✅ `Database connection successful` = Working
   - ❌ Any errors = Need to fix

### Step 5: Verify Backend Files

1. **In cPanel → File Manager**
2. **Navigate to** `~/nodejs` (or your app root)
3. **Verify these files exist**:
   - ✅ `server.js`
   - ✅ `package.json`
   - ✅ `routes/` folder
   - ✅ `config/` folder
   - ✅ `node_modules/` folder

### Step 6: Check Environment Variables

1. **In cPanel → Setup Node.js App → Your App**
2. **Check "Environment Variables"**:
   ```
   NODE_ENV=production
   PORT=5000
   DB_HOST=localhost
   DB_USER=theomkiq_charity
   DB_PASSWORD=Unicro@001
   DB_NAME=theomkiq_charity_website
   JWT_SECRET=your-secret-key
   ```

### Step 7: Restart Backend

1. **In cPanel → Setup Node.js App**
2. **Click "Restart App"**
3. **Wait 10-30 seconds**
4. **Check status** - should show "Running"

---

## Common Issues

### Issue 1: Application URL Mismatch

**Problem**: Application URL in cPanel doesn't match how API is accessed

**Solution**:
- If Application URL is `/api`, API routes should work at `/api/*`
- If Application URL is `/` or empty, API routes should work at `/api/*`
- Make sure backend `server.js` has routes defined as `/api/*`

### Issue 2: Static File Server Intercepting

**Problem**: Apache/Nginx is catching `/api/*` routes before Node.js

**Solution**:
- Check if `.htaccess` file exists in `public_html/`
- May need to configure reverse proxy
- Contact hosting support if needed

### Issue 3: Backend Not Running

**Problem**: Node.js app is stopped or crashed

**Solution**:
1. Check app status in cPanel
2. Check application logs for errors
3. Restart the app
4. Check if dependencies are installed

### Issue 4: Port Conflict

**Problem**: Port 5000 is already in use

**Solution**:
- cPanel usually handles port automatically
- Check application logs for port errors
- May need to change PORT in environment variables

---

## Quick Checklist

- [ ] Backend app is **Running** in cPanel
- [ ] Application URL is configured correctly
- [ ] Environment variables are set
- [ ] Dependencies installed (`npm install --production`)
- [ ] API endpoints return JSON (test directly in browser)
- [ ] Application logs show no errors
- [ ] Backend files are in correct directory

---

## Test After Fix

1. **Test API directly**:
   ```
   https://theonerupeerevolution.org/api/settings
   ```
   Should return JSON, not HTML

2. **Check browser console** (F12):
   - Should see API responses
   - No "No routes matched" errors
   - No network errors

3. **Check Network tab**:
   - API calls should have status **200**
   - Response should be **JSON**
   - Not HTML

---

## Still Not Working?

If backend still doesn't work:

1. **Check Application URL** in cPanel - what is it set to?
2. **Check application logs** - any errors?
3. **Test API directly** - what do you see?
4. **Contact hosting support** - may need reverse proxy configuration

---

## Summary

**The Problem**: Backend isn't accessible, so React Router intercepts API calls.

**The Solution**: 
1. Ensure backend is running
2. Verify Application URL configuration
3. Test API endpoints directly
4. Check application logs

**Test**: Visit `https://theonerupeerevolution.org/api/settings` - should see JSON, not HTML!

