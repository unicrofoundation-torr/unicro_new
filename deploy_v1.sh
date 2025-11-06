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
CLIENT_DIR="$PROJECT_DIR/client"
PRIVATE_KEY="/mnt/c/Users/KanishkRajSinghDodiy/Downloads/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"
LOG_FILE="$LOG_DIR/deploy_$(date +%d-%m-%Y_%H-%M).log"

# --- Start Logging ---
mkdir -p "$LOG_DIR" "$BACKUP_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# --- MySQL Backup ---
echo "💾 Taking MySQL Backup..."
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%d-%m-%Y_%H-%M).sql"
/mnt/c/Program\ Files/MySQL/MySQL\ Server\ 8.0/bin/mysqldump.exe -u$DB_USER -p$DB_PASS $DB_NAME > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "✅ MySQL backup successful: $BACKUP_FILE"
else
  echo "❌ MySQL backup failed."
  exit 1
fi

# --- Git Commit & Push ---
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

# --- Rsync Upload (Frontend Only) ---
echo "🌐 Uploading client (frontend) to cPanel..."
rsync -avz -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" "$CLIENT_DIR/" $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR

if [ $? -eq 0 ]; then
  echo "✅ Frontend deployed successfully!"
else
  echo "❌ Deployment failed during upload."
  exit 1
fi
