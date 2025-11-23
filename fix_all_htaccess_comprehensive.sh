#!/bin/bash
# Comprehensive .htaccess fix - one-time setup to prevent conflicts

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Comprehensive .htaccess Fix"
echo "=============================="
echo ""
echo "This will set up ALL .htaccess files correctly to prevent conflicts"
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~

echo "1️⃣  Backing up existing .htaccess files..."
echo "==========================================="
BACKUP_DIR=".htaccess_backups_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup all .htaccess files
if [ -f ~/public_html/.htaccess ]; then
  cp ~/public_html/.htaccess "$BACKUP_DIR/public_html.htaccess"
  echo "✅ Backed up ~/public_html/.htaccess"
fi

if [ -f ~/public_html/api/.htaccess ]; then
  cp ~/public_html/api/.htaccess "$BACKUP_DIR/api.htaccess"
  echo "✅ Backed up ~/public_html/api/.htaccess"
fi

echo "   Backups saved to: ~/$BACKUP_DIR"
echo ""

echo "2️⃣  Setting up .htaccess for API (Node.js/Passenger)..."
echo "========================================================"
mkdir -p ~/public_html/api

# ONLY CloudLinux Passenger config - no duplicates
cat > ~/public_html/api/.htaccess << 'API_HTACCESS'
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/theomkiq/nodejs"
PassengerBaseURI "/api"
PassengerNodejs "/home/theomkiq/nodevenv/nodejs/14/bin/node"
PassengerAppType node
PassengerStartupFile server.js
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END
API_HTACCESS

echo "✅ Created ~/public_html/api/.htaccess (Passenger config only)"
echo ""

echo "3️⃣  Setting up .htaccess for Frontend (React Router)..."
echo "======================================================"
mkdir -p ~/public_html

# React Router SPA routing - only if file doesn't exist
cat > ~/public_html/.htaccess << 'FRONTEND_HTACCESS'
# React Router - Handle client-side routing
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Don't rewrite files or directories that exist
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  
  # Don't rewrite /api requests (handled by Passenger)
  RewriteCond %{REQUEST_URI} !^/api
  
  # Don't rewrite /uploads (static files)
  RewriteCond %{REQUEST_URI} !^/uploads
  
  # Send everything else to index.html for React Router
  RewriteRule . /index.html [L]
</IfModule>
FRONTEND_HTACCESS

echo "✅ Created ~/public_html/.htaccess (React Router config)"
echo ""

echo "4️⃣  Verifying .htaccess files..."
echo "================================="
echo ""
echo "📄 ~/public_html/api/.htaccess:"
echo "--------------------------------"
cat ~/public_html/api/.htaccess
echo ""
echo "📄 ~/public_html/.htaccess:"
echo "--------------------------------"
cat ~/public_html/.htaccess
echo ""

echo "5️⃣  Checking for conflicts..."
echo "=============================="
API_PASSENGER_COUNT=$(grep -c "PassengerAppRoot" ~/public_html/api/.htaccess 2>/dev/null || echo "0")
FRONTEND_PASSENGER_COUNT=$(grep -c "PassengerAppRoot" ~/public_html/.htaccess 2>/dev/null || echo "0")

if [ "$API_PASSENGER_COUNT" -eq 1 ]; then
  echo "✅ API .htaccess: Single Passenger config (correct)"
else
  echo "⚠️  API .htaccess: $API_PASSENGER_COUNT Passenger configs"
fi

if [ "$FRONTEND_PASSENGER_COUNT" -eq 0 ]; then
  echo "✅ Frontend .htaccess: No Passenger config (correct)"
else
  echo "⚠️  Frontend .htaccess: Has Passenger config (should not)"
fi

echo ""
echo "✅ .htaccess setup complete!"
echo ""

EOF

echo ""
echo "============================================"
echo "✅ Comprehensive .htaccess Fix Complete!"
echo "============================================"
echo ""
echo "📋 What was set up:"
echo ""
echo "1. ~/public_html/api/.htaccess"
echo "   → ONLY CloudLinux Passenger config"
echo "   → Handles /api/* requests → Node.js app"
echo ""
echo "2. ~/public_html/.htaccess"
echo "   → React Router rewrite rules"
echo "   → Handles all other requests → React app"
echo "   → Excludes /api and /uploads"
echo ""
echo "🔄 Next steps:"
echo "1. Restart Node.js app in cPanel (if needed)"
echo "2. Clear browser cache"
echo "3. Test:"
echo "   - https://theonerupeerevolution.org/api/settings (API)"
echo "   - https://theonerupeerevolution.org/admin (Frontend)"
echo ""
echo "💡 This setup prevents conflicts:"
echo "   - API requests (/api/*) → Passenger → Node.js"
echo "   - Frontend routes (/admin, /donate, etc.) → React Router"
echo "   - No duplicate Passenger configs"
echo "   - No conflicting rewrite rules"
echo ""

