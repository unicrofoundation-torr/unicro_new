#!/bin/bash
# Quick backend restart and health check

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔧 Quick Backend Restart & Health Check"
echo "========================================"
echo ""

echo "⚠️  IMPORTANT: This script can diagnose, but you need to restart the app in cPanel"
echo ""
echo "1️⃣  Run diagnostic first:"
echo "   bash check_backend_status.sh"
echo ""
echo "2️⃣  Then in cPanel:"
echo "   - Go to: cPanel → Setup Node.js App"
echo "   - Click: 'STOP APP' (wait 10 seconds)"
echo "   - Click: 'RESTART' (wait 60 seconds)"
echo ""
echo "3️⃣  Test: https://theonerupeerevolution.org/api/settings"
echo ""

# Quick check
ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "📋 Quick Status Check:"
echo ""

# Check if app files exist
if [ -f server.js ] && [ -f package.json ] && [ -d node_modules ]; then
  echo "✅ App files: OK"
else
  echo "❌ App files: MISSING"
  echo "   - server.js: $([ -f server.js ] && echo '✅' || echo '❌')"
  echo "   - package.json: $([ -f package.json ] && echo '✅' || echo '❌')"
  echo "   - node_modules: $([ -d node_modules ] && echo '✅' || echo '❌')"
fi

# Check processes
NODE_PROCS=$(ps aux | grep -E "node|passenger" | grep -v grep | wc -l)
if [ "$NODE_PROCS" -gt 0 ]; then
  echo "✅ Processes: Running ($NODE_PROCS)"
else
  echo "❌ Processes: NOT RUNNING"
  echo "   → App needs to be started in cPanel"
fi

echo ""
echo "💡 Next: Run 'bash check_backend_status.sh' for detailed diagnosis"
echo ""

EOF

