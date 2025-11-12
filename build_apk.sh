#!/bin/bash
# Flutter APK Build Script - Fixes APK location issues

set -e

echo "=========================================="
echo "Flutter APK Build Script"
echo "=========================================="
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
echo "✓ Cleaned"

# Get dependencies
echo "Getting dependencies..."
flutter pub get
echo "✓ Dependencies updated"

# Build APK
echo "Building release APK..."
flutter build apk --release

# Find and display APK locations
echo ""
echo "=========================================="
echo "APK Build Complete!"
echo "=========================================="
echo ""

echo "APK files found:"
find . -name "*.apk" -type f | grep -E "(release|universal)" | while read apk; do
    size=$(ls -lh "$apk" | awk '{print $5}')
    echo "  📱 $apk ($size)"
done

echo ""
echo "Main release APK:"
MAIN_APK=$(find . -name "app-release.apk" -o -name "app-universal-release.apk" | head -1)
if [ -n "$MAIN_APK" ]; then
    echo "  ✅ $MAIN_APK"
    echo ""
    echo "To install on device:"
    echo "  adb install \"$MAIN_APK\""
    echo ""
    echo "To copy to desktop:"
    echo "  cp \"$MAIN_APK\" ~/Desktop/"
else
    echo "  ❌ Main APK not found"
    echo ""
    echo "All APK files:"
    find . -name "*.apk" -type f
fi

echo ""
echo "=========================================="
