#!/usr/bin/env node
// Collectible reachability check (no Qt needed): builds the level's static solids, then explores where
// Isabela and Pedro can stand by simulating real jumps/walks/crawls with CharacterMotion + Physics from
// every reachable standing spot (a BFS over spots). Gates count as open, pushables sit where they start,
// moving platforms are sampled along their path, hidden platforms count as revealed. Prints every
// star/pencil/memory that no simulated move touches.
//   node scripts/check-reachability.mjs [--verbose]
import { loadQmlJs } from "../tests/qmljs-shim.mjs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const app = join(here, "..", "app");
const Physics = loadQmlJs(join(app, "scripts/Physics.js"));
const Motion = loadQmlJs(join(app, "scripts/CharacterMotion.js"));
const Tuning = loadQmlJs(join(app, "config/tuning.js"));
const Level = loadQmlJs(join(app, "config/level.js"));
const verbose = process.argv.includes("--verbose");
const dt = 1 / 60, STEP = 0.5;

// ---- world -----------------------------------------------------------------------------------------
const world = Physics.makeWorld(Tuning.base.gravity);
const solids = [], collectibles = [];
for (const s of Level.level.sections) for (const e of s.entities) {
  switch (e.type) {
    case "ground": case "platform": case "wall": case "lowpass": case "ladder": {
      let kind = Physics.SOLID;
      if (e.type === "lowpass") kind = Physics.LOW; else if (e.type === "ladder") kind = Physics.LADDER; else if (e.oneway) kind = Physics.ONEWAY;
      solids.push(Physics.addSolid(world, { x: e.x, y: e.y, w: e.w, h: e.h, kind, gap: e.gap || 0.8, id: e.id || (e.type + "@" + e.x), tag: e.type }));
      break;
    }
    case "moving": {
      if (process.argv.includes("--strict")) break;
      const n = 4;
      for (let i = 0; i <= n; ++i) { const a = e.path[0], b = e.path[e.path.length - 1]; const u = i / n;
        solids.push(Physics.addSolid(world, { x: a.x + (b.x - a.x) * u, y: a.y + (b.y - a.y) * u, w: e.w, h: e.h, kind: Physics.SOLID, id: e.id + "#" + i, tag: "moving" })); }
      break;
    }
    case "pushable": if (process.argv.includes("--strict")) break; solids.push(Physics.addSolid(world, { x: e.x - e.w / 2, y: e.y, w: e.w, h: e.h, kind: Physics.SOLID, id: e.id, tag: "pushable" })); break;
    case "star": case "pencil": case "memory": {
      const size = e.type === "star" ? 0.55 : 0.75;
      collectibles.push({ type: e.type, x: e.x, y: e.y, section: s.id, sensor: { x: e.x - size / 2, y: e.y, w: size, h: size }, reached: null });
      break;
    }
  }
}

// ---- standing spots: sampled along every top surface where a body fits -----------------------------
function fits(def, x, y, crouch) {
  const h = crouch ? def.crouchHeight : def.height, w = def.width;
  const box = { x: x - w / 2, y: y + 0.02, w, h: h - 0.04 };
  for (const s of solids) {
    if (s.kind === Physics.LADDER) continue;
    if (s.kind === Physics.LOW && crouch && box.y + box.h <= s.y + s.gap + 0.01) continue;
    if (s.kind === Physics.ONEWAY) continue;
    if (Physics.overlap(box, s)) return false;
  }
  return true;
}
const chars = { isabela: Tuning.characters.isabela, pedro: Tuning.characters.pedro };
const spotKey = (x, y) => Math.round(x / 0.25) + "," + Math.round(y / 0.25);

