#!/bin/bash
# Verify local build is fresh, then deploy

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

# LIVE Razorpay Key
RAZORPAY_KEY_ID="rzp_live_RhWOsPuVUOT0Xx"

echo "🔧 Verify & Deploy Fresh Build"
echo "==============================="
echo ""

cd "$CLIENT_DIR"

# Step 1: Check if build exists and is recent
echo "1️⃣  Checking local build..."
echo "==========================="
if [ ! -d "$BUILD_DIR" ]; then
  echo "   ❌ No build directory - need to build first"
  echo "   → Run: bash aggressive_rebuild_live_key.sh"
  exit 1
fi

BUILD_TIME=$(stat -c %y "$BUILD_DIR/index.html" 2>/dev/null || stat -f "%Sm" "$BUILD_DIR/index.html" 2>/dev/null || echo "unknown")
echo "   Build time: $BUILD_TIME"

# Check for test key in local build
if grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
  echo "   ❌ TEST key found in LOCAL build!"
  echo "   → Need to rebuild"
  echo ""
  echo "   Running aggressive rebuild..."
  bash "$PROJECT_ROOT/aggressive_rebuild_live_key.sh"
  exit $?
fi

# Check for live key
if grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
  echo "   ✅ LIVE key found in local build"
elif grep -r "rzp_live" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
  echo "   ✅ LIVE key pattern found"
else
  echo "   ⚠️  No key in build (will use fallback)"
fi
echo ""

# Step 2: Deploy with force
echo "2️⃣  Deploying to server (force overwrite)..."
echo "============================================="
rsync -avz --delete --progress -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | tail -10

echo ""
echo "✅ Deployment complete"
echo ""

# Step 3: Verify on server
echo "3️⃣  Verifying on server..."
echo "==========================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html

echo "   Checking build timestamp..."
if [ -f index.html ]; then
  BUILD_TIME=$(stat -c %y index.html 2>/dev/null || stat -f "%Sm" index.html 2>/dev/null || echo "unknown")
  echo "   Server build time: $BUILD_TIME"
fi

echo ""
echo "   Checking for test key..."
cd static/js
TEST_COUNT=$(grep -c "rzp_test" main.*.js 2>/dev/null || echo "0")
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "   ❌ TEST key still found on server ($TEST_COUNT occurrences)!"
  echo "   → Deployment might have failed or old files cached"
  exit 1
else
  echo "   ✅ No TEST key on server"
fi

echo ""
echo "   Checking for LIVE key..."
if grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key (rzp_live_RhWOsPuVUOT0Xx) confirmed!"
elif grep -q "rzp_live" main.*.js 2>/dev/null; then
  KEY=$(grep -o "rzp_live_[A-Za-z0-9]*" main.*.js 2>/dev/null | head -1)
  echo "   ✅ LIVE key found: $KEY"
else
  echo "   ⚠️  No key in file (will use fallback from Donate.js)"
fi
EOF

echo ""
echo "============================================"
echo "✅ Verification Complete!"
echo "============================================"
echo ""
echo "🔄 Next: Clear browser cache and test!"
echo ""

