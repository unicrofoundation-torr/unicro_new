# Fix: "No such application (or application not configured) 'nodejs'"

## Problem
When trying to change Application URL, you get error: "No such application (or application not configured) 'nodejs'"

## Root Cause
The Application Root directory (`nodejs`) either:
1. Doesn't exist
2. Doesn't have the required files (`server.js`, `package.json`)
3. Isn't properly configured as a Node.js app

## Solution

### Step 1: Check Application Root Directory

1. **Go to cPanel → Setup Node.js App**
2. **Click on your application**
3. **Check "Application Root"** - what is it set to?
   - Should be: `nodejs` or `backend` or similar
   - This is where your backend files should be

### Step 2: Verify Directory Exists

1. **Go to cPanel → File Manager**
2. **Navigate to your home directory** (`/home/theomkiq/`)
3. **Check if `nodejs` folder exists**:
   - ✅ If exists: Check if it has `server.js` and `package.json`
   - ❌ If doesn't exist: Create it

### Step 3: Verify Backend Files

In `~/nodejs/` (or your Application Root), you should have:

**Required Files**:
- ✅ `server.js` - Main server file
- ✅ `package.json` - Dependencies
- ✅ `package-lock.json` - Lock file
- ✅ `config/` folder - Database config
- ✅ `routes/` folder - API routes
- ✅ `node_modules/` folder - Dependencies (after install)

**If files are missing**, you need to deploy the backend.

### Step 4: Deploy Backend Files

If backend files are missing, deploy them:

**Option A: Using Deployment Script**
```bash
bash deploy_full.sh
```

**Option B: Manual Upload via File Manager**
1. **Go to cPanel → File Manager**
2. **Navigate to** `~/nodejs/` (or your Application Root)
3. **Upload these files**:
   - `server.js`
   - `package.json`
   - `package-lock.json`
   - `config/` folder
   - `routes/` folder

### Step 5: Install Dependencies

1. **Go to cPanel → Setup Node.js App → Your App**
2. **Click "NPM Install"** button
   - Or use Terminal:
   ```bash
   cd ~/nodejs
   npm install --production
   ```

### Step 6: Recreate Node.js App (If Still Not Working)

If the app still doesn't work:

1. **Go to cPanel → Setup Node.js App**
2. **Delete the existing app** (if possible)
3. **Create a new Node.js app**:
   - **Node.js Version**: Latest LTS (18.x or 20.x)
   - **Application Mode**: `Production`
   - **Application Root**: `nodejs` (or `backend`)
   - **Application URL**: `/` (or `/api` if you want)
   - **Application Startup File**: `server.js`
4. **Click "Create"**

### Step 7: Set Environment Variables

After creating/recreating the app:

1. **Go to cPanel → Setup Node.js App → Your App**
2. **Add Environment Variables**:
   ```
   NODE_ENV=production
   PORT=5000
   DB_HOST=localhost
   DB_USER=theomkiq_charity
   DB_PASSWORD=Unicro@001
   DB_NAME=theomkiq_charity_website
   JWT_SECRET=your-secret-key-here
   ```

### Step 8: Start the App

1. **Go to cPanel → Setup Node.js App**
2. **Click "Start"** or **"Restart"** button
3. **Wait 10-30 seconds**
4. **Check status** - should show "Running"

---

## Alternative: Use Root Application URL

If you want to avoid the `/api` Application URL issue:

1. **Set Application URL to `/`** (or empty)
2. **Backend will handle all routes** including `/api/*`
3. **No need for `public_html/api/.htaccess`**

This is simpler and recommended.

---

## Quick Checklist

- [ ] `~/nodejs/` directory exists
- [ ] `server.js` exists in `~/nodejs/`
- [ ] `package.json` exists in `~/nodejs/`
- [ ] `routes/` folder exists in `~/nodejs/`
- [ ] `config/` folder exists in `~/nodejs/`
- [ ] Dependencies installed (`node_modules/` exists)
- [ ] Environment variables configured
- [ ] App is running

---

## Test After Fix

1. **Test API directly**:
   ```
   https://theonerupeerevolution.org/api/settings
   ```
   Should return JSON

2. **Check application logs**:
   - Should show: `Server is running on port 5000`
   - Should show: `Database connection successful`

---

## Summary

**The Problem**: Application Root directory (`nodejs`) doesn't exist or isn't properly configured.

**The Solution**: 
1. Verify `~/nodejs/` directory exists
2. Ensure backend files are deployed
3. Install dependencies
4. Recreate app if needed
5. Set Application URL to `/` (simpler) or `/api` (with `.htaccess`)

