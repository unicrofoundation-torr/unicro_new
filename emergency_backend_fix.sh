#!/bin/bash
# Emergency fix for 508 error - stop crash loop and restart cleanly

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🚨 Emergency Backend Fix for 508 Error"
echo "======================================="
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking current status..."
echo "=============================="
NODE_PROCS=$(ps aux | grep -E "node|passenger" | grep -v grep | wc -l)
echo "   Active processes: $NODE_PROCS"
if [ "$NODE_PROCS" -gt 0 ]; then
  echo "   Processes:"
  ps aux | grep -E "node|passenger" | grep -v grep | head -3 | sed 's/^/   /'
fi
echo ""

echo "2️⃣  Verifying backend files..."
echo "==============================="
FILES_OK=true
[ -f server.js ] && echo "   ✅ server.js" || { echo "   ❌ server.js MISSING"; FILES_OK=false; }
[ -f package.json ] && echo "   ✅ package.json" || { echo "   ❌ package.json MISSING"; FILES_OK=false; }
[ -d routes ] && echo "   ✅ routes/" || { echo "   ❌ routes/ MISSING"; FILES_OK=false; }
[ -d config ] && echo "   ✅ config/" || { echo "   ❌ config/ MISSING"; FILES_OK=false; }
[ -d node_modules ] && echo "   ✅ node_modules/" || { echo "   ⚠️  node_modules/ MISSING (need npm install)"; }

if [ "$FILES_OK" = false ]; then
  echo ""
  echo "   ❌ CRITICAL: Backend files are missing!"
  echo "   → Need to redeploy backend"
fi
echo ""

echo "3️⃣  Checking server.js export..."
echo "=================================="
if grep -q "^module.exports = app" server.js || grep -q "^module.exports = app;" server.js; then
  echo "   ✅ server.js exports app correctly"
else
  echo "   ❌ server.js does NOT export app"
  echo "   → Need to fix server.js"
fi
echo ""

echo "4️⃣  Checking database.js..."
echo "============================"
if [ -f config/database.js ]; then
  if grep -q "theomkiq_charity" config/database.js; then
    echo "   ✅ database.js has correct default"
  else
    echo "   ⚠️  database.js default might be wrong"
  fi
else
  echo "   ❌ database.js NOT FOUND"
fi
echo ""

echo "5️⃣  Checking .htaccess..."
echo "=========================="
if [ -f ~/public_html/api/.htaccess ]; then
  echo "   ✅ .htaccess exists"
  if grep -q "PassengerAppRoot" ~/public_html/api/.htaccess; then
    echo "   ✅ Passenger config found"
  fi
else
  echo "   ⚠️  .htaccess NOT FOUND"
fi
echo ""

EOF

echo ""
echo "============================================"
echo "🔄 EMERGENCY FIX STEPS"
echo "============================================"
echo ""
echo "The 508 error means the app is hitting resource limits,"
echo "likely due to a crash loop. Follow these steps:"
echo ""
echo "STEP 1: Stop the app completely"
echo "--------------------------------"
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click 'STOP APP'"
echo "3. Wait 60 seconds (let resources free up)"
echo ""
echo "STEP 2: Verify environment variables"
echo "-------------------------------------"
echo "In cPanel → Setup Node.js App → Your App → Environment Variables"
echo "Make sure these are set:"
echo "  DB_HOST=localhost"
echo "  DB_USER=theomkiq_charity"
echo "  DB_PASSWORD=Unicro@001"
echo "  DB_NAME=theomkiq_charity"
echo "  NODE_ENV=production"
echo "  PORT=5000"
echo ""
echo "STEP 3: Check if npm install is needed"
echo "---------------------------------------"
echo "If node_modules is missing:"
echo "  - In cPanel → Setup Node.js App → Your App"
echo "  - Click 'Run NPM Install'"
echo "  - Wait for completion"
echo ""
echo "STEP 4: Restart the app"
echo "-----------------------"
echo "1. In cPanel → Setup Node.js App"
echo "2. Click 'START APP' or 'RESTART'"
echo "3. Wait 60 seconds"
echo ""
echo "STEP 5: Test"
echo "-----------"
echo "Visit: https://theonerupeerevolution.org/api/settings"
echo ""
echo "💡 If still getting 508:"
echo "   - Wait 5 minutes (resource limits reset)"
echo "   - Check logs in cPanel → Setup Node.js App → Your App → Logs"
echo "   - Verify database is accessible"
echo ""

