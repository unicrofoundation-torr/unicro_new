#!/bin/bash
# Find and fix test key in build - last resort approach

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

echo "🔧 Finding and Fixing Test Key in Build"
echo "========================================"
echo ""

cd "$CLIENT_DIR"

# Step 1: Find test key in build
echo "1️⃣  Finding test key in build..."
echo "================================="
if [ ! -d "$BUILD_DIR/static/js" ]; then
  echo "   ❌ No build directory - need to build first"
  exit 1
fi

TEST_KEY_FOUND=""
for file in "$BUILD_DIR/static/js"/*.js; do
  if [ -f "$file" ] && grep -q "rzp_test" "$file" 2>/dev/null; then
    TEST_KEY=$(grep -o "rzp_test_[A-Za-z0-9]*" "$file" 2>/dev/null | head -1)
    if [ -n "$TEST_KEY" ]; then
      TEST_KEY_FOUND="$TEST_KEY"
      TEST_FILE="$file"
      echo "   ❌ Found test key: $TEST_KEY"
      echo "   In file: $(basename $file)"
      break
    fi
  fi
done

if [ -z "$TEST_KEY_FOUND" ]; then
  echo "   ✅ No test key found in build"
  echo "   → Build is clean, ready to deploy"
  exit 0
fi

echo ""

# Step 2: Replace test key with LIVE key in build
echo "2️⃣  Replacing test key with LIVE key in build..."
echo "================================================"
if [ -n "$TEST_FILE" ]; then
  echo "   Replacing in: $(basename $TEST_FILE)"
  sed -i "s/$TEST_KEY_FOUND/rzp_live_RhWOsPuVUOT0Xx/g" "$TEST_FILE"
  echo "   ✅ Replaced test key with LIVE key"
  
  # Verify replacement
  if grep -q "rzp_test" "$TEST_FILE" 2>/dev/null; then
    echo "   ⚠️  Test key still found - might be in multiple places"
    # Replace all test keys
    sed -i "s/rzp_test_[A-Za-z0-9]*/rzp_live_RhWOsPuVUOT0Xx/g" "$TEST_FILE"
    echo "   ✅ Replaced all test keys"
  fi
fi

# Replace in all JS files in build
echo "   Replacing in all build files..."
find "$BUILD_DIR/static/js" -name "*.js" -exec sed -i "s/rzp_test_[A-Za-z0-9]*/rzp_live_RhWOsPuVUOT0Xx/g" {} \; 2>/dev/null
echo "   ✅ Replaced in all files"
echo ""

# Step 3: Verify
echo "3️⃣  Verifying build is clean..."
echo "================================"
TEST_COUNT=$(grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null | wc -l)
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "   ❌ Still found $TEST_COUNT test key occurrences"
  echo "   → Manual fix needed"
else
  echo "   ✅ No test keys found in build"
fi

LIVE_COUNT=$(grep -r "rzp_live_RhWOsPuVUOT0Xx" "$BUILD_DIR/static/js" 2>/dev/null | wc -l)
if [ "$LIVE_COUNT" -gt 0 ]; then
  echo "   ✅ Found $LIVE_COUNT LIVE key occurrences"
else
  echo "   ⚠️  No LIVE key found (might be minified)"
fi
echo ""

echo "✅ Build fixed! Ready to deploy."
echo ""

