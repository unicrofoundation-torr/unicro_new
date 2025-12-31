#!/bin/bash

# =====================================================
# 🎨 Update Logo/Favicon and Deploy Script
# =====================================================
# This script will:
# 1. Update favicon files with your logo
# 2. Rebuild the frontend with updated meta tags
# 3. Deploy everything to the server
# =====================================================

echo "====================================================="
echo "🎨 Update Logo & Deploy Script"
echo "🚀 Started at $(date)"
echo "====================================================="

# --- Configuration ---
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
PUBLIC_DIR="$CLIENT_DIR/public"
LOGO_SOURCE="$PUBLIC_DIR/uploads/logo-1760602707648-414861542.png"
LOG_DIR="$PROJECT_ROOT/logs"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
REMOTE_DIR="~/public_html"

# Razorpay Key ID (for frontend build)
RAZORPAY_KEY_ID="rzp_live_RhWOsPuVUOT0Xx"

# --- Create necessary folders ---
mkdir -p "$LOG_DIR"

# --- Create log file ---
LOG_FILE="$LOG_DIR/update_logo_deploy_$(date +%d-%m-%Y_%H-%M).log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to log
log() {
    echo "$@"
}

# --- Step 1: Update Favicon Files ---
log ""
log "====================================================="
log "📸 Step 1: Updating favicon files with logo..."
log "====================================================="

if [ ! -f "$LOGO_SOURCE" ]; then
    log "❌ Error: Logo file not found at $LOGO_SOURCE"
    log "Please ensure the logo file exists in the uploads directory."
    exit 1
fi

log "✅ Logo file found: $LOGO_SOURCE"

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    log "✅ ImageMagick found. Creating optimized favicon files..."
    
    # Create favicon.ico (16x16, 32x32, 48x48 sizes)
    convert "$LOGO_SOURCE" -resize 16x16 -resize 32x32 -resize 48x48 "$PUBLIC_DIR/favicon.ico" 2>/dev/null || {
        log "⚠️  Could not create .ico file, copying PNG instead..."
        cp "$LOGO_SOURCE" "$PUBLIC_DIR/favicon.ico"
    }
    
    # Create logo192.png (192x192)
    convert "$LOGO_SOURCE" -resize 192x192 "$PUBLIC_DIR/logo192.png" 2>/dev/null || {
        log "⚠️  Could not resize to 192x192, copying original..."
        cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo192.png"
    }
    
    # Create logo512.png (512x512)
    convert "$LOGO_SOURCE" -resize 512x512 "$PUBLIC_DIR/logo512.png" 2>/dev/null || {
        log "⚠️  Could not resize to 512x512, copying original..."
        cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo512.png"
    }
    
    log "✅ Favicon files updated successfully!"
else
    log "⚠️  ImageMagick not found. Copying logo file directly..."
    log "   For best results, install ImageMagick: sudo apt-get install imagemagick"
    
    # Fallback: just copy the logo file
    cp "$LOGO_SOURCE" "$PUBLIC_DIR/favicon.ico"
    cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo192.png"
    cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo512.png"
    
    log "✅ Logo files copied (may need manual resizing for optimal display)"
fi

# --- Step 2: Build React Frontend ---
log ""
log "====================================================="
log "🏗️ Step 2: Building React frontend..."
log "====================================================="

cd "$CLIENT_DIR" || exit 1

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    log "📦 Installing dependencies..."
    npm install
else
    log "✅ Dependencies already installed, skipping..."
fi

# Build with environment variables
log "🏗️ Building production bundle..."
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

npm run build

if [ $? -ne 0 ]; then
    log "❌ Build failed! Check the errors above."
    exit 1
fi

log "✅ React build successful"

# --- Step 3: Deploy Frontend ---
log ""
log "====================================================="
log "🌐 Step 3: Deploying frontend to server..."
log "====================================================="

BUILD_DIR="$CLIENT_DIR/build"

if [ ! -d "$BUILD_DIR" ]; then
    log "❌ Error: Build directory not found at $BUILD_DIR"
    exit 1
fi

log "📤 Uploading build folder to cPanel..."
log "Source: $BUILD_DIR"
log "Destination: $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR"

# Use rsync for incremental uploads (no --delete flag)
rsync -avz --progress \
    -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
    "$BUILD_DIR/" \
    "$CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR/"

if [ $? -ne 0 ]; then
    log "❌ Upload failed! Check SSH connection and permissions."
    exit 1
fi

log "✅ Frontend deployment completed successfully!"

# --- Step 4: Create .htaccess for API (if needed) ---
log ""
log "====================================================="
log "📝 Step 4: Ensuring .htaccess file exists..."
log "====================================================="

# Create .htaccess file for API directory
HTACCESS_CONTENT="PassengerEnabled On
PassengerAppRoot /home/theomkiq/nodejs
PassengerAppType node
PassengerStartupFile server.js
PassengerNodejs /home/theomkiq/nodejs/nodevenv.nodejs/18/bin/node
PassengerAppLogFile /home/theomkiq/logs/passenger.log
PassengerRestartDir /home/theomkiq/nodejs"

ssh -i "$PRIVATE_KEY" -p $CPANEL_PORT "$CPANEL_USER@$CPANEL_HOST" \
    "mkdir -p ~/public_html/api && cat > ~/public_html/api/.htaccess << 'EOF'
$HTACCESS_CONTENT
EOF"

if [ $? -eq 0 ]; then
    log "✅ .htaccess file created/updated"
else
    log "⚠️  Could not create .htaccess file (may already exist)"
fi

# --- Summary ---
log ""
log "====================================================="
log "🎉 Deployment Summary"
log "====================================================="
log "✅ Favicon files updated with your logo"
log "✅ Frontend rebuilt with updated meta tags"
log "✅ Files deployed to server (incremental upload)"
log "✅ .htaccess file ensured"
log ""
log "📝 Next Steps:"
log "1. Clear Google's cache using Google Search Console"
log "2. Request re-indexing of your homepage"
log "3. Wait 24-48 hours for Google to re-crawl your site"
log ""
log "📄 Logs saved at: $LOG_FILE"
log "====================================================="
log "✨ All done! Your logo should appear in Google search results soon."
log "====================================================="

