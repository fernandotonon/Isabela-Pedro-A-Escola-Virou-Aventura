#!/usr/bin/env python3
"""Fill web/index.html for a deploy directory and stamp the service worker:

    make-web-index.py <deploy_dir> [app_name]

* expected download size and the sprite-sheet list for the loading screen (from escola-manifest.json
  and assets/sprites/*.png, written by make-web-pack.py / build-wasm.sh)
* a build id (hash of the wasm + asset manifest) so the service worker caches per build
* program arguments from the URL: index.html?args=--autotest%20--no-models
"""
import glob
import hashlib
import os
import json
import sys

d = sys.argv[1]
app = sys.argv[2] if len(sys.argv) > 2 else "escola_aventura"
root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

h = hashlib.sha1()
for f in (f"{app}.wasm", "escola-assets.json", "escola-pack.json"):
    p = os.path.join(d, f)
    if os.path.exists(p):
        h.update(open(p, "rb").read())
build_id = h.hexdigest()[:12]

manifest = json.load(open(os.path.join(d, "escola-manifest.json"))) if os.path.exists(os.path.join(d, "escola-manifest.json")) else {"expectedBytes": 0}
# loading-screen sprites: the turntable sheets with their dark studio background keyed out (kept out of
# assets/ so they are neither packed nor preloaded into the game's filesystem)
sprites = []
try:
    from PIL import Image
    os.makedirs(os.path.join(d, "loading"), exist_ok=True)
    for src in sorted(glob.glob(os.path.join(d, "assets", "sprites", "*.png"))):
        im = Image.open(src).convert("RGBA")
        bg = im.getpixel((2, 2))[:3]
        px = im.load()
        w, h = im.size
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                dist = max(abs(r - bg[0]), abs(g - bg[1]), abs(b - bg[2]))
                if dist < 22:
                    px[x, y] = (r, g, b, 0)
                elif dist < 40:
                    px[x, y] = (r, g, b, int(a * (dist - 22) / 18))
        out = os.path.join(d, "loading", os.path.basename(src))
        im.save(out, optimize=True)
        sprites.append("loading/" + os.path.basename(src))
except ImportError:
    sprites = sorted(os.path.relpath(p, d).replace(os.sep, "/") for p in glob.glob(os.path.join(d, "assets", "sprites", "*.png")))

html = open(os.path.join(root, "web", "index.html"), encoding="utf-8").read()
html = (html.replace("__APP__", app).replace("__TITLE__", "Isabela & Pedro: A Escola Virou Aventura")
            .replace("__EXPECTED_BYTES__", str(manifest["expectedBytes"])).replace("__SPRITES__", json.dumps(sprites)).replace("__BUILD_ID__", build_id))
open(os.path.join(d, "index.html"), "w", encoding="utf-8").write(html)

sw = open(os.path.join(root, "web", "escola-sw.js"), encoding="utf-8").read().replace("__BUILD_ID__", build_id)
open(os.path.join(d, "escola-sw.js"), "w", encoding="utf-8").write(sw)
for stale in ("coi-serviceworker.js", "qtlogo.svg"):
    if os.path.exists(os.path.join(d, stale)):
        os.remove(os.path.join(d, stale))
print(f"wrote index.html (build {build_id}, {len(sprites)} loading sprites, expected {manifest['expectedBytes'] / 1048576:.1f} MB) and escola-sw.js")
