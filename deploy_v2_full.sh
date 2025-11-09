#!/bin/bash
echo "====================================================="
echo "🚀 Full Stack Deployment (Frontend + Backend)"
echo "🚀 Deployment started at $(date)"
echo "====================================================="

# --- Configuration ---
# Local Database (for backup)
LOCAL_DB_USER="root"
LOCAL_DB_PASS="root123"
LOCAL_DB_NAME="charity_website"

# Remote Database (cPanel - UPDATE THESE!)
REMOTE_DB_USER="theomkiq_charity"  # 👈 Update with your cPanel database user
REMOTE_DB_PASS="Unicro@001"  # 👈 Update with your cPanel database password
REMOTE_DB_NAME="theomkiq_charity"  # 👈 Update with your cPanel database name (usually username_dbname)
REMOTE_DB_HOST="localhost"  # Usually localhost on cPanel

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_DIR="$PROJECT_ROOT/logs"
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"
BACKEND_DIR="~/nodejs"  # Backend directory on cPanel (if Node.js is supported)

# --- Create necessary folders ---
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# --- Create log file ---
LOG_FILE="$LOG_DIR/deploy_$(date +%d-%m-%Y_%H-%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Step 1: MySQL Backup (Local) ---
echo "💾 Taking MySQL Backup (Local)..."
BACKUP_FILE="$BACKUP_DIR/${LOCAL_DB_NAME}_$(date +%d-%m-%Y_%H-%M).sql"
/mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u$LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME > "$BACKUP_FILE"
if [ $? -eq 0 ]; then
  echo "✅ MySQL backup successful: $BACKUP_FILE"
else
  echo "❌ MySQL backup failed."
  exit 1
fi

# --- Step 2: Push latest code to GitHub ---
echo "📦 Pushing latest code to GitHub..."
cd "$PROJECT_ROOT"
git add .
git commit -m "Auto-deploy: $(date)" || echo "⚠️ No changes to commit"
git push origin main || echo "⚠️ Git push failed — continuing deployment"

# --- Step 3: Build React Frontend ---
echo "🏗️ Building React project..."
cd "$CLIENT_DIR"

# Set environment variables for production build
export REACT_APP_TINYMCE_API_KEY="umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7"
export NODE_ENV=production
export GENERATE_SOURCEMAP=false

# If .env file exists, source it (optional)
if [ -f ".env" ]; then
  echo "📝 Loading environment variables from .env file..."
  set -a
  source .env
  set +a
fi

npm install --legacy-peer-deps
npm run build
if [ $? -ne 0 ]; then
  echo "❌ React build failed."
  exit 1
fi
echo "✅ React build successful"

# --- Step 4: Upload Frontend Build to cPanel ---
echo "🌐 Uploading frontend build to cPanel..."
cd "$PROJECT_ROOT"

# Clean existing frontend files
ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST "rm -rf $REMOTE_DIR/*"

# Upload frontend build
rsync -avz \
  --exclude 'node_modules/' \
  --exclude '.git/' \
  --exclude '.env' \
  --include '.htaccess' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$CLIENT_DIR/build/" $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR

if [ $? -ne 0 ]; then
  echo "❌ Frontend deployment failed."
  exit 1
fi
echo "✅ Frontend deployment successful"

# --- Step 5: Upload Backend to cPanel ---
echo "🔧 Uploading backend to cPanel..."
echo "⚠️  NOTE: This assumes your cPanel supports Node.js"
echo "⚠️  If not, you'll need to deploy backend separately (VPS, Heroku, etc.)"

# Create backend directory on server
ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST "mkdir -p $BACKEND_DIR"

# Upload backend files (excluding client folder, node_modules, etc.)
# First, clean the backend directory (optional - comment out if you want to keep existing files)
# ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST "rm -rf $BACKEND_DIR/*"

# Upload backend files - use explicit file/folder copying
echo "📤 Uploading backend files..."
rsync -avz \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$PROJECT_ROOT/server.js" \
  "$PROJECT_ROOT/server-demo.js" \
  "$PROJECT_ROOT/setup.js" \
  "$PROJECT_ROOT/package.json" \
  "$PROJECT_ROOT/package-lock.json" \
  "$PROJECT_ROOT/config/" \
  "$PROJECT_ROOT/routes/" \
  "$PROJECT_ROOT/database/schema.sql" \
  $CPANEL_USER@$CPANEL_HOST:$BACKEND_DIR/

