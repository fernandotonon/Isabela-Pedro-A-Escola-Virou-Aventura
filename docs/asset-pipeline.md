# Asset pipeline — QtMeshEditor → Clayground

Every 3D asset starts as one concept image (`assets/source-images/<id>.png`, 1024-1536 px, grey
backdrop) and is produced by QtMeshEditor's CLI; Qt's `balsam` converts it for Qt Quick 3D. Every step
is a documented command that can be re-run.

```
assets/source-images/<id>.png
        │  scripts/prematte.py (subject-only alpha, drop shadow removed)
        │  qtmesh generate3d --backend trellis2 --preset high --target-tris N --texture-size S
        ▼                                                              scripts/generate-models.sh
assets/exported/<id>/<id>.glb  (+ .material, 4 PBR PNGs)
        │  qtmesh rig --skeleton humanoid --skin  +  qtmesh anim --generate <action>  (characters)
        ▼                                                              scripts/rig-character.sh
assets/rigged/<id>/<id>_rigged.glb  (humanoid skin + Idle/Walk/Run/Jump/Land/Push/Pickup/Climb/Crouch/Crawl/Hit/Cheer/Wave/Hang)
        │  balsam + runtime patch (`clip` property, one-shot clips emit clipFinished)
        ▼                                                              scripts/import-runtime.py
assets/runtime/<id>/<Type>.qml  (+ meshes/*.mesh, maps/*.png, animations/*.qad)
        │  qtmesh turntable / qtmesh isometric  (optional sprite sheets from the same GLBs)
        ▼                                                              scripts/render-sprites.sh
assets/sprites/<id>.png
        │  scripts/update-asset-manifest.py
        ▼
app/config/assets.js  →  PropVisual / CharacterVisual   (gameplay never names a file)
```

## Quality settings

| | props | characters (pedro, isabela) |
|---|---|---|
| preset | `high` (falls back to `balanced`, then `fast` when a preset hangs, see below) | `high` (same fallback) |
| `--target-tris` | 10 000 | 25 000 |
| `--texture-size` | 1024 | 2048 |

`--target-tris` runs QtMeshEditor's game-ready pass (weld, debris cull, meshopt simplify, detail
re-baked into the normal map). `assets/exported/<id>/.preset` records which preset produced each model.

**Known limit on this Mac (24 GB, Apple Silicon):** the `high` (1536) and `balanced` (1024)
TRELLIS.2 cascades stall in a Metal command buffer that never completes (0 % CPU forever).
`scripts/generate-models.sh` has a watchdog: if the generator gains less than 2 CPU-seconds in
150 s it is killed and the next preset is tried. The 512 pipeline (`fast`) always completes
(≈ 3-6 min per model). On a machine with more GPU memory the `high` preset is used as authored.

## Rigging and clips

* Skeleton: QtMeshEditor's humanoid template (Pinocchio auto-skin). Works best on upright, single
  component T/A-pose meshes — both siblings' concept images are T-poses for this reason.
* Clips come from QtMeshEditor's bundled permissive motion library (`qtmesh anim --generate`), retargeted
  through its canonical skeleton. Actions used: `idle walk run jump landleft push pickup climb crouch crawl hit cheer wave`.
  List all with `qtmesh anim x.glb --generate zzz` (the error prints them). Never pass `--variant`.
* Clip names in the game are fixed by the manifest's `clips` map (FSM state → clip name), so a rig
  with different clip names only needs a manifest edit.

## Runtime import

`balsam` writes compiled `.mesh` + textures + `QtQuick.Timeline` keyframes; `import-runtime.py` adds
`property string clip`, `readonly property var clips`, `signal clipFinished(name)`; only the selected
Timeline is enabled/running, one-shot clips have `loops: 1`.

## Sprite sheets

`qtmesh turntable <glb> --frames 8` renders one row of 8 views; `qtmesh isometric <rigged glb>
--directions 8 --frames 8 --animation Walk` renders rows = directions × columns = frames.
`Sprite3D.qml` shows one frame by UV offset/scale on a quad with alpha masking; the manifest's
`sprite` block gives sheet, columns, rows, frames, fps (and per-clip rows for characters).

## Manifest conventions

* `scale` — metres of height for the model (TRELLIS.2 output is a ~1 unit box); `footOffset` lifts the
  base to y = 0 (`-minY` of the GLB, written by `update-asset-manifest.py`).
* `rotation` — yaw degrees so the model faces the camera (+Z) at rest; characters add ±68° for facing.
* `collider` — suggested body size (w, h, d) in metres for level entities that use the asset.
* `shadow` — `{ cast, receive }`; `status` — `placeholder | pending | generated`.

## Web deployment paths

Assets are addressed relative to the QML files that use them (`Qt.resolvedUrl`), so the same tree
works compiled into the desktop binary (`qrc:/assets/runtime/...`) and copied next to the wasm for
the web (`file:///game/assets/...` after the loader preloads `escola-assets.json`). Directory imports
over HTTP need the `qmldir` in `app/`.

## Fit modes and raised passages

`fit` in a manifest entry decides how a model is scaled into an entity's box: default is the tighter
dimension (and wide platforms repeat the model along X), `fit: "height"` matches the box height and lets the
width exceed it (gates, levers, flags, lamp posts), `fit: "width"` matches the width (the swing seat, whose
hangers rise above the platform box). Low passages marked `raised: true` in `level.js` draw placeholder
visuals on legs above the crawl gap; a real model keeps its own geometry.

Concept images with light parts touching the backdrop (a white net, cream book pages) lose them to the
pre-matte; generate those with `PREMATTE=0 scripts/generate-models.sh <id>` (QtMeshEditor's own
background removal).
