# Backend Deployment to cPanel (Node.js)

## Prerequisites

✅ Your cPanel supports Node.js  
✅ Database credentials are correct  
✅ Frontend is already deployed  

## Step 1: Setup Node.js Application in cPanel

### 1.1 Login to cPanel
1. Go to: `https://theonerupeerevolution.org:2083`
2. Login with your cPanel credentials

### 1.2 Find Node.js Section
1. In cPanel, look for **"Software"** section
2. Click on **"Setup Node.js App"** or **"Node.js Selector"**

### 1.3 Create New Node.js Application
1. Click **"Create Application"** button
2. Fill in the details:
   - **Node.js Version**: Select latest LTS version (e.g., 18.x or 20.x)
   - **Application Mode**: `Production`
   - **Application Root**: `nodejs` (or `backend` - this is where your backend files will be)
   - **Application URL**: Leave default or set to `/api` if you want
   - **Application Startup File**: `server.js`
   - **Passenger Log File**: Leave default
3. Click **"Create"**

### 1.4 Note Important Information
After creating, cPanel will show:
- **Application URL**: e.g., `https://theonerupeerevolution.org/api` or `https://theonerupeerevolution.org:3000`
- **Application Root**: e.g., `/home/theomkiq/nodejs`
- **Node.js Version**: e.g., `18.20.0`

**Save these details!** You'll need them later.

---

## Step 2: Upload Backend Files

### Option A: Using SSH (Recommended - Already in deploy_v2_full.sh)

Your `deploy_v2_full.sh` script already uploads backend files to `~/nodejs`. Just make sure:

1. **Backend directory matches cPanel Application Root**:
   - In `deploy_v2_full.sh`, line 28: `BACKEND_DIR="~/nodejs"`
   - This should match your cPanel Node.js app root directory

2. **Run the deployment script**:
   ```bash
   bash deploy_v2_full.sh
   ```

3. **Verify files are uploaded**:
   - Check that `server.js`, `package.json`, `routes/`, `config/` are in `~/nodejs`

### Option B: Using cPanel File Manager

1. **Open File Manager** in cPanel
2. **Navigate to** your Node.js app root (e.g., `nodejs` folder)
3. **Upload backend files**:
   - `server.js`
   - `package.json`
   - `package-lock.json`
   - `config/` folder
   - `routes/` folder
   - `database/` folder (optional - only if needed)
4. **Do NOT upload**:
   - `client/` folder (frontend is separate)
   - `node_modules/` (will be installed on server)
   - `.env` file (use cPanel environment variables instead)
   - `backups/`, `logs/` folders

---

## Step 3: Configure Environment Variables

### 3.1 In cPanel Node.js App Settings

1. **Go back to** "Setup Node.js App" in cPanel
2. **Find your application** in the list
3. **Click on your app** to edit settings
4. **Scroll to "Environment Variables"** section
5. **Add these variables**:

```
NODE_ENV=production
PORT=5000
DB_HOST=localhost
DB_USER=theomkiq_charity
DB_PASSWORD=Unicro@001
DB_NAME=theomkiq_charity_website
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
```

**Important Notes:**
- Replace `DB_USER`, `DB_PASSWORD`, `DB_NAME` with your actual database credentials
- Replace `JWT_SECRET` with a secure random string (at least 32 characters)
- `PORT` might be automatically set by cPanel - check your app settings

### 3.2 Generate JWT Secret (if needed)

