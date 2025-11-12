#!/bin/bash
# Build Without Firebase (For Testing)
# Temporarily disables Firebase to build and test the app

set -e

echo "=========================================="
echo "🔨 Building Without Firebase"
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

# Backup original build.gradle.kts
print_status "Backing up build.gradle.kts..."
cp android/app/build.gradle.kts android/app/build.gradle.kts.backup
print_success "Backup created"

# Comment out Firebase plugin
print_status "Disabling Firebase plugin..."
sed -i.tmp 's/id("com.google.gms.google-services")/\/\/ id("com.google.gms.google-services")/' android/app/build.gradle.kts
rm android/app/build.gradle.kts.tmp
print_success "Firebase plugin disabled"

echo ""
print_warning "Firebase is temporarily disabled for this build"
print_warning "Auth, Firestore, and Analytics will NOT work"
echo ""

# Clean and build
print_status "Cleaning..."
flutter clean > /dev/null 2>&1
print_success "Cleaned"

print_status "Getting dependencies..."
flutter pub get > /dev/null 2>&1
print_success "Dependencies updated"

echo ""
echo "=========================================="
print_status "Building APK..."
echo "=========================================="
echo ""

if flutter build apk --release; then
    print_success "APK built successfully!"
    echo ""
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        SIZE=$(ls -lh "build/app/outputs/flutter-apk/app-release.apk" | awk '{print $5}')
        echo "Output: build/app/outputs/flutter-apk/app-release.apk ($SIZE)"
        
        # Copy to Desktop
        cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/KashmirShaivism-NoFirebase-v0.1.0.apk
        print_success "Copied to: ~/Desktop/KashmirShaivism-NoFirebase-v0.1.0.apk"
    fi
else
    print_error "Build failed"
    
    # Restore original
    print_status "Restoring original build.gradle.kts..."
    mv android/app/build.gradle.kts.backup android/app/build.gradle.kts
    exit 1
fi

# Restore original build.gradle.kts
echo ""
print_status "Restoring Firebase plugin..."
mv android/app/build.gradle.kts.backup android/app/build.gradle.kts
print_success "Restored"

echo ""
echo "=========================================="
echo "✨ Build Complete!"
echo "=========================================="
echo ""
print_warning "This APK does NOT include Firebase"
print_warning "Features that won't work:"
echo "  • User authentication (sign in/out)"
echo "  • Cloud sync of progress"
echo "  • Leaderboards"
echo "  • Analytics"
echo ""
echo "Installation:"
echo "  adb uninstall com.plainos.kashmirshaivism"
echo "  adb install ~/Desktop/KashmirShaivism-NoFirebase-v0.1.0.apk"
echo ""
echo "To build WITH Firebase:"
echo "  1. Setup new Firebase project (see SETUP_NEW_FIREBASE_PROJECT.md)"
echo "  2. Replace google-services.json"
echo "  3. Run: ./build_universal_apk.sh"
echo ""

