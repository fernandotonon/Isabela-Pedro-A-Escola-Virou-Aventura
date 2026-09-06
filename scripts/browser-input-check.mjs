// Keyboard check for the web build: load, press Space before any click, click inside the canvas, press Space
// again and hold D. With `?args=--log-input` the game prints "INPUT press <action>" for every key it received.
//   node scripts/browser-input-check.mjs "http://localhost:8080/index.html?args=--log-input" <shot dir>   (WAIT=<s> load time)
import { spawn } from "node:child_process";
import { writeFileSync } from "node:fs";
const url = process.argv[2] ?? "http://localhost:8080/index.html";
const outDir = process.argv[3] ?? ".";
const chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const port = 9334;
const proc = spawn(chrome, ["--headless=new", `--remote-debugging-port=${port}`, "--remote-allow-origins=*", "--window-size=1280,720", "--user-data-dir=/tmp/escola-input-check", "--no-first-run", "about:blank"], { stdio: "ignore" });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws, id = 0; const pending = new Map();
const send = (method, params = {}) => new Promise((res, rej) => { const m = ++id; pending.set(m, { res, rej }); ws.send(JSON.stringify({ id: m, method, params })); setTimeout(() => { if (pending.has(m)) { pending.delete(m); rej(new Error(method + " timed out")) } }, 20000) });
const key = async (k, code, keyCode, text) => {
  await send("Input.dispatchKeyEvent", { type: "keyDown", key: k, code, windowsVirtualKeyCode: keyCode, nativeVirtualKeyCode: keyCode, text });
  await sleep(120);
  await send("Input.dispatchKeyEvent", { type: "keyUp", key: k, code, windowsVirtualKeyCode: keyCode, nativeVirtualKeyCode: keyCode });
};
const shot = async (name) => { const s = await send("Page.captureScreenshot", { format: "png" }); writeFileSync(`${outDir}/${name}.png`, Buffer.from(s.data, "base64")); console.log("shot", name) };
const SHADOW = "(() => { const h = document.querySelector('#qt-shadow-container'); if (!h || !h.shadowRoot) return 'no shadow'; const r = h.shadowRoot; const els = [...r.querySelectorAll('*')].slice(0, 12).map(e => e.tagName + '.' + e.className + ' tabindex=' + e.tabIndex + (e === r.activeElement ? ' [ACTIVE]' : '')); return JSON.stringify({ hostActive: document.activeElement === h, shadowActive: r.activeElement ? (r.activeElement.tagName + '.' + r.activeElement.className) : null, els }) })()";
const evalJs = async (expr) => (await send("Runtime.evaluate", { expression: expr, returnByValue: true })).result.value;
try {
  let targets; for (let i = 0; i < 50; ++i) { try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); break } catch { await sleep(200) } }
  ws = new WebSocket(targets.find(t => t.type === "page").webSocketDebuggerUrl);
  await new Promise(r => ws.onopen = r);
  ws.onmessage = ev => { const m = JSON.parse(ev.data); if (m.id && pending.has(m.id)) { const p = pending.get(m.id); pending.delete(m.id); m.error ? p.rej(m.error) : p.res(m.result); return }
    if (m.method === "Runtime.consoleAPICalled") { const t = m.params.args.map(a => a.value ?? a.description ?? "").join(" "); if (!/Failed to load/.test(t)) console.log("console:", t.slice(0, 160)) } };
  await send("Runtime.enable"); await send("Page.enable");
  await send("Page.navigate", { url });
  await sleep(Number(process.env.WAIT || 40) * 1000);
  console.log("activeElement before:", await evalJs("document.activeElement && (document.activeElement.tagName + '#' + document.activeElement.id + ' tabindex=' + document.activeElement.tabIndex)"));
  console.log("canvas info:", await evalJs("JSON.stringify([...document.querySelectorAll('canvas, #screen, #screen > *')].map(e => e.tagName + '#' + e.id + ' class=' + e.className + ' tabindex=' + e.tabIndex))"));
  console.log("shadow before:", await evalJs(SHADOW));
  await key(" ", "Space", 32, " "); await sleep(2500); await shot("a-space-no-click");
  console.log("shadow after space:", await evalJs(SHADOW));
  await send("Input.dispatchMouseEvent", { type: "mousePressed", x: 640, y: 600, button: "left", clickCount: 1 });
  await send("Input.dispatchMouseEvent", { type: "mouseReleased", x: 640, y: 600, button: "left", clickCount: 1 });
  await sleep(300);
  console.log("activeElement after click:", await evalJs("document.activeElement && (document.activeElement.tagName + '#' + document.activeElement.id + ' tabindex=' + document.activeElement.tabIndex)"));
  console.log("shadow after click:", await evalJs(SHADOW));
  await key(" ", "Space", 32, " "); await sleep(2500); await shot("b-space-after-click");
  await send("Input.dispatchKeyEvent", { type: "keyDown", key: "d", code: "KeyD", windowsVirtualKeyCode: 68, nativeVirtualKeyCode: 68, text: "d" });
  await sleep(2000);
  await send("Input.dispatchKeyEvent", { type: "keyUp", key: "d", code: "KeyD", windowsVirtualKeyCode: 68, nativeVirtualKeyCode: 68 });
  await shot("c-after-hold-d");
} catch (e) { console.error("failed:", e) } finally { proc.kill() }
