#!/bin/bash
# Fix API routing - Set Application URL to /api with proper .htaccess

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Fixing API Routing"
echo "====================="
echo ""
echo "This will create a minimal .htaccess that works with Application URL = /api"
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/api

# Create minimal .htaccess - only CloudLinux Passenger config
cat > .htaccess << 'HTACCESS_EOF'
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/theomkiq/nodejs"
PassengerBaseURI "/api"
PassengerNodejs "/home/theomkiq/nodevenv/nodejs/14/bin/node"
PassengerAppType node
PassengerStartupFile server.js
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END
HTACCESS_EOF

echo "✅ Created minimal .htaccess"
echo ""
echo "Content:"
cat .htaccess
echo ""

EOF

echo ""
echo "✅ .htaccess created!"
echo ""
echo "============================================"
echo "⚠️  IMPORTANT: Change Application URL in cPanel"
echo "============================================"
echo ""
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click on your app"
echo "3. Find 'Application URL' field"
echo "4. Change from '/' to '/api'"
echo "   - Domain: theonerupeerevolution.org"
echo "   - Path: api"
echo "5. Click 'SAVE'"
echo ""
echo "6. Restart the app:"
echo "   - Click 'STOP APP' (wait 10 seconds)"
echo "   - Click 'RESTART' (wait 60 seconds)"
echo ""
echo "7. Test: https://theonerupeerevolution.org/api/settings"
echo ""
echo "💡 Why this works:"
echo "   - Application URL = /api → Passenger routes /api/* to Node.js"
echo "   - Minimal .htaccess → No duplicate config, no loops"
echo "   - Frontend in public_html → Served by web server (not Node.js)"
echo "   - API routes work → /api/settings matches server.js routes"
echo ""

