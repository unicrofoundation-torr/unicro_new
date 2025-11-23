#!/bin/bash
# Complete server fix script - updates database.js and ensures server.js is correct

# --- Configuration ---
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Complete Server Fix"
echo "===================="
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "📋 Current directory: $(pwd)"
echo ""

# 1. Fix database.js
echo "1️⃣  Updating config/database.js..."
cd config
cp database.js database.js.backup.$(date +%Y%m%d_%H%M%S)

cat > database.js << 'DBEOF'
const mysql = require('mysql2');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'theomkiq_charity',  // Default for cPanel
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

module.exports = pool.promise();
DBEOF

echo "✅ database.js updated"
echo ""

# 2. Check server.js
cd ..
echo "2️⃣  Checking server.js..."
if grep -q "module.exports = app" server.js; then
  echo "✅ server.js already exports app (correct for Passenger)"
else
  echo "⚠️  server.js might need update - check if it exports app for Passenger"
fi
echo ""

# 3. Verify environment variables
echo "3️⃣  Checking environment variables..."
echo "Current DB_NAME from env: ${DB_NAME:-NOT SET}"
echo ""

# 4. Test database connection
echo "4️⃣  Testing database connection..."
node -e "
const db = require('./config/database');
db.execute('SELECT 1')
  .then(() => {
    console.log('✅ Database connection test: SUCCESS');
    process.exit(0);
  })
  .catch(err => {
    console.error('❌ Database connection test: FAILED');
    console.error('Error:', err.message);
    process.exit(1);
  });
" 2>&1

echo ""
echo "📋 Summary:"
echo "  - database.js: Updated with default 'theomkiq_charity'"
echo "  - Backup created in config/database.js.backup.*"
echo ""
EOF

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Server fix completed!"
  echo ""
  echo "🔄 Next steps:"
  echo "1. Go to cPanel → Setup Node.js App"
  echo "2. Verify Environment Variables:"
  echo "   - DB_HOST=localhost"
  echo "   - DB_USER=theomkiq_charity"
  echo "   - DB_PASSWORD=Unicro@001"
  echo "   - DB_NAME=theomkiq_charity"
  echo "3. Click 'Restart App'"
  echo "4. Wait 30-60 seconds"
  echo "5. Test: https://theonerupeerevolution.org/api/settings"
else
  echo ""
  echo "❌ Server fix failed"
fi

