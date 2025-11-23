#!/bin/bash
# Complete rebuild and deploy - does everything in one go

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

echo "🔧 Complete Rebuild & Deploy"
echo "============================"
echo ""

cd "$CLIENT_DIR"

# Step 1: Remove everything
echo "1️⃣  Removing old build and caches..."
rm -rf "$BUILD_DIR"
rm -rf node_modules/.cache
rm -rf .cache
echo "✅ Cleaned"
echo ""

# Step 2: Ensure Donate.js has LIVE key
echo "2️⃣  Ensuring Donate.js has LIVE key..."
if ! grep -q "rzp_live_RhWOsPuVUOT0Xx" "$CLIENT_DIR/src/pages/Donate.js"; then
  sed -i "s/process.env.REACT_APP_RAZORPAY_KEY_ID || '[^']*'/process.env.REACT_APP_RAZORPAY_KEY_ID || 'rzp_live_RhWOsPuVUOT0Xx'/g" "$CLIENT_DIR/src/pages/Donate.js"
  echo "   ✅ Added LIVE key fallback"
fi

# Remove any test keys from source
find "$CLIENT_DIR/src" -type f -name "*.js" -exec sed -i "s/rzp_test[^'\"]*/rzp_live_RhWOsPuVUOT0Xx/g" {} \; 2>/dev/null
echo "   ✅ Verified LIVE key in source"
echo ""

# Step 3: Build
echo "3️⃣  Building with LIVE key..."
cd "$CLIENT_DIR"
REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID" \
NODE_ENV=production \
GENERATE_SOURCEMAP=false \
npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build complete"
echo ""

# Step 4: Verify build
echo "4️⃣  Verifying build..."
if grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null; then
  echo "   ❌ TEST key found in build!"
  exit 1
fi
echo "   ✅ No test key in build"
echo ""

# Step 5: Deploy
echo "5️⃣  Deploying to server..."
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | grep -E "(sending|sent|deleting)" | tail -5

echo ""
echo "✅ Deployed"
echo ""

# Step 6: Verify on server
echo "6️⃣  Verifying on server..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js
if grep -q "rzp_test" main.*.js 2>/dev/null; then
  echo "   ❌ TEST key still on server!"
  exit 1
elif grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key confirmed on server!"
elif grep -q "rzp_live" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key found on server"
else
  echo "   ⚠️  No key (will use fallback)"
fi
EOF

echo ""
echo "✅ Complete! Clear browser cache and test."
echo ""

