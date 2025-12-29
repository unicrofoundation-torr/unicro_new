#!/bin/bash
echo "====================================================="
echo "🔧 Complete Razorpay Live Mode Fix"
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
LOG_FILE="$LOG_DIR/fix_razorpay_complete_$(date +%d-%m-%Y_%H-%M).log"

log() {
    echo "$@" | tee -a "$LOG_FILE"
}

log ""
log "Step 1: Rebuilding frontend with LIVE Razorpay key..."
log "   Using Razorpay Key ID: $RAZORPAY_KEY_ID"
log ""

cd "$CLIENT_DIR"

# Verify it's a live key
if [[ ! "$RAZORPAY_KEY_ID" =~ ^rzp_live_ ]]; then
    log "❌ ERROR: Key ID must start with 'rzp_live_'"
    log "   Current key: $RAZORPAY_KEY_ID"
    log "   Please update RAZORPAY_KEY_ID in this script with your LIVE key"
    exit 1
fi

# Set environment variables for build
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

# Build React app with live key
log "   Building production bundle..."
npm run build 2>&1 | tee -a "$LOG_FILE"
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
    log "✅ Frontend build successful"
    
    # Verify key is in build
    MAIN_JS=$(find "$BUILD_DIR/static/js" -name "main*.js" -type f | head -1)
    if [ -n "$MAIN_JS" ] && grep -q "$RAZORPAY_KEY_ID" "$MAIN_JS" 2>/dev/null; then
        log "✅ Live Razorpay key verified in build files"
    else
        log "⚠️  Warning: Could not verify key in build files"
    fi
else
    log "❌ Frontend build failed"
    exit 1
fi

log ""
log "Step 2: Deploying frontend to server..."
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
log "Step 3: Checking backend configuration..."
log ""

ssh -i $PRIVATE_KEY -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << ENDSSH
echo "   Current backend environment variables:"
echo ""
echo "   Checking if Node.js app can access environment variables..."
cd ~/nodejs 2>/dev/null || echo "   ⚠️  nodejs directory not found"

# Try to check environment via Node.js
if command -v node &> /dev/null; then
    NODE_PATH=\$(which node)
    echo "   Node.js found at: \$NODE_PATH"
    echo ""
    echo "   To check your current environment variables, run this in cPanel Terminal:"
    echo "   cd ~/nodejs && node -e \"console.log('RAZORPAY_KEY_ID:', process.env.RAZORPAY_KEY_ID || 'NOT SET')\""
else
    echo "   ⚠️  Node.js not found in PATH"
fi
ENDSSH

log ""
log "====================================================="
log "✅ Frontend Fix Complete!"
log "====================================================="
log ""
log "📋 CRITICAL: Backend Environment Variables"
log ""
log "You MUST update backend environment variables in cPanel:"
log ""
log "1. Go to: cPanel → Setup Node.js App → Your App"
log "2. Click: 'Environment Variables' or 'Edit'"
log "3. Set these variables with LIVE keys:"
log ""
log "   RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID"
log "   RAZORPAY_KEY_SECRET=(your-live-secret-key)"
log "   RAZORPAY_WEBHOOK_SECRET=(your-live-webhook-secret)"
log ""
log "⚠️  IMPORTANT:"
log "   - Keys MUST start with 'rzp_live_' (NOT 'rzp_test_')"
log "   - After updating, click 'Save'"
log "   - Then click 'Restart App'"
log "   - Wait 10-30 seconds for app to restart"
log ""
log "4. Verify Razorpay Dashboard:"
log "   - Go to: https://dashboard.razorpay.com/"
log "   - Check top-right corner says 'Live Mode' (not 'Test Mode')"
log "   - Go to: Settings → API Keys"
log "   - Make sure you're viewing 'Live Mode' keys"
log ""
log "5. Test:"
log "   - Clear browser cache (Ctrl+Shift+Delete)"
log "   - Visit: https://theonerupeerevolution.org/donate"
log "   - Try making a donation"
log "   - Payment page should NOT show 'TEST MODE'"
log ""
log "====================================================="
log "Logs saved at: $LOG_FILE"
log "====================================================="

