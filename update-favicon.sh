#!/bin/bash

# Script to update favicon and logo files with the actual site logo
# This ensures Google search results show your logo instead of React icon

echo "🔄 Updating favicon and logo files..."

LOGO_SOURCE="client/public/uploads/logo-1760602707648-414861542.png"
PUBLIC_DIR="client/public"

# Check if logo file exists
if [ ! -f "$LOGO_SOURCE" ]; then
    echo "❌ Error: Logo file not found at $LOGO_SOURCE"
    echo "Please ensure the logo file exists in the uploads directory."
    exit 1
fi

# Check if ImageMagick is installed (for image conversion)
if command -v convert &> /dev/null; then
    echo "✅ ImageMagick found. Creating optimized favicon files..."
    
    # Create favicon.ico (16x16, 32x32, 48x48 sizes)
    convert "$LOGO_SOURCE" -resize 16x16 -resize 32x32 -resize 48x48 "$PUBLIC_DIR/favicon.ico" 2>/dev/null || {
        echo "⚠️  Could not create .ico file, copying PNG instead..."
        cp "$LOGO_SOURCE" "$PUBLIC_DIR/favicon.ico"
    }
    
    # Create logo192.png (192x192)
    convert "$LOGO_SOURCE" -resize 192x192 "$PUBLIC_DIR/logo192.png" 2>/dev/null || {
        echo "⚠️  Could not resize to 192x192, copying original..."
        cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo192.png"
    }
    
    # Create logo512.png (512x512)
    convert "$LOGO_SOURCE" -resize 512x512 "$PUBLIC_DIR/logo512.png" 2>/dev/null || {
        echo "⚠️  Could not resize to 512x512, copying original..."
        cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo512.png"
    }
    
    echo "✅ Favicon files updated successfully!"
else
    echo "⚠️  ImageMagick not found. Copying logo file directly..."
    echo "   For best results, install ImageMagick: sudo apt-get install imagemagick"
    
    # Fallback: just copy the logo file
    cp "$LOGO_SOURCE" "$PUBLIC_DIR/favicon.ico"
    cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo192.png"
    cp "$LOGO_SOURCE" "$PUBLIC_DIR/logo512.png"
    
    echo "✅ Logo files copied (may need manual resizing for optimal display)"
fi

echo ""
echo "📝 Next steps:"
echo "1. Rebuild the frontend: cd client && npm run build"
echo "2. Deploy the updated files"
echo "3. Clear Google's cache using Google Search Console"
echo "4. Wait 24-48 hours for Google to re-crawl your site"
echo ""
echo "✨ Done!"

