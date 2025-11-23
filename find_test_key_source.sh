#!/bin/bash
# Find where the test key is coming from

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

echo "🔍 Finding Test Key Source"
echo "=========================="
echo ""

cd "$CLIENT_DIR"

# Step 1: Check source files
echo "1️⃣  Checking source files..."
echo "============================"
if grep -r "rzp_test" src/ 2>/dev/null; then
  echo "   ❌ TEST key found in source files!"
  echo "   Files:"
  grep -r "rzp_test" src/ 2>/dev/null | cut -d: -f1 | sort -u
else
  echo "   ✅ No test key in source files"
fi
echo ""

# Step 2: Check Donate.js specifically
echo "2️⃣  Checking Donate.js..."
echo "=========================="
if grep -q "rzp_live_RhWOsPuVUOT0Xx" src/pages/Donate.js; then
  echo "   ✅ LIVE key is hardcoded in Donate.js"
else
  echo "   ❌ LIVE key NOT found in Donate.js!"
  echo "   Current key line:"
  grep -n "key:" src/pages/Donate.js | grep -A2 -B2 "Razorpay"
fi

if grep -q "rzp_test" src/pages/Donate.js; then
  echo "   ❌ TEST key found in Donate.js!"
  echo "   Line:"
  grep -n "rzp_test" src/pages/Donate.js
fi
echo ""

# Step 3: Check build directory
echo "3️⃣  Checking build directory..."
echo "================================"
if [ -d "$BUILD_DIR/static/js" ]; then
  echo "   Build files found"
  for file in "$BUILD_DIR/static/js"/*.js; do
    if [ -f "$file" ]; then
      TEST_COUNT=$(grep -c "rzp_test" "$file" 2>/dev/null || echo "0")
      if [ "$TEST_COUNT" -gt 0 ]; then
        echo "   ❌ TEST key in: $(basename $file) ($TEST_COUNT occurrences)"
        echo "   Showing matches:"
        grep -o "rzp_test_[A-Za-z0-9]*" "$file" 2>/dev/null | sort -u | head -3
      fi
    fi
  done
else
  echo "   ⚠️  No build directory found"
fi
echo ""

# Step 4: Check for webpack chunks or other cached files
echo "4️⃣  Checking for cached chunks..."
echo "=================================="
find "$CLIENT_DIR" -name "*.chunk.js" -o -name "*.bundle.js" 2>/dev/null | while read file; do
  if grep -q "rzp_test" "$file" 2>/dev/null; then
    echo "   ❌ TEST key in cached file: $file"
  fi
done

echo ""
echo "✅ Source check complete"
echo ""

