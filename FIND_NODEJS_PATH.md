# 🔍 Find Node.js Installation Path

## Problem

No `ea-nodejs*` directories in `/opt/cpanel/`. Node.js might be installed elsewhere.

## Find Node.js Path

### Method 1: Check cPanel Node.js App Settings

1. **Go to cPanel → Setup Node.js App**
2. **Click on your application**
3. **Look for "Node.js Version"** - it will show the path
4. **Or check "Node.js Binary"** field

### Method 2: Search for Node.js

Run these commands in SSH:

```bash
# Find node binary
find /opt -name "node" -type f 2>/dev/null | head -5

# Find npm binary
find /opt -name "npm" -type f 2>/dev/null | head -5

# Check common locations
ls -la /usr/local/bin/node 2>/dev/null
ls -la /usr/bin/node 2>/dev/null
ls -la ~/nodejs/node_modules/.bin/node 2>/dev/null

# Check if node is available via module path
cd ~/nodejs
node --version 2>/dev/null || echo "Node not in PATH"
```

### Method 3: Use cPanel Terminal

1. **Go to cPanel → Terminal**
2. **Run:** `node --version`
3. **If it works, run:** `which node`
4. **Use that path for npm**

### Method 4: Check Node.js Selector

Some cPanel setups use Node.js Selector:

```bash
# Check for nodejsselector
ls -la /opt/cpanel/ea-nodejsselector* 2>/dev/null

# Or check user's nodejs directory
ls -la ~/nodejs/
ls -la ~/.nodejs/
```

---

## Alternative: Use cPanel NPM Install Button

If you can't find the path, use cPanel's built-in button:

1. **Go to cPanel → Setup Node.js App → Your App**
2. **Click "NPM Install"** button
3. **Wait for completion**

This should work even if you can't find the npm path manually.

---

## Quick Test Commands

Run these to find Node.js:

```bash
# Test 1: Check if node works in app directory
cd ~/nodejs
node --version

# Test 2: Check if npm works
npm --version

# Test 3: Try installing with npm (if it works)
npm install --production

# Test 4: Check package.json location
cat package.json | grep -A 5 "dependencies"
```

---

## Most Likely Solution

**Use cPanel's "NPM Install" button** - it will use the correct Node.js path automatically!

1. Go to: **cPanel → Setup Node.js App → Your App**
2. Click: **"NPM Install"**
3. Wait: **2-3 minutes**
4. Check: **Success message**
5. Restart: **App**

This is the easiest and most reliable method!