```bash
# In terminal/WSL
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Copy the output and use it as `JWT_SECRET`.

---

## Step 4: Install Dependencies

### Option A: Using cPanel Terminal (Recommended)

1. **Open Terminal** in cPanel (under "Advanced" section)
2. **Navigate to your app directory**:
   ```bash
   cd ~/nodejs
   ```
3. **Install dependencies**:
   ```bash
   npm install --production
   ```
4. **Wait for installation to complete**

### Option B: Using SSH

1. **SSH into your server**:
   ```bash
   ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
   ```
2. **Navigate to app directory**:
   ```bash
   cd ~/nodejs
   ```
3. **Install dependencies**:
   ```bash
   npm install --production
   ```

---

## Step 5: Update Database Configuration

### 5.1 Check Database Connection

Your backend needs to connect to your cPanel database. Make sure:

1. **Database host**: Usually `localhost` on cPanel
2. **Database user**: Has permissions to access the database
3. **Database name**: Correct database name

### 5.2 Test Database Connection

In cPanel Terminal or SSH:

```bash
cd ~/nodejs
node -e "
const mysql = require('mysql2/promise');
(async () => {
  try {
    const conn = await mysql.createConnection({
      host: 'localhost',
      user: 'theomkiq_charity',
      password: 'Unicro@001',
      database: 'theomkiq_charity_website'
    });
    await conn.execute('SELECT 1');
    console.log('✅ Database connection successful!');
    await conn.end();
  } catch (err) {
    console.error('❌ Database connection failed:', err.message);
  }
})();
"
```

Replace credentials with your actual values.

---

## Step 6: Start/Restart Node.js Application

### 6.1 In cPanel Node.js App Settings

1. **Go to** "Setup Node.js App" in cPanel
2. **Find your application**
3. **Click "Restart App"** button
   - Or click the **"Stop"** button, then **"Start"** button

### 6.2 Check Application Status

1. **Check logs** in cPanel:
   - Look for "Passenger Log File" or "Application Logs"
   - Should show: `🚀 Server is running on port 5000`
   - Should show: `✅ Database connection successful`

2. **Check if app is running**:
   - Status should show as **"Running"** or **"Active"**

---

## Step 7: Test Backend API

### 7.1 Test API Endpoints

Open your browser or use curl:

```bash
# Test settings endpoint
curl https://theonerupeerevolution.org/api/settings

# Test navigation endpoint
curl https://theonerupeerevolution.org/api/navigation

# Test health check (if you have one)
curl https://theonerupeerevolution.org/api/health
```

**Expected Response:**
- Should return JSON data
- Should NOT return 404 or 500 errors

### 7.2 Check Application URL

Your backend API should be accessible at:
- `https://theonerupeerevolution.org/api/*` (if configured as subdirectory)
- OR `https://theonerupeerevolution.org:PORT/api/*` (if on different port)

**Note:** Check your cPanel Node.js app settings for the exact URL.

---

## Step 8: Update Frontend API URL (If Needed)

### 8.1 Check Current API URL

In `client/src/services/api.js`:
```javascript
const API_BASE_URL = process.env.REACT_APP_API_URL || 
  (process.env.NODE_ENV === 'production' ? '/api' : 'http://localhost:5000/api');
```

### 8.2 If Backend is on Same Domain

If your backend is at `https://theonerupeerevolution.org/api`, the relative URL `/api` should work.

### 8.3 If Backend is on Different Port/Subdomain

Update the API URL:
```javascript
const API_BASE_URL = process.env.REACT_APP_API_URL || 
  (process.env.NODE_ENV === 'production' 
    ? 'https://theonerupeerevolution.org/api'  // Your actual backend URL
    : 'http://localhost:5000/api');
```

Then rebuild and redeploy frontend.

---

## Step 9: Verify Everything Works

### 9.1 Test Frontend
1. Visit: `https://theonerupeerevolution.org`
2. Open browser console (F12)
3. Check for API errors
4. Navigation should load
5. Footer should load
6. Site settings should load

### 9.2 Test Admin Panel
1. Visit: `https://theonerupeerevolution.org/admin/login`
2. Login with admin credentials
3. Should be able to access admin panel

---

## Troubleshooting

### Issue 1: Application Won't Start

**Symptoms:**
- Status shows "Stopped" or "Error"
- Logs show errors

**Solutions:**
1. **Check logs** in cPanel → Setup Node.js App → View Logs
2. **Check startup file**: Should be `server.js`
3. **Check Node.js version**: Try different version
4. **Check environment variables**: Make sure all are set correctly
5. **Check file permissions**: Files should be readable

### Issue 2: Database Connection Failed

**Symptoms:**
- Logs show: `❌ Database connection failed`
- API returns 500 errors

