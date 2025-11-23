#!/bin/bash
# Fix admin 404 and Razorpay test mode issues

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

# Razorpay Key (LIVE MODE)
RAZORPAY_KEY_ID="rzp_live_RhWOsPuVUOT0Xx"

echo "🔧 Fixing Admin Route & Razorpay Live Mode"
echo "==========================================="
echo ""

# Step 1: Check if .htaccess exists in public_html root
echo "1️⃣  Checking .htaccess in public_html..."
echo "========================================"
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
if [ -f ~/public_html/.htaccess ]; then
  echo "✅ .htaccess exists in public_html"
  echo ""
  echo "Current content:"
  cat ~/public_html/.htaccess
  echo ""
else
  echo "⚠️  No .htaccess in public_html root"
fi
EOF

echo ""

# Step 2: Create/Update .htaccess for React Router
echo "2️⃣  Creating .htaccess for React Router..."
echo "=========================================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html

# Backup existing .htaccess
if [ -f .htaccess ]; then
  cp .htaccess .htaccess.backup.$(date +%Y%m%d_%H%M%S)
  echo "✅ Backed up existing .htaccess"
fi

# Create .htaccess for React Router (SPA routing)
cat > .htaccess << 'HTACCESS_EOF'
# React Router - Handle client-side routing
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Don't rewrite files or directories that exist
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_URI} !^/api
  RewriteRule . /index.html [L]
</IfModule>
HTACCESS_EOF

echo "✅ Created .htaccess for React Router"
echo ""
echo "New .htaccess content:"
cat .htaccess
echo ""

EOF

echo ""

# Step 3: Rebuild frontend with correct Razorpay key
echo "3️⃣  Rebuilding frontend with LIVE Razorpay key..."
echo "================================================="
cd "$CLIENT_DIR"

# Set environment variables for build
export NODE_ENV=production
export GENERATE_SOURCEMAP=false
export REACT_APP_RAZORPAY_KEY_ID="$RAZORPAY_KEY_ID"

echo "   Using Razorpay Key ID: $RAZORPAY_KEY_ID"
echo "   Building React app..."
npm run build

if [ $? -ne 0 ]; then
  echo "❌ Build failed!"
  exit 1
fi

echo "✅ Build successful with LIVE Razorpay key"
echo ""

# Step 4: Deploy frontend
echo "4️⃣  Deploying frontend..."
echo "========================="
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | grep -E "(sending|sent|deleting|error)" || echo "   ✅ Deployment complete"

echo ""
echo "✅ Frontend deployed!"
echo ""

# Step 5: Verify .htaccess is still there
echo "5️⃣  Verifying .htaccess..."
echo "==========================="
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
if [ -f ~/public_html/.htaccess ]; then
  echo "✅ .htaccess exists"
  echo ""
  echo "Content:"
  cat ~/public_html/.htaccess
else
  echo "⚠️  .htaccess was deleted during deployment"
  echo "   Recreating..."
  cat > ~/public_html/.htaccess << 'HTACCESS_EOF'
# React Router - Handle client-side routing
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  
  # Don't rewrite files or directories that exist
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteCond %{REQUEST_URI} !^/api
  RewriteRule . /index.html [L]
</IfModule>
HTACCESS_EOF
  echo "✅ Recreated .htaccess"
fi
EOF

echo ""
echo "============================================"
echo "✅ Fix Complete!"
echo "============================================"
echo ""
echo "📋 What was fixed:"
echo "   1. Created .htaccess for React Router (fixes /admin 404)"
echo "   2. Rebuilt frontend with LIVE Razorpay key (fixes test mode)"
echo ""
echo "🔄 Next steps:"
echo "   1. Clear browser cache (Ctrl+Shift+R)"
echo "   2. Test: https://theonerupeerevolution.org/admin"
echo "   3. Test: https://theonerupeerevolution.org/donate (check Razorpay shows LIVE mode)"
echo ""

