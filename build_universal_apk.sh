#!/bin/bash
# Build Universal APK for Android Installation
# This creates a single APK that works on all devices

set -e

echo "=========================================="
echo "🔨 Building Universal APK"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Step 1: Clean
print_status "Cleaning previous builds..."
flutter clean > /dev/null 2>&1
print_success "Cleaned"
echo ""

# Step 2: Get dependencies
print_status "Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Dependencies updated"
echo ""

# Step 3: Build universal APK
echo "=========================================="
print_status "Building Universal APK (all architectures in one file)..."
echo "=========================================="
echo ""
echo "Note: By default, Flutter creates a 'fat APK' containing all architectures."
echo "This APK will work on any Android device (ARM, ARM64, x86, x86_64)."
echo ""

if flutter build apk --release; then
    print_success "Universal APK built successfully!"
else
    print_error "Build failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "📦 Build Output"
echo "=========================================="
echo ""

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    print_success "Universal APK created:"
    echo "  📍 Location: $APK_PATH"
    echo "  📏 Size: $SIZE"
    echo ""
    
    # Copy to Desktop for easy access
    print_status "Copying to Desktop..."
    cp "$APK_PATH" ~/Desktop/LearningHubKS-v0.1.0.apk
    print_success "Copied to: ~/Desktop/LearningHubKS-v0.1.0.apk"
    echo ""
    
    echo "=========================================="
    echo "📱 Installation Instructions"
    echo "=========================================="
    echo ""
    echo "1️⃣  UNINSTALL old version first (if any):"
    echo "   - Go to Settings → Apps → Learning Hub KS"
    echo "   - Tap 'Uninstall'"
    echo ""
    echo "2️⃣  Install via USB (ADB):"
    echo "   adb install ~/Desktop/LearningHubKS-v0.1.0.apk"
    echo ""
    echo "3️⃣  Or transfer to phone and install:"
    echo "   - Copy file from Desktop to phone"
    echo "   - Open file on phone to install"
    echo "   - Allow 'Install from Unknown Sources' if prompted"
    echo ""
    
    # Check if device is connected
    print_status "Checking for connected Android devices..."
    if command -v adb &> /dev/null; then
        DEVICES=$(adb devices | grep -v "List" | grep "device" | wc -l)
        if [ "$DEVICES" -gt 0 ]; then
            print_success "Device connected! You can install now:"
            echo ""
            echo "Run this command to install:"
            echo "  adb install -r ~/Desktop/LearningHubKS-v0.1.0.apk"
            echo ""
            echo "(The -r flag will replace any existing version)"
        else
            print_warning "No device connected via USB"
            echo "Connect your phone and enable USB debugging, or"
            echo "transfer the APK file manually from Desktop"
        fi
    else
        print_warning "ADB not found - install Android SDK or transfer APK manually"
    fi
    
else
    print_error "APK not found at $APK_PATH"
    echo ""
    echo "Looking for APK files..."
    find build -name "*.apk" -type f 2>/dev/null || echo "No APK files found"
fi

echo ""
echo "=========================================="
echo "✨ Done!"
echo "=========================================="

