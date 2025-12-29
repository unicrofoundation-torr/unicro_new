#!/bin/bash
log "====================================================="
log "🚀 Frontend-Only Deployment started at $(date)"
log "====================================================="

# --- Configuration ---
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
LOG_DIR="$PROJECT_ROOT/logs"
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"   # Frontend deployment directory

# --- Create necessary folders ---
mkdir -p "$LOG_DIR"

# --- Create log file ---
LOG_FILE="$LOG_DIR/deploy_frontend_$(date +%d-%m-%Y_%H-%M).log"

# Function to log and display
log() {
    echo "$@" | tee -a "$LOG_FILE"
}

# --- Step 1: Build React Frontend ---
log ""
log "🏗️ Building React project..."
cd "$CLIENT_DIR"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    log "   Installing dependencies..."
    npm install --legacy-peer-deps 2>&1 | tee -a "$LOG_FILE"
else
    log "   Dependencies already installed, skipping..."
fi

# Build the React app
log "   Building production bundle..."
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
npm run build 2>&1 | tee -a "$LOG_FILE"
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    log "✅ React build successful"
else
    log "❌ React build failed."
    exit 1
fi

# --- Step 2: Upload build to cPanel ---
log ""
log "🌐 Uploading build folder to cPanel..."
log "   Source: $CLIENT_DIR/build/"
log "   Destination: $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR"

# Upload new build (ignore node_modules, git files, backups)
# Include .htaccess for React Router support
rsync -avz \
  --progress \
  --delete \
  --exclude 'node_modules/' \
  --exclude '.git/' \
  --exclude '.env' \
  --exclude '*.map' \
  --include '.htaccess' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$CLIENT_DIR/build/" $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR

if [ $? -eq 0 ]; then
    log ""
    log "✅ Frontend deployment completed successfully!"
    log ""
    log "====================================================="
    log "🎉 Frontend Deployed Successfully!"
    log "====================================================="
    log "Logs saved at: $LOG_FILE"
    log ""
    log "Your frontend is now live at your website URL"
else
    log ""
    log "❌ Deployment failed during upload."
    log "Check the logs at: $LOG_FILE"
    exit 1
fi

