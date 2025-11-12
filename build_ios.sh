#!/bin/bash
# iOS Build Script for Learning Kashmir Shaivism
# Builds iOS app and IPA for App Store distribution

set -e

echo "=========================================="
echo "📱 iOS Build Script"
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

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "iOS builds can only be created on macOS"
    exit 1
fi

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

# Step 3: Install iOS pods
print_status "Installing iOS CocoaPods..."
cd ios
pod install
cd ..
print_success "Pods installed"
echo ""

# Step 4: Build options
echo "=========================================="
echo "Build Options"
echo "=========================================="
echo ""
echo "1. Build for testing (no codesign)"
echo "2. Build IPA for App Store (requires certificates)"
echo "3. Build IPA for Ad Hoc distribution"
echo "4. Open in Xcode"
echo ""
read -p "Select option (1-4): " BUILD_OPTION
echo ""

case $BUILD_OPTION in
    1)
        echo "=========================================="
        print_status "Building iOS app (no codesign)..."
        echo "=========================================="
        echo ""
        
        if flutter build ios --release --no-codesign; then
            print_success "iOS app built successfully!"
            echo ""
            echo "Output: build/ios/iphoneos/Runner.app"
            echo ""
            echo "To test on simulator:"
            echo "  flutter run -d \"iPhone 14 Pro\""
        else
            print_error "Build failed"
            exit 1
        fi
        ;;
        
    2)
        echo "=========================================="
        print_status "Building IPA for App Store..."
        echo "=========================================="
        echo ""
        
        print_warning "Make sure you have:"
        echo "  ✓ Apple Developer account"
        echo "  ✓ Distribution certificate installed"
        echo "  ✓ App Store provisioning profile"
        echo "  ✓ Xcode configured with your account"
        echo ""
        read -p "Press Enter to continue or Ctrl+C to cancel..."
        echo ""
        
        if flutter build ipa --release --export-method app-store; then
            print_success "IPA built successfully!"
            echo ""
            
            if [ -f "build/ios/ipa/learning_hub.ipa" ]; then
                SIZE=$(ls -lh "build/ios/ipa/learning_hub.ipa" | awk '{print $5}')
                echo "Output: build/ios/ipa/learning_hub.ipa ($SIZE)"
                echo ""
                echo "Next steps:"
                echo "  1. Upload to App Store Connect:"
                echo "     xcrun altool --upload-app --file build/ios/ipa/learning_hub.ipa"
                echo "  2. Or use Transporter app"
                echo "  3. Or upload via Xcode > Window > Organizer"
                
                # Copy to Desktop
                cp build/ios/ipa/learning_hub.ipa ~/Desktop/LearningKashmirShaivism-v0.1.0.ipa
                print_success "Copied to Desktop: LearningKashmirShaivism-v0.1.0.ipa"
            fi
        else
            print_error "Build failed"
            echo ""
            echo "Common issues:"
            echo "  • Missing certificates or provisioning profiles"
            echo "  • Xcode not configured with Apple ID"
            echo "  • Bundle ID not registered in Apple Developer"
            echo ""
            echo "Try opening in Xcode to diagnose:"
            echo "  open ios/Runner.xcworkspace"
            exit 1
        fi
        ;;
        
    3)
        echo "=========================================="
        print_status "Building IPA for Ad Hoc distribution..."
        echo "=========================================="
        echo ""
        
        print_warning "Make sure you have:"
        echo "  ✓ Development certificate installed"
        echo "  ✓ Ad Hoc provisioning profile"
        echo "  ✓ Device UDIDs registered"
        echo ""
        read -p "Press Enter to continue or Ctrl+C to cancel..."
        echo ""
        
        if flutter build ipa --release --export-method ad-hoc; then
            print_success "IPA built successfully!"
            echo ""
            
            if [ -f "build/ios/ipa/learning_hub.ipa" ]; then
                SIZE=$(ls -lh "build/ios/ipa/learning_hub.ipa" | awk '{print $5}')
                echo "Output: build/ios/ipa/learning_hub.ipa ($SIZE)"
                echo ""
                echo "Installation:"
                echo "  1. Share IPA file with testers"
                echo "  2. Install via Apple Configurator"
                echo "  3. Or use TestFlight for easier distribution"
                
                # Copy to Desktop
                cp build/ios/ipa/learning_hub.ipa ~/Desktop/LearningKashmirShaivism-AdHoc-v0.1.0.ipa
                print_success "Copied to Desktop: LearningKashmirShaivism-AdHoc-v0.1.0.ipa"
            fi
        else
            print_error "Build failed"
            exit 1
        fi
        ;;
        
    4)
        print_status "Opening in Xcode..."
        open ios/Runner.xcworkspace
        print_success "Xcode opened"
        echo ""
        echo "In Xcode:"
        echo "  1. Select your development team"
        echo "  2. Select target device or 'Any iOS Device'"
        echo "  3. Product > Archive"
        echo "  4. Window > Organizer to manage archives"
        ;;
        
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "✨ Done!"
echo "=========================================="
echo ""

# Additional info
echo "📚 Additional Resources:"
echo ""
echo "Test on Simulator:"
echo "  flutter run -d \"iPhone 14 Pro\""
echo ""
echo "List available simulators:"
echo "  flutter devices"
echo ""
echo "Create archive in Xcode:"
echo "  open ios/Runner.xcworkspace"
echo "  Product > Archive"
echo ""
echo "App Store submission:"
echo "  https://appstoreconnect.apple.com"
echo ""

