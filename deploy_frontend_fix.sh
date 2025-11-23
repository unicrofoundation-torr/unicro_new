#!/bin/bash
# Quick frontend deploy for Navigation and App.js fixes

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Deploying Frontend Fixes..."
echo ""

cd "$PROJECT_ROOT"

# Build React app
echo "1️⃣  Building React frontend..."
cd "$CLIENT_DIR"
npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build successful"
echo ""

# Deploy to cPanel
echo "2️⃣  Deploying to cPanel..."
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | grep -E "(sending|sent|deleting|error)" || echo "   ✅ Deployment complete"

echo ""
echo "✅ Frontend fixes deployed!"
echo ""
echo "🔄 Next steps:"
echo "1. Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)"
echo "2. Test:"
echo "   - https://theonerupeerevolution.org/admin (should redirect to /admin/login)"
echo "   - Click 'Donate Now' button in header (should navigate to /donate)"
echo ""

