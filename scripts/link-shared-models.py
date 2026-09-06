#!/usr/bin/env python3
"""Manifest entries that share another entry's model (run after update-asset-manifest.py):
   school_gate_small -> school_gate (same gate, smaller box). Copies model/unit sizes/footOffset/status."""
import os, re
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHARED = {"school_gate_small": "school_gate"}
path = os.path.join(ROOT, "app", "config", "assets.js")
src = open(path, encoding="utf-8").read()

def entry(aid):
    m = re.search(rf"^\s{{4}}{aid}:\s*\{{.*?\n(?=\s{{4}}\w+:\s*\{{|\}})", src, re.M | re.S)
    return m.group(0) if m else None

def field(text, key):
    m = re.search(rf"\b{key}:\s*([^,}}]+)", text)
    return m.group(1).strip() if m else None

def set_field(text, key, value):
    if re.search(rf"\b{key}:", text):
        return re.sub(rf"(\b{key}:\s*)([^,}}]+)", lambda m: m.group(1) + value, text, count=1)
    return text.replace("{", "{ " + key + ": " + value + ",", 1)

for target, source in SHARED.items():
    t, s_ = entry(target), entry(source)
    if not t or not s_ or field(s_, "status") != '"generated"':
        continue
    new = t
    for key in ("model", "unitWidth", "unitHeight", "footOffset", "status", "representation"):
        v = field(s_, key)
        if v is not None:
            new = set_field(new, key, v)
    if new != t:
        src = src.replace(t, new); print(f"{target}: now shares {source}'s model")
open(path, "w", encoding="utf-8").write(src)
