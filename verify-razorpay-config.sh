#!/bin/bash
echo "====================================================="
echo "🔍 Verifying Razorpay Configuration"
echo "====================================================="

# Configuration
PRIVATE_KEY="$HOME/.ssh/key_private"
CPANEL_USER="theomkiq"
CPANEL_HOST="server357.web-hosting.com"
CPANEL_PORT=21098
PROJECT_ROOT="/mnt/e/kanishk data/projects/UNICRO"
CLIENT_DIR="$PROJECT_ROOT/client"
BUILD_DIR="$CLIENT_DIR/build"

echo ""
echo "1. Checking Frontend Build for Razorpay Key..."
echo "-----------------------------------------------"

if [ -d "$BUILD_DIR/static/js" ]; then
    # Find the main JS file
    MAIN_JS=$(find "$BUILD_DIR/static/js" -name "main*.js" -type f | head -1)
    
    if [ -n "$MAIN_JS" ]; then
        echo "   Found build file: $(basename $MAIN_JS)"
        
        # Check for live key
        if grep -q "rzp_live" "$MAIN_JS" 2>/dev/null; then
            echo "   ✅ LIVE key (rzp_live_*) found in build"
            grep -o "rzp_live_[^\"]*" "$MAIN_JS" | head -1 | sed 's/^/   Key: /'
        elif grep -q "rzp_test" "$MAIN_JS" 2>/dev/null; then
            echo "   ❌ TEST key (rzp_test_*) found in build!"
            grep -o "rzp_test_[^\"]*" "$MAIN_JS" | head -1 | sed 's/^/   Key: /'
        else
            echo "   ⚠️  No Razorpay key found in build (might be empty)"
        fi
    else
        echo "   ❌ Build files not found"
    fi
else
    echo "   ❌ Build directory not found"
fi

echo ""
echo "2. Checking Backend Environment Variables..."
echo "-----------------------------------------------"

ssh -i $PRIVATE_KEY -p $CPANEL_PORT $CPANEL_USER@$CPANEL_HOST << 'ENDSSH'
echo "   Checking environment variables in cPanel..."
echo ""
echo "   RAZORPAY_KEY_ID:"
if [ -f ~/nodejs/.env ]; then
    grep "RAZORPAY_KEY_ID" ~/nodejs/.env 2>/dev/null || echo "      Not found in .env file"
else
    echo "      .env file not found"
fi

echo ""
echo "   Note: Environment variables are usually set in:"
echo "      cPanel → Setup Node.js App → Your App → Environment Variables"
echo ""
echo "   To check via Node.js app, run this in cPanel Terminal:"
echo "      cd ~/nodejs && node -e \"console.log('Key ID:', process.env.RAZORPAY_KEY_ID || 'NOT SET')\""
ENDSSH

echo ""
echo "3. Recommendations..."
echo "-----------------------------------------------"
echo ""
echo "   ✅ Make sure BOTH frontend and backend use LIVE keys:"
echo ""
echo "   Frontend:"
echo "   - Rebuild with: REACT_APP_RAZORPAY_KEY_ID=rzp_live_xxx npm run build"
echo "   - Key should start with 'rzp_live_' (NOT 'rzp_test_')"
echo ""
echo "   Backend (cPanel Environment Variables):"
echo "   - RAZORPAY_KEY_ID=rzp_live_xxxxxxxxxxxxx"
echo "   - RAZORPAY_KEY_SECRET=(your-live-secret-key)"
echo "   - RAZORPAY_WEBHOOK_SECRET=(your-live-webhook-secret)"
echo ""
echo "   ⚠️  IMPORTANT:"
echo "   - Keys must start with 'rzp_live_' (NOT 'rzp_test_')"
echo "   - After updating, RESTART the Node.js app in cPanel"
echo "   - Clear browser cache and test again"
echo ""
echo "====================================================="

