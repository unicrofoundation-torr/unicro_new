#!/bin/bash

# Quick Backend-Only Deployment Script
# This deploys only the backend files (routes, config, server.js) to the server

echo "====================================================="
echo "🚀 Backend-Only Deployment"
echo "🚀 Started at $(date)"
echo "====================================================="

# Configuration
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
BACKEND_DIR="~/nodejs"

cd "$PROJECT_ROOT" || exit 1

echo ""
echo "📤 Deploying backend files to server..."
echo ""

# Deploy backend files (routes, config, server.js)
rsync -avz \
  --progress \
  --exclude='client/' \
  --exclude='node_modules/' \
  --exclude='.git/' \
  --exclude='backups/' \
  --exclude='logs/' \
  --exclude='*.log' \
  --exclude='.env' \
  --exclude='*.md' \
  --exclude='*.sh' \
  --exclude='*.bat' \
  --exclude='*.ps1' \
  --exclude='git-filter-repo/' \
  --include='server.js' \
  --include='package.json' \
  --include='package-lock.json' \
  --include='config/' \
  --include='config/**' \
  --include='routes/' \
  --include='routes/**' \
  --exclude='*' \
  -e "ssh -i $PRIVATE_KEY -p $CPANEL_PORT" \
  "$PROJECT_ROOT/" $CPANEL_USER@$CPANEL_HOST:$BACKEND_DIR

if [ $? -ne 0 ]; then
  echo "❌ Backend deployment failed"
  exit 1
fi

echo ""
echo "✅ Backend files deployed successfully"
echo ""
echo "📋 Next Steps:"
echo "1. Go to cPanel → Setup Node.js App"
echo "2. Click 'Restart App' to reload the backend"
echo "3. Test the sync endpoints in your admin dashboard"
echo ""
echo "====================================================="
echo "✨ Done!"
echo "====================================================="

