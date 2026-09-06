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

Enable Pages once (Settings → Pages → Deploy from a branch → `gh-pages`, `/`). The bundled
`coi-serviceworker.js` provides the cross-origin isolation GitHub Pages cannot set itself;
`.wasm` is served as `application/wasm` by Pages. Assets are separate files preloaded from
`escola-assets.json` so the wasm stays cacheable. CI (`.github/workflows/ci.yml`) builds desktop
+ tests and the wasm deploy directory on every push.

Alternative without a local toolchain: `scripts/pack-web-runtime.sh <clayground-starter dir>` puts the
QML next to Clayground's prebuilt Web Runtime (preview only - the C++ save/gamepad helpers are not in it).
