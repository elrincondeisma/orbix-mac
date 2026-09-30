#!/usr/bin/env bash
# Builds build/Orbix-<version>.dmg from build/Orbix.app (already built, and notarized for
# distribution). With a Developer ID it signs, notarizes and staples the dmg too.
#
#   ./Scripts/make-dmg.sh                       # firma y notariza si hay Developer ID
#   ORBIX_SKIP_NOTARIZE=1 ./Scripts/make-dmg.sh # solo para revisar la maqueta
set -euo pipefail

cd "$(dirname "$0")/.."
VERSION="$(cat VERSION)"
APP=build/Orbix.app
DMG="build/Orbix-$VERSION.dmg"
NOTARY_PROFILE="${ORBIX_NOTARY_PROFILE:-orbix-notary}"
[ -d "$APP" ] || { echo "Falta $APP: ejecuta antes ./Scripts/build-app.sh"; exit 1; }

# Window background, @1x and @2x in one HiDPI tiff.
swiftc -O -framework AppKit Tools/dmgbackground/main.swift -o build/dmgbackground
build/dmgbackground build/dmg-fondo "$VERSION"
tiffutil -cathidpicheck build/dmg-fondo.png build/dmg-fondo@2x.png -out build/dmg-fondo.tiff >/dev/null

rm -f "$DMG"
uvx --quiet --from dmgbuild dmgbuild \
    -s packaging/dmg-settings.py \
    -D app="$APP" \
    -D icon=Resources/AppIcon.icns \
    -D background=build/dmg-fondo.tiff \
    "Orbix" "$DMG"

AUTHORITY="$(codesign -dvv "$APP" 2>&1 | sed -n 's/^Authority=//p' | head -1)"
if [[ "$AUTHORITY" == Developer\ ID* && "${ORBIX_SKIP_NOTARIZE:-0}" != "1" ]]; then
    codesign --force --timestamp --sign "$AUTHORITY" "$DMG"
    echo "Notarizando el dmg…"
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
fi
echo "Listo: $DMG"