if [ $? -ne 0 ]; then
  echo "⚠️  Backend upload failed. You may need to deploy backend separately."
  echo "⚠️  Check if your cPanel supports Node.js applications."
else
  echo "✅ Backend files uploaded successfully"
  
  # Install backend dependencies on server
  echo "📦 Installing backend dependencies on server..."
  echo "⚠️  Note: npm install will be done via cPanel Node.js app settings"
  echo "⚠️  Or you can install manually via cPanel Terminal:"
  echo "    cd ~/nodejs && npm install --production"
  
  # Try to find npm in common cPanel locations
  ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << 'ENDSSH'
    cd ~/nodejs
    
    # Try to find npm in common cPanel Node.js paths
    NPM_PATH=""
    if command -v npm &> /dev/null; then
      NPM_PATH="npm"
    elif [ -f "/opt/cpanel/ea-nodejs18/bin/npm" ]; then
      NPM_PATH="/opt/cpanel/ea-nodejs18/bin/npm"
    elif [ -f "/opt/cpanel/ea-nodejs20/bin/npm" ]; then
      NPM_PATH="/opt/cpanel/ea-nodejs20/bin/npm"
    elif [ -f "/opt/cpanel/ea-nodejs16/bin/npm" ]; then
      NPM_PATH="/opt/cpanel/ea-nodejs16/bin/npm"
    fi
    
    if [ -n "$NPM_PATH" ]; then
      echo "📦 Found npm at: $NPM_PATH"
      $NPM_PATH install --production
      if [ $? -eq 0 ]; then
        echo "✅ Backend dependencies installed successfully"
      else
        echo "⚠️  npm install failed. Install manually via cPanel Terminal."
      fi
    else
      echo "⚠️  npm not found in standard locations."
      echo "⚠️  Please install dependencies manually:"
      echo "   1. Login to cPanel → Terminal"
      echo "   2. Run: cd ~/nodejs && npm install --production"
      echo "   3. Or use cPanel Node.js app settings to install dependencies"
    fi
ENDSSH
fi

# --- Step 6: SQL Schema (Manual Import) ---
echo "🗄️  SQL schema deployment skipped (manual import via phpMyAdmin)"
echo "📋 To import database schema manually:"
echo "   1. Login to cPanel → phpMyAdmin"
echo "   2. Select your database: $REMOTE_DB_NAME"
echo "   3. Click 'Import' tab"
echo "   4. Upload: database/schema.sql from your project"
echo "   5. Click 'Go' to import"
echo ""
echo "✅ Schema file is available at: $PROJECT_ROOT/database/schema.sql"

echo ""
echo "====================================================="
echo "📋 DEPLOYMENT SUMMARY"
echo "====================================================="
echo "✅ Frontend: Deployed to $REMOTE_DIR"
echo "✅ Backend: Uploaded to $BACKEND_DIR"
echo "⚠️  Database: Manual import required (see steps below)"
echo ""
echo "🔧 NEXT STEPS:"
echo ""
echo "1. 📦 Install Backend Dependencies:"
echo "   - Login to cPanel → Terminal"
echo "   - Run: cd ~/nodejs && npm install --production"
echo "   - OR use cPanel Node.js app settings to install"
echo ""
echo "2. ⚙️  Setup Node.js App in cPanel:"
echo "   - Login to cPanel → Setup Node.js App"
echo "   - Create new application (if not already created)"
echo "   - Application Root: nodejs"
echo "   - Startup File: server.js"
echo "   - Add environment variables (DB_HOST, DB_USER, DB_PASS, DB_NAME, JWT_SECRET, etc.)"
echo ""
echo "3. 🗄️  Import Database Schema:"
echo "   - Login to cPanel → phpMyAdmin"
echo "   - Select database: $REMOTE_DB_NAME"
echo "   - Click 'Import' → Upload database/schema.sql"
echo ""
echo "4. 🚀 Start/Restart Node.js App:"
echo "   - In cPanel → Setup Node.js App"
echo "   - Click 'Restart App' button"
echo ""
echo "5. ✅ Test Backend API:"
echo "   - Visit: https://theonerupeerevolution.org/api/settings"
echo "   - Should return JSON data (not 404 or 500 error)"
echo ""
echo "6. 📱 Verify Frontend:"
echo "   - Visit: https://theonerupeerevolution.org"
echo "   - Check browser console for errors"
echo "   - Navigation and footer should load correctly"
echo ""
echo "📝 Logs saved at: $LOG_FILE"
echo "====================================================="

