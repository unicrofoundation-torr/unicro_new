# PowerShell script to update favicon and logo files with the actual site logo
# This ensures Google search results show your logo instead of React icon

Write-Host "🔄 Updating favicon and logo files..." -ForegroundColor Cyan

$LOGO_SOURCE = "client\public\uploads\logo-1760602707648-414861542.png"
$PUBLIC_DIR = "client\public"

# Check if logo file exists
if (-not (Test-Path $LOGO_SOURCE)) {
    Write-Host "❌ Error: Logo file not found at $LOGO_SOURCE" -ForegroundColor Red
    Write-Host "Please ensure the logo file exists in the uploads directory."
    exit 1
}

Write-Host "⚠️  Note: For best results, use ImageMagick to resize images properly." -ForegroundColor Yellow
Write-Host "   On Windows, you can install ImageMagick from: https://imagemagick.org/script/download.php" -ForegroundColor Yellow
Write-Host ""

# Copy logo files (they will be resized during build if needed)
Copy-Item $LOGO_SOURCE "$PUBLIC_DIR\favicon.ico" -Force
Copy-Item $LOGO_SOURCE "$PUBLIC_DIR\logo192.png" -Force
Copy-Item $LOGO_SOURCE "$PUBLIC_DIR\logo512.png" -Force

Write-Host "✅ Logo files copied!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. Rebuild the frontend: cd client; npm run build"
Write-Host "2. Deploy the updated files"
Write-Host "3. Clear Google's cache using Google Search Console"
Write-Host "4. Wait 24-48 hours for Google to re-crawl your site"
Write-Host ""
Write-Host "✨ Done!" -ForegroundColor Green

