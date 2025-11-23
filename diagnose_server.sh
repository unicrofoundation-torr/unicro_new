#!/bin/bash
# Diagnostic script to check server status

# --- Configuration ---
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Server Diagnostic"
echo "===================="
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking Node.js app files..."
echo "   - server.js exists: $([ -f server.js ] && echo '✅ YES' || echo '❌ NO')"
echo "   - package.json exists: $([ -f package.json ] && echo '✅ YES' || echo '❌ NO')"
echo "   - config/database.js exists: $([ -f config/database.js ] && echo '✅ YES' || echo '❌ NO')"
echo ""

echo "2️⃣  Checking node_modules..."
if [ -d "node_modules" ]; then
  echo "   ✅ node_modules exists"
  echo "   - razorpay: $([ -d node_modules/razorpay ] && echo '✅' || echo '❌')"
  echo "   - mysql2: $([ -d node_modules/mysql2 ] && echo '✅' || echo '❌')"
  echo "   - express: $([ -d node_modules/express ] && echo '✅' || echo '❌')"
else
  echo "   ❌ node_modules NOT FOUND - run npm install!"
fi
echo ""

echo "3️⃣  Checking server.js export..."
if grep -q "module.exports = app" server.js; then
  echo "   ✅ server.js exports app (correct for Passenger)"
else
  echo "   ⚠️  server.js might not export app correctly"
  echo "   Last few lines of server.js:"
  tail -5 server.js
fi
echo ""

echo "4️⃣  Checking database.js default..."
if grep -q "theomkiq_charity" config/database.js; then
  echo "   ✅ database.js has correct default"
else
  echo "   ⚠️  database.js might have wrong default"
  grep "database:" config/database.js
fi
echo ""

echo "5️⃣  Testing database connection..."
node -e "
const db = require('./config/database');
console.log('   Attempting database connection...');
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
" 2>&1 | sed 's/^/   /'

echo ""
echo "6️⃣  Checking environment variables..."
echo "   DB_HOST: ${DB_HOST:-NOT SET}"
echo "   DB_USER: ${DB_USER:-NOT SET}"
echo "   DB_NAME: ${DB_NAME:-NOT SET}"
echo "   NODE_ENV: ${NODE_ENV:-NOT SET}"
echo "   PORT: ${PORT:-NOT SET}"
echo ""

echo "7️⃣  Testing if server.js can be required..."
node -e "
try {
  const app = require('./server.js');
  console.log('   ✅ server.js can be required');
  console.log('   App type:', typeof app);
  if (typeof app === 'function') {
    console.log('   ✅ App is a function (Express app)');
  } else {
    console.log('   ⚠️  App is not a function');
  }
} catch (err) {
  console.error('   ❌ Failed to require server.js');
  console.error('   Error:', err.message);
  console.error('   Stack:', err.stack.split('\n').slice(0, 3).join('\n'));
}
" 2>&1 | sed 's/^/   /'

echo ""
echo "8️⃣  Checking Passenger logs (if accessible)..."
if [ -f ~/nodejs/logs/passenger.log ]; then
  echo "   Last 10 lines of passenger.log:"
  tail -10 ~/nodejs/logs/passenger.log 2>/dev/null | sed 's/^/   /' || echo "   (log file not readable)"
else
  echo "   ⚠️  Passenger log not found at ~/nodejs/logs/passenger.log"
fi
echo ""

EOF

echo ""
echo "✅ Diagnostic complete!"
echo ""
echo "📋 Next steps based on results:"
echo "  - If node_modules missing: Run npm install in cPanel"
echo "  - If database fails: Check environment variables"
echo "  - If server.js can't be required: Check for syntax errors"