**Solutions:**
1. **Verify database credentials** in environment variables
2. **Test database connection** (see Step 5.2)
3. **Check database user permissions** in cPanel → MySQL Databases
4. **Check database host**: Should be `localhost` on cPanel

### Issue 3: Port Already in Use

**Symptoms:**
- Logs show: `Port 5000 is already in use`

**Solutions:**
1. **Change PORT** in environment variables to different port (e.g., 3000, 8080)
2. **Check cPanel Node.js app settings** - port might be auto-assigned
3. **Use the port assigned by cPanel** instead of hardcoding

### Issue 4: Module Not Found

**Symptoms:**
- Logs show: `Cannot find module 'express'` or similar

**Solutions:**
1. **Install dependencies**:
   ```bash
   cd ~/nodejs
   npm install --production
   ```
2. **Check package.json**: Make sure all dependencies are listed
3. **Check node_modules**: Should exist in app directory

### Issue 5: API Returns 404

**Symptoms:**
- API calls return 404 Not Found

**Solutions:**
1. **Check Application URL** in cPanel Node.js settings
2. **Check routes** in `server.js` - should start with `/api`
3. **Check if app is running**: Status should be "Running"
4. **Check file structure**: `server.js` should be in app root

### Issue 6: CORS Errors

**Symptoms:**
- Browser console shows CORS errors
- API calls fail

**Solutions:**
1. **Check CORS configuration** in `server.js`:
   ```javascript
   app.use(cors()); // Should allow all origins
   ```
2. **If needed, configure CORS**:
   ```javascript
   app.use(cors({
     origin: 'https://theonerupeerevolution.org',
     credentials: true
   }));
   ```

---

## Maintenance

### Updating Backend Code

1. **Make changes** to your code locally
2. **Run deployment script**:
   ```bash
   bash deploy_v2_full.sh
   ```
3. **Or manually upload** changed files via File Manager/SSH
4. **Restart app** in cPanel → Setup Node.js App → Restart

### Viewing Logs

1. **In cPanel** → Setup Node.js App
2. **Click on your app**
3. **View "Passenger Log File"** or **"Application Logs"**
4. **Or use Terminal**:
   ```bash
   tail -f ~/nodejs/logs/app.log  # If you have logging setup
   ```

### Stopping/Starting App

1. **In cPanel** → Setup Node.js App
2. **Click "Stop"** to stop the app
3. **Click "Start"** to start the app
4. **Click "Restart"** to restart the app

---

## Quick Reference

### Important Paths
- **App Root**: `~/nodejs` (or as configured in cPanel)
- **Logs**: Check in cPanel → Setup Node.js App → Logs
- **Environment Variables**: cPanel → Setup Node.js App → Environment Variables

### Important Commands
```bash
# Navigate to app
cd ~/nodejs

# Install dependencies
npm install --production

# Test database connection
node -e "const mysql = require('mysql2/promise'); ..."

# View logs (if configured)
tail -f ~/nodejs/logs/app.log
```

### Important URLs
- **cPanel**: `https://theonerupeerevolution.org:2083`
- **Backend API**: `https://theonerupeerevolution.org/api` (check your app settings)
- **Frontend**: `https://theonerupeerevolution.org`
- **Admin Panel**: `https://theonerupeerevolution.org/admin/login`

---

## Checklist

Before considering deployment complete:

- [ ] Node.js app created in cPanel
- [ ] Backend files uploaded to app directory
- [ ] Environment variables configured
- [ ] Dependencies installed (`npm install --production`)
- [ ] Database connection tested and working
- [ ] Application started and running
- [ ] API endpoints accessible (test with curl)
- [ ] Frontend can connect to backend (no console errors)
- [ ] Admin panel accessible and working
- [ ] Logs show no errors

---

## Need Help?

If you encounter issues:
1. **Check logs** in cPanel → Setup Node.js App
2. **Test database connection** (Step 5.2)
3. **Verify environment variables** are set correctly
4. **Check file permissions** and structure
5. **Contact your hosting provider** if cPanel Node.js features aren't working

