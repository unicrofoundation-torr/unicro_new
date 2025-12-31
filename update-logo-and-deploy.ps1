# PowerShell script to update logo/favicon and deploy
# This script will:
# 1. Update favicon files with your logo
# 2. Rebuild the frontend with updated meta tags
# 3. Deploy everything to the server

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "🎨 Update Logo & Deploy Script" -ForegroundColor Cyan
Write-Host "🚀 Started at $(Get-Date)" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# --- Configuration ---
$PROJECT_ROOT = "E:\kanishk data\projects\UNICRO"
$CLIENT_DIR = "$PROJECT_ROOT\client"
$PUBLIC_DIR = "$CLIENT_DIR\public"
$LOGO_SOURCE = "$PUBLIC_DIR\uploads\logo-1760602707648-414861542.png"
$BUILD_DIR = "$CLIENT_DIR\build"
$LOG_DIR = "$PROJECT_ROOT\logs"

# SSH Configuration
$PRIVATE_KEY = "$env:USERPROFILE\.ssh\key_private"
$CPANEL_USER = "theomkiq"
$CPANEL_HOST = "server357.web-hosting.com"
$CPANEL_PORT = 21098
$REMOTE_DIR = "~/public_html"

# Razorpay Key ID
$RAZORPAY_KEY_ID = "rzp_live_RhWOsPuVUOT0Xx"

# Create log directory
New-Item -ItemType Directory -Force -Path $LOG_DIR | Out-Null
$LOG_FILE = "$LOG_DIR\update_logo_deploy_$(Get-Date -Format 'dd-MM-yyyy_HH-mm').log"

function Log-Message {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LOG_FILE -Value $logMessage
}

# --- Step 1: Update Favicon Files ---
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "📸 Step 1: Updating favicon files with logo..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

if (-not (Test-Path $LOGO_SOURCE)) {
    Log-Message "❌ Error: Logo file not found at $LOGO_SOURCE"
    Log-Message "Please ensure the logo file exists in the uploads directory."
    exit 1
}

Log-Message "✅ Logo file found: $LOGO_SOURCE"

# Copy logo files
Copy-Item $LOGO_SOURCE "$PUBLIC_DIR\favicon.ico" -Force
Copy-Item $LOGO_SOURCE "$PUBLIC_DIR\logo192.png" -Force
Copy-Item $LOGO_SOURCE "$PUBLIC_DIR\logo512.png" -Force

Log-Message "✅ Logo files copied!"

# --- Step 2: Build React Frontend ---
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "🏗️ Step 2: Building React frontend..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

Set-Location $CLIENT_DIR

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Log-Message "📦 Installing dependencies..."
    npm install
} else {
    Log-Message "✅ Dependencies already installed, skipping..."
}

# Build with environment variables
Log-Message "🏗️ Building production bundle..."
$env:NODE_ENV = "production"
$env:GENERATE_SOURCEMAP = "false"
$env:REACT_APP_RAZORPAY_KEY_ID = $RAZORPAY_KEY_ID

npm run build

if ($LASTEXITCODE -ne 0) {
    Log-Message "❌ Build failed! Check the errors above."
    exit 1
}

Log-Message "✅ React build successful"

# --- Step 3: Deploy Frontend ---
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "🌐 Step 3: Deploying frontend to server..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

if (-not (Test-Path $BUILD_DIR)) {
    Log-Message "❌ Error: Build directory not found at $BUILD_DIR"
    exit 1
}

Log-Message "📤 Uploading build folder to cPanel..."
Log-Message "Source: $BUILD_DIR"
Log-Message "Destination: $CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR"

# Use rsync via WSL or SSH
# Note: You may need to adjust this based on your setup
$rsyncCommand = "rsync -avz --progress -e `"ssh -i $PRIVATE_KEY -p $CPANEL_PORT`" `"$BUILD_DIR/`" `"$CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR/`""

# If using WSL
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl bash -c "cd /mnt/e/kanishk\ data/projects/UNICRO && rsync -avz --progress -e `"ssh -i ~/.ssh/key_private -p $CPANEL_PORT`" `"client/build/`" `"$CPANEL_USER@$CPANEL_HOST:$REMOTE_DIR/`""
} else {
    Log-Message "⚠️  rsync not available. Please deploy manually or use WSL."
    Log-Message "   Command would be: $rsyncCommand"
}

if ($LASTEXITCODE -eq 0) {
    Log-Message "✅ Frontend deployment completed successfully!"
} else {
    Log-Message "⚠️  Deployment may have issues. Check manually."
}

# --- Summary ---
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "🎉 Deployment Summary" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "✅ Favicon files updated with your logo" -ForegroundColor Green
Write-Host "✅ Frontend rebuilt with updated meta tags" -ForegroundColor Green
Write-Host "✅ Files ready for deployment" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Clear Google's cache using Google Search Console"
Write-Host "2. Request re-indexing of your homepage"
Write-Host "3. Wait 24-48 hours for Google to re-crawl your site"
Write-Host ""
Write-Host "📄 Logs saved at: $LOG_FILE" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "✨ All done! Your logo should appear in Google search results soon." -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

