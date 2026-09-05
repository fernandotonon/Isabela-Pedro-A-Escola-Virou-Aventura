#!/usr/bin/env bash
# QtMeshEditor: static character GLB -> rigged + animated GLB with the game's clip names.
#
#   scripts/rig-character.sh <id>            # e.g. pedro, isabela
#
#   Input : assets/exported/<id>/<id>.glb    (from scripts/generate-models.sh)
#   Output: assets/rigged/<id>/<id>_rigged.glb  (+ textures copied alongside)
#
# Clips come from QtMeshEditor's bundled permissive motion library (`qtmesh anim --generate`,
# retargeted through its canonical skeleton). The game's animation states map to these names
# in config/assets.js (`clips`). List every action with: qtmesh anim x.glb --generate zzz
# NOTE: never pass --variant, it indexes the whole library rather than one action.
set -euo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
Q="${QTMESH:-/opt/homebrew/bin/qtmesheditor}"

ID="$1"
IN="assets/exported/$ID/$ID.glb"
OUT_DIR="assets/rigged/$ID"
[ -f "$IN" ] || { echo "missing $IN"; exit 1; }
mkdir -p "$OUT_DIR"
WORK="$(mktemp -d)"
cp "assets/exported/$ID"/*.png "$WORK/" 2>/dev/null || true

echo "== rig + skin (humanoid template, Pinocchio, offline)"
"$Q" rig "$IN" --skeleton humanoid --skin --algo pinocchio --up-axis y -o "$WORK/r0.glb" --json | tail -1

# action:ClipName:duration  - the platformer state machine's clips
CLIPS=("idle:Idle:3" "walk:Walk:1" "run:Run:0.8" "jump:Jump:0.9" "landleft:Land:0.5" "push:Push:1.2"
       "pickup:Pickup:1.0" "climb:Climb:1.2" "crouch:Crouch:1.0" "crawl:Crawl:1.0" "hit:Hit:0.7"
       "cheer:Cheer:2.0" "wave:Wave:1.6")

prev="$WORK/r0.glb"; i=0
for spec in "${CLIPS[@]}"; do
    IFS=: read -r action clip dur <<<"$spec"
    i=$((i+1))
    echo "== generate $action ($dur s)"
    if "$Q" anim "$prev" --generate "$action" --duration "$dur" -o "$WORK/a$i.glb" --json | tail -1; then
        prev="$WORK/a$i.glb"
    else
        echo "   (action $action unavailable, skipped)"
    fi
done
for spec in "${CLIPS[@]}"; do
    IFS=: read -r action clip dur <<<"$spec"
    i=$((i+1))
    if "$Q" anim "$prev" --rename "generated_$action" "$clip" -o "$WORK/a$i.glb" >/dev/null 2>&1; then prev="$WORK/a$i.glb"; fi
done
# a Hang pose: the idle clip slowed down, renamed (a dedicated hang clip is a follow-up)
if "$Q" anim "$prev" --generate idle --duration 2 -o "$WORK/h1.glb" --json >/dev/null 2>&1 && \
   "$Q" anim "$WORK/h1.glb" --rename generated_idle Hang -o "$WORK/h2.glb" >/dev/null 2>&1; then prev="$WORK/h2.glb"; fi

cp "$prev" "$OUT_DIR/${ID}_rigged.glb"
cp "${prev%.glb}.material" "$OUT_DIR/${ID}_rigged.material" 2>/dev/null || true
cp "assets/exported/$ID"/*.png "$OUT_DIR/" 2>/dev/null || true
rm -rf "$WORK"
echo "== clips in $OUT_DIR/${ID}_rigged.glb"
"$Q" anim "$OUT_DIR/${ID}_rigged.glb" --list
