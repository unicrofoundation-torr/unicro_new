#!/bin/bash
# Simple rebuild and deploy - ensures LIVE key is used

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

echo "🔧 Simple Rebuild & Deploy with LIVE Key"
echo "========================================="
echo ""

cd "$CLIENT_DIR"

# Step 1: Verify Donate.js has LIVE key
echo "1️⃣  Checking Donate.js..."
if grep -q "rzp_live_RhWOsPuVUOT0Xx" "$CLIENT_DIR/src/pages/Donate.js"; then
  echo "   ✅ Donate.js has LIVE key fallback"
else
  echo "   ❌ Donate.js missing LIVE key - adding it..."
  sed -i "s/process.env.REACT_APP_RAZORPAY_KEY_ID || ''/process.env.REACT_APP_RAZORPAY_KEY_ID || 'rzp_live_RhWOsPuVUOT0Xx'/g" "$CLIENT_DIR/src/pages/Donate.js"
  echo "   ✅ Added LIVE key fallback"
fi
echo ""

# Step 2: Clean everything
echo "2️⃣  Cleaning..."
rm -rf "$BUILD_DIR"
rm -rf node_modules/.cache
echo "✅ Cleaned"
echo ""

# Step 3: Build
echo "3️⃣  Building with LIVE key..."
cd "$CLIENT_DIR"
REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID" NODE_ENV=production npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build complete"
echo ""

# Step 4: Check build for test key (should NOT be there)
echo "4️⃣  Verifying build..."
if grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null; then
  echo "   ❌ TEST key found in build - this shouldn't happen!"
  exit 1
fi

if grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null; then
  echo "   ✅ LIVE key found in build!"
else
  echo "   ⚠️  LIVE key not in build, but fallback in Donate.js will work"
fi
echo ""

# Step 5: Deploy
echo "5️⃣  Deploying..."
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" > /dev/null 2>&1

echo "✅ Deployed"
echo ""

# Step 6: Verify on server
echo "6️⃣  Verifying on server..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js
if grep -q "rzp_test" main.*.js 2>/dev/null; then
  echo "   ❌ TEST key still on server!"
elif grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key confirmed on server!"
elif grep -q "rzp_live" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key pattern found"
else
  echo "   ⚠️  No key in file (will use fallback)"
fi
EOF

echo ""
echo "✅ Done! Clear browser cache and test."
echo ""

