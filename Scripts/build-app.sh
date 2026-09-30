#!/usr/bin/env bash
# Builds Orbix.app in ./build without needing Xcode (Command Line Tools are enough).
#
#   ORBIX_SIGN_IDENTITY  signing identity; defaults to "Developer ID Application" if installed,
#                        then "Apple Development", then ad-hoc.
set -euo pipefail

cd "$(dirname "$0")/.."
VERSION="$(cat VERSION)"
REPO="elrincondeisma/orbix-mac"
# EdDSA public key for Sparkle; the private half lives in the login Keychain (account "orbix").
SPARKLE_PUBLIC_KEY="01MSjG3pucht0BaPGWSkpLcQ7YIBY3040P/q0FVojdE="

swift build -c release --arch arm64 --arch x86_64

APP=build/Orbix.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Frameworks" "$APP/Contents/Resources"
cp "$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/Orbix" "$APP/Contents/MacOS/Orbix"
# App icon, generated from Resources/icon/AppIcon.png by Scripts/make-icon.sh.
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
# ditto keeps the framework's symlinks intact.
ditto .build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework \
    "$APP/Contents/Frameworks/Sparkle.framework"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Orbix</string>
    <key>CFBundleDisplayName</key><string>Orbix</string>
    <key>CFBundleIdentifier</key><string>dev.orbix.app</string>
    <key>CFBundleExecutable</key><string>Orbix</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundleVersion</key><string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <!-- Menu bar only: no Dock icon, no main window. -->
    <key>LSUIElement</key><true/>
    <!-- Sparkle: the appcast is an asset of the latest GitHub release. -->
    <key>SUFeedURL</key><string>https://github.com/${REPO}/releases/latest/download/appcast.xml</string>
    <key>SUPublicEDKey</key><string>${SPARKLE_PUBLIC_KEY}</string>
    <key>SUEnableAutomaticChecks</key><true/>
    <key>SUScheduledCheckInterval</key><integer>86400</integer>
</dict>
</plist>
PLIST

# Keychain "Always Allow", privacy permissions and Gatekeeper are tied to the signature:
# ad-hoc signing makes every rebuild look like a new app.
IDENTITY="${ORBIX_SIGN_IDENTITY:-}"
if [ -z "$IDENTITY" ]; then
    IDENTITIES="$(security find-identity -v -p codesigning 2>/dev/null)"
    IDENTITY="$(sed -n 's/.*"\(Developer ID Application:[^"]*\)".*/\1/p' <<<"$IDENTITIES" | head -1)"
    [ -z "$IDENTITY" ] && IDENTITY="$(sed -n 's/.*"\(Apple Development:[^"]*\)".*/\1/p' <<<"$IDENTITIES" | head -1)"
fi

if [ -z "$IDENTITY" ]; then
    codesign --force --deep --sign - "$APP"
    echo "Firmado ad-hoc (los permisos se pedirán de nuevo en cada compilación)"
else
    # Hardened runtime everywhere (required for notarization); secure timestamp for Developer ID.
    FLAGS=(--force --options runtime --sign "$IDENTITY")
    [[ "$IDENTITY" == Developer\ ID* ]] && FLAGS+=(--timestamp)
    # Inside out, as Sparkle documents: XPC services, helpers, framework, then the app.
    SPARKLE="$APP/Contents/Frameworks/Sparkle.framework/Versions/B"
    codesign "${FLAGS[@]}" "$SPARKLE/XPCServices/Installer.xpc"
    codesign "${FLAGS[@]}" --preserve-metadata=entitlements "$SPARKLE/XPCServices/Downloader.xpc"
    codesign "${FLAGS[@]}" "$SPARKLE/Autoupdate"
    codesign "${FLAGS[@]}" "$SPARKLE/Updater.app"
    codesign "${FLAGS[@]}" "$APP/Contents/Frameworks/Sparkle.framework"
    codesign "${FLAGS[@]}" "$APP"
    echo "Firmado con: $IDENTITY"
fi
codesign --verify --deep --strict "$APP"
echo "Listo: $APP ($VERSION)"
