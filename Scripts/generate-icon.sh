#!/usr/bin/env bash
# Generates Orbix icon candidates with OpenAI GPT Image 2.5 (variants flare and sunburst)
# into Resources/icon/. Reads the key from OPENAI_API_KEY; it is never written anywhere.
#
#   OPENAI_API_KEY=sk-… ./Scripts/generate-icon.sh
set -euo pipefail

cd "$(dirname "$0")/.."
: "${OPENAI_API_KEY:?Define OPENAI_API_KEY antes de ejecutarlo}"
mkdir -p Resources/icon

PROMPT="A premium macOS app icon for an app called Orbix, a menu bar utility that tracks Claude AI usage limits. \
Shape: the standard macOS rounded-square (squircle) app icon plate, centered, occupying about 80% of the canvas with \
a fully transparent background around it and a soft natural drop shadow below the plate. Plate: deep near-black green \
gradient (#0B0F0E to #111A16), subtle top highlight and fine inner bevel, very slight glassy depth. Symbol centered on \
the plate: a clean circular orbit ring in luminous emerald green (#34D399) with a soft glow, drawn as a thick smooth \
stroke; about three quarters of the ring is bright and the remaining quarter fades into a dim track, suggesting a usage \
gauge; a small solid emerald planet sphere sits on the ring at the upper right, with a gentle highlight. Minimal, \
geometric, balanced, flat-meets-depth style of modern Apple icons, crisp edges, high contrast, no text, no letters, \
no extra objects."

for variant in flare sunburst; do
    python3 - "$variant" "$PROMPT" <<'PY' &
import base64, json, os, sys, urllib.error, urllib.request

variant, prompt = sys.argv[1], sys.argv[2]
body = json.dumps({
    "model": f"gpt-image-2.5-{variant}",
    "prompt": prompt,
    "size": "1024x1024",
    "quality": "high",
    "background": "transparent",
    "output_format": "png",
    "n": 1,
}).encode()
request = urllib.request.Request(
    "https://api.openai.com/v1/images/generations",
    data=body,
    headers={"Authorization": "Bearer " + os.environ["OPENAI_API_KEY"], "Content-Type": "application/json"},
)
try:
    data = json.load(urllib.request.urlopen(request, timeout=300))
    path = f"Resources/icon/orbix-{variant}.png"
    with open(path, "wb") as f:
        f.write(base64.b64decode(data["data"][0]["b64_json"]))
    print(f"{variant}: {path}")
except urllib.error.HTTPError as error:
    print(f"{variant}: error {error.code} {json.load(error).get('error', {}).get('message')}")
PY
done
wait
