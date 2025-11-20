# 📦 Install Dependencies via SSH

## Problem

`npm` is not in PATH, but Node.js is installed via cPanel.

## Solution: Use cPanel's Node.js Path

Since your Node.js version is **14.21.2**, use the cPanel Node.js 14 path.

---

## Step-by-Step Installation

### Step 1: Connect to Server

```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
```

### Step 2: Navigate to App Directory

```bash
cd ~/nodejs
```

### Step 3: Install Dependencies

Try these commands in order:

#### Option 1: Use Node.js 14 Path (Your Version)

```bash
/opt/cpanel/ea-nodejs14/bin/npm install --production
```

#### Option 2: If Node.js 14 doesn't work, try Node.js 18

```bash
/opt/cpanel/ea-nodejs18/bin/npm install --production
```

#### Option 3: If Node.js 18 doesn't work, try Node.js 20

```bash
/opt/cpanel/ea-nodejs20/bin/npm install --production
```

#### Option 4: Find the correct path

```bash
# List available Node.js versions
ls -la /opt/cpanel/ea-nodejs*/

# Then use the one that exists
# Example: /opt/cpanel/ea-nodejs14/bin/npm install --production
```

### Step 4: Verify Installation

```bash
# Check if razorpay package is installed
ls -la node_modules/razorpay/

# Should show: razorpay/ directory

# Check total packages
ls node_modules/ | wc -l
# Should show 50+ packages
```

### Step 5: Exit SSH

```bash
exit
```

---

## Alternative: Use cPanel NPM Install Button

If SSH installation doesn't work:

1. **Go to cPanel → Setup Node.js App → Your App**
2. **Click "NPM Install" button**
3. **Wait for completion** (2-3 minutes)
4. **Check for success message**

---

## After Installation

1. **Go to cPanel → Setup Node.js App**
2. **Click "Restart App"**
3. **Wait 30 seconds**
4. **Test:** `https://theonerupeerevolution.org/api/settings`

---

## Troubleshooting

### If npm command not found

Use the full path:
```bash
/opt/cpanel/ea-nodejs14/bin/npm install --production
```

### If permission denied

```bash
# Check permissions
ls -la ~/nodejs

# Fix if needed
chmod 755 ~/nodejs
```

### If installation is slow

This is normal. Installing all packages can take 2-5 minutes.

### If installation fails

Check for errors:
```bash
# Try with verbose output
/opt/cpanel/ea-nodejs14/bin/npm install --production --verbose
```

---

## Quick Command (Copy-Paste)

```bash
cd ~/nodejs && /opt/cpanel/ea-nodejs14/bin/npm install --production
```

This will:
1. Go to app directory
2. Install all dependencies
3. Show progress

Wait for "added X packages" message, then exit and restart the app in cPanel.

