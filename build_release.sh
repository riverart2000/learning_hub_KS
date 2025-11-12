#!/bin/bash
# Comprehensive Release Build Script for Android and macOS
# Author: Learning Hub Build System
# Date: $(date)

set -e

echo "=========================================="
echo "🚀 Learning Hub - Release Build Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR=$(pwd)

# Function to print colored output
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

# Step 1: Clean previous builds
print_status "Cleaning previous builds..."
flutter clean > /dev/null 2>&1
print_success "Cleaned"
echo ""

# Step 2: Get dependencies
print_status "Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Dependencies updated"
echo ""

# Step 3: Build Android Release
echo "=========================================="
echo "📱 Building Android Release"
echo "=========================================="
echo ""

print_status "Building Android APK (release)..."
if flutter build apk --release; then
    print_success "Android APK built successfully"
else
    print_error "Android APK build failed"
fi
echo ""

print_status "Building Android App Bundle (release)..."
if flutter build appbundle --release; then
    print_success "Android App Bundle built successfully"
else
    print_error "Android App Bundle build failed"
fi
echo ""

# Step 4: Build iOS Release
echo "=========================================="
echo "📱 Building iOS Release"
echo "=========================================="
echo ""

print_status "Building iOS app (release)..."
if flutter build ios --release --no-codesign; then
    print_success "iOS app built successfully (no codesign)"
else
    print_error "iOS app build failed"
fi
echo ""

print_status "Building iOS IPA (release)..."
if flutter build ipa --release; then
    print_success "iOS IPA built successfully"
else
    print_warning "iOS IPA build failed (requires Apple Developer account and certificates)"
fi
echo ""

# Step 5: Build macOS Release
echo "=========================================="
echo "🖥️  Building macOS Release"
echo "=========================================="
echo ""

print_status "Building macOS app (release)..."
if flutter build macos --release; then
    print_success "macOS app built successfully"
else
    print_error "macOS app build failed"
fi
echo ""

# Step 6: Display build outputs
echo "=========================================="
echo "📦 Build Outputs"
echo "=========================================="
echo ""

print_status "Android APK:"
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    SIZE=$(ls -lh "build/app/outputs/flutter-apk/app-release.apk" | awk '{print $5}')
    echo "  ✅ build/app/outputs/flutter-apk/app-release.apk ($SIZE)"
else
    print_warning "  APK not found"
fi
echo ""

print_status "Android App Bundle:"
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    SIZE=$(ls -lh "build/app/outputs/bundle/release/app-release.aab" | awk '{print $5}')
    echo "  ✅ build/app/outputs/bundle/release/app-release.aab ($SIZE)"
else
    print_warning "  AAB not found"
fi
echo ""

print_status "iOS IPA:"
if [ -f "build/ios/ipa/learning_hub.ipa" ]; then
    SIZE=$(ls -lh "build/ios/ipa/learning_hub.ipa" | awk '{print $5}')
    echo "  ✅ build/ios/ipa/learning_hub.ipa ($SIZE)"
else
    print_warning "  IPA not found (requires code signing)"
fi
echo ""

print_status "iOS App (unsigned):"
if [ -d "build/ios/iphoneos/Runner.app" ]; then
    SIZE=$(du -sh "build/ios/iphoneos/Runner.app" | awk '{print $1}')
    echo "  ✅ build/ios/iphoneos/Runner.app ($SIZE)"
else
    print_warning "  iOS app not found"
fi
echo ""

print_status "macOS App:"
if [ -d "build/macos/Build/Products/Release/learning_hub_KS.app" ]; then
    SIZE=$(du -sh "build/macos/Build/Products/Release/learning_hub_KS.app" | awk '{print $1}')
    echo "  ✅ build/macos/Build/Products/Release/learning_hub_KS.app ($SIZE)"
else
    print_warning "  macOS app not found"
fi
echo ""

# Step 7: Quick commands reference
echo "=========================================="
echo "📋 Quick Commands"
echo "=========================================="
echo ""
echo "📱 Android:"
echo "  Install APK: adb install build/app/outputs/flutter-apk/app-release.apk"
echo "  Copy APK: cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/"
echo "  Copy AAB: cp build/app/outputs/bundle/release/app-release.aab ~/Desktop/"
echo ""
echo "📱 iOS:"
echo "  Open in Xcode: open ios/Runner.xcworkspace"
echo "  Archive: Product > Archive in Xcode"
echo "  Copy IPA: cp build/ios/ipa/learning_hub.ipa ~/Desktop/ (if built)"
echo ""
echo "🖥️  macOS:"
echo "  Open app: open build/macos/Build/Products/Release/learning_hub_KS.app"
echo "  Copy app: cp -r build/macos/Build/Products/Release/learning_hub_KS.app ~/Desktop/"
echo ""

echo "=========================================="
echo "✨ Build Complete!"
echo "=========================================="

