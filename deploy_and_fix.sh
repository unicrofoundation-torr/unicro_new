#!/bin/bash
# Complete fix: Deploy server.js and fix database.js

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Deploying Fixes..."
echo ""

# 1. Deploy server.js
echo "1️⃣  Deploying updated server.js..."
rsync -avz -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  server.js \
  "$CPANEL_USER@$CPANEL_HOST:~/nodejs/" && echo "   ✅ server.js deployed" || echo "   ❌ Failed to deploy server.js"

echo ""

# 2. Fix database.js
echo "2️⃣  Fixing database.js..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs/config

cp database.js database.js.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null

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
echo "✅ Deployment complete!"
echo ""
echo "⚠️  CRITICAL NEXT STEP:"
echo "   Go to cPanel → Setup Node.js App → Your App"
echo "   Add these Environment Variables:"
echo ""
echo "   NODE_ENV = production"
echo "   PORT = 5000"
echo "   DB_HOST = localhost"
echo "   DB_USER = theomkiq_charity"
echo "   DB_PASSWORD = Unicro@001"
echo "   DB_NAME = theomkiq_charity"
echo ""
echo "   Then RESTART the app!"
echo ""

