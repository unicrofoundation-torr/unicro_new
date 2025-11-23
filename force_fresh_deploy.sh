#!/bin/bash
# Force fresh deployment by removing old files first

PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

# SSH Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Force Fresh Deployment"
echo "========================="
echo ""

# Step 1: Verify and fix local build
echo "1️⃣  Verifying local build..."
if [ ! -d "$BUILD_DIR" ]; then
  echo "   ❌ No build directory - run: bash nuclear_rebuild.sh"
  exit 1
fi

if grep -r "rzp_test" "$BUILD_DIR/static/js" 2>/dev/null; then
  echo "   ⚠️  TEST key found in build - fixing it..."
  bash "$PROJECT_ROOT/fix_test_key_in_build.sh"
  if [ $? -ne 0 ]; then
    echo "   ❌ Failed to fix test key in build"
    exit 1
  fi
  echo "   ✅ Test key fixed in build"
else
  echo "   ✅ Local build is clean"
fi
echo ""

# Step 2: Remove old files on server first
echo "2️⃣  Removing old files on server..."
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/public_html

echo "   Backing up old static/js directory..."
if [ -d static/js ]; then
  mv static/js static/js.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
  echo "   ✅ Backed up old JS files"
fi

echo "   Removing old index.html..."
if [ -f index.html ]; then
  mv index.html index.html.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
  echo "   ✅ Backed up old index.html"
fi

echo "   ✅ Old files removed/backed up"
EOF

echo ""

# Step 3: Deploy fresh build
echo "3️⃣  Deploying fresh build..."
rsync -avz --delete -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$BUILD_DIR/" \
  "$CPANEL_USER@$CPANEL_HOST:~/public_html/" 2>&1 | tail -10

if [ $? -ne 0 ]; then
  echo "   ❌ Deployment failed!"
  exit 1
fi

echo ""
echo "✅ Deployed"
echo ""

# Step 4: Final check
echo "4️⃣  Running final check..."
bash check_test_key_final.sh

echo ""
echo "✅ Force deployment complete!"
echo ""

