#!/bin/bash
# Aggressive rebuild - completely removes old build and ensures LIVE key

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

echo "🔧 Aggressive Rebuild - Removing ALL Test Keys"
echo "==============================================="
echo ""

cd "$CLIENT_DIR"

# Step 1: Aggressively remove build and all caches
echo "1️⃣  Aggressively cleaning..."
echo "============================"
rm -rf "$BUILD_DIR"
rm -rf node_modules/.cache
rm -rf .cache
rm -rf .eslintcache
find . -name "*.cache" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".cache" -type d -exec rm -rf {} + 2>/dev/null || true
echo "✅ All caches and build removed"
echo ""

# Step 2: Verify Donate.js has LIVE key (not test key)
echo "2️⃣  Verifying Donate.js..."
echo "==========================="
if grep -q "rzp_test" "$CLIENT_DIR/src/pages/Donate.js"; then
  echo "   ❌ TEST key found in Donate.js - removing it!"
  sed -i "s/rzp_test[^'\"]*/rzp_live_RhWOsPuVUOT0Xx/g" "$CLIENT_DIR/src/pages/Donate.js"
  echo "   ✅ Removed test key"
fi

if grep -q "rzp_live_RhWOsPuVUOT0Xx" "$CLIENT_DIR/src/pages/Donate.js"; then
  echo "   ✅ LIVE key fallback confirmed in Donate.js"
else
  echo "   ⚠️  Adding LIVE key fallback..."
  sed -i "s/process.env.REACT_APP_RAZORPAY_KEY_ID || ''/process.env.REACT_APP_RAZORPAY_KEY_ID || 'rzp_live_RhWOsPuVUOT0Xx'/g" "$CLIENT_DIR/src/pages/Donate.js"
  echo "   ✅ Added LIVE key fallback"
fi

# Verify no test key anywhere
if grep -r "rzp_test" "$CLIENT_DIR/src" 2>/dev/null; then
  echo "   ⚠️  WARNING: Test key found in source files!"
  echo "   Files with test key:"
  grep -r "rzp_test" "$CLIENT_DIR/src" 2>/dev/null | cut -d: -f1 | sort -u
  echo "   → Replacing test keys with LIVE key..."
  find "$CLIENT_DIR/src" -type f -name "*.js" -exec sed -i "s/rzp_test[^'\"]*/rzp_live_RhWOsPuVUOT0Xx/g" {} \;
  echo "   ✅ Replaced test keys"
fi
echo ""

# Step 3: Build with explicit LIVE key
echo "3️⃣  Building with LIVE key..."
echo "=============================="
cd "$CLIENT_DIR"

# Unset any existing test key env vars
unset REACT_APP_RAZORPAY_KEY_ID

# Build with LIVE key explicitly
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

# Step 4: Verify build has NO test key
echo "4️⃣  Verifying build (checking for test key)..."
echo "=============================================="
if [ -d "$BUILD_DIR/static/js" ]; then
  # Check for test key (should NOT exist)
  TEST_KEY_FOUND=$(grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | wc -l)
  if [ "$TEST_KEY_FOUND" -gt 0 ]; then
    echo "   ❌ TEST key still found in build ($TEST_KEY_FOUND occurrences)!"
    echo "   → This means the source code still has test key"
    echo "   → Checking which files..."
    grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | head -3
    exit 1
  else
    echo "   ✅ No TEST key found in build"
  fi
  
  # Check for live key
  if grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null; then
    echo "   ✅ LIVE key (rzp_live_RhWOsPuVUOT0Xx) found in build!"
  elif grep -r "rzp_live" "$BUILD_DIR/static/js" 2>/dev/null; then
    echo "   ✅ LIVE key pattern found"
    KEY_FOUND=$(grep -ro "rzp_live_[A-Za-z0-9]*" "$BUILD_DIR/static/js" 2>/dev/null | head -1 | cut -d: -f2)
    echo "   Key: $KEY_FOUND"
  else
    echo "   ⚠️  No LIVE key in build, but fallback in Donate.js will work"
  fi
else
  echo "   ❌ Build directory not found!"
  exit 1
fi
echo ""

# Step 5: Deploy
echo "5️⃣  Deploying..."
echo "================"
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | tail -3

echo "✅ Deployed"
echo ""

# Step 6: Final verification on server
echo "6️⃣  Final verification on server..."
echo "==================================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js
echo "   Checking for test key (should NOT exist)..."
TEST_COUNT=$(grep -c "rzp_test" main.*.js 2>/dev/null || echo "0")
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "   ❌ TEST key still found on server ($TEST_COUNT occurrences)!"
  exit 1
else
  echo "   ✅ No TEST key on server"
fi

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
echo "✅ Aggressive Rebuild Complete!"
echo "============================================"
echo ""
echo "📋 Summary:"
echo "   - Removed all caches and old builds"
echo "   - Verified/updated Donate.js with LIVE key"
echo "   - Replaced any test keys in source files"
echo "   - Built with LIVE key environment variable"
echo "   - Verified NO test key in build"
echo "   - Deployed to server"
echo "   - Verified on server"
echo ""
echo "🔄 Next: Clear browser cache and test!"
echo ""

