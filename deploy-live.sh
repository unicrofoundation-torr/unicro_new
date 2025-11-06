#!/bin/bash

# ============================================
# Single Command Deployment Script
# Makes the website live with production build
# ============================================

set -e  # Exit on any error

echo "====================================================="
echo "🚀 Starting Live Deployment"
echo "====================================================="
echo ""

# Get the project directory (assuming script is in project root)
# Handle both Windows (WSL) and Linux paths
if [ -f "${BASH_SOURCE[0]}" ]; then
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    # Fallback: try to detect from common Windows WSL paths
    if [ -d "/mnt/e/kanishk data/projects/UNICRO" ]; then
        PROJECT_DIR="/mnt/e/kanishk data/projects/UNICRO"
    else
        PROJECT_DIR="$(pwd)"
    fi
fi

cd "$PROJECT_DIR"

echo "📁 Project Directory: $PROJECT_DIR"
echo ""

# ============================================
# STEP 1: Install/Update Dependencies
# ============================================
echo "📦 Installing dependencies..."
echo ""

# Install root dependencies
if [ ! -d "node_modules" ]; then
    echo "   Installing root dependencies..."
    npm install
else
    echo "   Root dependencies already installed"
fi

# Install client dependencies
if [ ! -d "client/node_modules" ]; then
    echo "   Installing client dependencies..."
    cd client
    npm install
    cd ..
else
    echo "   Client dependencies already installed"
fi

echo "✅ Dependencies installed"
echo ""

# ============================================
# STEP 2: Build React App for Production
# ============================================
echo "🔨 Building React app for production..."
echo ""

cd client
export NODE_ENV=production
export GENERATE_SOURCEMAP=false

npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build failed! Please check the errors above."
    exit 1
fi

cd ..

echo "✅ Production build completed"
echo ""

# ============================================
# STEP 3: Set Production Environment
# ============================================
echo "⚙️  Setting production environment..."
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found. Creating from template..."
    cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=root123
DB_NAME=charity_website

# Server Configuration
PORT=5000
NODE_ENV=production

# JWT Secret (CHANGE THIS IN PRODUCTION!)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Cashfree Configuration (if using)
CASHFREE_ENV=TEST
CASHFREE_APP_ID=your-app-id
CASHFREE_SECRET_KEY=your-secret-key
CASHFREE_RETURN_URL=http://localhost:3000/donate?cf_return=1&order_id={order_id}
CASHFREE_NOTIFY_URL=http://localhost:5000/api/donations/cf/webhook
CASHFREE_WEBHOOK_SECRET=your-webhook-secret
EOF
    echo "✅ Created .env file. Please update it with your production values!"
    echo ""
fi

# ============================================
# STEP 4: Start Production Server
# ============================================
echo "🌐 Starting production server..."
echo ""

# Set production environment
export NODE_ENV=production

# Check if server is already running
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "⚠️  Port 5000 is already in use. Stopping existing process..."
    pkill -f "node server.js" || true
    sleep 2
fi

# Start the server
echo "🚀 Server starting on port 5000..."
echo ""

# Run in background and save PID
nohup node server.js > server.log 2>&1 &
SERVER_PID=$!

# Wait a moment for server to start
sleep 3

# Check if server started successfully
if ps -p $SERVER_PID > /dev/null; then
    echo "✅ Server started successfully!"
    echo "   PID: $SERVER_PID"
    echo "   Logs: $PROJECT_DIR/server.log"
    echo ""
    echo "====================================================="
    echo "🎉 Deployment Complete!"
    echo "====================================================="
    echo ""
    echo "📱 Your website is now live!"
    echo "   Frontend: http://localhost:5000"
    echo "   API: http://localhost:5000/api"
    echo "   Admin Panel: http://localhost:5000/admin/login"
    echo ""
    echo "📋 To stop the server, run:"
    echo "   kill $SERVER_PID"
    echo "   or"
    echo "   pkill -f 'node server.js'"
    echo ""
    echo "📝 To view logs:"
    echo "   tail -f $PROJECT_DIR/server.log"
    echo ""
else
    echo "❌ Server failed to start. Check server.log for errors."
    exit 1
fi

