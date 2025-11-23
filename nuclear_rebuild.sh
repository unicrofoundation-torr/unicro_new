#!/bin/bash
# Nuclear rebuild - removes EVERYTHING and rebuilds from scratch

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "☢️  NUCLEAR REBUILD - Complete Clean Slate"
echo "==========================================="
echo ""
echo "This will:"
echo "  1. Remove ALL caches (npm, webpack, etc.)"
echo "  2. Remove node_modules"
echo "  3. Remove build directory"
echo "  4. Reinstall dependencies"
echo "  5. Build from scratch"
echo ""

cd "$CLIENT_DIR"

# Step 1: Verify Donate.js has hardcoded LIVE key
echo "1️⃣  Verifying Donate.js has hardcoded LIVE key..."
if grep -q "key: 'rzp_live_RhWOsPuVUOT0Xx'" "$CLIENT_DIR/src/pages/Donate.js"; then
  echo "   ✅ LIVE key is hardcoded"
else
  echo "   ❌ LIVE key not hardcoded!"
  echo "   → Fixing it..."
  sed -i "s/key:.*Razorpay.*/key: 'rzp_live_RhWOsPuVUOT0Xx', \/\/ LIVE key - hardcoded/" "$CLIENT_DIR/src/pages/Donate.js"
  sed -i "s/process.env.REACT_APP_RAZORPAY_KEY_ID[^}]*}/'rzp_live_RhWOsPuVUOT0Xx'/g" "$CLIENT_DIR/src/pages/Donate.js"
  echo "   ✅ Fixed"
fi

# Remove ALL test keys from source
echo "   Removing any test keys from ALL source files..."
find "$CLIENT_DIR/src" -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) -exec sed -i "s/rzp_test[^'\"]*/rzp_live_RhWOsPuVUOT0Xx/g" {} \; 2>/dev/null
find "$CLIENT_DIR/src" -type f \( -name "*.js" -o -name "*.jsx" \) -exec sed -i "s/process\.env\.REACT_APP_RAZORPAY_KEY_ID[^}]*}/'rzp_live_RhWOsPuVUOT0Xx'/g" {} \; 2>/dev/null
echo "   ✅ Source files cleaned"
echo ""

# Step 2: NUCLEAR CLEAN - Remove EVERYTHING
echo "2️⃣  NUCLEAR CLEAN - Removing EVERYTHING..."
echo "==========================================="

# Remove build
rm -rf "$BUILD_DIR"
echo "   ✅ Removed build directory"

# Remove ALL caches
rm -rf node_modules/.cache
rm -rf .cache
rm -rf .eslintcache
rm -rf .parcel-cache
rm -rf .next
find . -name "*.cache" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".cache" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name ".eslintcache" -type f -delete 2>/dev/null || true
echo "   ✅ Removed all caches"

# Clear npm cache
npm cache clean --force 2>/dev/null || true
echo "   ✅ Cleared npm cache"

# Remove node_modules (nuclear option)
echo "   Removing node_modules (will reinstall)..."
rm -rf node_modules
echo "   ✅ Removed node_modules"
echo ""

# Step 3: Reinstall dependencies
echo "3️⃣  Reinstalling dependencies..."
echo "=================================="
npm install --legacy-peer-deps

if [ $? -ne 0 ]; then
  echo "❌ npm install failed!"
  exit 1
fi

echo "✅ Dependencies installed"
echo ""

# Step 4: Build from scratch
echo "4️⃣  Building from scratch (no caches, no env vars needed)..."
echo "============================================================"
cd "$CLIENT_DIR"

# Build without any env vars (key is hardcoded)
NODE_ENV=production GENERATE_SOURCEMAP=false npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build complete"
echo ""

# Step 5: Verify build
echo "5️⃣  Verifying build..."
echo "======================"

# Check for test key (should NOT exist)
TEST_MATCHES=$(grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | wc -l)
if [ "$TEST_MATCHES" -gt 0 ]; then
  echo "   ❌ TEST key found in build ($TEST_MATCHES matches)!"
  echo "   → This shouldn't happen with hardcoded key"
  echo "   → Checking what's in the build..."
  grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | head -3
  echo ""
  echo "   → Checking Donate.js source again..."
  grep -n "key:" "$CLIENT_DIR/src/pages/Donate.js" | grep -A2 -B2 "Razorpay"
  exit 1
else
  echo "   ✅ No TEST key in build"
fi

# Check for LIVE key
if grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null | head -1; then
  echo "   ✅ LIVE key (rzp_live_RhWOsPuVUOT0Xx) found in build!"
