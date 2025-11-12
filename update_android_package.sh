#!/bin/bash
# Update Android Package Name
# Changes package from com.biohackerjoe.learninghub to com.biohackerjoe.learninghubks

set -e

echo "=========================================="
echo "📦 Updating Android Package Name"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

OLD_PACKAGE_PATH="android/app/src/main/kotlin/com/biohackerjoe/learninghub"
NEW_PACKAGE_PATH="android/app/src/main/kotlin/com/biohackerjoe/learninghubks"

# Create new directory structure
print_status "Creating new package directory..."
mkdir -p "$NEW_PACKAGE_PATH"
print_success "Directory created"

# Move MainActivity.kt to new location
print_status "Moving MainActivity.kt..."
if [ -f "$OLD_PACKAGE_PATH/MainActivity.kt" ]; then
    cp "$OLD_PACKAGE_PATH/MainActivity.kt" "$NEW_PACKAGE_PATH/MainActivity.kt"
    print_success "MainActivity.kt moved"
else
    print_status "MainActivity.kt already in correct location"
fi

# Clean old directory
print_status "Cleaning up old directory..."
if [ -d "$OLD_PACKAGE_PATH" ]; then
    rm -rf "$OLD_PACKAGE_PATH"
    print_success "Old directory removed"
fi

# Clean build cache
print_status "Cleaning build cache..."
rm -rf android/build
rm -rf android/app/build
flutter clean > /dev/null 2>&1
print_success "Build cache cleaned"

# Get dependencies
print_status "Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Dependencies updated"

echo ""
echo "=========================================="
echo "✨ Package Name Updated!"
echo "=========================================="
echo ""
echo "Old: com.biohackerjoe.learninghub"
echo "New: com.biohackerjoe.learninghubks"
echo ""
echo "Next steps:"
echo "  1. Uninstall old app: adb uninstall com.biohackerjoe.learninghub"
echo "  2. Build new APK: ./build_universal_apk.sh"
echo "  3. Install: adb install ~/Desktop/LearningKashmirShaivism-v0.1.0.apk"
echo ""

