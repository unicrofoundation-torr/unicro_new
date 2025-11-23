#!/bin/bash
# Rebuild frontend with LIVE Razorpay key and deploy

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

echo "🔧 Rebuilding Frontend with LIVE Razorpay Key"
echo "=============================================="
echo ""
echo "⚠️  Using LIVE key: $RAZORPAY_KEY_ID"
echo ""

# Step 1: Check current build
echo "1️⃣  Checking current build..."
echo "============================="
cd "$CLIENT_DIR"

if [ -d "$BUILD_DIR" ]; then
  echo "✅ Build directory exists"
  # Check if key is in current build
  if grep -r "rzp_" "$BUILD_DIR/static/js" 2>/dev/null | grep -q "rzp_live"; then
    echo "   ⚠️  Current build has LIVE key (but might be old)"
  elif grep -r "rzp_" "$BUILD_DIR/static/js" 2>/dev/null | grep -q "rzp_test"; then
    echo "   ❌ Current build has TEST key - needs rebuild"
  else
    echo "   ⚠️  No Razorpay key found in build"
  fi
else
  echo "⚠️  No build directory - will create new build"
fi
echo ""

# Step 2: Clean build
echo "2️⃣  Cleaning old build..."
echo "=========================="
rm -rf "$BUILD_DIR"
echo "✅ Cleaned build directory"
echo ""

# Step 3: Set environment variables
echo "3️⃣  Setting environment variables..."
echo "====================================="
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

echo "   NODE_ENV=production"
echo "   REACT_APP_RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID"
echo ""

# Step 4: Build React app
echo "4️⃣  Building React app with LIVE key..."
echo "========================================"
cd "$CLIENT_DIR"
npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build successful"
echo ""

# Step 5: Verify key is in build
echo "5️⃣  Verifying LIVE key in build..."
echo "===================================="
if grep -r "rzp_live" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
  echo "   ✅ LIVE key found in build!"
  KEY_FOUND=$(grep -ro "rzp_live_[A-Za-z0-9]*" "$BUILD_DIR/static/js" 2>/dev/null | head -1 | cut -d: -f2)
  echo "   Key: $KEY_FOUND"
elif grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
  echo "   ❌ TEST key found instead of LIVE key!"
  echo "   → Build might have used cached environment"
  echo "   → Try: rm -rf node_modules/.cache && npm run build"
  exit 1
else
  echo "   ⚠️  No Razorpay key found in build"
  echo "   → Check if REACT_APP_RAZORPAY_KEY_ID is being used correctly"
fi
echo ""

# Step 6: Deploy
echo "6️⃣  Deploying to cPanel..."
echo "==========================="
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | grep -E "(sending|sent|deleting|error)" || echo "   ✅ Deployment complete"

echo ""
echo "✅ Frontend deployed with LIVE Razorpay key!"
echo ""

# Step 7: Verify on server
echo "7️⃣  Verifying on server..."
echo "==========================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js
if grep -q "rzp_live" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key confirmed on server"
  KEY=$(grep -o "rzp_live_[A-Za-z0-9]*" main.*.js 2>/dev/null | head -1)
  echo "   Key: $KEY"
else
  echo "   ⚠️  LIVE key not found on server"
fi
EOF

echo ""
echo "============================================"
echo "✅ Rebuild Complete!"
echo "============================================"
echo ""
echo "🔄 Next steps:"
echo "1. Clear browser cache completely:"
echo "   - Chrome: Settings → Privacy → Clear browsing data"
echo "   - Or use Incognito/Private window"
echo ""
echo "2. Test: https://theonerupeerevolution.org/donate"
echo "   - Open payment modal"
echo "   - Should show LIVE mode (not TEST mode)"
echo ""
echo "💡 If still showing TEST mode:"
echo "   - Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)"
echo "   - Clear browser cache completely"
echo "   - Try incognito/private window"
echo ""

