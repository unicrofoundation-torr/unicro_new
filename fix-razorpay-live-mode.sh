#!/bin/bash
echo "====================================================="
echo "🔧 Fixing Razorpay Live Mode Configuration"
echo "====================================================="

# --- Configuration ---
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"
LOG_DIR="$PROJECT_ROOT/logs"

# Razorpay LIVE Key ID (UPDATE THIS!)
RAZORPAY_KEY_ID="rzp_live_RhWOsPuVUOT0Xx"  # 👈 Make sure this is your LIVE key

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
FRONTEND_DIR="~/public_html"

# --- Create log file ---
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/fix_razorpay_$(date +%d-%m-%Y_%H-%M).log"

log() {
    echo "$@" | tee -a "$LOG_FILE"
}

log ""
log "Step 1: Rebuilding frontend with LIVE Razorpay key..."
log "   Using Razorpay Key ID: $RAZORPAY_KEY_ID"
log ""

cd "$CLIENT_DIR"

# Set environment variables for build
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

# Build React app with live key
log "   Building production bundle..."
npm run build 2>&1 | tee -a "$LOG_FILE"
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    log "✅ Frontend build successful with LIVE Razorpay key"
else
    log "❌ Frontend build failed"
    exit 1
fi

log ""
log "Step 2: Verifying Razorpay key in build..."
if grep -q "$RAZORPAY_KEY_ID" "$BUILD_DIR/static/js/main"*.js 2>/dev/null; then
    log "✅ Live Razorpay key found in build files"
else
    log "⚠️  Warning: Could not verify Razorpay key in build files"
fi

log ""
log "Step 3: Deploying frontend to server..."
rsync -avz \
  --progress \
  --delete \
  --exclude='node_modules/' \
  --exclude='.git/' \
  --exclude='.env' \
  --exclude='*.map' \
  --include='.htaccess' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" $CPANEL_USER@$CPANEL_HOST:$FRONTEND_DIR

if [ $? -eq 0 ]; then
    log "✅ Frontend deployed successfully"
else
    log "❌ Frontend deployment failed"
    exit 1
fi

log ""
log "====================================================="
log "✅ Razorpay Live Mode Fix Complete!"
log "====================================================="
log ""
log "📋 IMPORTANT: Verify Backend Environment Variables"
log ""
log "Go to: cPanel → Setup Node.js App → Your App → Environment Variables"
log ""
log "Make sure these are set with LIVE keys:"
log "   RAZORPAY_KEY_ID=rzp_live_RhWOsPuVUOT0Xx"
log "   RAZORPAY_KEY_SECRET=(your-live-secret-key)"
log "   RAZORPAY_WEBHOOK_SECRET=(your-live-webhook-secret)"
log ""
log "⚠️  Make sure:"
log "   - Keys start with 'rzp_live_' (NOT 'rzp_test_')"
log "   - Razorpay account is in LIVE mode"
log "   - Restart the Node.js app after updating variables"
log ""
log "🧪 Test:"
log "   1. Visit: https://theonerupeerevolution.org/donate"
log "   2. Try making a donation"
log "   3. Payment page should NOT show 'TEST MODE'"
log ""
log "Logs saved at: $LOG_FILE"
log ""

