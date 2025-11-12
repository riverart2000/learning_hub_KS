#!/bin/bash
# Fix iOS CocoaPods Installation
# This script cleans and reinstalls iOS pods with correct deployment target

set -e

echo "=========================================="
echo "🔧 Fixing iOS CocoaPods"
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

cd ios

# Clean existing pods
print_status "Removing existing Pods and Podfile.lock..."
rm -rf Pods
rm -f Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
print_success "Cleaned"
echo ""

# Clean Flutter
print_status "Cleaning Flutter..."
cd ..
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1
print_success "Flutter cleaned and dependencies updated"
echo ""

# Reinstall pods
print_status "Installing CocoaPods (this may take a few minutes)..."
cd ios
pod install --repo-update
cd ..

print_success "Pods installed successfully!"
echo ""

echo "=========================================="
echo "✨ iOS CocoaPods Fixed!"
echo "=========================================="
echo ""
echo "Deployment target set to: iOS 15.0"
echo ""
echo "Next steps:"
echo "  1. Run: ./build_ios.sh"
echo "  2. Or: flutter build ios --release --no-codesign"
echo ""

