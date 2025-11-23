#!/bin/bash
# Verify server.js exports correctly on the server

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Verifying server.js on server..."
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "📋 Last 20 lines of server.js:"
echo "--------------------------------"
tail -20 server.js
echo ""
echo ""

echo "🔍 Checking for 'module.exports = app':"
if grep -q "module.exports = app" server.js; then
  echo "✅ Found: module.exports = app"
else
  echo "❌ NOT FOUND: module.exports = app"
  echo "   This means server.js is not exporting the app correctly!"
fi
echo ""

echo "🔍 Checking for 'app.listen':"
if grep -q "app.listen" server.js; then
  echo "⚠️  Found: app.listen (this is OK if inside require.main check)"
  grep -n "app.listen" server.js | head -2
else
  echo "✅ No app.listen found (good for Passenger)"
fi
echo ""

echo "🔍 Checking structure:"
echo "   - Lines with 'module.exports':"
grep -n "module.exports" server.js || echo "   (none found)"
echo ""
echo "   - Lines with 'require.main':"
grep -n "require.main" server.js || echo "   (none found)"
echo ""

EOF

echo ""
echo "✅ Verification complete!"

