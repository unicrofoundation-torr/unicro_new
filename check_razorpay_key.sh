#!/bin/bash
# Check what Razorpay key is actually in the deployed frontend

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Checking Razorpay Key in Deployed Frontend"
echo "=============================================="
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html

echo "1️⃣  Searching for Razorpay key in built JavaScript files..."
echo "==========================================================="

# Search for Razorpay key patterns in main JS files
echo "Searching in static/js/main.*.js files..."
for file in static/js/main.*.js; do
  if [ -f "$file" ]; then
    echo ""
    echo "📄 File: $file"
    # Search for rzp_ pattern (both test and live keys start with rzp_)
    if grep -q "rzp_" "$file" 2>/dev/null; then
      echo "   ✅ Found Razorpay key pattern"
      # Extract the key (look for rzp_test_ or rzp_live_)
      KEY=$(grep -o "rzp_[a-zA-Z0-9_]*" "$file" | head -1)
      if [ -n "$KEY" ]; then
        echo "   Key found: $KEY"
        if [[ "$KEY" == *"test"* ]]; then
          echo "   ⚠️  TEST MODE KEY DETECTED!"
        elif [[ "$KEY" == *"live"* ]]; then
          echo "   ✅ LIVE MODE KEY DETECTED"
        else
          echo "   ⚠️  Unknown key format"
        fi
      fi
    else
      echo "   ⚠️  No Razorpay key pattern found"
    fi
  fi
done

echo ""
echo "2️⃣  Checking for environment variable references..."
echo "===================================================="
# Check if it's using process.env (which means it wasn't replaced at build time)
for file in static/js/main.*.js; do
  if [ -f "$file" ]; then
    if grep -q "REACT_APP_RAZORPAY_KEY_ID\|process.env" "$file" 2>/dev/null; then
      echo "   ⚠️  Found process.env reference - key not embedded at build time!"
      echo "   → Frontend needs to be rebuilt with REACT_APP_RAZORPAY_KEY_ID set"
    fi
  fi
done

echo ""
echo "3️⃣  Checking build timestamp..."
echo "==============================="
if [ -f index.html ]; then
  echo "   index.html last modified:"
  ls -lh index.html | awk '{print "   " $6, $7, $8}'
fi

if [ -d static/js ]; then
  echo "   Latest JS file:"
  ls -lht static/js/main.*.js 2>/dev/null | head -1 | awk '{print "   " $6, $7, $8, $9}'
fi

EOF

echo ""
echo "============================================"
echo "📋 Analysis Complete"
echo "============================================"
echo ""
echo "💡 If test key is found:"
echo "   → Frontend needs to be rebuilt with LIVE key"
echo ""
echo "💡 If no key is found:"
echo "   → Key might not be set in build process"
echo ""
echo "🔄 Next: Run rebuild script to fix"
echo ""

