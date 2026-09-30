#!/usr/bin/env bash
# Publishes a new Orbix version as a GitHub release that installed copies update to.
#
#   ./Scripts/release.sh 0.2.0 "Qué cambia en esta versión"
#
# Steps: bump VERSION → build and sign → notarize (with Developer ID) → zip → sign the zip
# for Sparkle (EdDSA) → appcast.xml → dmg for people to download (signed and notarized) →
# commit + tag → GitHub release with dmg, zip and appcast.
#
# Notarization needs a "Developer ID Application" certificate and a notarytool profile:
#   xcrun notarytool store-credentials orbix-notary --apple-id <email> --team-id <TEAM>
# Without them the release only opens without warnings on this Mac; set
# ORBIX_ALLOW_UNNOTARIZED=1 to publish anyway.
set -euo pipefail

cd "$(dirname "$0")/.."
REPO="elrincondeisma/orbix-mac"
NOTARY_PROFILE="${ORBIX_NOTARY_PROFILE:-orbix-notary}"
TOOLS=.build/sparkle-tools/bin

VERSION="${1:?Uso: release.sh <versión> [notas]}"
NOTES="${2:-Orbix $VERSION}"
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "La versión debe ser X.Y.Z"; exit 1; }
git diff --quiet && git diff --cached --quiet || { echo "Hay cambios sin commitear."; exit 1; }
git rev-parse "v$VERSION" >/dev/null 2>&1 && { echo "La versión v$VERSION ya existe."; exit 1; }
[ -x "$TOOLS/sign_update" ] || { echo "Faltan las herramientas de Sparkle: ./Scripts/setup-sparkle.sh"; exit 1; }

echo "$VERSION" > VERSION
./Scripts/build-app.sh

APP=build/Orbix.app
ZIP="build/Orbix-$VERSION.zip"
AUTHORITY="$(codesign -dvv "$APP" 2>&1 | sed -n 's/^Authority=//p' | head -1)"

if [[ "$AUTHORITY" == Developer\ ID* ]]; then
    echo "Notarizando…"
    ditto -c -k --keepParent "$APP" "$ZIP"
    xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$APP"
elif [ "${ORBIX_ALLOW_UNNOTARIZED:-0}" != "1" ]; then
    echo "Firmada con «$AUTHORITY», no con Developer ID: en otros Macs Gatekeeper la bloqueará."
    echo "Usa ORBIX_ALLOW_UNNOTARIZED=1 para publicarla igualmente."
    git checkout VERSION
    exit 1
fi

# Final archive (after stapling, so the ticket travels inside the app).
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
SIGNATURE="$("$TOOLS/sign_update" --account orbix "$ZIP")"   # sparkle:edSignature="…" length="…"

cat > build/appcast.xml <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Orbix</title>
    <item>
      <title>Orbix $VERSION</title>
      <pubDate>$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S +0000")</pubDate>
      <sparkle:version>$VERSION</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <sparkle:releaseNotesLink>https://github.com/$REPO/releases/tag/v$VERSION</sparkle:releaseNotesLink>
      <enclosure url="https://github.com/$REPO/releases/download/v$VERSION/Orbix-$VERSION.zip"
                 type="application/octet-stream" $SIGNATURE />
    </item>
  </channel>
</rss>
XML

# Installer for first-time downloads; Sparkle keeps using the zip.
./Scripts/make-dmg.sh
DMG="build/Orbix-$VERSION.dmg"

git add VERSION
# The first release may already carry its number in VERSION.
git diff --cached --quiet || git commit -m "Orbix $VERSION"
git tag "v$VERSION"
git push origin HEAD "v$VERSION"
gh release create "v$VERSION" "$DMG" "$ZIP" build/appcast.xml --repo "$REPO" --title "Orbix $VERSION" --notes "$NOTES"
echo "Publicada: https://github.com/$REPO/releases/tag/v$VERSION"
