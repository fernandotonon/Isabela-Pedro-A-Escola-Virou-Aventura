#!/usr/bin/env python3
"""Bring app/config/assets.js in line with what exists under assets/: for every id with a
runtime QML (balsam import) set model/footOffset/representation/status; for every id with a
sprite sheet fill in the sprite block. Gameplay never changes - only the manifest.

    python3 scripts/update-asset-manifest.py [--dry-run] [--prefer sprite|model]

footOffset = -minY of the GLB the runtime asset was imported from (rigged GLB for characters),
read with `qtmesh info`. TRELLIS.2 output is normalised to a ~1 unit box, `scale` in the manifest
is the wanted height in metres and is kept as authored.
"""
import glob
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
Q = os.environ.get("QTMESH", "/opt/homebrew/bin/qtmesheditor")
ENV = dict(os.environ, QTMESH_NO_TELEMETRY="1")
DRY = "--dry-run" in sys.argv
PREFER = sys.argv[sys.argv.index("--prefer") + 1] if "--prefer" in sys.argv else "model"
CHARACTERS = {"pedro", "isabela"}


def bbox(glb):
    out = subprocess.run([Q, "info", glb], capture_output=True, text=True, env=ENV).stdout
    m = re.search(r"Bounding Box: \(([-\d.]+), ([-\d.]+), ([-\d.]+)\) to \(([-\d.]+), ([-\d.]+), ([-\d.]+)\)", out)
    if not m:
        return None
    lo = [float(m.group(i)) for i in (1, 2, 3)]
    hi = [float(m.group(i)) for i in (4, 5, 6)]
    return {"footOffset": -lo[1], "w": hi[0] - lo[0], "h": hi[1] - lo[1], "d": hi[2] - lo[2]}


def collider_of(entry_src):
    m = re.search(r"collider:\s*\{\s*w:\s*([-\d.]+),\s*h:\s*([-\d.]+),\s*d:\s*([-\d.]+)", entry_src)
    return (float(m.group(1)), float(m.group(2)), float(m.group(3))) if m else None


def authored_scale(entry_src):
    m = re.search(r"\bscale:\s*([-\d.]+)", entry_src)
    return float(m.group(1)) if m else 1.0


def type_name(asset_id):
    return "".join(p.capitalize() for p in asset_id.split("_"))


def set_field(entry_src, key, value):
    lit = json.dumps(value) if isinstance(value, str) else (repr(value) if not isinstance(value, bool) else ("true" if value else "false"))
    if re.search(rf"\b{key}:\s*", entry_src):
        return re.sub(rf"(\b{key}:\s*)(\"[^\"]*\"|[-\w.]+|null)", lambda m: m.group(1) + lit, entry_src, count=1)
    # new key: right after footOffset when present, else at the start of the entry
    if re.search(r"footOffset:\s*[-\d.]+,", entry_src):
        return re.sub(r"(footOffset:\s*[-\d.]+,)", lambda m: m.group(1) + " " + key + ": " + lit + ",", entry_src, count=1)
    return entry_src.replace("{", "{ " + key + ": " + lit + ",", 1)


def main():
    path = os.path.join(ROOT, "app", "config", "assets.js")
    src = open(path, encoding="utf-8").read()
    changed = []
    for asset_id in re.findall(r"^\s{4}(\w+):\s*\{", src, re.M):
        runtime_qml = os.path.join(ROOT, "assets", "runtime", asset_id, type_name(asset_id) + ".qml")
        sprite = os.path.join(ROOT, "assets", "sprites", asset_id + ".png")
        has_model = os.path.exists(runtime_qml)
        has_sprite = os.path.exists(sprite)
        if not has_model and not has_sprite:
            continue
        m = re.search(rf"^\s{{4}}{asset_id}:\s*\{{.*?\n(?=\s{{4}}\w+:\s*\{{|\}})", src, re.M | re.S)
        if not m:
            continue
        entry = m.group(0)
        new = entry
        if has_model:
            rel = os.path.relpath(runtime_qml, ROOT)
            new = set_field(new, "model", rel)
            glb = os.path.join(ROOT, "assets", "rigged", asset_id, f"{asset_id}_rigged.glb") if asset_id in CHARACTERS else os.path.join(ROOT, "assets", "exported", asset_id, f"{asset_id}.glb")
            if not os.path.exists(glb):
                glb = os.path.join(ROOT, "assets", "exported", asset_id, f"{asset_id}.glb")
            if os.path.exists(glb):
                bb = bbox(glb)
                if bb:
                    new = set_field(new, "footOffset", round(bb["footOffset"], 3))
                    new = set_field(new, "unitHeight", round(bb["h"], 3))
                    new = set_field(new, "unitWidth", round(bb["w"], 3))
                    # scale: fit the model into the suggested collider (width and height), else the
                    # authored value is the wanted height in metres
                    col = collider_of(entry)
                    if col and asset_id not in CHARACTERS:
                        fit = min(col[0] / max(bb["w"], 1e-3), col[1] / max(bb["h"], 1e-3))
                    elif asset_id in CHARACTERS:
                        fit = col[1] / max(bb["h"], 1e-3) if col else authored_scale(entry)
                    else:
                        fit = authored_scale(entry) / max(bb["h"], 1e-3)
                    new = set_field(new, "scale", round(fit, 3))
                    new = set_field(new, "height", round(bb["h"] * fit, 3))
            new = set_field(new, "status", "generated")
        if has_sprite:
            new = re.sub(r"sprite:\s*(null|\{[^}]*\})", 'sprite: { sheet: "assets/sprites/%s.png", columns: 8, rows: 1, frames: 8, fps: 0 }' % asset_id, new, count=1) \
                if re.search(r"\bsprite:", new) else new.replace("{", '{ sprite: { sheet: "assets/sprites/%s.png", columns: 8, rows: 1, frames: 8, fps: 0 },' % asset_id, 1)
        rep = "model" if (has_model and (PREFER == "model" or not has_sprite)) else "sprite"
        if re.search(r'kind:\s*"backdrop"', entry):      # scene dioramas do not work as side-scroller backdrops
            rep = "placeholder"
        new = set_field(new, "representation", rep)
        if new != entry:
            src = src.replace(entry, new)
            changed.append(f"{asset_id}: {'model ' if has_model else ''}{'sprite ' if has_sprite else ''}-> {rep}")
    for line in changed:
        print(line)
    if not DRY and changed:
        open(path, "w", encoding="utf-8").write(src)
        print("updated", os.path.relpath(path, ROOT))
    elif not changed:
        print("nothing to update")


if __name__ == "__main__":
    main()
