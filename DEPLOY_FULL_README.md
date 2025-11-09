# Full Stack Deployment Script

Complete deployment script for both **Frontend** (React) and **Backend** (Node.js) to cPanel.

## 📋 Prerequisites

1. ✅ **SSH Access** to cPanel server
2. ✅ **SSH Private Key** configured
3. ✅ **Node.js App** created in cPanel
4. ✅ **Database credentials** ready
5. ✅ **Git** installed (optional, for version control)

## 🚀 Quick Start

### For Linux/WSL/Mac:

```bash
bash deploy_full.sh
```

### For Windows:

```cmd
deploy_full.bat
```

## ⚙️ Configuration

Before running, **update these variables** in the script:

### 1. Database Credentials (cPanel)

```bash
REMOTE_DB_USER="theomkiq_charity"      # Your cPanel database user
REMOTE_DB_PASS="Unicro@001"            # Your cPanel database password
REMOTE_DB_NAME="theomkiq_charity_website"  # Your cPanel database name
REMOTE_DB_HOST="localhost"             # Usually localhost on cPanel
```

### 2. SSH Configuration

```bash
PRIVATE_KEY="$HOME/.ssh/key_private"   # Path to your SSH private key
CPANEL_USER="theomkiq"                 # Your cPanel username
CPANEL_HOST="server357.web-hosting.com"  # Your cPanel server
CPANEL_PORT=21098                      # Your SSH port
```

### 3. Remote Directories

```bash
FRONTEND_DIR="~/public_html"  # Where frontend is deployed
BACKEND_DIR="~/nodejs"        # Where backend is deployed (must match cPanel Node.js app root)
```

## 📦 What the Script Does

### Step 1: MySQL Backup (Local)
- Creates a backup of your local database
- Saves to `backups/` folder

### Step 2: Push to GitHub (Optional)
- Commits any uncommitted changes
- Pushes to GitHub repository

### Step 3: Install Client Dependencies
- Installs React dependencies if needed
- Uses `npm install --legacy-peer-deps`

### Step 4: Build React Frontend
- Builds React app for production
- Sets `NODE_ENV=production`
- Sets `REACT_APP_TINYMCE_API_KEY` for TinyMCE editor
- Output: `client/build/`

### Step 5: Deploy Frontend to cPanel
- Uploads `client/build/` to `~/public_html/`
- Uses `rsync` for efficient file transfer
- Excludes unnecessary files (node_modules, .git, etc.)

### Step 6: Deploy Backend to cPanel
- Uploads backend files to `~/nodejs/`
- Includes:
  - `server.js`
  - `package.json`
  - `config/` folder
  - `routes/` folder
  - `database/` folder
- Excludes:
  - `client/` folder
  - `node_modules/`
  - `.git/`
  - Logs and backups

### Step 7: Install Backend Dependencies
- Attempts to install dependencies on server
- Tries multiple npm paths (cPanel, local, etc.)
- Falls back to manual installation if needed

## 📋 Post-Deployment Steps

After running the script, you **MUST** complete these steps:

### 1. Configure Environment Variables in cPanel

1. Go to: **cPanel → Setup Node.js App**
2. Click on your application
3. Scroll to **"Environment Variables"** section
4. Add these variables:

```
NODE_ENV=production
PORT=5000
DB_HOST=localhost
DB_USER=theomkiq_charity
DB_PASSWORD=Unicro@001
DB_NAME=theomkiq_charity_website
JWT_SECRET=your-secret-key-here
```

**Important**: Replace with your actual database credentials!

### 2. Install Dependencies (if not done automatically)

**Option A: Using cPanel**
1. Go to: **cPanel → Setup Node.js App → Your App**
2. Click **"NPM Install"** button

**Option B: Using SSH**
```bash
ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com
cd ~/nodejs
npm install --production
```

### 3. Restart Node.js App

1. Go to: **cPanel → Setup Node.js App**
2. Find your application
3. Click **"Restart App"** button
4. Wait 10-30 seconds

### 4. Test API Endpoints

Open these URLs in your browser:

- ✅ `https://theonerupeerevolution.org/api/settings`
- ✅ `https://theonerupeerevolution.org/api/slider`
- ✅ `https://theonerupeerevolution.org/api/gallery`
- ✅ `https://theonerupeerevolution.org/api/navigation`

**Expected**: JSON data like `[{...}]` or `{...}`  
**Wrong**: HTML page (React app) or 404/500 error

### 5. Verify Frontend

1. Visit: `https://theonerupeerevolution.org`
2. Open **DevTools** (F12)
3. Check **Console** tab for errors
4. Check **Network** tab - API calls should return JSON

## 🔧 Troubleshooting

### Issue 1: Frontend Not Deploying

**Problem**: rsync not found or SSH connection failed

**Solution**:
- Install WSL (Windows Subsystem for Linux) on Windows
- Or use cPanel File Manager to upload manually
- Check SSH key permissions: `chmod 600 ~/.ssh/key_private`

### Issue 2: Backend Not Deploying

**Problem**: Backend files not uploading

**Solution**:
- Check `BACKEND_DIR` matches cPanel Node.js app root
- Verify SSH connection works
- Check file permissions on server

### Issue 3: Dependencies Not Installing

**Problem**: npm not found on server

**Solution**:
- Use cPanel "NPM Install" button
- Or install manually via SSH
- Check Node.js app is created in cPanel

### Issue 4: API Returns HTML Instead of JSON

**Problem**: Backend not running or not accessible

**Solution**:
1. Check Node.js app is **Running** in cPanel
2. Check environment variables are set
3. Check application logs for errors
4. Verify API routes are configured correctly

### Issue 5: Build Fails

**Problem**: React build errors

**Solution**:
- Check for TypeScript/ESLint errors
- Check `package.json` dependencies
- Try: `npm install --legacy-peer-deps`
- Check Node.js version (should be 16+)

## 📝 Logs

Deployment logs are saved to:
```
logs/deploy_full_YYYY-MM-DD_HH-MM.log
```

Check logs if deployment fails!

## 🔄 Updating Configuration

To update configuration:

1. **Edit the script** (`deploy_full.sh` or `deploy_full.bat`)
2. **Update variables** at the top of the file
3. **Save and run** again

## 📊 Script Summary

| Step | Action | Time |
|------|--------|------|
| 1 | MySQL Backup | ~5s |
| 2 | Git Push | ~10s |
| 3 | Install Client Deps | ~30s |
| 4 | Build React | ~60s |
| 5 | Deploy Frontend | ~30s |
| 6 | Deploy Backend | ~20s |
| 7 | Install Backend Deps | ~30s |
| **Total** | | **~3-5 min** |

## ✅ Checklist

Before deployment:
- [ ] Database credentials updated
- [ ] SSH credentials updated
- [ ] Node.js app created in cPanel
- [ ] SSH key has correct permissions

After deployment:
- [ ] Environment variables configured
- [ ] Dependencies installed
- [ ] Node.js app restarted
- [ ] API endpoints tested
- [ ] Frontend verified

## 🆘 Need Help?

If deployment fails:

1. **Check logs**: `logs/deploy_full_*.log`
2. **Check cPanel**: Node.js app status
3. **Check SSH**: Test connection manually
4. **Check API**: Test endpoints directly

## 📚 Related Documentation

- `BACKEND_DEPLOYMENT_CPANEL.md` - Backend deployment guide
- `ENVIRONMENT_VARIABLES_CPANEL.md` - Environment variables guide
- `HOW_TO_CHECK_API_RESPONSE.md` - API testing guide

---

**Happy Deploying! 🚀**

