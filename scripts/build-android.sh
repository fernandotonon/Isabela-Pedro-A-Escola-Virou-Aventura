#!/usr/bin/env bash
# Build the Android APK (arm64-v8a) with the Qt for Android kit.
#
#   scripts/build-android.sh [--debug] [--deploy-only]
#
# Needs: Qt 6.11.1 android_arm64_v8a kit (aqt install-qt all_os android 6.11.1 android_arm64_v8a
# -m qtquick3d qtquick3dphysics qtquicktimeline qtmultimedia qtshadertools), the matching host kit,
# Android SDK (platform 35, build-tools 35, NDK r27) and JDK 17. Override the paths with the
# environment variables below. Output: build-android/android-build/build/outputs/apk/...
set -euo pipefail
cd "$(dirname "$0")/.."

BUILD_TYPE=Release; DEPLOY_ONLY=0
for a in "$@"; do case "$a" in --debug) BUILD_TYPE=Debug ;; --deploy-only) DEPLOY_ONLY=1 ;; *) echo "unknown arg $a"; exit 2 ;; esac; done

export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
export ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-$(ls -d "$ANDROID_SDK_ROOT"/ndk/27.* | sort | tail -1)}"
QT_ANDROID_ROOT="${QT_ANDROID_ROOT:-$HOME/Qt/6.11.1/android_arm64_v8a}"
QT_HOST_ROOT="${QT_HOST_ROOT:-$HOME/Qt/6.11.1/macos}"
BUILD_DIR="${BUILD_DIR:-build-android}"
# Clayground's network plugin (libdatachannel) needs OpenSSL; the KDAB android_openssl bundle that ships
# with Qt's SDK setup has static 1.1.1 libraries per ABI (https://github.com/KDAB/android_openssl).
ANDROID_OPENSSL="${ANDROID_OPENSSL:-$ANDROID_SDK_ROOT/android_openssl/static}"
ANDROID_OPENSSL_INCLUDE="${ANDROID_OPENSSL_INCLUDE:-$ANDROID_OPENSSL/include}"
ANDROID_OPENSSL_LIBDIR="${ANDROID_OPENSSL_LIBDIR:-$ANDROID_OPENSSL/lib/arm64}"      # KDAB ssl_3 layout: <root>/arm64-v8a
APP=escola_aventura
export PATH="$JAVA_HOME/bin:$PATH"

echo "Qt android kit: $QT_ANDROID_ROOT"; echo "NDK: $ANDROID_NDK_ROOT"; echo "JDK: $("$JAVA_HOME/bin/java" -version 2>&1 | head -1)"

if [ "$DEPLOY_ONLY" = 0 ]; then
"$QT_ANDROID_ROOT/bin/qt-cmake" -S . -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DQT_HOST_PATH="$QT_HOST_ROOT" \
    -DANDROID_SDK_ROOT="$ANDROID_SDK_ROOT" \
    -DANDROID_NDK_ROOT="$ANDROID_NDK_ROOT" \
    -DQT_ANDROID_ABIS="arm64-v8a" \
    -DOPENSSL_ROOT_DIR="$ANDROID_OPENSSL" -DOPENSSL_USE_STATIC_LIBS=TRUE \
    -DOPENSSL_INCLUDE_DIR="$ANDROID_OPENSSL_INCLUDE" \
    -DOPENSSL_CRYPTO_LIBRARY="$ANDROID_OPENSSL_LIBDIR/libcrypto.a" \
    -DOPENSSL_SSL_LIBRARY="$ANDROID_OPENSSL_LIBDIR/libssl.a" \
    -DGGML_NATIVE=OFF \
    -DBUILD_TESTING=OFF \
    -DESCOLA_DEV_TOOLS=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_IGNORE_PREFIX_PATH=/usr/local \
    ${FETCHCONTENT_SOURCE_DIR_LLAMA_CPP:+-DFETCHCONTENT_SOURCE_DIR_LLAMA_CPP="$FETCHCONTENT_SOURCE_DIR_LLAMA_CPP"} \
    ${FETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL:+-DFETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL="$FETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL"}
cmake --build "$BUILD_DIR" --target "$APP" -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc)"
fi
cmake --build "$BUILD_DIR" --target apk
UNSIGNED="$(find "$BUILD_DIR" -path "*outputs/apk/*" -name "*unsigned.apk" | head -1)"
# Sign: a release keystore from the environment (ANDROID_KEYSTORE / _ALIAS / _STORE_PASS / _KEY_PASS), else the
# Android debug keystore (~/.android/debug.keystore, created here if missing) - fine for side-loading.
BT="$(ls -d "$ANDROID_SDK_ROOT"/build-tools/36.* "$ANDROID_SDK_ROOT"/build-tools/35.* 2>/dev/null | sort | tail -1)"
KS="${ANDROID_KEYSTORE:-$HOME/.android/debug.keystore}"; ALIAS="${ANDROID_KEYSTORE_ALIAS:-androiddebugkey}"
SPASS="${ANDROID_KEYSTORE_STORE_PASS:-android}"; KPASS="${ANDROID_KEYSTORE_KEY_PASS:-android}"
if [ ! -f "$KS" ]; then
    mkdir -p "$(dirname "$KS")"
    "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$KS" -storepass "$SPASS" -keypass "$KPASS" -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" >/dev/null
fi
OUT="$BUILD_DIR/escola_aventura-$([ -n "${ANDROID_KEYSTORE:-}" ] && echo release || echo debugsigned).apk"
"$BT/zipalign" -p -f 4 "$UNSIGNED" "$BUILD_DIR/aligned.apk"
"$BT/apksigner" sign --ks "$KS" --ks-pass "pass:$SPASS" --key-pass "pass:$KPASS" --ks-key-alias "$ALIAS" --out "$OUT" "$BUILD_DIR/aligned.apk"
"$BT/apksigner" verify "$OUT" && rm -f "$BUILD_DIR/aligned.apk"
echo "APK: $OUT ($(du -h "$OUT" | cut -f1))"
