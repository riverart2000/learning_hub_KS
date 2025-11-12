#!/bin/bash
# Sync App Config
# This script reads app_config.json and updates all platform-specific files

set -e

echo "=========================================="
echo "🔄 Syncing App Configuration"
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

# Read config values using jq (or Python if jq not available)
CONFIG_FILE="assets/data/app_config.json"

if ! command -v jq &> /dev/null; then
    print_status "Installing jq for JSON parsing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq 2>/dev/null || {
            echo "Please install jq: brew install jq"
            exit 1
        }
    fi
fi

# Extract values from config
APP_NAME=$(jq -r '.app.displayName' "$CONFIG_FILE")
APP_VERSION=$(jq -r '.app.version' "$CONFIG_FILE")
BUILD_NUMBER=$(jq -r '.app.buildNumber' "$CONFIG_FILE")
PACKAGE_NAME=$(jq -r '.app.packageName' "$CONFIG_FILE")
AUTHOR=$(jq -r '.developer.author' "$CONFIG_FILE")
COPYRIGHT=$(jq -r '.legal.copyright' "$CONFIG_FILE")

echo "Configuration values:"
echo "  App Name: $APP_NAME"
echo "  Version: $APP_VERSION"
echo "  Build: $BUILD_NUMBER"
echo "  Package: $PACKAGE_NAME"
echo "  Author: $AUTHOR"
echo ""

# Update pubspec.yaml
print_status "Updating pubspec.yaml..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^version: .*/version: $APP_VERSION+$BUILD_NUMBER/" pubspec.yaml
else
    sed -i "s/^version: .*/version: $APP_VERSION+$BUILD_NUMBER/" pubspec.yaml
fi
print_success "Updated pubspec.yaml"

# Update Android Manifest
print_status "Updating AndroidManifest.xml..."
ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/" "$ANDROID_MANIFEST"
else
    sed -i "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/" "$ANDROID_MANIFEST"
fi
print_success "Updated AndroidManifest.xml"

# Update iOS Info.plist
print_status "Updating iOS Info.plist..."
IOS_PLIST="ios/Runner/Info.plist"
if command -v plutil &> /dev/null; then
    plutil -replace CFBundleDisplayName -string "$APP_NAME" "$IOS_PLIST" 2>/dev/null || true
    print_success "Updated iOS Info.plist"
else
    print_status "Skipping iOS (plutil not available)"
fi

# Update macOS AppInfo.xcconfig
print_status "Updating macOS AppInfo.xcconfig..."
MACOS_CONFIG="macos/Runner/Configs/AppInfo.xcconfig"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^PRODUCT_NAME = .*/PRODUCT_NAME = $APP_NAME/" "$MACOS_CONFIG"
    sed -i '' "s/^PRODUCT_COPYRIGHT = .*/PRODUCT_COPYRIGHT = $COPYRIGHT/" "$MACOS_CONFIG"
else
    sed -i "s/^PRODUCT_NAME = .*/PRODUCT_NAME = $APP_NAME/" "$MACOS_CONFIG"
    sed -i "s/^PRODUCT_COPYRIGHT = .*/PRODUCT_COPYRIGHT = $COPYRIGHT/" "$MACOS_CONFIG"
fi
print_success "Updated macOS AppInfo.xcconfig"

# Update Web manifest.json
print_status "Updating web/manifest.json..."
WEB_MANIFEST="web/manifest.json"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"name\": \"[^\"]*\"/\"name\": \"$APP_NAME\"/" "$WEB_MANIFEST"
    sed -i '' "s/\"short_name\": \"[^\"]*\"/\"short_name\": \"$APP_NAME\"/" "$WEB_MANIFEST"
else
    sed -i "s/\"name\": \"[^\"]*\"/\"name\": \"$APP_NAME\"/" "$WEB_MANIFEST"
    sed -i "s/\"short_name\": \"[^\"]*\"/\"short_name\": \"$APP_NAME\"/" "$WEB_MANIFEST"
fi
print_success "Updated web/manifest.json"

# Update Web index.html
print_status "Updating web/index.html..."
WEB_INDEX="web/index.html"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/<title>.*<\/title>/<title>$APP_NAME<\/title>/" "$WEB_INDEX"
    sed -i '' "s/content=\"[^\"]*\" name=\"apple-mobile-web-app-title\"/content=\"$APP_NAME\" name=\"apple-mobile-web-app-title\"/" "$WEB_INDEX"
else
    sed -i "s/<title>.*<\/title>/<title>$APP_NAME<\/title>/" "$WEB_INDEX"
    sed -i "s/content=\"[^\"]*\" name=\"apple-mobile-web-app-title\"/content=\"$APP_NAME\" name=\"apple-mobile-web-app-title\"/" "$WEB_INDEX"
fi
print_success "Updated web/index.html"

# Sync assets/app_config.json with assets/data/app_config.json
print_status "Syncing config files..."
cp assets/data/app_config.json assets/app_config.json
print_success "Synced config files"

echo ""
echo "=========================================="
echo "✨ Configuration Sync Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ pubspec.yaml"
echo "  ✓ AndroidManifest.xml"
echo "  ✓ iOS Info.plist"
echo "  ✓ macOS AppInfo.xcconfig"
echo "  ✓ Web manifest.json"
echo "  ✓ Web index.html"
echo ""
echo "Next steps:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  flutter build apk --release"
echo ""

