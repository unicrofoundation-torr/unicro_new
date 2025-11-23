#!/bin/bash
# Check server.js and app status

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Checking Server Status..."
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking server.js export..."
echo "--------------------------------"
if grep -q "^module.exports = app" server.js || grep -q "^module.exports = app;" server.js; then
  echo "✅ server.js exports app correctly"
  echo ""
  echo "   Last 5 lines:"
  tail -5 server.js | sed 's/^/   /'
else
  echo "❌ server.js does NOT export app correctly"
  echo ""
  echo "   Last 10 lines:"
  tail -10 server.js | sed 's/^/   /'
fi
echo ""

echo "2️⃣  Checking database.js..."
echo "--------------------------------"
if [ -f config/database.js ]; then
  echo "✅ database.js exists"
  echo ""
  echo "   Database config:"
  grep -A 2 "database:" config/database.js | sed 's/^/   /'
else
  echo "❌ database.js NOT FOUND"
fi
echo ""

echo "3️⃣  Checking routes directory..."
echo "--------------------------------"
if [ -d routes ]; then
  echo "✅ routes directory exists"
  echo "   Files:"
  ls -1 routes/*.js 2>/dev/null | wc -l | xargs echo "   Total route files:"
else
  echo "❌ routes directory NOT FOUND"
fi
echo ""

echo "4️⃣  Checking package.json..."
echo "--------------------------------"
if [ -f package.json ]; then
  echo "✅ package.json exists"
  if grep -q "razorpay" package.json; then
    echo "✅ razorpay in dependencies"
  else
    echo "⚠️  razorpay not in package.json"
  fi
else
  echo "❌ package.json NOT FOUND"
fi
echo ""

echo "5️⃣  Testing if app can be loaded (syntax check)..."
echo "--------------------------------"
node -c server.js 2>&1 | sed 's/^/   /' && echo "   ✅ server.js syntax is valid" || echo "   ❌ server.js has syntax errors"
echo ""

EOF

echo ""
echo "✅ Check complete!"
echo ""
echo "📋 Next Steps:"
echo "1. If server.js exports correctly → Restart app in cPanel"
echo "2. If syntax errors → Fix and redeploy"
echo "3. After restart, wait 60 seconds before testing"