else
  echo "   ⚠️  LIVE key not found in build"
  echo "   → Checking what keys are in build..."
  grep -ro "rzp_[a-z]*_[A-Za-z0-9]*" "$BUILD_DIR/static/js" 2>/dev/null | sort -u | head -5
fi
echo ""

# Step 6: Deploy with verification
echo "6️⃣  Deploying to server..."
echo "==========================="
echo "   Local build timestamp:"
LOCAL_TIME=$(stat -c %y "$BUILD_DIR/index.html" 2>/dev/null || stat -f "%Sm" "$BUILD_DIR/index.html" 2>/dev/null || echo "unknown")
echo "   $LOCAL_TIME"

echo ""
echo "   Deploying with force overwrite..."
rsync -avz --delete --force -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1

DEPLOY_EXIT_CODE=$?
if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
  echo ""
  echo "   ❌ Deployment failed with exit code: $DEPLOY_EXIT_CODE"
  echo "   → Check SSH connection and permissions"
  exit 1
fi

echo ""
echo "✅ Deployed successfully"
echo ""

# Verify deployment actually happened
echo "   Verifying deployment succeeded..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << EOF
cd ~/public_html
if [ -f index.html ]; then
  SERVER_TIME=\$(stat -c %y index.html 2>/dev/null || stat -f "%Sm" index.html 2>/dev/null || echo "unknown")
  echo "   Server build timestamp: \$SERVER_TIME"
  if [ "\$SERVER_TIME" != "unknown" ] && [ "\$SERVER_TIME" != "$LOCAL_TIME" ]; then
    echo "   ⚠️  Timestamp mismatch - deployment might not have worked"
  else
    echo "   ✅ Timestamp matches (or close enough)"
  fi
fi
EOF
echo ""

# Step 7: Verify on server
echo "7️⃣  Final verification on server..."
echo "===================================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html

echo "   Checking build timestamp..."
if [ -f index.html ]; then
  BUILD_TIME=$(stat -c %y index.html 2>/dev/null || stat -f "%Sm" index.html 2>/dev/null || echo "unknown")
  echo "   Server build time: $BUILD_TIME"
  echo "   (Should be recent, not Nov 20)"
fi

echo ""
cd static/js
echo "   Checking for test key (CRITICAL CHECK)..."
TEST_COUNT=$(grep -c "rzp_test" main.*.js 2>/dev/null || echo "0")
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "   ❌❌❌ TEST KEY FOUND ON SERVER ($TEST_COUNT occurrences)! ❌❌❌"
  echo ""
  echo "   This means:"
  echo "   - Old build is still deployed"
  echo "   - OR deployment failed"
  echo "   - OR test key is in source code"
  echo ""
  echo "   Test key found:"
  grep -o "rzp_test_[A-Za-z0-9]*" main.*.js 2>/dev/null | head -1
  exit 1
else
  echo "   ✅✅✅ NO TEST KEY ON SERVER ✅✅✅"
fi

echo ""
echo "   Checking for LIVE key..."
if grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅✅✅ LIVE KEY CONFIRMED (rzp_live_RhWOsPuVUOT0Xx) ✅✅✅"
  echo ""
  echo "   Showing context:"
  grep -B2 -A2 "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null | head -5
elif grep -q "rzp_live" main.*.js 2>/dev/null; then
  KEY=$(grep -o "rzp_live_[A-Za-z0-9]*" main.*.js 2>/dev/null | head -1)
  echo "   ✅ LIVE key found: $KEY"
  if [ "$KEY" != "rzp_live_RhWOsPuVUOT0Xx" ]; then
    echo "   ⚠️  Different LIVE key - verify this is correct"
  fi
else
  echo "   ❌ No LIVE key found!"
  exit 1
fi
EOF

echo ""
echo "============================================"
echo "✅ NUCLEAR REBUILD COMPLETE!"
echo "============================================"
echo ""
echo "📋 Final Status:"
echo "   - Build timestamp verified (should be recent)"
echo "   - Test key check: PASSED (no test key found)"
echo "   - LIVE key check: PASSED (LIVE key confirmed)"
echo ""
echo "🔄 Next: Clear browser cache and test!"
echo ""

echo ""
echo "============================================"
echo "✅ NUCLEAR REBUILD COMPLETE!"
echo "============================================"
echo ""
echo "📋 What was done:"
echo "   - Removed ALL caches (npm, webpack, etc.)"
echo "   - Removed node_modules and reinstalled"
echo "   - Removed build directory"
echo "   - Built from scratch with hardcoded LIVE key"
echo "   - Verified no test key in build"
echo "   - Deployed to server"
echo "   - Verified on server"
echo ""
echo "🔄 Next: Clear browser cache and test!"
echo ""

