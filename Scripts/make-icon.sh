#!/usr/bin/env bash
# Builds Resources/AppIcon.icns from Resources/icon/AppIcon.png (1024×1024, transparent corners).
set -euo pipefail

cd "$(dirname "$0")/.."
SOURCE=Resources/icon/AppIcon.png
ICONSET="$(mktemp -d)/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
    sips -z $size $size "$SOURCE" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    sips -z $((size * 2)) $((size * 2)) "$SOURCE" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns
rm -rf "$(dirname "$ICONSET")"
echo "Listo: Resources/AppIcon.icns"
