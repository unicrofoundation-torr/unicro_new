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
# Passenger configuration for Node.js app
PassengerEnabled On
PassengerAppRoot /home/theomkiq/nodejs
PassengerBaseURI /api
PassengerAppType node
PassengerStartupFile server.js

# Set Node.js environment (Node.js 14.21.2)
PassengerNodejs /opt/cpanel/ea-nodejs14/bin/node

# Set application environment
SetEnv NODE_ENV production

# Error handling
PassengerFriendlyErrorPages Off
EOF

echo "✅ .htaccess file created successfully!"
ls -la ~/public_html/api/.htaccess
ENDSSH

echo ""
echo "✅ Done! You can now stop/restart the app in cPanel without errors."

