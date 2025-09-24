#!/bin/bash

# Three Ace Pass Manager - Optimized Release Build Script
# This script builds an optimized release APK with proper naming

echo "🔧 Building Three Ace Pass Manager - Optimized Release..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get app version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
echo "📱 App Version: $VERSION"

# Build optimized release APK
echo "🏗️  Building optimized release APK..."
flutter build apk --release \
    --shrink \
    --split-debug-info=build/app/outputs/symbols \
    --obfuscate \
    --tree-shake-icons

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Create custom named APK
    APK_NAME="ThreeAcePassManager-v${VERSION}-release.apk"
    cp build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/$APK_NAME"
    
    echo "📦 APK created: $APK_NAME"
    echo "📍 Location: build/app/outputs/flutter-apk/$APK_NAME"
    
    # Show file size
    SIZE=$(du -h "build/app/outputs/flutter-apk/$APK_NAME" | cut -f1)
    echo "📏 APK Size: $SIZE"
    
    echo ""
    echo "🎉 Release build complete!"
    echo "You can now share: build/app/outputs/flutter-apk/$APK_NAME"
else
    echo "❌ Build failed!"
    exit 1
fi
