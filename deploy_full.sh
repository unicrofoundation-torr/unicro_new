#!/bin/bash
echo "====================================================="
echo "🚀 Full Stack Deployment to cPanel"
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
REMOTE_DB_NAME="theomkiq_charity"  # 👈 Update with your cPanel database name
REMOTE_DB_HOST="localhost"  # Usually localhost on cPanel

# Project paths
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_DIR="$PROJECT_ROOT/logs"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

# Remote directories
FRONTEND_DIR="~/public_html"  # Frontend deployment directory
BACKEND_DIR="~/nodejs"  # Backend deployment directory

# TinyMCE API Key (for frontend build)
TINYMCE_API_KEY="umr1eq61a2537s4649w0i6dru4y7cypj6clshpyrkmsti4k7"

# Razorpay Key ID (for frontend build - REQUIRED for payments)
# Get this from: Razorpay Dashboard → Settings → API Keys
RAZORPAY_KEY_ID="rzp_live_RhWOsPuVUOT0Xx"  # 👈 UPDATE THIS with your Razorpay Key ID

# --- Create necessary folders ---
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# --- Create log file ---
LOG_FILE="$LOG_DIR/deploy_full_$(date +%d-%m-%Y_%H-%M).log"
# Use tee for logging (works with bash)
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Step 1: MySQL Backup (Local) ---
echo "💾 Taking MySQL Backup (Local)..."
BACKUP_FILE="$BACKUP_DIR/${LOCAL_DB_NAME}_$(date +%d-%m-%Y_%H-%M).sql"
if [ -f "/mnt/c/Program Files/MySQL/MySQL Server 8.0/bin/mysqldump.exe" ]; then
  /mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u$LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME > "$BACKUP_FILE" 2>/dev/null
  if [ $? -eq 0 ]; then
    echo "✅ MySQL backup successful: $BACKUP_FILE"
  else
    echo "⚠️ MySQL backup failed (continuing anyway)"
  fi
else
  echo "⚠️ MySQL not found, skipping backup"
fi

# --- Step 2: Push to GitHub (Optional) ---
echo "📦 Pushing latest code to GitHub..."
cd "$PROJECT_ROOT"
git add . 2>/dev/null || true
git commit -m "Auto-deploy: $(date +%Y-%m-%d_%H-%M-%S)" 2>/dev/null || echo "⚠️ Nothing to commit"
git push origin main 2>/dev/null || echo "⚠️ Git push failed or no changes to push"

# --- Step 3: Install Client Dependencies ---
echo "📦 Installing client dependencies..."
cd "$CLIENT_DIR"
if [ ! -d "node_modules" ]; then
  echo "   Installing dependencies..."
  npm install --legacy-peer-deps
  if [ $? -ne 0 ]; then
    echo "❌ Client dependencies installation failed"
    exit 1
  fi
else
  echo "   Dependencies already installed"
fi

# --- Step 4: Build React Frontend ---
echo "🏗️ Building React frontend..."
cd "$CLIENT_DIR"

# Set environment variables for build
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_TINYMCE_API_KEY="$TINYMCE_API_KEY"
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

# Build React app
npm run build
if [ $? -ne 0 ]; then
  echo "❌ React build failed"
  exit 1
fi

echo "✅ React build successful"

# --- Step 5: Deploy Frontend to cPanel ---
echo "📤 Deploying frontend to cPanel..."
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Build directory not found: $BUILD_DIR"
  exit 1
fi

rsync -avz \
  --progress \
  --delete \
  --exclude='node_modules/' \
  --exclude='.git/' \
  --exclude='.env' \
  --exclude='*.map' \
  --exclude='.DS_Store' \
  --exclude='api/' \
  --include='.htaccess' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" $CPANEL_USER@$CPANEL_HOST:$FRONTEND_DIR/

if [ $? -ne 0 ]; then
  echo "❌ Frontend deployment failed"
  exit 1
fi

echo "✅ Frontend deployed successfully"

# --- Step 6: Deploy Backend to cPanel ---
echo "📤 Deploying backend to cPanel..."
cd "$PROJECT_ROOT"

