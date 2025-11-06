#!/bin/bash
echo "====================================================="
echo "🚀 Deployment started at $(date)"
echo "====================================================="

# --- Configuration ---
DB_USER="root"
DB_PASS="root123"
DB_NAME="charity_website"
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_DIR="$PROJECT_ROOT/logs"
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"   # 👈 change to ~/public_html/client if you want subfolder deploy

# --- Create necessary folders ---
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# --- Create log file ---
LOG_FILE="$LOG_DIR/deploy_$(date +%d-%m-%Y_%H-%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Step 1: MySQL Backup ---
echo "💾 Taking MySQL Backup..."
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%d-%m-%Y_%H-%M).sql"
/mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u$DB_USER -p$DB_PASS $DB_NAME > "$BACKUP_FILE"
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
git commit -m "Auto-deploy: $(date)"
git push origin main
if [ $? -eq 0 ]; then
  echo "✅ GitHub push successful"
else
  echo "⚠️ Git push failed — continuing deployment"
fi

# --- Step 3: Build React Frontend ---
echo "🏗️ Building React project..."
cd "$CLIENT_DIR"
npm install --legacy-peer-deps
npm run build
if [ $? -eq 0 ]; then
  echo "✅ React build successful"
else
  echo "❌ React build failed."
  exit 1
fi

# --- Step 4: Upload build to cPanel ---
echo "🌐 Uploading build folder to cPanel..."
# Clean existing files (optional but recommended)
ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST "rm -rf $REMOTE_DIR/*"

# Upload new build (ignore node_modules, git files, backups)
rsync -avz \
  --exclude 'node_modules/' \
  --exclude '.git/' \
  --exclude '.env' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$CLIENT_DIR/build/" $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR

if [ $? -eq 0 ]; then
  echo "✅ Deployment completed successfully!"
else
  echo "❌ Deployment failed during upload."
  exit 1
fi

echo "====================================================="
echo "🎉 All Done! Deployment Finished at $(date)"
echo "Logs saved at: $LOG_FILE"
echo "====================================================="

