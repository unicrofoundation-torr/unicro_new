#!/bin/bash
# Check if the app is actually running and accessible

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Checking App Runtime Status..."
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking if Passenger process is running..."
echo "--------------------------------"
if ps aux | grep -i passenger | grep -v grep > /dev/null; then
  echo "✅ Passenger process found"
  ps aux | grep -i passenger | grep -v grep | head -2 | sed 's/^/   /'
else
  echo "⚠️  No Passenger process found (app might not be running)"
fi
echo ""

echo "2️⃣  Checking for Node.js processes..."
echo "--------------------------------"
NODE_PROCS=$(ps aux | grep node | grep -v grep | wc -l)
if [ "$NODE_PROCS" -gt 0 ]; then
  echo "✅ Found $NODE_PROCS Node.js process(es)"
  ps aux | grep node | grep -v grep | head -3 | sed 's/^/   /'
else
  echo "⚠️  No Node.js processes found"
fi
echo ""

echo "3️⃣  Checking .htaccess file..."
echo "--------------------------------"
if [ -f ~/public_html/api/.htaccess ]; then
  echo "✅ .htaccess exists"
  echo "   Content:"
  cat ~/public_html/api/.htaccess | sed 's/^/   /'
else
  echo "⚠️  .htaccess NOT FOUND at ~/public_html/api/.htaccess"
  echo "   This might be needed if Application URL is /api"
fi
echo ""

echo "4️⃣  Checking application root structure..."
echo "--------------------------------"
echo "   Current directory: $(pwd)"
echo "   server.js exists: $([ -f server.js ] && echo '✅' || echo '❌')"
echo "   package.json exists: $([ -f package.json ] && echo '✅' || echo '❌')"
echo "   node_modules exists: $([ -d node_modules ] && echo '✅' || echo '❌')"
echo "   routes/ exists: $([ -d routes ] && echo '✅' || echo '❌')"
echo "   config/ exists: $([ -d config ] && echo '✅' || echo '❌')"
echo ""

echo "5️⃣  Checking for error logs..."
echo "--------------------------------"
# Check common log locations
if [ -f ~/nodejs/logs/error.log ]; then
  echo "✅ Found error.log"
  echo "   Last 10 lines:"
  tail -10 ~/nodejs/logs/error.log 2>/dev/null | sed 's/^/   /' || echo "   (could not read)"
elif [ -f ~/logs/nodejs.log ]; then
  echo "✅ Found nodejs.log"
  echo "   Last 10 lines:"
  tail -10 ~/logs/nodejs.log 2>/dev/null | sed 's/^/   /' || echo "   (could not read)"
else
  echo "⚠️  No error log found in common locations"
  echo "   Check cPanel → Setup Node.js App → Your App → Logs"
fi
echo ""

echo "6️⃣  Testing local API call (if app is running)..."
echo "--------------------------------"
# Try to make a local request to see if app responds
if curl -s http://localhost:5000/api/settings > /dev/null 2>&1; then
  echo "✅ App responds on localhost:5000"
  curl -s http://localhost:5000/api/settings | head -c 100
  echo ""
else
  echo "⚠️  App does not respond on localhost:5000"
  echo "   (This is normal if Passenger is handling requests differently)"
fi
echo ""

EOF

echo ""
echo "✅ Runtime check complete!"
echo ""
echo "📋 Based on results:"
echo "  - If Passenger/Node processes found → App is running, check logs for errors"
echo "  - If no processes → App needs to be started in cPanel"
echo "  - If .htaccess missing → May need to create it (see create_htaccess_after_deploy.sh)"
echo ""

