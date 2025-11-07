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
rsync -avz \
  --exclude 'client/' \
  --exclude 'node_modules/' \
  --exclude '.git/' \
  --exclude 'backups/' \
  --exclude 'logs/' \
  --exclude '*.log' \
  --exclude '.env' \
  --include 'server.js' \
  --include 'package.json' \
  --include 'package-lock.json' \
  --include 'config/' \
  --include 'routes/' \
  --include 'database/' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$PROJECT_ROOT/" $CPANEL_USER@$CPANEL_HOST:$BACKEND_DIR

if [ $? -ne 0 ]; then
  echo "⚠️  Backend upload failed. You may need to deploy backend separately."
  echo "⚠️  Check if your cPanel supports Node.js applications."
else
  echo "✅ Backend files uploaded successfully"
  
  # Install backend dependencies on server
  echo "📦 Installing backend dependencies on server..."
  ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << 'ENDSSH'
    cd ~/nodejs
    if command -v npm &> /dev/null; then
      npm install --production
      echo "✅ Backend dependencies installed"
    else
      echo "⚠️  npm not found. Node.js may not be installed on cPanel."
      echo "⚠️  You may need to enable Node.js in cPanel or use a different hosting solution."
    fi
ENDSSH
fi

# --- Step 6: Deploy SQL Schema to Remote Database ---
echo "🗄️  Deploying SQL schema to remote database..."
echo "⚠️  Make sure you've updated REMOTE_DB_* variables in the script!"

# Upload schema.sql to server
echo "📤 Uploading schema.sql to server..."
scp -i "$PRIVATE_KEY" -P $CPANEL_PORT "$PROJECT_ROOT/database/schema.sql" $CPANEL_USER@$CPANEL_HOST:~/schema.sql

if [ $? -eq 0 ]; then
  echo "✅ Schema file uploaded"
  
  # Import schema to remote database
  echo "📥 Importing schema to remote database..."
  ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << ENDSSH
    # Check if mysql command is available
    if command -v mysql &> /dev/null; then
      # Import schema (this will create tables if they don't exist)
      mysql -u${REMOTE_DB_USER} -p${REMOTE_DB_PASS} -h${REMOTE_DB_HOST} ${REMOTE_DB_NAME} < ~/schema.sql
      if [ \$? -eq 0 ]; then
        echo "✅ SQL schema imported successfully"
      else
        echo "❌ SQL schema import failed. Check database credentials."
        echo "⚠️  You may need to import manually via phpMyAdmin"
      fi
    else
      echo "⚠️  mysql command not found. You may need to import manually via phpMyAdmin"
      echo "📋 To import manually:"
      echo "   1. Login to cPanel → phpMyAdmin"
      echo "   2. Select database: ${REMOTE_DB_NAME}"
      echo "   3. Click 'Import' tab"
      echo "   4. Upload: ~/schema.sql"
    fi
    
    # Clean up uploaded schema file
    rm -f ~/schema.sql
ENDSSH
else
  echo "❌ Failed to upload schema file"
  echo "⚠️  You'll need to import schema manually via phpMyAdmin"
fi

echo ""
echo "====================================================="
echo "📋 DEPLOYMENT SUMMARY"
echo "====================================================="
echo "✅ Frontend: Deployed to $REMOTE_DIR"
echo "⚠️  Backend: Uploaded to $BACKEND_DIR"
echo "⚠️  Database: Schema deployment attempted"
echo ""
echo "🔧 NEXT STEPS:"
echo "1. ⚠️  IMPORTANT: Update database credentials in script:"
echo "   - REMOTE_DB_USER (usually: cpanel_username_dbuser)"
echo "   - REMOTE_DB_PASS (your cPanel database password)"
echo "   - REMOTE_DB_NAME (usually: cpanel_username_dbname)"
echo ""
echo "2. If SQL import failed, import manually:"
echo "   - Login to cPanel → phpMyAdmin"
echo "   - Select database: $REMOTE_DB_NAME"
echo "   - Click 'Import' → Upload database/schema.sql"
echo ""
echo "3. Check if your cPanel supports Node.js applications"
echo "4. If yes, configure Node.js app in cPanel to run server.js"
echo "5. If no, deploy backend to:"
echo "   - VPS (DigitalOcean, AWS EC2, etc.)"
echo "   - Heroku"
echo "   - Railway"
echo "   - Render"
echo "   - Or any Node.js hosting service"
echo ""
echo "6. Update frontend API URL to point to your backend server"
echo "7. Configure database connection in backend .env file"
echo ""
echo "📝 Logs saved at: $LOG_FILE"
echo "====================================================="

