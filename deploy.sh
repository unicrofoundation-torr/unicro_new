#!/bin/bash
echo "====================================================="
echo "🚀 Deployment started at $(date)"
echo "====================================================="

# --- Configuration ---
DB_USER="root"
DB_PASS="root123"
DB_NAME="charity_website"
PROJECT_DIR="/mnt/e/kanishk data/projects/UNICRO"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"
PRIVATE_KEY="~/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"

# Ensure directories exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

# --- Logging setup ---
LOG_FILE="$LOG_DIR/deploy_$(date +%d-%m-%Y_%H-%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- Step 1: MySQL Backup ---
echo "💾 Taking MySQL Backup..."
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%d-%m-%Y_%H-%M).sql"

/mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "✅ MySQL backup successful: $BACKUP_FILE"
else
  echo "❌ MySQL backup failed."
  exit 1
fi

# --- Step 2: Git Push ---
echo "📦 Pushing latest code to GitHub..."
cd "$PROJECT_DIR"
git add .
git commit -m "Auto-deploy: $(date)"
git push origin main

if [ $? -eq 0 ]; then
  echo "✅ GitHub push successful"
else
  echo "⚠️ Git push failed — continuing deployment"
fi

# --- Step 3: Deploy via rsync ---
echo "🌐 Uploading to cPanel using rsync..."
rsync -avz -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" "$PROJECT_DIR/src/" "$CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR"

if [ $? -eq 0 ]; then
  echo "✅ Deployment completed successfully!"
else
  echo "❌ Deployment failed during upload."
  exit 1
fi

echo "====================================================="
echo "🎉 All Done! Deployment completed at $(date)"
echo "Logs saved at: $LOG_FILE"
echo "====================================================="

