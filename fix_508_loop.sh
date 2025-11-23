#!/bin/bash
# Fix 508 Loop Detected error

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Fixing 508 Loop Detected Error"
echo "=================================="
echo ""
echo "This script will:"
echo "1. Backup current .htaccess"
echo "2. Create minimal .htaccess (let cPanel handle Passenger)"
echo "3. Provide instructions to fix Application URL in cPanel"
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/api

# Backup
if [ -f .htaccess ]; then
  cp .htaccess .htaccess.backup.508fix.$(date +%Y%m%d_%H%M%S)
  echo "✅ Backed up existing .htaccess"
fi

# Create minimal .htaccess - let CloudLinux Passenger handle everything
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
echo "New .htaccess content:"
cat .htaccess
echo ""

EOF

echo ""
echo "✅ .htaccess fixed!"
echo ""
echo "============================================"
echo "⚠️  CRITICAL: Fix Application URL in cPanel"
echo "============================================"
echo ""
echo "The 508 Loop is likely caused by Application URL mismatch."
echo ""
echo "OPTION 1 (Recommended): Change Application URL to '/'"
echo "-----------------------------------------------------"
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click on your app"
echo "3. Find 'Application URL' field"
echo "4. Change from '/api' to '/'"
echo "5. Click 'SAVE'"
echo "6. Delete ~/public_html/api/.htaccess (or move it)"
echo "7. Restart the app"
echo ""
echo "OPTION 2: Keep Application URL as '/api'"
echo "----------------------------------------"
echo "1. Keep Application URL as '/api'"
echo "2. Keep the .htaccess file (already fixed above)"
echo "3. Restart the app"
echo ""
echo "============================================"
echo "🔄 After fixing, restart the app:"
echo "============================================"
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click 'STOP APP' (wait 10 seconds)"
echo "3. Click 'RESTART' (wait 60 seconds)"
echo "4. Test: https://theonerupeerevolution.org/api/settings"
echo ""
echo "💡 If still getting 508 error:"
echo "   - Try Option 1 (change URL to '/')"
echo "   - OR remove .htaccess completely and let cPanel handle it"
echo ""

