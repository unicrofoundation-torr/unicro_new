# 🔧 Fix: Error 508 - Resource Limit Reached

## What is Error 508?

**Error 508** means your Node.js app is consuming too much:
- **Memory (RAM)**
- **CPU resources**
- **Processes**

This usually happens when:
- App is crashing and restarting repeatedly (crash loop)
- Memory leak in the code
- Too many processes running
- Infinite loop
- Database connection issues causing retries

---

## Quick Fix Steps

### Step 1: Stop the App (Immediate)

1. **Go to cPanel → Setup Node.js App**
2. **Find your application**
3. **Click "Stop App"** button
4. **Wait 30-60 seconds** (let resources free up)

---

### Step 2: Check for Multiple Processes

**Via SSH (if available):**
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# Check for running Node processes
ps aux | grep node

# If you see multiple processes, kill them
pkill -f node

# Exit
exit
```

**Or via cPanel:**
- Stop the app
- Wait 1-2 minutes
- Check if resources are freed

---

### Step 3: Check Application Code for Issues

Common causes of resource exhaustion:

#### Issue 1: Database Connection Loop

**Check:** `config/database.js` - Make sure connections are properly closed

#### Issue 2: Memory Leak in Routes

**Check:** Routes that might be creating too many objects

#### Issue 3: File Upload Issues

**Check:** Multer configuration in `server.js`

---

### Step 4: Restart with Limited Resources

1. **In cPanel → Setup Node.js App → Your App**
2. **Check "Node.js Version"** - Make sure it's correct (14.21.2)
3. **Check "Application URL"** - Should be `/api` or `/`
4. **Restart the app**

---

### Step 5: Monitor Resource Usage

After restarting:
1. **Wait 1-2 minutes**
2. **Test API:** `https://theonerupeerevolution.org/api/settings`
3. **If 508 again:** App is likely in a crash loop

---

## Common Causes & Solutions

### Cause 1: Crash Loop (Most Common)

**Problem:** App crashes → cPanel restarts it → crashes again → repeat

**Solution:**
1. **Stop the app**
2. **Check environment variables** - Missing DB credentials cause crashes
3. **Check if dependencies are installed**
4. **Fix the root cause** (see below)
5. **Restart**

---

### Cause 2: Missing Environment Variables

**Problem:** App tries to connect to database but credentials are missing → crashes → restarts → repeat

**Solution:**
1. **Go to Setup Node.js App → Your App → Environment Variables**
2. **Make sure these are set:**
   ```
   NODE_ENV=production
   PORT=5000
   DB_HOST=localhost
   DB_USER=theomkiq_charity
   DB_PASSWORD=Unicro@001
   DB_NAME=theomkiq_charity_website
   JWT_SECRET=your-secret-key
   ```
3. **Save and restart**

---

### Cause 3: Dependencies Not Installed

**Problem:** App tries to load modules that don't exist → crashes → restarts

**Solution:**
1. **Stop the app**
2. **Click "NPM Install"** in cPanel
3. **Wait for completion**
4. **Restart app**

---

### Cause 4: Database Connection Failed

**Problem:** Can't connect to database → app crashes → restarts

**Solution:**
1. **Check database credentials** in environment variables
2. **Verify database exists** in cPanel → MySQL Databases
3. **Test database connection** via phpMyAdmin
4. **Fix credentials if wrong**
5. **Restart app**

---

### Cause 5: Port Already in Use

**Problem:** Multiple instances trying to use same port → resource conflict

**Solution:**
1. **Stop the app**
2. **Wait 30 seconds**
3. **Check for other Node processes** (via SSH if possible)
4. **Kill any duplicate processes**
5. **Restart app**

---

## Step-by-Step Recovery

### 1. Stop Everything
```
cPanel → Setup Node.js App → Stop App
Wait 1-2 minutes
```

### 2. Check Environment Variables
```
Setup Node.js App → Your App → Environment Variables
Verify all are set correctly
```

### 3. Install Dependencies
```
Setup Node.js App → Your App → NPM Install
Wait for completion
```

### 4. Check Database
```
cPanel → MySQL Databases
Verify database exists
Verify user has permissions
```

### 5. Restart App
```
Setup Node.js App → Restart App
Wait 30 seconds
```

### 6. Test
```
Visit: https://theonerupeerevolution.org/api/settings
Should return JSON (not 508)
```

---

## If Still Getting 508

### Option 1: Contact Hosting Support

Tell them:
- "Node.js app is hitting resource limits (Error 508)"
- "App might be in a crash loop"
- "Can you check server resources and app logs?"

### Option 2: Check via SSH

```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com

# Check memory usage
free -h

# Check CPU usage
top

# Check Node processes
ps aux | grep node

# Check app directory
cd ~/nodejs
ls -la

# Check if node_modules exists
ls -la node_modules/ | head -20

# Exit
exit
```

### Option 3: Simplify the App

Temporarily disable features to find the issue:

1. **Comment out routes** in `server.js` one by one
2. **Test after each change**
3. **Find which route causes the issue**

---

## Prevention

### 1. Add Error Handling

Make sure your `server.js` has proper error handling:

```javascript
// Catch unhandled errors
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  // Don't exit - let Passenger handle it
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
  // Don't exit - let Passenger handle it
});
```

### 2. Limit File Uploads

Make sure multer has size limits (already in your code):
```javascript
limits: {
  fileSize: 5 * 1024 * 1024 // 5MB limit
}
```

### 3. Close Database Connections

Make sure database connections are properly managed.

---

## Quick Test

After fixing, test these endpoints:

1. **Settings:** `https://theonerupeerevolution.org/api/settings`
2. **Slider:** `https://theonerupeerevolution.org/api/slider`
3. **Gallery:** `https://theonerupeerevolution.org/api/gallery`

**Expected:** JSON data  
**Wrong:** 508 error, HTML page, or other errors

---

## Most Likely Fix

**90% of the time, it's one of these:**

1. ✅ **Missing environment variables** → Add them
2. ✅ **Dependencies not installed** → Run NPM Install
3. ✅ **Database connection failed** → Check credentials
4. ✅ **Crash loop** → Fix the root cause above

**Try this order:**
1. Stop app
2. Add all environment variables
3. Run NPM Install
4. Restart app
5. Test API

---

**If you're still getting 508 after trying everything, the app is likely crashing on startup. Check environment variables and database connection first!**

