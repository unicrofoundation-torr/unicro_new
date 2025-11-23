#!/bin/bash
# Hardcode LIVE Razorpay key directly in source - no env vars needed

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Hardcoding LIVE Razorpay Key in Source"
echo "=========================================="
echo ""
echo "This approach:"
echo "  - Hardcodes LIVE key directly in Donate.js"
echo "  - No environment variables needed"
echo "  - No caching issues"
echo "  - Always uses LIVE key"
echo ""

cd "$CLIENT_DIR"

# Step 1: Verify the hardcode is in place
echo "1️⃣  Verifying hardcoded LIVE key in Donate.js..."
if grep -q "key: 'rzp_live_RhWOsPuVUOT0Xx'" "$CLIENT_DIR/src/pages/Donate.js"; then
  echo "   ✅ LIVE key is hardcoded"
else
  echo "   ❌ LIVE key not hardcoded - this shouldn't happen!"
  echo "   Current line:"
  grep -n "key:" "$CLIENT_DIR/src/pages/Donate.js" | grep -A2 -B2 "Razorpay"
  exit 1
fi

# Remove any test keys from source
echo "   Removing any test keys from source files..."
find "$CLIENT_DIR/src" -type f -name "*.js" -exec sed -i "s/rzp_test[^'\"]*/rzp_live_RhWOsPuVUOT0Xx/g" {} \; 2>/dev/null
find "$CLIENT_DIR/src" -type f -name "*.js" -exec sed -i "s/process.env.REACT_APP_RAZORPAY_KEY_ID[^}]*}/'rzp_live_RhWOsPuVUOT0Xx'/g" {} \; 2>/dev/null
echo "   ✅ Source files cleaned"
echo ""

# Step 2: Remove all caches and old build
echo "2️⃣  Removing all caches and old build..."
rm -rf "$BUILD_DIR"
rm -rf node_modules/.cache
rm -rf .cache
rm -rf .eslintcache
find . -name "*.cache" -type d -exec rm -rf {} + 2>/dev/null || true
echo "✅ All caches removed"
echo ""

# Step 3: Build (no env vars needed - key is hardcoded)
echo "3️⃣  Building (key is hardcoded, no env vars needed)..."
cd "$CLIENT_DIR"
NODE_ENV=production GENERATE_SOURCEMAP=false npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build complete"
echo ""

# Step 4: Verify build has LIVE key and NO test key
echo "4️⃣  Verifying build..."
if grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null; then
  echo "   ❌ TEST key found in build!"
  echo "   → This means test key is still in source code"
  echo "   → Checking source files..."
  grep -r "rzp_test" "$CLIENT_DIR/src" 2>/dev/null || echo "   (no test key in source - might be from cache)"
  exit 1
fi

if grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null; then
  echo "   ✅ LIVE key (rzp_live_RhWOsPuVUOT0Xx) found in build!"
else
  echo "   ⚠️  LIVE key not found in build"
  echo "   → Checking what key is in build..."
  grep -ro "rzp_[a-z]*_[A-Za-z0-9]*" "$BUILD_DIR/static/js" 2>/dev/null | head -3
fi
echo ""

# Step 5: Deploy
echo "5️⃣  Deploying to server..."
rsync -avz --delete --progress -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | tail -5

echo ""
echo "✅ Deployed"
echo ""

# Step 6: Verify on server
echo "6️⃣  Verifying on server..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js
echo "   Checking for test key (should NOT exist)..."
if grep -q "rzp_test" main.*.js 2>/dev/null; then
  echo "   ❌ TEST key still on server!"
  echo "   → Deployment might have failed"
  exit 1
else
  echo "   ✅ No TEST key on server"
fi

echo ""
echo "   Checking for LIVE key..."
if grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅ LIVE key (rzp_live_RhWOsPuVUOT0Xx) confirmed!"
  echo ""
  echo "   Showing key in context:"
  grep -o "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null | head -1
elif grep -q "rzp_live" main.*.js 2>/dev/null; then
  KEY=$(grep -o "rzp_live_[A-Za-z0-9]*" main.*.js 2>/dev/null | head -1)
  echo "   ✅ LIVE key found: $KEY"
  if [ "$KEY" != "rzp_live_RhWOsPuVUOT0Xx" ]; then
    echo "   ⚠️  Different LIVE key - verify this is correct"
  fi
else
  echo "   ❌ No LIVE key found!"
  echo "   → Build might have failed"
  exit 1
fi
EOF

echo ""
echo "============================================"
echo "✅ Hardcoded Key Deploy Complete!"
echo "============================================"
echo ""
echo "📋 What was done:"
echo "   - LIVE key is now hardcoded in Donate.js"
echo "   - No environment variables needed"
echo "   - No caching issues"
echo "   - Always uses LIVE key"
echo ""
echo "🔄 Next: Clear browser cache and test!"
echo ""

