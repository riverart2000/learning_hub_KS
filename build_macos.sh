#!/bin/bash
# macOS Build Script for Learning Kashmir Shaivism

set -e

echo "=========================================="
echo "🖥️  macOS Build Script"
echo "=========================================="
echo ""

# Colors
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

# Check if on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ macOS builds can only be created on macOS"
    exit 1
fi

# Step 1: Clean
print_status "Cleaning previous builds..."
flutter clean > /dev/null 2>&1
print_success "Cleaned"
echo ""

# Step 2: Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Dependencies updated"
echo ""

# Step 3: Update CocoaPods repo
print_status "Updating CocoaPods repository (this may take a few minutes)..."
pod repo update
print_success "CocoaPods repository updated"
echo ""

# Step 4: Clean old pods
print_status "Cleaning old macOS Pods..."
cd macos
rm -rf Pods
rm -f Podfile.lock
cd ..
print_success "Old pods cleaned"
echo ""

# Step 5: Install pods with repo update
print_status "Installing macOS CocoaPods (with repo update)..."
cd macos
pod install --repo-update
cd ..
print_success "Pods installed"
echo ""

# Step 6: Build macOS app
echo "=========================================="
print_status "Building macOS app (release)..."
echo "=========================================="
echo ""

if flutter build macos --release; then
    print_success "macOS app built successfully!"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "=========================================="
echo "📦 Build Output"
echo "=========================================="
echo ""

APP_PATH="build/macos/Build/Products/Release/learning_kashmir_shaivism.app"

if [ -d "$APP_PATH" ]; then
    SIZE=$(du -sh "$APP_PATH" | awk '{print $1}')
    print_success "macOS app created:"
    echo "  📍 Location: $APP_PATH"
    echo "  📏 Size: $SIZE"
    echo ""
    
    # Copy to Desktop
    print_status "Copying to Desktop..."
    cp -r "$APP_PATH" ~/Desktop/
    print_success "Copied to: ~/Desktop/learning_kashmir_shaivism.app"
    echo ""
    
    echo "=========================================="
    echo "🚀 Installation & Usage"
    echo "=========================================="
    echo ""
    echo "1️⃣  Open the app:"
    echo "   open ~/Desktop/learning_kashmir_shaivism.app"
    echo ""
    echo "2️⃣  Move to Applications folder:"
    echo "   mv ~/Desktop/learning_kashmir_shaivism.app /Applications/"
    echo ""
    echo "3️⃣  Or double-click the app in Finder"
    echo ""
    echo "⚠️  First time launch:"
    echo "   If macOS blocks the app (unsigned):"
    echo "   - Right-click the app → Open"
    echo "   - Click 'Open' in the dialog"
    echo "   Or: System Settings → Privacy & Security → Allow"
    echo ""
    
else
    echo "❌ App not found at $APP_PATH"
    echo ""
    echo "Looking for build outputs..."
    find build/macos -name "*.app" -type d 2>/dev/null || echo "No .app bundles found"
fi

echo ""
echo "=========================================="
echo "✨ Done!"
echo "=========================================="
echo ""
echo "App Details:"
echo "  Name: Learning Kashmir Shaivism"
echo "  Bundle ID: com.plainos.kashmirshaivism"
echo "  Version: 0.1.0"
echo "  Platform: macOS 10.14+"
echo ""