// One simulated move from a standing position; returns the landing spot (or null) and marks collectibles touched.
function simulate(def, x, y, input, seconds) {
  const c = Motion.create(world, def, x, y);
  for (let i = 0; i < 4; ++i) { Motion.setInput(c, Motion.emptyInput()); Motion.update(c, dt); }
  if (!c.body.grounded) return null;
  let left = false, landing = null;
  const n = Math.round(seconds / dt);
  for (let i = 0; i < n; ++i) {
    const inp = Motion.emptyInput();
    inp.moveX = input.moveX; inp.moveY = input.moveY || 0; inp.downHeld = !!input.down;
    inp.jumpPressed = i === 0 && input.hold > 0; inp.jumpHeld = i * dt < input.hold;
    Motion.setInput(c, inp); Motion.update(c, dt);
    const b = c.body;
    for (const col of collectibles) if (!col.reached && Math.abs(col.x - b.x) < 3 && Physics.overlap(Physics.box(b), col.sensor)) col.reached = def.id + " from (" + x.toFixed(1) + "," + y.toFixed(1) + ")";
    if (b.y < Tuning.level.killY) return null;
    if (!b.grounded) left = true;
    else if (left && i > 6) { landing = { x: b.x, y: b.y }; break; }
    if (Motion.is(c, "Idle") && i > 30 && !left && !input.down) { landing = { x: b.x, y: b.y }; break; }
    if (i === n - 1 && b.grounded) landing = { x: b.x, y: b.y };
  }
  return landing;
}

const moves = [];
for (const dir of [-1, 1]) {
  moves.push({ moveX: dir, hold: 0, seconds: 1.6 });                          // walk (and fall off edges)
  moves.push({ moveX: dir * 0.5, hold: 0, seconds: 1.0 });
  for (const hold of [0.06, 0.18, 0.32, 0.5]) for (const mx of [0.35, 1]) moves.push({ moveX: dir * mx, hold, seconds: 2.2, moveY: 1 });
  moves.push({ moveX: dir, hold: 0, down: true, seconds: 2.0 });              // crawl (Pedro)
}
moves.push({ moveX: 0, hold: 0.5, seconds: 1.6, moveY: 1 });                  // straight up
moves.push({ moveX: 0, hold: 0, moveY: 1, seconds: 2.5 });                    // climb a ladder

// Isabela explores first; Pedro starts from every spot she reached (the player switches siblings and the
// companion teleports to the leader's safe spot, so wherever one stands the other can stand too).
const reachable = {}; let expansions = 0; let carried = [];
for (const id of ["isabela", "pedro"]) {
  const def = Object.assign({ id }, chars[id]);
  const seen = new Set(); const queue = [{ x: Level.level.start.x, y: Level.level.start.y }, ...carried];
  for (const q of queue) seen.add(spotKey(q.x, q.y));
  const visited = [];
  while (queue.length) {
    const p = queue.shift(); expansions++; visited.push(p);
    for (const m of moves) {
      if (m.down && !def.canCrawl) continue;
      const land = simulate(def, p.x, p.y, m, m.seconds);
      if (!land) continue;
      const k = spotKey(land.x, land.y);
      if (!seen.has(k)) { seen.add(k); queue.push(land); }
    }
  }
  reachable[id] = seen.size; carried = visited;
}

const missing = collectibles.filter(c => !c.reached);
console.log(`explored ${expansions} standing spots (isabela ${reachable.isabela}, pedro ${reachable.pedro}); collectibles ${collectibles.length}, reached ${collectibles.length - missing.length}`);
for (const c of missing) {
  const near = solids.filter(s => Math.abs(s.x + s.w / 2 - c.x) < 4 && s.y < c.y + 1 && s.y + s.h > c.y - 4).map(s => `${s.tag}@${s.x},${s.y} ${s.w}x${s.h}`);
  console.log(`UNREACHED ${c.type} ${c.section} (${c.x}, ${c.y}) near: ${near.join(" | ")}`);
}
// collectibles whose sensor sits inside a solid look trapped even when a body can touch them
for (const c of collectibles) {
  const inside = solids.filter(s => s.kind !== Physics.LADDER && Physics.overlap(c.sensor, s)).map(s => `${s.tag}@${s.x},${s.y} ${s.w}x${s.h}` + (s.kind === Physics.LOW ? " (low passage)" : ""));
  if (inside.length) console.log(`EMBEDDED ${c.type} ${c.section} (${c.x}, ${c.y}) inside: ${inside.join(" | ")}`);
}
if (verbose) for (const c of collectibles.filter(c => c.reached)) console.log(`ok ${c.type} ${c.section} (${c.x}, ${c.y}) <- ${c.reached}`);
process.exit(missing.length ? 1 : 0);