# Create backend deployment package
rsync -avz \
  --progress \
  --exclude='client/' \
  --exclude='node_modules/' \
  --exclude='.git/' \
  --exclude='backups/' \
  --exclude='logs/' \
  --exclude='*.log' \
  --exclude='.env' \
  --exclude='*.md' \
  --exclude='*.sh' \
  --exclude='*.bat' \
  --exclude='git-filter-repo/' \
  --exclude='database/schema.sql' \
  --include='server.js' \
  --include='server-demo.js' \
  --include='setup.js' \
  --include='package.json' \
  --include='package-lock.json' \
  --include='config/' \
  --include='config/**' \
  --include='routes/' \
  --include='routes/**' \
  --include='database/' \
  --include='database/schema.sql' \
  --exclude='*' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$PROJECT_ROOT/" $CPANEL_USER@$CPANEL_HOST:$BACKEND_DIR

if [ $? -ne 0 ]; then
  echo "❌ Backend deployment failed"
  exit 1
fi

echo "✅ Backend files deployed successfully"

# --- Step 7: Install Backend Dependencies on Server ---
echo "📦 Installing backend dependencies on server..."
ssh -i $PRIVATE_KEY -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << 'ENDSSH'
cd ~/nodejs
echo "   Checking for npm..."
if command -v npm &> /dev/null; then
  echo "   npm found, installing dependencies..."
  npm install --production
elif [ -f ~/nodejs/node_modules/.bin/npm ]; then
  echo "   Using local npm..."
  ~/nodejs/node_modules/.bin/npm install --production
elif [ -f /opt/cpanel/ea-nodejs18/bin/npm ]; then
  echo "   Using cPanel npm..."
  /opt/cpanel/ea-nodejs18/bin/npm install --production
elif [ -f /opt/cpanel/ea-nodejs20/bin/npm ]; then
  echo "   Using cPanel npm..."
  /opt/cpanel/ea-nodejs20/bin/npm install --production
else
  echo "   ⚠️ npm not found - please install dependencies manually in cPanel"
  echo "   Go to: cPanel → Setup Node.js App → Your App → NPM Install"
fi
ENDSSH

echo "✅ Backend dependencies installation completed"

# --- Step 8: Display Summary ---
echo ""
echo "====================================================="
echo "🎉 Full Stack Deployment Complete!"
echo "====================================================="
echo ""
echo "📊 Deployment Summary:"
echo "   ✅ Frontend deployed to: $FRONTEND_DIR"
echo "   ✅ Backend deployed to: $BACKEND_DIR"
echo "   ✅ Logs saved at: $LOG_FILE"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. ⚙️  Configure Environment Variables in cPanel:"
echo "   - Go to: cPanel → Setup Node.js App → Your App"
echo "   - Add these environment variables:"
echo "     NODE_ENV=production"
echo "     PORT=5000"
echo "     DB_HOST=$REMOTE_DB_HOST"
echo "     DB_USER=$REMOTE_DB_USER"
echo "     DB_PASSWORD=$REMOTE_DB_PASS"
echo "     DB_NAME=$REMOTE_DB_NAME (should be: theomkiq_charity)"
echo "     JWT_SECRET=your-secret-key-here"
echo ""
echo "2. 🔑 Add Razorpay Environment Variables:"
echo "   - RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID"
echo "   - RAZORPAY_KEY_SECRET=your_razorpay_secret_key"
echo "   - RAZORPAY_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx"
echo ""
echo "3. 📝 Create .htaccess file (if Application URL is /api):"
echo "   - Run: ssh -i ~/.ssh/key_private -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST"
echo "   - Then: mkdir -p ~/public_html/api && cat > ~/public_html/api/.htaccess << 'EOF'"
echo "   - Paste .htaccess content (see FIX_HTACCESS_ERROR_QUICK.md)"
echo ""
echo "4. 🔄 Restart Node.js App in cPanel:"
echo "   - Go to: cPanel → Setup Node.js App"
echo "   - Click: 'Restart App' button"
echo ""
echo "5. ✅ Test API Endpoints:"
echo "   - https://theonerupeerevolution.org/api/settings"
echo "   - https://theonerupeerevolution.org/api/slider"
echo "   - https://theonerupeerevolution.org/api/gallery"
echo ""
echo "6. 🧪 Verify Frontend:"
echo "   - https://theonerupeerevolution.org"
echo "   - Check browser console (F12) for errors"
echo ""
echo "7. 💳 Test Payment Integration:"
echo "   - Visit: https://theonerupeerevolution.org/donate"
echo "   - Complete a test donation"
echo "   - Check admin panel for donation record"
echo ""
echo "====================================================="
echo "🚀 Deployment finished at $(date)"
echo "====================================================="

