# Third-party notices

| Component | Licence | Use |
|---|---|---|
| [Clayground](https://github.com/MisterGC/clayground) | MIT | game framework (submodule `external/clayground`) |
| Qt 6 (Qt Quick, Qt Quick 3D, Qt Multimedia, Qt Quick Timeline) | LGPL-3.0 / GPL-3.0 (Qt Quick 3D is GPL-3.0 in the open-source edition) | runtime; the game's own code is MIT, compatible |
| [QtMeshEditor](https://github.com/fernandotonon/QtMeshEditor) | GPL-3.0 (tool only) | asset generation (image → GLB, rig, sprites); not shipped |
| TRELLIS.2 (via trellis.cpp) | MIT (code and weights) | image-to-3D backend used by QtMeshEditor, offline only |
| QtMeshEditor motion library | CC0 / CC-BY clips (CMU and others), see QtMeshEditor's documentation | character animation clips baked into the rigged GLBs |
| Emscripten | MIT / UIUC | WebAssembly toolchain |
| coi-serviceworker.js | MIT | COOP/COEP shim for static hosts (from Clayground) |

Audio: every sound and music loop is synthesized by `scripts/gen-audio.py` (original, no external samples).
Concept images (`assets/source-images`) are the project's own artwork; the school depicted is fictional ("Escola Horizonte").
