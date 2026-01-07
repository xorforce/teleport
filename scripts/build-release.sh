#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VERSION="${1:-0.1.0}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

echo -e "${GREEN}Building Teleport v$VERSION${NC}"
echo "=================================="

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ================================
# Build CLI
# ================================
echo -e "\n${YELLOW}Building CLI...${NC}"
cd "$PROJECT_ROOT/teleport-cli"

# Apple Silicon
echo "  → Building for Apple Silicon (arm64)..."
GOOS=darwin GOARCH=arm64 go build -ldflags="-s -w -X main.version=$VERSION" -o teleport .
tar -czvf "$BUILD_DIR/teleport-cli-darwin-arm64.tar.gz" teleport
rm teleport

# Intel
echo "  → Building for Intel (amd64)..."
GOOS=darwin GOARCH=amd64 go build -ldflags="-s -w -X main.version=$VERSION" -o teleport .
tar -czvf "$BUILD_DIR/teleport-cli-darwin-amd64.tar.gz" teleport
rm teleport

echo -e "${GREEN}  ✓ CLI binaries built${NC}"

# ================================
# Build macOS App
# ================================
echo -e "\n${YELLOW}Building macOS App...${NC}"
cd "$PROJECT_ROOT/teleport-app"

# Build with xcodebuild
xcodebuild -project teleport-app.xcodeproj \
  -scheme teleport-app \
  -configuration Release \
  -archivePath "$BUILD_DIR/teleport-app.xcarchive" \
  archive \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

# Extract app from archive
mkdir -p "$BUILD_DIR/app"
cp -R "$BUILD_DIR/teleport-app.xcarchive/Products/Applications/teleport-app.app" "$BUILD_DIR/app/"

# Create DMG
echo "  → Creating DMG..."
mkdir -p "$BUILD_DIR/dmg-contents"
cp -R "$BUILD_DIR/app/teleport-app.app" "$BUILD_DIR/dmg-contents/"
ln -s /Applications "$BUILD_DIR/dmg-contents/Applications"

hdiutil create \
  -volname "Teleport" \
  -srcfolder "$BUILD_DIR/dmg-contents" \
  -ov \
  -format UDZO \
  "$BUILD_DIR/Teleport.dmg"

# Cleanup
rm -rf "$BUILD_DIR/dmg-contents" "$BUILD_DIR/app" "$BUILD_DIR/teleport-app.xcarchive"

echo -e "${GREEN}  ✓ macOS App built${NC}"

# ================================
# Calculate checksums
# ================================
echo -e "\n${YELLOW}Calculating SHA256 checksums...${NC}"
cd "$BUILD_DIR"

ARM64_SHA=$(shasum -a 256 teleport-cli-darwin-arm64.tar.gz | cut -d ' ' -f 1)
AMD64_SHA=$(shasum -a 256 teleport-cli-darwin-amd64.tar.gz | cut -d ' ' -f 1)
APP_SHA=$(shasum -a 256 Teleport.dmg | cut -d ' ' -f 1)

echo ""
echo "SHA256 Checksums:"
echo "  teleport-cli-darwin-arm64.tar.gz: $ARM64_SHA"
echo "  teleport-cli-darwin-amd64.tar.gz: $AMD64_SHA"
echo "  Teleport.dmg: $APP_SHA"

# ================================
# Update Homebrew formulas
# ================================
echo -e "\n${YELLOW}Updating Homebrew formulas...${NC}"

# Update CLI formula
FORMULA="$PROJECT_ROOT/homebrew-tap/Formula/teleport-cli.rb"
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$FORMULA"
sed -i '' "s/sha256 \".*\" # arm64/sha256 \"$ARM64_SHA\" # arm64/" "$FORMULA" 2>/dev/null || \
sed -i '' "s/PLACEHOLDER_ARM64_SHA256/$ARM64_SHA/" "$FORMULA"
sed -i '' "s/sha256 \".*\" # amd64/sha256 \"$AMD64_SHA\" # amd64/" "$FORMULA" 2>/dev/null || \
sed -i '' "s/PLACEHOLDER_AMD64_SHA256/$AMD64_SHA/" "$FORMULA"

# Update Cask
CASK="$PROJECT_ROOT/homebrew-tap/Casks/teleport.rb"
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$CASK"
sed -i '' "s/sha256 \".*\"/sha256 \"$APP_SHA\"/" "$CASK" 2>/dev/null || \
sed -i '' "s/PLACEHOLDER_APP_SHA256/$APP_SHA/" "$CASK"

echo -e "${GREEN}  ✓ Homebrew formulas updated${NC}"

# ================================
# Summary
# ================================
echo -e "\n${GREEN}=================================="
echo "Build complete!"
echo "==================================${NC}"
echo ""
echo "Artifacts in $BUILD_DIR:"
ls -lh "$BUILD_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Test the builds locally"
echo "  2. Create a git tag: git tag -a v$VERSION -m \"Release v$VERSION\""
echo "  3. Push the tag: git push origin v$VERSION"
echo "  4. GitHub Actions will create the release automatically"
echo ""
echo "Or manually upload these files to a GitHub release."

