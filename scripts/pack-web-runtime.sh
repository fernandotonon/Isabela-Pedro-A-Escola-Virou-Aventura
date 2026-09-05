#!/usr/bin/env bash
# Assemble a no-build-step deployment: Clayground Web Runtime files + the game's QML + assets.
#
#   scripts/pack-web-runtime.sh <runtime_dir> [out_dir=deploy/web-runtime]
#
# <runtime_dir> holds clayground.wasm/.js, qtloader.js, coi-serviceworker.js, index.html,
# LICENSES/ and RUNTIME-MANIFEST.json - an unzipped clayground-starter.zip from a Clayground
# release (>= 2026.7 for QtQuick.Timeline + AssetUtils, i.e. animated balsam models).
# NOTE: the C++ helpers (SaveStore, GamepadBridge) are not part of the prebuilt runtime, so this
# path is for previews; the published build is scripts/build-wasm.sh.
set -euo pipefail
cd "$(dirname "$0")/.."
RT="${1:?runtime dir}"; OUT="${2:-deploy/web-runtime}"
[ -f "$RT/clayground.wasm" ] || { echo "no clayground.wasm in $RT"; exit 1; }
rm -rf "$OUT"; mkdir -p "$OUT/scripts" "$OUT/config" "$OUT/assets"
cp "$RT"/clayground.wasm "$RT"/clayground.js "$RT"/qtloader.js "$RT"/coi-serviceworker.js "$RT"/index.html "$OUT"/
cp "$RT"/RUNTIME-MANIFEST.json "$OUT"/ 2>/dev/null || true
[ -d "$RT/LICENSES" ] && cp -R "$RT/LICENSES" "$OUT"/
cp web-runtime/Main.qml "$OUT"/
cp app/*.qml app/qmldir "$OUT"/ && rm -f "$OUT/Main.qml.bak"
cp web-runtime/Main.qml "$OUT/Main.qml"
cp app/scripts/*.js "$OUT/scripts/" && cp app/config/*.js "$OUT/config/"
printf '.pragma library\nvar devTools = false\nvar version = "web-runtime"\nvar buildType = "Release"\n' > "$OUT/config/build.js"
[ -d assets/runtime ] && cp -R assets/runtime "$OUT/assets/"
[ -d assets/sprites ] && cp -R assets/sprites "$OUT/assets/"
cp -R assets/audio "$OUT/assets/"
( cd "$OUT" && find assets -type f ! -name '.DS_Store' | sort | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin], indent=0))' > assets-manifest.json )
sed -i '' 's|<title>My Clayground Game</title>|<title>Isabela \&amp; Pedro: A Escola Virou Aventura</title>|' "$OUT/index.html" 2>/dev/null || true
touch "$OUT/.nojekyll"
du -sh "$OUT" | cut -f1; echo "Serve: python3 scripts/serve.py $OUT"
