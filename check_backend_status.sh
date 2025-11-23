#!/bin/bash
# Check backend status and diagnose issues

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Checking Backend Status..."
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking Node.js processes..."
echo "=================================="
NODE_PROCS=$(ps aux | grep -E "node|passenger" | grep -v grep | wc -l)
if [ "$NODE_PROCS" -gt 0 ]; then
  echo "✅ Found $NODE_PROCS process(es):"
  ps aux | grep -E "node|passenger" | grep -v grep | head -5 | sed 's/^/   /'
else
  echo "❌ No Node.js/Passenger processes found"
  echo "   → App is NOT running!"
fi
echo ""

echo "2️⃣  Testing API endpoint locally..."
echo "==================================="
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/settings 2>/dev/null | grep -q "200\|404\|500"; then
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/settings 2>/dev/null)
  echo "   HTTP Status: $HTTP_CODE"
  if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ API is responding"
  else
    echo "   ⚠️  API responding but with error code"
  fi
else
  echo "   ❌ API not responding (connection refused or timeout)"
fi
echo ""

echo "3️⃣  Checking server.js..."
echo "========================="
if [ -f server.js ]; then
  echo "✅ server.js exists"
  if grep -q "module.exports = app" server.js; then
    echo "✅ server.js exports app correctly"
  else
    echo "❌ server.js does NOT export app"
  fi
else
  echo "❌ server.js NOT FOUND"
fi
echo ""

echo "4️⃣  Checking database connection..."
echo "=================================="
node -e "
const db = require('./config/database');
db.execute('SELECT 1')
  .then(() => {
    console.log('   ✅ Database connection: SUCCESS');
    process.exit(0);
  })
  .catch(err => {
    console.error('   ❌ Database connection: FAILED');
    console.error('   Error:', err.message);
    console.error('   Code:', err.code);
    process.exit(1);
  });
" 2>&1 | sed 's/^/   /' || echo "   ⚠️  Could not test (node not in PATH or error)"
echo ""

echo "5️⃣  Checking environment variables..."
echo "====================================="
echo "   DB_HOST: ${DB_HOST:-NOT SET}"
echo "   DB_USER: ${DB_USER:-NOT SET}"
echo "   DB_NAME: ${DB_NAME:-NOT SET}"
echo "   NODE_ENV: ${NODE_ENV:-NOT SET}"
echo "   PORT: ${PORT:-NOT SET}"
echo ""

echo "6️⃣  Checking for error logs..."
echo "==============================="
# Check various log locations
if [ -f ~/nodejs/logs/error.log ]; then
  echo "✅ Found error.log"
  echo "   Last 20 lines:"
  tail -20 ~/nodejs/logs/error.log 2>/dev/null | sed 's/^/   /' || echo "   (could not read)"
elif [ -f ~/logs/nodejs.log ]; then
  echo "✅ Found nodejs.log"
  echo "   Last 20 lines:"
  tail -20 ~/logs/nodejs.log 2>/dev/null | sed 's/^/   /' || echo "   (could not read)"
else
  echo "⚠️  No error log found in common locations"
  echo "   Check cPanel → Setup Node.js App → Your App → Logs"
fi
echo ""

echo "7️⃣  Checking .htaccess..."
echo "========================="
if [ -f ~/public_html/api/.htaccess ]; then
  echo "✅ .htaccess exists"
  if grep -q "PassengerAppRoot" ~/public_html/api/.htaccess; then
    echo "✅ Passenger configuration found"
  else
    echo "⚠️  No Passenger configuration in .htaccess"
  fi
else
  echo "⚠️  .htaccess NOT FOUND (might be OK if Application URL is '/')"
fi
echo ""

EOF

echo ""
echo "✅ Diagnostic complete!"
echo ""
echo "📋 Common Issues & Fixes:"
echo "  - If no processes → Restart app in cPanel"
echo "  - If database fails → Check environment variables"
echo "  - If API not responding → Check app status in cPanel"
echo "  - If 508 error → App might be in crash loop, check logs"
echo ""

