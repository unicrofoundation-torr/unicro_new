#!/bin/bash
# Clean up .htaccess - remove duplicates, keep CloudLinux config

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Cleaning up .htaccess file..."
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/api

# Backup current .htaccess
cp .htaccess .htaccess.backup.$(date +%Y%m%d_%H%M%S)

# Create clean .htaccess with only CloudLinux Passenger config
cat > .htaccess << 'HTACCESS_EOF'
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/theomkiq/nodejs"
PassengerBaseURI "/api"
PassengerNodejs "/home/theomkiq/nodevenv/nodejs/14/bin/node"
PassengerAppType node
PassengerStartupFile server.js
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END

# Set application environment
SetEnv NODE_ENV production

# Error handling
PassengerFriendlyErrorPages Off
HTACCESS_EOF

echo "✅ .htaccess cleaned up"
echo ""
echo "Current .htaccess content:"
cat .htaccess
echo ""

EOF

echo ""
echo "✅ .htaccess cleanup complete!"
echo ""
echo "🔄 Next steps:"
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Make sure app is STARTED (green status)"
echo "3. If not started, click 'START APP' or 'RESTART'"
echo "4. Wait 60 seconds"
echo "5. Test: https://theonerupeerevolution.org/api/settings"
echo ""

