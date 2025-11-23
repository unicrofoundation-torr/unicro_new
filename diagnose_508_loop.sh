#!/bin/bash
# Comprehensive diagnostic for 508 Loop Detected error

PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098

echo "🔍 Comprehensive 508 Loop Detection Analysis"
echo "============================================"
echo ""

ssh -i "$PRIVATE_KEY" -p "$CPANEL_PORT" "$CPANEL_USER@$CPANEL_HOST" << 'EOF'
cd ~/nodejs

echo "1️⃣  Checking .htaccess file location and content..."
echo "=================================================="
echo ""
if [ -f ~/public_html/api/.htaccess ]; then
  echo "✅ Found: ~/public_html/api/.htaccess"
  echo ""
  echo "Full content:"
  echo "--------------------------------"
  cat ~/public_html/api/.htaccess
  echo "--------------------------------"
  echo ""
  
  # Check for redirect rules
  if grep -q "RewriteRule\|Redirect\|RedirectMatch" ~/public_html/api/.htaccess; then
    echo "⚠️  WARNING: Found redirect rules that might cause loops!"
    grep -n "RewriteRule\|Redirect\|RedirectMatch" ~/public_html/api/.htaccess | sed 's/^/   /'
  else
    echo "✅ No redirect rules found"
  fi
  echo ""
  
  # Check for duplicate Passenger config
  PASSENGER_COUNT=$(grep -c "PassengerAppRoot" ~/public_html/api/.htaccess)
  if [ "$PASSENGER_COUNT" -gt 1 ]; then
    echo "⚠️  WARNING: Multiple PassengerAppRoot entries found ($PASSENGER_COUNT)"
    echo "   This might cause conflicts!"
  else
    echo "✅ Single PassengerAppRoot entry"
  fi
  echo ""
else
  echo "❌ .htaccess NOT FOUND at ~/public_html/api/.htaccess"
fi
echo ""

echo "2️⃣  Checking for other .htaccess files..."
echo "=========================================="
echo ""
if [ -f ~/public_html/.htaccess ]; then
  echo "⚠️  Found: ~/public_html/.htaccess"
  echo "   This might interfere with /api routing"
  echo "   Content:"
  cat ~/public_html/.htaccess | head -20 | sed 's/^/   /'
  echo ""
else
  echo "✅ No .htaccess in public_html root"
fi
echo ""

echo "3️⃣  Checking server.js routing..."
echo "================================="
echo ""
if [ -f server.js ]; then
  echo "✅ server.js exists"
  echo ""
  echo "Route definitions:"
  grep -n "app.use.*'/api" server.js | sed 's/^/   /' || echo "   (no /api routes found - checking all routes)"
  echo ""
  echo "All route definitions:"
  grep -n "app.use" server.js | sed 's/^/   /'
  echo ""
  
  # Check if app exports correctly
  if grep -q "module.exports = app" server.js; then
    echo "✅ server.js exports app correctly"
  else
    echo "❌ server.js does NOT export app"
  fi
  echo ""
else
  echo "❌ server.js NOT FOUND"
fi
echo ""

echo "4️⃣  Checking Passenger configuration..."
echo "======================================"
echo ""
# Check Passenger environment
if [ -n "$PASSENGER_BASE_URI" ]; then
  echo "   PASSENGER_BASE_URI: $PASSENGER_BASE_URI"
else
  echo "   PASSENGER_BASE_URI: (not set in environment)"
fi

if [ -n "$PASSENGER_APP_ROOT" ]; then
  echo "   PASSENGER_APP_ROOT: $PASSENGER_APP_ROOT"
else
  echo "   PASSENGER_APP_ROOT: (not set in environment)"
fi
echo ""

echo "5️⃣  Checking application structure..."
echo "===================================="
echo ""
echo "   Application root: $(pwd)"
echo "   server.js: $([ -f server.js ] && echo '✅' || echo '❌')"
echo "   package.json: $([ -f package.json ] && echo '✅' || echo '❌')"
echo "   node_modules: $([ -d node_modules ] && echo '✅' || echo '❌')"
echo "   routes/: $([ -d routes ] && echo '✅' || echo '❌')"
echo ""

echo "6️⃣  Checking for symlinks or redirects..."
echo "=========================================="
echo ""
if [ -L ~/public_html/api ]; then
  echo "⚠️  /api is a symlink!"
  ls -la ~/public_html/api | sed 's/^/   /'
  echo "   Target: $(readlink ~/public_html/api)"
else
  echo "✅ /api is not a symlink"
fi
echo ""

echo "7️⃣  Testing server.js can be loaded..."
echo "======================================"
echo ""
# Try to require server.js to check for syntax errors
cd ~/nodejs
if node -e "try { const app = require('./server.js'); console.log('✅ server.js loaded successfully'); console.log('   App type:', typeof app); } catch(e) { console.error('❌ Error loading server.js:', e.message); }" 2>&1; then
  echo ""
else
  echo "⚠️  Could not test (node command might not be in PATH)"
fi
echo ""

echo "8️⃣  Checking Node.js app status in cPanel..."
echo "============================================="
echo ""
echo "⚠️  Manual check required:"
echo "   1. Go to cPanel → Setup Node.js App"
echo "   2. Check 'Application URL' - should be '/api' or '/'"
echo "   3. Check 'Application Root' - should be 'nodejs'"
echo "   4. Check app status - should be 'Running'"
echo ""

EOF

echo ""
echo "============================================"
echo "📋 Analysis Complete!"
echo "============================================"
echo ""
echo "🔍 Common causes of 508 Loop Detected:"
echo "   1. Application URL in cPanel conflicts with .htaccess"
echo "   2. Duplicate Passenger configuration in .htaccess"
echo "   3. Redirect rules in .htaccess causing loops"
echo "   4. Application URL set to '/api' but app expects '/'"
echo ""
echo "💡 Recommended fixes:"
echo "   1. Change Application URL to '/' in cPanel (instead of '/api')"
echo "   2. OR remove .htaccess and let cPanel handle it"
echo "   3. OR fix .htaccess to match Application URL"
echo ""

