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
    html = re.sub(r"(<head[^>]*>)", r'\1\n<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">', html, count=1)
if "touch-action:none" not in html:   # phones: no pinch-zoom, pull-to-refresh or text selection over the game
    html = re.sub(r"(<head[^>]*>)", r'\1\n<style>html,body{touch-action:none;overscroll-behavior:none;-webkit-user-select:none;user-select:none;-webkit-touch-callout:none;background:#f3e7c9}</style>', html, count=1)

# Keyboard focus guard. Qt for WebAssembly keeps its key listeners on a focus-helper element inside
# the shadow DOM; a click inside the canvas can drop the DOM focus to <body> (Qt prevents the default
# pointer behaviour), after which the game receives no key events. Put the focus back whenever it is lost.
focus_js = """
        // keep keyboard focus on Qt's focus helper (a click inside the canvas can drop it to <body>)
        const qtKeyboardFocus = () => {
            const host = document.querySelector('#qt-shadow-container');
            if (!host) return;
            const helper = host.shadowRoot && host.shadowRoot.querySelector('.qt-window-focus-helper');
            if (document.activeElement !== host) (helper || host).focus({ preventScroll: true });
        };
        ['pointerup', 'mouseup', 'touchend'].forEach(t => document.addEventListener(t, () => setTimeout(qtKeyboardFocus, 0), true));
        document.addEventListener('focusout', (e) => { if (!e.relatedTarget) setTimeout(qtKeyboardFocus, 0); }, true);
        window.addEventListener('keydown', () => { if (document.activeElement === document.body) qtKeyboardFocus(); }, true);
        window.addEventListener('focus', () => setTimeout(qtKeyboardFocus, 0));
"""
if "qtKeyboardFocus" not in html:
    html = html.replace("        async function init()", focus_js + "        async function init()", 1)
    html = html.replace("onLoaded: () => showUi(screen),", "onLoaded: () => { showUi(screen); setTimeout(qtKeyboardFocus, 0); },", 1)

html = html.replace(f"<title>{app}</title>", "<title>Isabela & Pedro: A Escola Virou Aventura</title>")
open(os.path.join(d, "index.html"), "w", encoding="utf-8").write(html)
print(f"wrote {os.path.join(d, 'index.html')}")
