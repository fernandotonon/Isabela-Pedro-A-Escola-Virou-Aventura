// Mobile check for the web build: emulate a phone (touch, small landscape viewport), tap "Novo jogo",
// drag on the left half (stick) while tapping the jump button, then tap Pedro's card to switch.
// With `?args=--log-input` the game prints "INPUT press <action>" for each button and the switch.
//   node scripts/browser-touch-check.mjs "http://localhost:8080/index.html?args=--log-input" <shot dir>   (WAIT=<s>)
import { spawn } from "node:child_process";
import { writeFileSync } from "node:fs";
const url = process.argv[2] ?? "http://localhost:8080/index.html?args=--log-input";
const outDir = process.argv[3] ?? ".";
const chrome = process.env.CHROME ?? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const port = 9335, W = 900, H = 420;
const proc = spawn(chrome, ["--headless=new", `--remote-debugging-port=${port}`, "--remote-allow-origins=*", `--window-size=${W},${H}`, "--user-data-dir=/tmp/escola-touch-check", "--no-first-run", "about:blank"], { stdio: "ignore" });
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws, id = 0; const pending = new Map(); const log = [];
const send = (method, params = {}) => new Promise((res, rej) => { const m = ++id; pending.set(m, { res, rej }); ws.send(JSON.stringify({ id: m, method, params })); setTimeout(() => { if (pending.has(m)) { pending.delete(m); rej(new Error(method + " timed out")) } }, 20000) });
const touch = (type, points) => send("Input.dispatchTouchEvent", { type, touchPoints: points.map((p, i) => ({ x: p.x, y: p.y, id: p.id ?? i, radiusX: 8, radiusY: 8, force: 1 })) });
const tap = async (x, y) => { await touch("touchStart", [{ x, y, id: 9 }]); await sleep(90); await touch("touchEnd", []); };
const shot = async (name) => { const s = await send("Page.captureScreenshot", { format: "png" }); writeFileSync(`${outDir}/${name}.png`, Buffer.from(s.data, "base64")); console.log("shot", name) };
try {
  let targets; for (let i = 0; i < 50; ++i) { try { targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json(); break } catch { await sleep(200) } }
  ws = new WebSocket(targets.find(t => t.type === "page").webSocketDebuggerUrl);
  await new Promise(r => ws.onopen = r);
  ws.onmessage = ev => { const m = JSON.parse(ev.data); if (m.id && pending.has(m.id)) { const p = pending.get(m.id); pending.delete(m.id); m.error ? p.rej(m.error) : p.res(m.result); return }
    if (m.method === "Runtime.consoleAPICalled") { const t = m.params.args.map(a => a.value ?? a.description ?? "").join(" "); if (!/Failed to load|AUTOTEST/.test(t)) { console.log("console:", t.slice(0, 160)); log.push(t) } } };
  await send("Runtime.enable"); await send("Page.enable");
  await send("Emulation.setDeviceMetricsOverride", { width: W, height: H, deviceScaleFactor: 2, mobile: true });
  await send("Emulation.setTouchEmulationEnabled", { enabled: true, maxTouchPoints: 5 });
  await send("Emulation.setUserAgentOverride", { userAgent: "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Mobile Safari/537.36" });
  await send("Page.navigate", { url });
  await sleep(Number(process.env.WAIT || 40) * 1000);
  await shot("m0-title");
  await tap(W / 2, H * 0.43);                 // "Novo jogo" (first menu entry)
  await sleep(3500); await shot("m1-playing");
  // stick: land on the left half and drag right while tapping jump twice
  await touch("touchStart", [{ x: 180, y: 300, id: 1 }]); await sleep(60);
  await touch("touchMove", [{ x: 260, y: 300, id: 1 }]); await sleep(900);
  await touch("touchStart", [{ x: 180 + 80, y: 300, id: 1 }, { x: W - 76, y: H - 80, id: 2 }]); await sleep(150);
  await touch("touchEnd", [{ x: 260, y: 300, id: 1 }]); await sleep(700);      // jump button up, stick stays
  await touch("touchStart", [{ x: 260, y: 300, id: 1 }, { x: W - 76, y: H - 80, id: 2 }]); await sleep(150);
  await touch("touchEnd", [{ x: 260, y: 300, id: 1 }]); await sleep(600);
  await shot("m2-stick-jump");
  await touch("touchEnd", []); await sleep(300);
  await tap(220, 40);                          // Pedro's card (second card, top-left)
  await sleep(900); await shot("m3-switched");
  const presses = log.filter(t => /INPUT press/.test(t)).length, sw = log.some(t => /INPUT press jump/.test(t));
  console.log(`button presses seen: ${presses}, jump: ${sw}`);
} catch (e) { console.error("failed:", e) } finally { proc.kill() }
