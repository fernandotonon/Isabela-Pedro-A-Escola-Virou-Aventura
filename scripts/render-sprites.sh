#!/usr/bin/env bash
# QtMeshEditor: render sprite sheets from the same GLBs the 3D mode uses, so any entity can be
# switched from "model" to "sprite" in config/assets.js without touching gameplay.
#
#   scripts/render-sprites.sh <id> [--animated]
#
#   static prop : qtmesh turntable <glb> --frames 8 -> assets/sprites/<id>.png (1 row x 8 columns)
#   character   : qtmesh isometric <rigged glb> --directions 8 --frames N --animation Clip
#                 -> assets/sprites/<id>_<clip>.png (rows = directions, cols = frames)
# The manifest entry then reads: sprite: { sheet: "assets/sprites/<id>.png", columns, rows, ... }
set -euo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
Q="${QTMESH:-/opt/homebrew/bin/qtmesheditor}"
ID="$1"; ANIMATED="${2:-}"
mkdir -p assets/sprites

if [ "$ANIMATED" = "--animated" ]; then
    GLB="assets/rigged/$ID/${ID}_rigged.glb"
    [ -f "$GLB" ] || { echo "missing $GLB (run scripts/rig-character.sh $ID)"; exit 1; }
    for clip in Idle Walk Run Jump; do
        out="assets/sprites/${ID}_$(echo "$clip" | tr 'A-Z' 'a-z').png"
        echo "== $ID $clip -> $out"
        "$Q" isometric "$GLB" -o "$out" --directions 8 --frames 8 --animation "$clip" --resolution 256 --json | tail -1 || echo "   (clip $clip failed)"
    done
else
    GLB="assets/exported/$ID/$ID.glb"
    [ -f "$GLB" ] || { echo "missing $GLB (run scripts/generate-models.sh $ID)"; exit 1; }
    out="assets/sprites/$ID.png"
    echo "== $ID -> $out"
    "$Q" turntable "$GLB" -o "$out" --frames 8 --size 256x256 --elevation 12 --json | tail -1
fi
