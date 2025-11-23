#!/bin/bash
# Fix 508 error after frontend deployment

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Fixing 508 Error After Frontend Deployment"
echo "=============================================="
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking if backend files are intact..."
echo "==========================================="
if [ -f server.js ] && [ -f package.json ] && [ -d routes ] && [ -d config ]; then
  echo "✅ Backend files: OK"
else
  echo "❌ Backend files: MISSING or CORRUPTED"
  echo "   - server.js: $([ -f server.js ] && echo '✅' || echo '❌')"
  echo "   - package.json: $([ -f package.json ] && echo '✅' || echo '❌')"
  echo "   - routes/: $([ -d routes ] && echo '✅' || echo '❌')"
  echo "   - config/: $([ -d config ] && echo '✅' || echo '❌')"
fi
echo ""

echo "2️⃣  Checking node_modules..."
echo "============================="
if [ -d node_modules ] && [ -d node_modules/express ] && [ -d node_modules/mysql2 ]; then
  echo "✅ node_modules: OK"
else
  echo "❌ node_modules: MISSING or INCOMPLETE"
  echo "   → Need to run 'npm install' in cPanel"
fi
echo ""

echo "3️⃣  Checking server.js export..."
echo "================================="
if grep -q "module.exports = app" server.js; then
  echo "✅ server.js exports app correctly"
else
  echo "❌ server.js does NOT export app"
  echo "   → Need to redeploy server.js"
fi
echo ""

echo "4️⃣  Checking database.js..."
echo "============================="
if [ -f config/database.js ]; then
  if grep -q "theomkiq_charity" config/database.js; then
    echo "✅ database.js has correct default"
  else
    echo "⚠️  database.js might have wrong default"
  fi
else
  echo "❌ database.js NOT FOUND"
fi
echo ""

echo "5️⃣  Checking for crash loops..."
echo "================================="
# Check if there are multiple node processes (crash loop indicator)
NODE_COUNT=$(ps aux | grep -E "node.*server.js|passenger.*nodejs" | grep -v grep | wc -l)
if [ "$NODE_COUNT" -gt 3 ]; then
  echo "⚠️  Multiple Node processes detected ($NODE_COUNT)"
  echo "   → Possible crash loop"
  echo "   → App needs to be stopped and restarted"
else
  echo "✅ Process count looks normal"
fi
echo ""

echo "6️⃣  Checking .htaccess..."
echo "=========================="
if [ -f ~/public_html/api/.htaccess ]; then
  echo "✅ .htaccess exists"
  PASSENGER_COUNT=$(grep -c "PassengerAppRoot" ~/public_html/api/.htaccess)
  if [ "$PASSENGER_COUNT" -gt 1 ]; then
    echo "⚠️  Multiple Passenger configs ($PASSENGER_COUNT) - might cause issues"
  else
    echo "✅ Single Passenger config"
  fi
else
  echo "⚠️  .htaccess NOT FOUND"
fi
echo ""

echo "7️⃣  Testing database connection..."
echo "==================================="
node -e "
const db = require('./config/database');
db.execute('SELECT 1')
  .then(() => {
    console.log('   ✅ Database: OK');
    process.exit(0);
  })
  .catch(err => {
    console.error('   ❌ Database: FAILED');
    console.error('   Error:', err.message);
    process.exit(1);
  });
" 2>&1 | sed 's/^/   /' || echo "   ⚠️  Could not test"
echo ""

EOF

echo ""
echo "============================================"
echo "📋 Diagnosis Complete!"
echo "============================================"
echo ""
echo "🔄 IMMEDIATE FIX STEPS:"
echo ""
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click 'STOP APP' (wait 30 seconds)"
echo "3. Wait for resources to free up"
echo "4. Click 'START APP' or 'RESTART' (wait 60 seconds)"
echo ""
echo "2. If node_modules is missing:"
echo "   - In cPanel → Setup Node.js App → Your App"
echo "   - Click 'Run NPM Install'"
echo "   - Wait for it to complete"
echo ""
echo "3. If backend files are missing:"
echo "   - Run: bash deploy_full.sh (full deployment)"
echo "   - OR: rsync backend files manually"
echo ""
echo "4. Test: https://theonerupeerevolution.org/api/settings"
echo ""
echo "💡 The 508 error is usually caused by:"
echo "   - App crash loop (too many restarts)"
echo "   - Resource limit exceeded"
echo "   - Missing dependencies"
echo "   - Database connection failure"
echo ""

