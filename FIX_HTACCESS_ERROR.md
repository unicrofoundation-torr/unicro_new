# Fix: FileNotFoundError - Missing .htaccess File

## Problem
cPanel is looking for `.htaccess` file at `/home/theomkiq/public_html/api/.htaccess` but it doesn't exist.

## Root Cause
Your Node.js app Application URL is set to `/api`, so cPanel expects a `.htaccess` file in `public_html/api/` directory.

## Solution

### Option 1: Create the Missing Directory and .htaccess File

1. **Login to cPanel → File Manager**
2. **Navigate to** `public_html/`
3. **Create `api` folder** (if it doesn't exist):
   - Click "New Folder"
   - Name it: `api`
4. **Create `.htaccess` file** in `public_html/api/`:
   - Click "New File"
   - Name it: `.htaccess`
   - Add this content:

```apache
# Passenger configuration for Node.js app
PassengerEnabled On
PassengerAppRoot /home/theomkiq/nodejs
PassengerBaseURI /api
PassengerAppType node
PassengerStartupFile server.js

# Set Node.js environment
PassengerNodejs /opt/cpanel/ea-nodejs18/bin/node

# Set application environment
SetEnv NODE_ENV production

# Error handling
PassengerFriendlyErrorPages Off
```

**Note**: Replace `/opt/cpanel/ea-nodejs18/bin/node` with your actual Node.js path if different. Check in cPanel → Setup Node.js App → Your App → Node.js Version.

### Option 2: Change Application URL (Recommended)

If you don't want to use `/api` as the Application URL:

1. **Go to cPanel → Setup Node.js App**
2. **Click on your application**
3. **Change "Application URL"**:
   - From: `/api`
   - To: `/` (or empty)
4. **Save changes**
5. **Restart the app**

**Important**: If you change Application URL to `/`, the backend will handle ALL routes, including `/api/*`. Make sure your `server.js` has API routes defined as `/api/*`.

### Option 3: Use SSH to Create the File

If you have SSH access:

```bash
# Create api directory
mkdir -p ~/public_html/api

# Create .htaccess file
cat > ~/public_html/api/.htaccess << 'EOF'
# Passenger configuration for Node.js app
PassengerEnabled On
PassengerAppRoot /home/theomkiq/nodejs
PassengerBaseURI /api
PassengerAppType node
PassengerStartupFile server.js

# Set Node.js environment (check your actual path)
PassengerNodejs /opt/cpanel/ea-nodejs18/bin/node

# Set application environment
SetEnv NODE_ENV production

# Error handling
PassengerFriendlyErrorPages Off
EOF
```

---

## Find Your Node.js Path

To find the correct Node.js path:

1. **In cPanel → Setup Node.js App → Your App**
2. **Check "Node.js Version"** (e.g., 18.20.0)
3. **Common paths**:
   - Node.js 18: `/opt/cpanel/ea-nodejs18/bin/node`
   - Node.js 20: `/opt/cpanel/ea-nodejs20/bin/node`
   - Or check: `which node` in cPanel Terminal

---

## After Creating .htaccess

1. **Go to cPanel → Setup Node.js App**
2. **Click "Restart App"**
3. **Wait 10-30 seconds**
4. **Check status** - should show "Running"

---

## Test

After fixing:

1. **Test API directly**:
   ```
   https://theonerupeerevolution.org/api/settings
   ```
   Should return JSON, not HTML

2. **Check browser console**:
   - No "No routes matched" errors
   - API calls should work

---

## Alternative: Use Root Application URL

If you prefer not to use `/api` as Application URL:

1. **Change Application URL to `/`** in cPanel
2. **Backend will handle all routes** including `/api/*`
3. **No need for `public_html/api/.htaccess`**

This is simpler and recommended if you want the backend to handle everything.

---

## Summary

**The Problem**: cPanel expects `.htaccess` file in `public_html/api/` but it doesn't exist.

**The Solution**: 
1. Create `public_html/api/` directory
2. Create `.htaccess` file with Passenger configuration
3. Restart the app

**Or**: Change Application URL to `/` to avoid this issue.

