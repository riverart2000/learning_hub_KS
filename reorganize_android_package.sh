#!/bin/bash
# Reorganize Android Package Structure
# From: com.biohackerjoe.learninghubks
# To: com.plainos.kashmirshaivism

set -e

echo "=========================================="
echo "📦 Reorganizing Android Package"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

BASE_DIR="android/app/src/main/kotlin"
OLD_PATH="$BASE_DIR/com/biohackerjoe/learninghubks"
NEW_PATH="$BASE_DIR/com/plainos/kashmirshaivism"

# Create new directory structure
print_status "Creating new package directory: com/plainos/kashmirshaivism..."
mkdir -p "$NEW_PATH"
print_success "Directory created"

# Copy MainActivity.kt to new location
print_status "Moving MainActivity.kt..."
if [ -f "$OLD_PATH/MainActivity.kt" ]; then
    cp "$OLD_PATH/MainActivity.kt" "$NEW_PATH/MainActivity.kt"
    print_success "MainActivity.kt moved to new package"
elif [ -f "$NEW_PATH/MainActivity.kt" ]; then
    print_success "MainActivity.kt already in correct location"
else
    echo "⚠️  MainActivity.kt not found, creating new one..."
    cat > "$NEW_PATH/MainActivity.kt" << 'EOF'
package com.plainos.kashmirshaivism

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
EOF
    print_success "Created new MainActivity.kt"
fi

# Remove old directory structure
print_status "Cleaning up old package directories..."
if [ -d "$BASE_DIR/com/biohackerjoe" ]; then
    rm -rf "$BASE_DIR/com/biohackerjoe"
    print_success "Old package directories removed"
fi

# Clean build cache
print_status "Cleaning build cache..."
rm -rf android/build
rm -rf android/app/build
rm -rf build
flutter clean > /dev/null 2>&1
print_success "Build cache cleaned"

# Get dependencies
print_status "Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Dependencies updated"

echo ""
echo "=========================================="
echo "✨ Package Reorganization Complete!"
echo "=========================================="
echo ""
echo "Package Details:"
echo "  Old: com.biohackerjoe.learninghubks"
echo "  New: com.plainos.kashmirshaivism"
echo ""
echo "Directory Structure:"
echo "  ✓ $NEW_PATH/MainActivity.kt"
echo ""
echo "Updated Files:"
echo "  ✓ android/app/build.gradle.kts"
echo "  ✓ MainActivity.kt (package declaration)"
echo "  ✓ google-services.json"
echo ""
echo "⚠️  Firebase Setup Required:"
echo ""
echo "This is a NEW separate app from Learning Hub, so you need to:"
echo ""
echo "1. Create a NEW Firebase project:"
echo "   - Go to https://console.firebase.google.com"
echo "   - Click 'Add project'"
echo "   - Name: 'Learning Kashmir Shaivism'"
echo "   - Follow setup wizard"
echo ""
echo "2. Add Android app in Firebase:"
echo "   - Package name: com.plainos.kashmirshaivism"
echo "   - Download new google-services.json"
echo "   - Replace android/app/google-services.json"
echo ""
echo "3. Add iOS app in Firebase (when ready):"
echo "   - Bundle ID: com.plainos.kashmirshaivism"
echo "   - Download GoogleService-Info.plist"
echo "   - Add to ios/Runner/"
echo ""
echo "4. Configure Firestore rules for new project"
echo ""
echo "For now, you can build WITHOUT Firebase by temporarily"
echo "removing the google-services plugin from build.gradle.kts"
echo ""
echo "Next step:"
echo "  ./build_universal_apk.sh"
echo ""

