#!/bin/bash
# Fix duplicate Passenger configuration in .htaccess

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Fixing Duplicate Passenger Configuration"
echo "============================================"
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/api

# Backup current .htaccess
if [ -f .htaccess ]; then
  cp .htaccess .htaccess.backup.$(date +%Y%m%d_%H%M%S)
  echo "✅ Backed up existing .htaccess"
  echo ""
  
  # Count Passenger configs
  PASSENGER_COUNT=$(grep -c "PassengerAppRoot" .htaccess)
  echo "   Found $PASSENGER_COUNT Passenger configuration(s)"
  echo ""
  
  # Show current content
  echo "Current .htaccess content:"
  echo "--------------------------------"
  cat .htaccess
  echo "--------------------------------"
  echo ""
fi

# Create clean .htaccess with ONLY CloudLinux Passenger config
echo "Creating clean .htaccess..."
cat > .htaccess << 'HTACCESS_EOF'
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/theomkiq/nodejs"
PassengerBaseURI "/api"
PassengerNodejs "/home/theomkiq/nodevenv/nodejs/14/bin/node"
PassengerAppType node
PassengerStartupFile server.js
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END
HTACCESS_EOF

echo "✅ Created clean .htaccess with single Passenger config"
echo ""
echo "New .htaccess content:"
echo "--------------------------------"
cat .htaccess
echo "--------------------------------"
echo ""

# Verify
NEW_COUNT=$(grep -c "PassengerAppRoot" .htaccess)
if [ "$NEW_COUNT" -eq 1 ]; then
  echo "✅ Verification: Single Passenger config confirmed"
else
  echo "⚠️  Warning: Still found $NEW_COUNT Passenger config(s)"
fi
echo ""

EOF

echo ""
echo "✅ .htaccess fixed!"
echo ""
echo "============================================"
echo "🔄 Next Steps"
echo "============================================"
echo ""
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click 'STOP APP' (wait 30 seconds)"
echo "3. Click 'RESTART' (wait 60 seconds)"
echo ""
echo "4. Test: https://theonerupeerevolution.org/api/settings"
echo ""
echo "💡 The duplicate Passenger config was likely causing conflicts"
echo "   that led to the 508 error. This should fix it!"
echo ""

