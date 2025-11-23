#!/bin/bash
# Final check for test key - run this after any rebuild

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 FINAL TEST KEY CHECK"
echo "======================="
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/static/js

echo "1️⃣  Checking build timestamp..."
if [ -f ../index.html ]; then
  BUILD_TIME=$(stat -c %y ../index.html 2>/dev/null || stat -f "%Sm" ../index.html 2>/dev/null || echo "unknown")
  echo "   Build timestamp: $BUILD_TIME"
  if echo "$BUILD_TIME" | grep -q "Nov 20"; then
    echo "   ⚠️  WARNING: Old build detected (Nov 20)!"
    echo "   → New build was NOT deployed"
  else
    echo "   ✅ Recent build detected"
  fi
fi

echo ""
echo "2️⃣  Checking for TEST key (CRITICAL)..."
echo "========================================"
TEST_COUNT=$(grep -c "rzp_test" main.*.js 2>/dev/null || echo "0")
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "   ❌❌❌ TEST KEY FOUND! ❌❌❌"
  echo "   Count: $TEST_COUNT occurrences"
  echo ""
  echo "   Test key found:"
  grep -o "rzp_test_[A-Za-z0-9]*" main.*.js 2>/dev/null | sort -u
  echo ""
  echo "   This means:"
  echo "   - Old build is still deployed"
  echo "   - OR deployment failed"
  echo "   - OR test key is in source code"
  echo ""
  exit 1
else
  echo "   ✅✅✅ NO TEST KEY FOUND ✅✅✅"
fi

echo ""
echo "3️⃣  Checking for LIVE key..."
echo "============================="
if grep -q "rzp_live_RhWOsPuVUOT0Xx" main.*.js 2>/dev/null; then
  echo "   ✅✅✅ LIVE KEY CONFIRMED ✅✅✅"
  echo "   Key: rzp_live_RhWOsPuVUOT0Xx"
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

echo ""
echo "============================================"
echo "✅ ALL CHECKS PASSED!"
echo "============================================"
echo ""
echo "✅ No test key found"
echo "✅ LIVE key confirmed"
echo "✅ Build is ready for production"
echo ""

EOF

EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  echo ""
  echo "✅ Final check: PASSED"
else
  echo ""
  echo "❌ Final check: FAILED"
  echo "   → Run: bash nuclear_rebuild.sh"
fi
echo ""

