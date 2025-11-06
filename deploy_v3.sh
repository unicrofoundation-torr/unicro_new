#!/bin/bash
echo "====================================================="
echo "🚀 Smart Incremental Deployment started at $(date)"
echo "====================================================="

# --- Configuration ---
DB_USER="root"
DB_PASS="root123"
DB_NAME="charity_website"
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"
BACKUP_DIR="$PROJECT_ROOT/backups"
LOG_DIR="$PROJECT_ROOT/logs"
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"

# --- Create necessary folders ---
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# --- Create log file ---
LOG_FILE="$LOG_DIR/deploy_v3_$(date +%d-%m-%Y_%H-%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Step 1: Check for changes ---
echo "🔍 Checking for changes..."
cd "$PROJECT_ROOT"

# Check if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo "📝 Found uncommitted changes, committing them..."
  git add .
  git commit -m "Auto-deploy: $(date +%Y-%m-%d_%H-%M-%S)" || echo "⚠️ Nothing to commit"
fi

# Get list of changed files since last deployment
LAST_DEPLOY_FILE="$LOG_DIR/last_deploy_commit.txt"
if [ -f "$LAST_DEPLOY_FILE" ]; then
  LAST_COMMIT=$(cat "$LAST_DEPLOY_FILE")
  CHANGED_FILES=$(git diff --name-only $LAST_COMMIT HEAD 2>/dev/null)
else
  # First deployment - deploy everything
  CHANGED_FILES="initial_deployment"
fi

# Check if client source files changed
CLIENT_CHANGED=false
if [ "$CHANGED_FILES" = "initial_deployment" ] || echo "$CHANGED_FILES" | grep -q "^client/src/"; then
  CLIENT_CHANGED=true
  echo "✅ Client source files changed - rebuild required"
fi

# Check if server files changed
SERVER_CHANGED=false
if [ "$CHANGED_FILES" = "initial_deployment" ] || echo "$CHANGED_FILES" | grep -q "^server.js\|^routes/\|^config/\|^database/"; then
  SERVER_CHANGED=true
  echo "✅ Server files changed"
fi

# --- Step 2: MySQL Backup (only if database-related files changed) ---
if [ "$CHANGED_FILES" = "initial_deployment" ] || echo "$CHANGED_FILES" | grep -q "database/\|schema.sql"; then
  echo "💾 Taking MySQL Backup..."
  BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%d-%m-%Y_%H-%M).sql"
  /mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u$DB_USER -p$DB_PASS $DB_NAME > "$BACKUP_FILE"
  if [ $? -eq 0 ]; then
    echo "✅ MySQL backup successful: $BACKUP_FILE"
  else
    echo "❌ MySQL backup failed."
    exit 1
  fi
else
  echo "⏭️ Skipping MySQL backup (no database changes detected)"
fi

# --- Step 3: Push to GitHub ---
echo "📦 Pushing latest code to GitHub..."
git push origin main 2>/dev/null || echo "⚠️ Git push failed or no changes to push"

# --- Step 4: Build React Frontend (only if client files changed) ---
if [ "$CLIENT_CHANGED" = true ] || [ ! -d "$BUILD_DIR" ]; then
  echo "🏗️ Building React project..."
  cd "$CLIENT_DIR"
  
  # Check if node_modules exists, if not install
  if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install --legacy-peer-deps
  fi
  
  # Build React app
  npm run build
  if [ $? -eq 0 ]; then
    echo "✅ React build successful"
  else
    echo "❌ React build failed."
    exit 1
  fi
else
  echo "⏭️ Skipping React build (no client source changes detected)"
fi

# --- Step 5: Smart Incremental Upload to cPanel ---
echo "🌐 Uploading changed files to cPanel..."

# rsync is smart - it only transfers files that have changed (by default checks size and mtime)
# Using --update to skip files that are newer on destination
# Using --checksum for more accurate change detection (slower but more reliable)
# Using --delete to remove files that no longer exist in build

if [ "$CLIENT_CHANGED" = true ] || [ "$CHANGED_FILES" = "initial_deployment" ] || [ ! -d "$BUILD_DIR" ]; then
  # Client source changed - sync entire build (rsync will only transfer changed files)
  echo "📤 Syncing build directory (rsync will only transfer changed files)..."
  rsync -avz \
    --progress \
    --checksum \
    --update \
    --delete \
    --exclude 'node_modules/' \
    --exclude '.git/' \
    --exclude '.env' \
    --exclude '*.map' \
    --exclude '.DS_Store' \
    --include '.htaccess' \
    -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
    "$BUILD_DIR/" $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR/
else
  # No client changes - but still sync to catch any manual changes or ensure consistency
  echo "📤 Syncing build directory (incremental - only changed files)..."
    rsync -avz \
      --progress \
      --checksum \
      --update \
      --delete \
      --exclude 'node_modules/' \
      --exclude '.git/' \
      --exclude '.env' \
      --exclude '*.map' \
      --exclude '.DS_Store' \
      --include '.htaccess' \
      -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
      "$BUILD_DIR/" $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR/
fi

if [ $? -eq 0 ]; then
  echo "✅ Deployment completed successfully!"
  
  # Save current commit hash for next deployment
  CURRENT_COMMIT=$(git rev-parse HEAD)
  echo "$CURRENT_COMMIT" > "$LAST_DEPLOY_FILE"
  echo "💾 Saved deployment commit: $CURRENT_COMMIT"
else
  echo "❌ Deployment failed during upload."
  exit 1
fi

echo "====================================================="
echo "🎉 Smart Deployment Finished at $(date)"
echo "📊 Summary:"
echo "   - Client changed: $CLIENT_CHANGED"
echo "   - Server changed: $SERVER_CHANGED"
echo "   - Logs saved at: $LOG_FILE"
echo "====================================================="

