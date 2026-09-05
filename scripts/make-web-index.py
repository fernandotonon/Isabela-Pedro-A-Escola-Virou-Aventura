#!/usr/bin/env python3
"""Turn Qt's generated <app>.html into the deployable index.html.

    make-web-index.py <deploy_dir> [app_name]

* adds the coi-serviceworker.js shim (COOP/COEP for hosts that cannot set headers)
* lets the page pass program arguments to the app:  index.html?args=--autotest%20--no-models
* preloads escola-assets.json (asset files -> in-memory FS under /game/) when present
* mobile viewport, page title, a warm background while the wasm loads
"""
import os
import re
import sys

d = sys.argv[1]
app = sys.argv[2] if len(sys.argv) > 2 else "escola_aventura"
html = open(os.path.join(d, f"{app}.html"), encoding="utf-8").read()

shim = '<script src="coi-serviceworker.js"></script>\n'
if "coi-serviceworker" not in html:
    html = re.sub(r"(<head[^>]*>)", r"\1\n" + shim, html, count=1)

args_js = ("arguments: (new URLSearchParams(location.search).get('args') || '')"
           ".split(' ').filter(Boolean),\n"
           # Emscripten's preload plugins would decode every preloaded .png with browser Image
           # elements; Qt reads the raw bytes itself, and hundreds of decodes stall startup.
           "                    noImageDecoding: true,\n                    noAudioDecoding: true,\n")
if "URLSearchParams(location.search).get('args')" not in html:
    html = html.replace("qtLoad({", "qtLoad({\n                    " + args_js, 1)

if os.path.exists(os.path.join(d, "escola-assets.json")) and "escola-assets.json" not in html:
    html = html.replace("qt: {", "qt: {\n                        preload: ['escola-assets.json'],", 1)

if "viewport" not in html:
    html = re.sub(r"(<head[^>]*>)", r'\1\n<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">'
                  '\n<style>html,body{touch-action:none;overscroll-behavior:none;-webkit-user-select:none;user-select:none;background:#f3e7c9}</style>', html, count=1)

html = html.replace(f"<title>{app}</title>", "<title>Isabela & Pedro: A Escola Virou Aventura</title>")
open(os.path.join(d, "index.html"), "w", encoding="utf-8").write(html)
print(f"wrote {os.path.join(d, 'index.html')}")
