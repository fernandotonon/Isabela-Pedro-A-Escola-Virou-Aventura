#!/usr/bin/env bash
# Bring assets/runtime, assets/sprites and the manifest in line with the exported/rigged GLBs.
#
#   scripts/refresh-assets.sh              # import everything that exists, render sprites, update manifest
#   scripts/refresh-assets.sh --no-sprites # skip the sprite sheets
#
# * characters (pedro, isabela) are imported from assets/rigged when a rig exists, else from exported
# * every other exported id is imported as a static model
# * scripts/update-asset-manifest.py then points app/config/assets.js at the results
set -uo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
SPRITES=1; [ "${1:-}" = "--no-sprites" ] && SPRITES=0
CHARACTERS=" pedro isabela "

type_name() { echo "$1" | awk -F_ '{ for (i = 1; i <= NF; i++) printf "%s%s", toupper(substr($i, 1, 1)), substr($i, 2) }'; }

for dir in assets/exported/*/; do
    id="$(basename "$dir")"
    exported="assets/exported/$id/$id.glb"
    rigged="assets/rigged/$id/${id}_rigged.glb"
    [ -f "$exported" ] || continue
    type="$(type_name "$id")"
    if [[ "$CHARACTERS" == *" $id "* ]] && [ -f "$rigged" ]; then
        echo "== import rigged $id"; python3 scripts/import-runtime.py "$rigged" "assets/runtime/$id" --name "$type" | tail -1 | cut -c1-120
    else
        echo "== import static $id"; python3 scripts/import-runtime.py "$exported" "assets/runtime/$id" --name "$type" | tail -1 | cut -c1-120
    fi
    if [ $SPRITES -eq 1 ] && [[ "$CHARACTERS" != *" $id "* ]] && [ ! -f "assets/sprites/$id.png" ]; then
        scripts/render-sprites.sh "$id" 2>&1 | tail -1
    fi
done
python3 scripts/update-asset-manifest.py
echo "runtime: $(du -sh assets/runtime 2>/dev/null | cut -f1)  sprites: $(du -sh assets/sprites 2>/dev/null | cut -f1)"
