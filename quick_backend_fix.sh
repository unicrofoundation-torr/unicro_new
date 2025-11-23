#!/bin/bash
# Quick backend fix - deploy updated server.js and fix database.js

# --- Configuration ---
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Quick Backend Fix"
echo "==================="
echo ""

# 1. Deploy updated server.js
echo "1️⃣  Deploying updated server.js..."
rsync -avz -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  server.js \
  "$CPANEL_USER@$CPANEL_HOST:~/nodejs/" 2>&1 | grep -E "(server.js|sent|error)" || echo "   ✅ server.js deployed"

echo ""

# 2. Fix database.js on server
echo "2️⃣  Fixing database.js on server..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs/config

# Backup
cp database.js database.js.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null

# Update
cat > database.js << 'DBEOF'
const mysql = require('mysql2');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'theomkiq_charity',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

module.exports = pool.promise();
DBEOF

echo "   ✅ database.js updated"
EOF

echo ""
echo "✅ Backend fix complete!"
echo ""
echo "🔄 Next steps:"
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click 'Restart App'"
echo "3. Wait 30-60 seconds"
echo "4. Test: https://theonerupeerevolution.org/api/settings"
echo ""
echo "💡 If still getting errors, run: bash diagnose_server.sh"

