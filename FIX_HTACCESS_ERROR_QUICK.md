# Quick Fix: Missing .htaccess Error

## Problem
When trying to stop/restart Node.js app in cPanel, you get:
```
FileNotFoundError: [Errno 2] No such file or directory: '/home/theomkiq/public_html/api/.htaccess'
```

## Quick Solution (Choose One)

### Option 1: Create .htaccess via SSH (Fastest - 30 seconds)

Run this in WSL:

```bash
# Connect to server
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# Create api directory if it doesn't exist
mkdir -p ~/public_html/api

# Create .htaccess file
cat > ~/public_html/api/.htaccess << 'EOF'
# Passenger configuration for Node.js app
PassengerEnabled On
PassengerAppRoot /home/theomkiq/nodejs
PassengerBaseURI /api
PassengerAppType node
PassengerStartupFile server.js

# Set Node.js environment (update path if needed)
PassengerNodejs /opt/cpanel/ea-nodejs14/bin/node

# Set application environment
SetEnv NODE_ENV production

# Error handling
PassengerFriendlyErrorPages Off
EOF

# Exit SSH
exit
```

**Note:** If your Node.js version is 20, change the path to:
```
PassengerNodejs /opt/cpanel/ea-nodejs20/bin/node
```

### Option 2: Create via cPanel File Manager

1. **Go to cPanel → File Manager**
2. **Navigate to** `public_html/`
3. **Create `api` folder** (if it doesn't exist):
   - Click "New Folder"
   - Name: `api`
4. **Enter the `api` folder**
5. **Create `.htaccess` file**:
   - Click "New File"
   - Name: `.htaccess`
   - Click "Edit" and paste this content:

```apache
# Passenger configuration for Node.js app
PassengerEnabled On
PassengerAppRoot /home/theomkiq/nodejs
PassengerBaseURI /api
PassengerAppType node
PassengerStartupFile server.js

# Set Node.js environment
PassengerNodejs /opt/cpanel/ea-nodejs14/bin/node

# Set application environment
SetEnv NODE_ENV production

# Error handling
PassengerFriendlyErrorPages Off
```

6. **Save the file**

### Option 3: Change Application URL (Alternative)

If you don't want to use `/api` as Application URL:

1. **Go to cPanel → Setup Node.js App**
2. **Click on your application**
3. **Change "Application URL"**:
   - From: `/api`
   - To: `/` (or leave empty)
4. **Save changes**
5. **Restart the app**

**Note:** If you change to `/`, the backend will handle all routes. Make sure your `server.js` has API routes defined as `/api/*`.

---

## After Creating .htaccess

1. **Go back to cPanel → Setup Node.js App**
2. **Now you can stop/restart the app** without errors
3. **Update environment variables** as needed
4. **Restart the app**

---

## Find Your Node.js Path

To find the correct Node.js path:

1. **In cPanel → Setup Node.js App → Your App**
2. **Check "Node.js Version"** (e.g., 18.20.0 or 20.x.x)
3. **Common paths**:
   - Node.js 14: `/opt/cpanel/ea-nodejs14/bin/node`
   - Node.js 16: `/opt/cpanel/ea-nodejs16/bin/node`
   - Node.js 18: `/opt/cpanel/ea-nodejs18/bin/node`
   - Node.js 20: `/opt/cpanel/ea-nodejs20/bin/node`

Update the `.htaccess` file with the correct path.

---

## Test After Fix

1. **Stop the app** (should work now)
2. **Update environment variables**
3. **Restart the app**
4. **Test API**: `https://theonerupeerevolution.org/api/settings`

---

**That's it! The error should be fixed now.** ✅

