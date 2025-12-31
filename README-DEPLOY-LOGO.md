# 🎨 Update Logo and Deploy - Quick Guide

## Scripts Created

I've created **2 scripts** that do everything sequentially:

### For Linux/WSL:
- **`update-logo-and-deploy.sh`** - Does everything in one go

### For Windows PowerShell:
- **`update-logo-and-deploy.ps1`** - Does everything in one go

---

## 🚀 How to Run (Choose One)

### Option 1: Linux/WSL (Recommended)
```bash
# Make script executable
chmod +x update-logo-and-deploy.sh

# Run the script
bash update-logo-and-deploy.sh
```

### Option 2: Windows PowerShell
```powershell
# Run the script
.\update-logo-and-deploy.ps1
```

---

## 📋 What the Script Does (Sequentially)

1. **Updates Favicon Files** 📸
   - Replaces `favicon.ico`, `logo192.png`, `logo512.png` with your logo
   - Uses ImageMagick if available (or copies directly)

2. **Rebuilds Frontend** 🏗️
   - Installs dependencies (if needed)
   - Builds React app with production settings
   - Includes updated meta tags for Google search

3. **Deploys to Server** 🌐
   - Uploads build files to cPanel (incremental upload)
   - Creates/updates `.htaccess` file for API

4. **Summary** ✅
   - Shows what was done
   - Provides next steps

---

## ⚙️ Configuration

The scripts use these settings (already configured):
- **Logo file**: `client/public/uploads/logo-1760602707648-414861542.png`
- **Server**: `theomkiq@server357.web-hosting.com`
- **Razorpay Key**: `rzp_live_RhWOsPuVUOT0Xx`

If you need to change these, edit the script files.

---

## 📝 After Running the Script

1. **Clear Google Cache**:
   - Go to [Google Search Console](https://search.google.com/search-console)
   - Use "URL Inspection" tool
   - Request indexing for your homepage

2. **Wait 24-48 hours** for Google to re-crawl your site

3. **Check Results**:
   - Search for your website on Google
   - Your logo should appear instead of React icon

---

## 🔧 Troubleshooting

### If ImageMagick is not installed:
```bash
# Ubuntu/Debian
sudo apt-get install imagemagick

# Or the script will just copy the logo file (works but not optimized)
```

### If deployment fails:
- Check SSH key permissions: `chmod 600 ~/.ssh/key_private`
- Verify server connection: `ssh -i ~/.ssh/key_private -p 21098 theomkiq@server357.web-hosting.com`

---

## ✅ That's It!

Just run **one script** and everything will be done automatically! 🎉

