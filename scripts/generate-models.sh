#!/usr/bin/env bash
# QtMeshEditor: concept image -> game-ready static GLB (TRELLIS.2 backend).
#
#   scripts/generate-models.sh                 # every assets/source-images/*.png without a model
#   scripts/generate-models.sh pedro isabela   # only these ids
#   SEED=7 scripts/generate-models.sh pedro    # another seed (remove the old export first)
#
# Quality (project decision, 2026-09-05):
#   * props:      --preset high, 10 000 triangles, 1024x1024 textures
#   * characters: --preset high, 25 000 triangles, 2048x2048 textures  (pedro, isabela)
#   PRESET / TRIS / TEXSIZE override the defaults for a run. If a preset hangs in a Metal
#   command buffer (seen with the 1024/1536 cascades on a 24 GB Mac), the watchdog kills it
#   after WATCHDOG_MIN minutes and retries with the next entry of FALLBACK_PRESETS.
#
# Output per model: assets/exported/<id>/<id>.glb + .material + 4 PBR PNGs.
# The full-resolution generation sidecar (<id>_source.qtm3d, ~20 MB) goes to
# assets/qtmesh-projects/sources/ (gitignored) so textures/LODs can be re-baked later.
set -uo pipefail
cd "$(dirname "$0")/.."
export QTMESH_NO_TELEMETRY=1
# trellis.cpp CLI + GGUF weights (QtMeshEditor's raw-mesh handshake needs the fork's --dump-post)
export QTMESH_TRELLIS2_CLI="${QTMESH_TRELLIS2_CLI:-$HOME/trellis.cpp/build-cpu/trellis-cli}"
export QTMESH_TRELLIS2_CLI_MODELS="${QTMESH_TRELLIS2_CLI_MODELS:-$HOME/trellis.cpp/models}"
Q="${QTMESH:-/opt/homebrew/bin/qtmesheditor}"
CHARACTERS=" pedro isabela "
WATCHDOG_MIN="${WATCHDOG_MIN:-30}"
FALLBACK_PRESETS="${FALLBACK_PRESETS-balanced fast}"
echo "using $Q ($($Q --version 2>/dev/null | head -1)), trellis-cli $QTMESH_TRELLIS2_CLI, preset ${PRESET:-high}"

mkdir -p assets/exported assets/qtmesh-projects/{sources,logs,matted}
if [ $# -gt 0 ]; then ids=("$@"); else
    ids=(); for f in assets/source-images/*.png; do ids+=("$(basename "${f%.png}")"); done
fi

# run "$@" with a watchdog: hard limit in minutes, plus a stall detector - if the generator's
# CPU time does not advance for STALL_SEC seconds it is stuck in a Metal command buffer that
# never completes (seen with the 1024/1536 cascades on a 24 GB Mac). Returns 124 on timeout.
STALL_SEC="${STALL_SEC:-600}"
# run "$@" with a watchdog. TRELLIS works on the GPU (near-zero CPU), so progress is measured by
# the log file growing: a stage that prints nothing for STALL_SEC seconds is a Metal command
# buffer that will never complete (a good 512 run finishes in 3-6 min with 7 stage banners).
run_with_watchdog() {
    local minutes="$1" logfile="$2"; shift 2
    "$@" &
    local pid=$!
    local waited=0 quiet=0 last_size=-1
    while kill -0 "$pid" 2>/dev/null; do
        sleep 10; waited=$((waited + 10))
        local size; size=$(stat -f %z "$logfile" 2>/dev/null || stat -c %s "$logfile" 2>/dev/null || echo 0)
        if [ "$size" = "$last_size" ]; then quiet=$((quiet + 10)); else quiet=0; last_size="$size"; fi
        if [ $quiet -ge "$STALL_SEC" ] || [ $waited -ge $((minutes * 60)) ]; then
            echo "watchdog: no output for ${quiet}s (ran ${waited}s), killing generate3d" >&2
            kill "$pid" 2>/dev/null; sleep 2; kill -9 "$pid" 2>/dev/null
            pkill -f "trellis-cli" 2>/dev/null
            return 124
        fi
    done
    wait "$pid"; return $?
}

for id in "${ids[@]}"; do
    img="assets/source-images/$id.png"
    dir="assets/exported/$id"; out="$dir/$id.glb"; log="assets/qtmesh-projects/logs/$id.log"
    [ -f "$img" ] || { echo "SKIP $id (no image)"; continue; }
    [ -s "$out" ] && { echo "SKIP $id (exists)"; continue; }
    if [[ "$CHARACTERS" == *" $id "* ]]; then tris="${TRIS:-25000}"; tex="${TEXSIZE:-2048}"
    else tris="${TRIS:-10000}"; tex="${TEXSIZE:-1024}"; fi
    mkdir -p "$dir"; S=$(date +%s)
    if [ "${PREMATTE:-1}" = "1" ]; then
        matted="assets/qtmesh-projects/matted/$id.png"
        python3 scripts/prematte.py "$img" "$matted" >> "$log" 2>&1
        input="$matted"; bgflag=""
    else
        input="$img"; bgflag="--remove-bg"
    fi
    rc=1
    for preset in "${PRESET:-high}" ${FALLBACK_PRESETS-balanced fast}; do
        echo "== $id: preset $preset, $tris tris, ${tex}px ($(date '+%H:%M:%S'))" | tee -a "$log"
        run_with_watchdog "$WATCHDOG_MIN" "$log" "$Q" generate3d "$input" -o "$out" --backend trellis2 --preset "$preset" \
            --target-tris "$tris" --texture-size "$tex" $bgflag --seed "${SEED:-42}" >> "$log" 2>&1
        rc=$?
        [ $rc -eq 0 ] && [ -s "$out" ] && { echo "$preset" > "$dir/.preset"; break; }
        echo "-- $id: preset $preset failed (rc=$rc)" | tee -a "$log"
        rm -f "$out"
    done
    if [ $rc -eq 0 ] && [ -s "$out" ]; then
        mv "$dir/${id}_source.qtm3d" assets/qtmesh-projects/sources/ 2>/dev/null || true
        python3 scripts/resize-textures.py "$dir" "$tex" >> "$log" 2>&1
        echo "OK   $id $(( $(date +%s) - S ))s preset=$(cat "$dir/.preset") tris=$tris tex=$tex"
    else
        echo "FAIL $id rc=$rc (see $log)"; rmdir "$dir" 2>/dev/null
    fi
done
