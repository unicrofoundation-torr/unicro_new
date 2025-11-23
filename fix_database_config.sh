#!/bin/bash
# Quick fix script to update database.js on the server

# --- Configuration ---
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Updating database.js on server..."
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs/config

# Backup the current file
cp database.js database.js.backup

# Update the default database name
cat > database.js << 'DBEOF'
const mysql = require('mysql2');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'theomkiq_charity',  // Updated for cPanel
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

module.exports = pool.promise();
DBEOF

echo "✅ database.js updated successfully"
echo "📋 Backup saved as: database.js.backup"
echo ""
echo "Current database.js content:"
cat database.js
EOF

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Database configuration updated on server!"
  echo ""
  echo "🔄 Next steps:"
  echo "1. Go to cPanel → Setup Node.js App"
  echo "2. Click 'Restart App'"
  echo "3. Test: https://theonerupeerevolution.org/api/settings"
else
  echo ""
  echo "❌ Failed to update database.js on server"
fi

