#!/bin/bash
# Setup Firebase for macOS

set -e

echo "=========================================="
echo "🔥 Setting up Firebase for macOS"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Check if GoogleService-Info.plist exists in Downloads
DOWNLOADS_FILE=~/Downloads/GoogleService-Info.plist
MACOS_RUNNER_DIR=macos/Runner

if [ ! -f "$DOWNLOADS_FILE" ]; then
    echo "❌ GoogleService-Info.plist not found in Downloads folder"
    echo ""
    echo "Please download it from Firebase Console:"
    echo "  1. Go to Firebase Console → Project Settings"
    echo "  2. Your apps → macOS app"
    echo "  3. Download GoogleService-Info.plist"
    echo "  4. Save to ~/Downloads/"
    echo ""
    exit 1
fi

print_success "Found GoogleService-Info.plist in Downloads"
echo ""

# Copy to macOS Runner directory
print_status "Copying GoogleService-Info.plist to macOS project..."
cp "$DOWNLOADS_FILE" "$MACOS_RUNNER_DIR/"
print_success "File copied to $MACOS_RUNNER_DIR/"
echo ""

# Verify the package name matches
print_status "Verifying bundle identifier..."
BUNDLE_ID=$(grep -A1 "BUNDLE_ID" "$MACOS_RUNNER_DIR/GoogleService-Info.plist" | tail -1 | sed 's/<string>//g' | sed 's/<\/string>//g' | xargs)
EXPECTED_BUNDLE_ID="com.plainos.kashmirshaivism"

if [ "$BUNDLE_ID" == "$EXPECTED_BUNDLE_ID" ]; then
    print_success "Bundle ID matches: $BUNDLE_ID"
else
    print_warning "Bundle ID mismatch!"
    echo "  Expected: $EXPECTED_BUNDLE_ID"
    echo "  Found: $BUNDLE_ID"
    echo ""
    echo "Make sure you created the macOS app in Firebase with bundle ID:"
    echo "  $EXPECTED_BUNDLE_ID"
    echo ""
fi
echo ""

print_success "GoogleService-Info.plist setup complete!"
echo ""

echo "=========================================="
echo "📝 Next Steps"
echo "=========================================="
echo ""
echo "The file has been copied, but you need to add it to Xcode:"
echo ""
echo "1️⃣  Open the project in Xcode:"
echo "   open macos/Runner.xcworkspace"
echo ""
echo "2️⃣  In Xcode, right-click on 'Runner' folder → 'Add Files to Runner...'"
echo ""
echo "3️⃣  Navigate to and select:"
echo "   macos/Runner/GoogleService-Info.plist"
echo ""
echo "4️⃣  Make sure to check:"
echo "   ✓ Copy items if needed"
echo "   ✓ Add to targets: Runner"
echo ""
echo "5️⃣  Click 'Add'"
echo ""
echo "6️⃣  Build the app:"
echo "   ./build_macos.sh"
echo ""
echo "=========================================="
echo ""
echo "Or skip Xcode and just rebuild (Flutter will find it):"
echo "   flutter build macos --release"
echo ""

