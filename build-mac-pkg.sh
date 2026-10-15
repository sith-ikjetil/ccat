
#!/bin/bash
set -euo pipefail

#
# Color Cat (ccat) macOS Release Script
#
# Usage:
#   ./release.sh 1.0.0
#   ./release.sh 1.0.0 --install
#

# ----------------------------------------
# Configuration
# ----------------------------------------

APP_NAME="ccat"
PRODUCT_NAME="color-cat"

APP_ID="no.ikjetil.color-cat"

APP_CERT="Developer ID Application: Kjetil Solberg (9L467T2S8C)"
PKG_CERT="Developer ID Installer: Kjetil Solberg (9L467T2S8C)"

NOTARY_PROFILE="ccat"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_DIR="${SCRIPT_DIR}/src"
BUILD_DIR="${SCRIPT_DIR}/build"
DIST_DIR="${SCRIPT_DIR}/dist"

SOURCE="${SOURCE_DIR}/ccat.pas"
EXECUTABLE="${BUILD_DIR}/${APP_NAME}"

# ----------------------------------------
# Arguments
# ----------------------------------------

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 <version> [--install]"
    exit 1
fi

VERSION="$1"
INSTALL=false

if [[ ! "$VERSION" =~ ^[0-9]+(\.[0-9]+){1,2}$ ]]; then
    echo "ERROR: Invalid version: $VERSION"
    exit 1
fi

if [[ $# -eq 2 ]]; then
    if [[ "$2" != "--install" ]]; then
        echo "ERROR: Unknown argument: $2"
        exit 1
    fi
    INSTALL=true
fi

PKG_NAME="${PRODUCT_NAME}-${VERSION}.pkg"
PKG_PATH="${DIST_DIR}/${PKG_NAME}"

# ----------------------------------------
# Helpers
# ----------------------------------------

step() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

fail() {
    echo "ERROR: $1" >&2
    exit 1
}

# ----------------------------------------
# Prerequisites
# ----------------------------------------

for tool in fpc codesign pkgbuild productsign \
            pkgutil spctl xcrun security \
            xattr dot_clean plutil shasum; do
    command -v "$tool" >/dev/null 2>&1 ||
        fail "Missing tool: $tool"
done

[[ -f "$SOURCE" ]] ||
    fail "Source file not found: $SOURCE"

security find-identity -v -p codesigning |
    grep -Fq "$APP_CERT" ||
    fail "Application signing certificate not found"

security find-certificate -c "$PKG_CERT" >/dev/null 2>&1 ||
    fail "Installer certificate not found"

# Never overwrite an existing release.
mkdir -p "$DIST_DIR"

[[ ! -e "$PKG_PATH" ]] ||
    fail "Release already exists: $PKG_PATH"

# ----------------------------------------
# 1. Build
# ----------------------------------------

step "1. Building Color Cat ${VERSION}"

mkdir -p "$BUILD_DIR"

# Build from src so relative unit/include
# paths work as expected.
cd "$SOURCE_DIR"

# Remove previous executable.
rm -f "$EXECUTABLE"

# Compile using Free Pascal.
fpc \
    "-FE${BUILD_DIR}" \
    "-FU${BUILD_DIR}" \
    ccat.pas

[[ -f "$EXECUTABLE" ]] ||
    fail "Executable not found: $EXECUTABLE"

# ----------------------------------------
# 2. Prepare staging directory
# ----------------------------------------

step "2. Preparing staging directory"

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

PAYLOAD="${STAGING}/root"
BIN_TARGET="${PAYLOAD}/usr/local/bin"

mkdir -p "$BIN_TARGET"

cp "$EXECUTABLE" "$BIN_TARGET/$APP_NAME"

TARGET="${BIN_TARGET}/${APP_NAME}"

chmod 755 "$TARGET"

# Remove extended attributes.
xattr -c "$TARGET"

# Remove AppleDouble metadata files.
dot_clean -m "$PAYLOAD"

# Remove any attributes merged by dot_clean.
xattr -cr "$PAYLOAD"

# Prevent AppleDouble metadata during packaging.
export COPYFILE_DISABLE=1

# ----------------------------------------
# 3. Sign executable
# ----------------------------------------

step "3. Signing executable"

codesign --force \
    --options runtime \
    --timestamp \
    --identifier "$APP_ID" \
    --sign "$APP_CERT" \
    "$TARGET"

# ----------------------------------------
# 4. Verify executable
# ----------------------------------------

step "4. Verifying executable"

codesign --verify \
    --strict \
    --verbose=2 \
    "$TARGET"

codesign -dv --verbose=2 "$TARGET"

# ----------------------------------------
# 5. Build unsigned package
# ----------------------------------------

step "5. Building installer package"

UNSIGNED_PKG="${STAGING}/unsigned.pkg"

pkgbuild \
    --root "$PAYLOAD" \
    --identifier "$APP_ID" \
    --version "$VERSION" \
    --install-location / \
    "$UNSIGNED_PKG"

# Verify payload contents.
pkgutil --payload-files "$UNSIGNED_PKG"

# ----------------------------------------
# 6. Sign package
# ----------------------------------------

step "6. Signing installer package"

productsign \
    --sign "$PKG_CERT" \
    "$UNSIGNED_PKG" \
    "$PKG_PATH"

pkgutil --check-signature "$PKG_PATH"

# ----------------------------------------
# 7. Notarize
# ----------------------------------------

step "7. Notarizing package"

NOTARY_OUTPUT="${STAGING}/notary-result.json"

if ! xcrun notarytool submit "$PKG_PATH" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait \
    --output-format json > "$NOTARY_OUTPUT"; then

    cat "$NOTARY_OUTPUT"
    fail "Notarization submission failed"
fi

cat "$NOTARY_OUTPUT"

NOTARY_STATUS=$(
    /usr/bin/plutil -extract status raw \
        -o - "$NOTARY_OUTPUT"
)

if [[ "$NOTARY_STATUS" != "Accepted" ]]; then
    fail "Notarization was not accepted: $NOTARY_STATUS"
fi

# ----------------------------------------
# 8. Staple
# ----------------------------------------

step "8. Stapling notarization ticket"

xcrun stapler staple "$PKG_PATH"

# ----------------------------------------
# 9. Verify package
# ----------------------------------------

step "9. Verifying package"

pkgutil --check-signature "$PKG_PATH"

xcrun stapler validate "$PKG_PATH"

spctl --assess \
    --type install \
    --verbose=2 \
    "$PKG_PATH"

# ----------------------------------------
# 10. Optionally install
# ----------------------------------------

if [[ "$INSTALL" == true ]]; then
    step "10. Installing Color Cat"

    sudo installer \
        -pkg "$PKG_PATH" \
        -target /
fi

# ----------------------------------------
# Finished
# ----------------------------------------

step "Release completed successfully"

echo "Version: $VERSION"
echo "Package: $PKG_PATH"

shasum -a 256 "$PKG_PATH"

echo
echo "Color Cat is ready for distribution!"
