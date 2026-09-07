# Running, swapping assets, publishing

## Run

```bash
export QT_ROOT=~/Qt/6.11.1/macos
cmake --preset desktop && cmake --build --preset desktop --target escola_aventura
./build-desktop/bin/escola_aventura.app/Contents/MacOS/escola_aventura            # play
./build-desktop/bin/escola_aventura.app/Contents/MacOS/escola_aventura --autotest # scripted pass, prints AUTOTEST lines
./build-desktop/bin/escola_aventura.app/Contents/MacOS/escola_aventura --walkthrough # plays the whole level (config/walkthrough.js), exit 0 = completable
node tests/run-node.mjs                                                            # rules/physics/level checks without Qt
ctest --preset desktop -R "escola|Escola|physics|rules"                            # the game's QML suites + app smoke test (headless)
```

`ctest` without `-R` also lists Clayground's own plugin tests; two of them (`qml_world_qml`, `qml_lab_qml`)
need plugins that are only built with the `all` target, so filter when you only built `escola_aventura`.
The `--walkthrough` run is stepped from the event loop, not from the render loop, so it keeps its pace
when the window is occluded or the app is napped (macOS stops `FrameAnimation` in that case).

More checks: `node scripts/check-reachability.mjs` simulates real jumps/crawls from every standing spot and
lists collectibles no sibling can touch (exit 1 if any); `--photo collectibles --shots <dir>` (or
`--photo 46,162,381`) teleports both siblings to each spot and saves a frame, to review how items read visually.

`QML_DISABLE_DISK_CACHE=1` avoids a stale QML cache after big edits. F1 opens the dev tools, F2 the
collider view (development builds only; `-DESCOLA_DEV_TOOLS=OFF` or the wasm script compile them out).

## Swap an asset

1. Put the concept image in `assets/source-images/<id>.png` and run `scripts/generate-models.sh <id>`.
2. Characters: `scripts/rig-character.sh <id>`.
3. `python3 scripts/import-runtime.py assets/{exported|rigged}/<id>/<id>[_rigged].glb assets/runtime/<id> --name <Type>`
4. Optional sprite sheet: `scripts/render-sprites.sh <id>` (or `--animated` for a rigged character).
5. `python3 scripts/update-asset-manifest.py` — sets `model`, `footOffset`, `status` and `representation`
   in `app/config/assets.js`. Set `representation: "sprite"` by hand (or `--prefer sprite`) to use the sheet.
6. Rebuild. Nothing in `app/config/level.js` or the systems changes.

A new placeholder id: add an entry to `assets.js` with a `placeholder: { shape, color, accent }`
(shapes in `app/scripts/PlaceholderShapes.js`) and use the id in `level.js`.

## Publish (same process as Ironfang)

```bash
scripts/build-wasm.sh                      # Qt wasm_multithread + emsdk 4.0.7 -> deploy/multithread
python3 scripts/serve.py deploy/multithread   # local check with COOP/COEP headers
scripts/deploy-pages.sh                    # push deploy/multithread to the gh-pages branch
```

`make-web-index.py` also injects a keyboard-focus guard: Qt for WebAssembly listens for keys on a
focus-helper element inside its shadow DOM, and a click inside the canvas can drop the browser focus to
`<body>`, after which no key reaches the game. `node scripts/browser-input-check.mjs "<url>?args=--log-input" <dir>`
checks it headless (the game prints `INPUT press <action>` per received key).

`node scripts/browser-touch-check.mjs "<url>?args=--log-input" <dir>` emulates a phone (touch, 900×420) and
drives the on-screen stick, the jump button and the tap-to-switch card.

Enable Pages once (Settings → Pages → Deploy from a branch → `gh-pages`, `/`). The bundled
`escola-sw.js` (a service worker derived from coi-serviceworker) provides the cross-origin isolation GitHub Pages
cannot set itself, caches every game file per build (second visit loads from disk) and inflates the gzip meshes;
`.wasm` is served as `application/wasm` by Pages. Assets are separate files preloaded from
`escola-assets.json` so the wasm stays cacheable. CI (`.github/workflows/ci.yml`) builds desktop
+ tests and the wasm deploy directory on every push.

Alternative without a local toolchain: `scripts/pack-web-runtime.sh <clayground-starter dir>` puts the
QML next to Clayground's prebuilt Web Runtime (preview only - the C++ save/gamepad helpers are not in it).

## Android

```bash
python3 -m aqt install-qt all_os android 6.11.1 android_arm64_v8a -O ~/Qt -m qtquick3d qtquick3dphysics qtquicktimeline qtmultimedia qtshadertools
sdkmanager "platforms;android-36" "build-tools;36.0.0" "ndk;27.2.12479018"      # JDK 17 on PATH
scripts/build-android.sh                    # -> build-android/escola_aventura-debugsigned.apk
```

`app/android/AndroidManifest.xml.in` (landscape, package `io.github.fernandotonon.escolaaventura`) replaces
Clayground's older template at configure time; icons come from `app/android/res`. Clayground's network plugin
needs OpenSSL for Android: the script defaults to the KDAB bundle under `$ANDROID_SDK_ROOT/android_openssl/static`,
`ANDROID_OPENSSL_INCLUDE` / `ANDROID_OPENSSL_LIBDIR` point it elsewhere (CI uses KDAB's `ssl_3/arm64-v8a`).
The CI workflow `android.yml` builds on every manual run and attaches the APK to the GitHub Release for `v*` tags;
a release keystore can be supplied through the `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_ALIAS`,
`ANDROID_KEYSTORE_STORE_PASS` and `ANDROID_KEYSTORE_KEY_PASS` repository secrets (otherwise a debug key is used).
