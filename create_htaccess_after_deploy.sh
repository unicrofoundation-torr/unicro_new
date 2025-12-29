#!/bin/bash
# Quick script to create .htaccess file after deployment

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "Creating .htaccess file in public_html/api/..."

ssh -i $PRIVATE_KEY -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << 'ENDSSH'
mkdir -p ~/public_html/api
cat > ~/public_html/api/.htaccess << 'EOF'
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/theomkiq/nodejs"
PassengerBaseURI "/api"
PassengerNodejs "/home/theomkiq/nodevenv/nodejs/14/bin/node"
PassengerAppType node
PassengerStartupFile server.js
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END
EOF

echo "✅ .htaccess file created successfully!"
ls -la ~/public_html/api/.htaccess
ENDSSH

echo ""
echo "✅ Done! You can now stop/restart the app in cPanel without errors."

