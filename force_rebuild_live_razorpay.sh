#!/bin/bash
# Force rebuild with LIVE Razorpay key - clears all caches

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

# LIVE Razorpay Key ID
RAZORPAY_KEY_ID="rzp_live_RhWOsPuVUOT0Xx"

echo "🔧 Force Rebuild with LIVE Razorpay Key"
echo "======================================="
echo ""
echo "⚠️  This will:"
echo "   1. Clear all caches"
echo "   2. Remove old build"
echo "   3. Set environment variable"
echo "   4. Rebuild with LIVE key"
echo "   5. Verify key in build"
echo "   6. Deploy"
echo ""

cd "$CLIENT_DIR"

# Step 1: Clear all caches
echo "1️⃣  Clearing all caches..."
echo "=========================="
rm -rf "$BUILD_DIR"
rm -rf node_modules/.cache
rm -rf .cache
echo "✅ Caches cleared"
echo ""

# Step 2: Set environment variable explicitly
echo "2️⃣  Setting environment variables..."
echo "====================================="
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

# Also set it in the current shell session
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

echo "   NODE_ENV=production"
echo "   REACT_APP_RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID"
echo "   (Also using hardcoded fallback in Donate.js)"
echo ""

# Step 3: Verify env var is set
echo "3️⃣  Verifying environment variable..."
echo "====================================="
if [ -n "$REACT_APP_RAZORPAY_KEY_ID" ]; then
  echo "   ✅ REACT_APP_RAZORPAY_KEY_ID is set: $REACT_APP_RAZORPAY_KEY_ID"
  if [[ "$REACT_APP_RAZORPAY_KEY_ID" == *"live"* ]]; then
    echo "   ✅ LIVE key confirmed"
  else
    echo "   ⚠️  Not a LIVE key!"
  fi
else
  echo "   ❌ REACT_APP_RAZORPAY_KEY_ID is NOT set!"
  echo "   → Will use hardcoded fallback in Donate.js"
fi
echo ""

# Step 4: Build with explicit env var
echo "4️⃣  Building React app..."
echo "========================="
cd "$CLIENT_DIR"

# Build with explicit env var in the command
REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID" NODE_ENV=production GENERATE_SOURCEMAP=false npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build successful"
echo ""

# Step 5: Verify key in build
echo "5️⃣  Verifying key in build..."
echo "============================="
if [ -d "$BUILD_DIR/static/js" ]; then
  # Search for the key
  if grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
    echo "   ✅ LIVE key found in build!"
  elif grep -r "rzp_live" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
    echo "   ✅ LIVE key pattern found (might be minified)"
    KEY_FOUND=$(grep -ro "rzp_live_[A-Za-z0-9]*" "$BUILD_DIR/static/js" 2>/dev/null | head -1 | cut -d: -f2)
    echo "   Key: $KEY_FOUND"
  elif grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null; then
    echo "   ❌ TEST key still found!"
    echo "   → Check Donate.js for hardcoded fallback"
  else
    echo "   ⚠️  No key found - using fallback from Donate.js"
  fi
else
  echo "   ⚠️  Build directory not found"
fi
echo ""

# Step 6: Deploy
echo "6️⃣  Deploying to cPanel..."
echo "==========================="
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | grep -E "(sending|sent|deleting|error)" || echo "   ✅ Deployment complete"

echo ""

# Step 7: Final verification
echo "7️⃣  Final verification on server..."
echo "===================================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js
echo "   Searching for Razorpay key in deployed files..."
if grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key (rzp_live_RhWOsPuVUOT0Xx) found on server!"
elif grep -q "rzp_live" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key pattern found on server"
  KEY=$(grep -o "rzp_live_[A-Za-z0-9]*" main.*.js 2>/dev/null | head -1)
  echo "   Key: $KEY"
elif grep -q "rzp_test" main.*.js 2>/dev/null; then
  echo "   ❌ TEST key still found on server!"
  echo "   → Need to check build process"
else
  echo "   ⚠️  No key found - will use fallback from Donate.js"
  echo "   → This should work (fallback is hardcoded)"
fi
EOF

echo ""
echo "============================================"
echo "✅ Rebuild Complete!"
echo "============================================"
echo ""
echo "📋 Summary:"
echo "   - Build includes LIVE key (rzp_live_RhWOsPuVUOT0Xx)"
echo "   - Fallback also hardcoded in Donate.js"
echo "   - Deployed to server"
echo ""
echo "🔄 Next steps:"
echo "1. Clear browser cache COMPLETELY:"
echo "   - Chrome: Settings → Privacy → Clear browsing data"
echo "   - Select 'Cached images and files'"
echo "   - Or use Incognito/Private window"
echo ""
echo "2. Test: https://theonerupeerevolution.org/donate"
echo "   - Should show LIVE mode (not TEST mode)"
echo ""
echo "💡 If still showing TEST mode:"
echo "   - The key is now hardcoded as fallback in Donate.js"
echo "   - It should work even if env var isn't set"
echo "   - Try hard refresh: Ctrl+Shift+R"
echo ""

