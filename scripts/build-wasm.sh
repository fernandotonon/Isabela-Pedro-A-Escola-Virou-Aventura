#!/usr/bin/env bash
# Build the game for Qt WebAssembly and assemble a static-hosting directory (deploy/).
#
#   scripts/build-wasm.sh [--single] [--debug] [--dev-tools]
#
# Requirements:
#   * Qt 6.11.1 wasm kit:   QT_WASM_ROOT (default ~/Qt/6.11.1/wasm_multithread)
#   * Emscripten 4.0.7:     EMSDK (default ~/emsdk-qt6) - the exact version Qt 6.11 expects
#   * Host Qt for tools:    QT_HOST_ROOT (default ~/Qt/6.11.1/macos)
# Production build: the in-game development tools are compiled OUT unless --dev-tools is given.
set -euo pipefail
cd "$(dirname "$0")/.."

FLAVOUR=multithread
BUILD_TYPE=Release
DEV_TOOLS=OFF
for a in "$@"; do
    case "$a" in
        --single) FLAVOUR=singlethread ;;
        --debug)  BUILD_TYPE=Debug ;;
        --dev-tools) DEV_TOOLS=ON ;;
        *) echo "unknown arg $a"; exit 2 ;;
    esac
done

EMSDK="${EMSDK:-$HOME/emsdk-qt6}"
QT_WASM_ROOT="${QT_WASM_ROOT:-$HOME/Qt/6.11.1/wasm_$FLAVOUR}"
QT_HOST_ROOT="${QT_HOST_ROOT:-$HOME/Qt/6.11.1/macos}"
BUILD_DIR="build-wasm-$FLAVOUR"
DEPLOY_DIR="deploy/$FLAVOUR"
APP=escola_aventura

# shellcheck disable=SC1091
source "$EMSDK/emsdk_env.sh" >/dev/null
echo "emcc: $(emcc --version | head -1)"
echo "Qt wasm kit: $QT_WASM_ROOT"

"$QT_WASM_ROOT/bin/qt-cmake" -S . -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_TESTING=OFF \
    -DESCOLA_DEV_TOOLS="$DEV_TOOLS" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
    ${FETCHCONTENT_SOURCE_DIR_LLAMA_CPP:+-DFETCHCONTENT_SOURCE_DIR_LLAMA_CPP="$FETCHCONTENT_SOURCE_DIR_LLAMA_CPP"} \
    ${FETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL:+-DFETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL="$FETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL"} \
    -DQT_HOST_PATH="$QT_HOST_ROOT"
cmake --build "$BUILD_DIR" --target "$APP" -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc)"

# ---- deploy directory: everything a static host needs -------------------------------------
rm -rf "$DEPLOY_DIR"; mkdir -p "$DEPLOY_DIR"
cp "$BUILD_DIR"/bin/$APP.{html,js,wasm} "$BUILD_DIR"/bin/qtloader.js "$DEPLOY_DIR/"
[ -f "$BUILD_DIR/bin/qtlogo.svg" ] && cp "$BUILD_DIR/bin/qtlogo.svg" "$DEPLOY_DIR/"
[ -f "$BUILD_DIR/bin/$APP.worker.js" ] && cp "$BUILD_DIR/bin/$APP.worker.js" "$DEPLOY_DIR/"
cp external/clayground/docs/coi-serviceworker.js "$DEPLOY_DIR/"
# Runtime 3D assets and sprites are not compiled into the wasm: ship them as files and let Qt's
# loader preload them into the in-memory filesystem (/game/assets/...) - see the assets manifest.
mkdir -p "$DEPLOY_DIR/assets"
[ -d assets/runtime ] && cp -R assets/runtime "$DEPLOY_DIR/assets/"
[ -d assets/sprites ] && cp -R assets/sprites "$DEPLOY_DIR/assets/"
find "$DEPLOY_DIR/assets" -name .DS_Store -delete 2>/dev/null || true
( cd "$DEPLOY_DIR" && find assets -type f | sort | python3 -c '
import json, sys
files = [l.strip() for l in sys.stdin if l.strip()]
json.dump([{"source": f, "destination": "/game/" + f} for f in files], open("escola-assets.json", "w"))
print(f"preload manifest: {len(files)} files")' )
python3 scripts/make-web-index.py "$DEPLOY_DIR" "$APP"
du -sh "$DEPLOY_DIR"/* | sed 's|^|  |'
echo
echo "Deploy dir ready: $DEPLOY_DIR"
echo "Serve it:         python3 scripts/serve.py $DEPLOY_DIR"
