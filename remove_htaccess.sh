#!/bin/bash
# Remove .htaccess file to fix 508 loop (when Application URL is '/')

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Removing .htaccess file..."
echo ""
echo "⚠️  This should only be done if Application URL is set to '/' in cPanel"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html/api

if [ -f .htaccess ]; then
  # Backup first
  cp .htaccess .htaccess.backup.removed.$(date +%Y%m%d_%H%M%S)
  echo "✅ Backed up .htaccess"
  
  # Remove it
  rm -f .htaccess
  echo "✅ Removed .htaccess file"
  echo ""
  echo "File removed. cPanel will handle Passenger configuration automatically."
else
  echo "⚠️  .htaccess file not found (already removed?)"
fi

EOF

echo ""
echo "✅ Done!"
echo ""
echo "🔄 Next steps:"
echo "1. Make sure Application URL is set to '/' in cPanel"
echo "2. Restart the app in cPanel"
echo "3. Test: https://theonerupeerevolution.org/api/settings"
echo ""

