#!/usr/bin/env bash
# Downloads Sparkle's command-line tools (generate_keys, sign_update) into .build/sparkle-tools.
# The first time on a Mac, also run `.build/sparkle-tools/bin/generate_keys --account orbix`
# only if the "orbix" signing key is not in the Keychain yet: a new key would not match the
# SUPublicEDKey that installed copies trust.
set -euo pipefail

cd "$(dirname "$0")/.."
SPARKLE_VERSION="2.10.0"
mkdir -p .build/sparkle-tools
cd .build/sparkle-tools
gh release download "$SPARKLE_VERSION" -R sparkle-project/Sparkle -p "Sparkle-$SPARKLE_VERSION.tar.xz" --clobber
tar -xf "Sparkle-$SPARKLE_VERSION.tar.xz"
echo "Herramientas de Sparkle en .build/sparkle-tools/bin"
