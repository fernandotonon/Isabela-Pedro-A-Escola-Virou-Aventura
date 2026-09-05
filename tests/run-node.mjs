#!/usr/bin/env node
// Headless checks of the pure-JS game systems (no Qt needed):  node tests/run-node.mjs
// The same behaviours are covered by the QML TestCase suites under ctest; this is the fast loop.
import { loadQmlJs } from "./qmljs-shim.mjs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const app = join(here, "..", "app");
const Physics = loadQmlJs(join(app, "scripts/Physics.js"));
const Motion = loadQmlJs(join(app, "scripts/CharacterMotion.js"));
const Companion = loadQmlJs(join(app, "scripts/CompanionAI.js"));
const Courage = loadQmlJs(join(app, "scripts/Courage.js"));
const Tuning = loadQmlJs(join(app, "config/tuning.js"));
const Level = loadQmlJs(join(app, "config/level.js"));
const LevelCheck = loadQmlJs(join(app, "scripts/LevelCheck.js"));
const Strings = loadQmlJs(join(app, "config/strings.js"));
const Assets = loadQmlJs(join(app, "config/assets.js"));

let failures = 0, passes = 0;
function check(cond, msg) { if (cond) passes++; else { failures++; console.log("  FAIL:", msg); } }
function test(name, fn) { console.log("-", name); try { fn(); } catch (e) { failures++; console.log("  EXCEPTION:", e.stack || e); } }
const DT = 1 / 60;

function flatWorld() {
  const w = Physics.makeWorld();
  Physics.addSolid(w, { x: -50, y: -1, w: 200, h: 1, id: "floor" });
  return w;
}
function run(c, frames, input) {
  for (let i = 0; i < frames; ++i) { Motion.setInput(c, Object.assign(Motion.emptyInput(), typeof input === "function" ? input(i) : input)); Motion.update(c, DT); }
}

test("physics: body lands on the floor and stays grounded", () => {
  const w = flatWorld(); const b = Physics.makeBody(0, 3, 0.6, 1.5);
  for (let i = 0; i < 120; ++i) { b.vy = Math.max(-20, b.vy - 30 * DT); Physics.step(w, b, 0, b.vy * DT); }
  check(b.grounded && Math.abs(b.y) < 0.01, `grounded=${b.grounded} y=${b.y}`);
});

test("physics: walls stop horizontal motion, one-way lets you jump through from below", () => {
  const w = flatWorld(); Physics.addSolid(w, { x: 3, y: 0, w: 1, h: 2, id: "wall" });
  const b = Physics.makeBody(2, 0, 0.6, 1.5); Physics.step(w, b, 2, 0);
  check(b.hitWall === 1 && b.x <= 3 - 0.3 + 0.01, `x=${b.x} hitWall=${b.hitWall}`);
  Physics.addSolid(w, { x: -2, y: 2, w: 2, h: 0.2, kind: Physics.ONEWAY, id: "shelf" });
  const j = Physics.makeBody(-1, 0, 0.6, 1.5); j.vy = 12;
  let passedThrough = false, landed = false;
  for (let i = 0; i < 200; ++i) { j.vy = Math.max(-20, j.vy - 30 * DT); Physics.step(w, j, 0, j.vy * DT); if (j.y > 2.2) passedThrough = true; if (j.grounded && j.ground && j.ground.id === "shelf") landed = true; }
  check(passedThrough && landed, `passed=${passedThrough} landed=${landed} y=${j.y}`);
});

test("physics: low passage blocks tall bodies and lets short ones through", () => {
  const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 3, h: 2, kind: Physics.LOW, gap: 0.8, id: "gap" });
  const tall = Physics.makeBody(1, 0, 0.6, 1.5); Physics.step(w, tall, 1.5, 0);
  const small = Physics.makeBody(1, 0, 0.5, 0.62); Physics.step(w, small, 1.5, 0);
  check(tall.hitWall === 1 && small.hitWall === 0 && small.x > 2, `tall.x=${tall.x} small.x=${small.x}`);
});

test("motion: Isabela jumps ~2.5 m, Pedro lower; coyote time and jump buffer work", () => {
  const w = flatWorld();
  const isa = Motion.create(w, Tuning.characters.isabela, 0, 0), ped = Motion.create(w, Tuning.characters.pedro, 3, 0);
  run(isa, 5, {}); run(ped, 5, {});
  let maxI = 0, maxP = 0;
  run(isa, 90, i => ({ jumpPressed: i === 0, jumpHeld: i < 40 })); // measured via body.y per frame below
  // re-run measuring apex
  Motion.teleport(isa, 0, 0); Motion.teleport(ped, 3, 0); run(isa, 5, {}); run(ped, 5, {});
  for (let i = 0; i < 90; ++i) {
    Motion.setInput(isa, Object.assign(Motion.emptyInput(), { jumpPressed: i === 0, jumpHeld: i < 40 })); Motion.update(isa, DT); maxI = Math.max(maxI, isa.body.y);
    Motion.setInput(ped, Object.assign(Motion.emptyInput(), { jumpPressed: i === 0, jumpHeld: i < 40 })); Motion.update(ped, DT); maxP = Math.max(maxP, ped.body.y);
  }
  check(maxI > 2.2 && maxI < 2.9, `isabela apex ${maxI.toFixed(2)}`);
  check(maxP > 1.4 && maxP < 1.9 && maxP < maxI, `pedro apex ${maxP.toFixed(2)}`);
  // variable height: short tap
  let maxShort = 0; Motion.teleport(isa, 0, 0); run(isa, 5, {});
  for (let i = 0; i < 90; ++i) { Motion.setInput(isa, Object.assign(Motion.emptyInput(), { jumpPressed: i === 0, jumpHeld: i < 5 })); Motion.update(isa, DT); maxShort = Math.max(maxShort, isa.body.y); }
  check(maxShort < maxI - 0.5, `short hop ${maxShort.toFixed(2)} vs full ${maxI.toFixed(2)}`);
  // coyote: walk off a ledge and press jump 4 frames later
  const w2 = Physics.makeWorld(); Physics.addSolid(w2, { x: -5, y: -1, w: 5, h: 1 });
  const c = Motion.create(w2, Tuning.characters.pedro, -0.5, 0); run(c, 3, {});
  let jumped = false;
  for (let i = 0; i < 60; ++i) { const off = !c.body.grounded; Motion.setInput(c, Object.assign(Motion.emptyInput(), { moveX: 1, jumpPressed: off && i > 0 && !jumped && c.coyote > 0 && c.coyote < Tuning.base.coyoteTime - 0.03 })); if (c.input.jumpPressed) jumped = true; Motion.update(c, DT); if (c.events.some(e => e.name === "jump")) { check(true, ""); return; } }
  check(false, "coyote jump never fired");
});

test("motion: jump buffer fires the jump on landing", () => {
  const w = flatWorld(); const c = Motion.create(w, Tuning.characters.isabela, 0, 0.2);
  let jumps = 0;
  for (let i = 0; i < 120; ++i) { Motion.setInput(c, Object.assign(Motion.emptyInput(), { jumpPressed: i === 2 })); Motion.update(c, DT); jumps += c.events.filter(e => e.name === "jump").length; }
  check(jumps === 1, `jumps=${jumps}`);
});

test("motion: Isabela grabs a ledge and climbs up; Pedro cannot", () => {
  const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 3, h: 2.4, id: "block" });
  const isa = Motion.create(w, Tuning.characters.isabela, 0.6, 0); run(isa, 3, {});
  let hung = false;
  for (let i = 0; i < 120; ++i) { Motion.setInput(isa, Object.assign(Motion.emptyInput(), { moveX: 1, jumpPressed: i === 0, jumpHeld: i < 30 })); Motion.update(isa, DT); if (Motion.is(isa, "Hang")) { hung = true; break; } }
  check(hung, "isabela hung on the ledge");
  for (let i = 0; i < 60 && !Motion.is(isa, "Idle"); ++i) { Motion.setInput(isa, Object.assign(Motion.emptyInput(), { moveY: 1 })); Motion.update(isa, DT); }
  check(Motion.is(isa, "Idle") && isa.body.y > 2.3 && isa.body.x > 2, `after climb state=${isa.fsm.state} x=${isa.body.x.toFixed(2)} y=${isa.body.y.toFixed(2)}`);
  const ped = Motion.create(w, Tuning.characters.pedro, 0.6, 0); run(ped, 3, {});
  let pedHung = false;
  for (let i = 0; i < 120; ++i) { Motion.setInput(ped, Object.assign(Motion.emptyInput(), { moveX: 1, jumpPressed: i === 0, jumpHeld: i < 30 })); Motion.update(ped, DT); if (Motion.is(ped, "Hang")) pedHung = true; }
  check(!pedHung && ped.body.y < 0.1, `pedro hung=${pedHung} y=${ped.body.y.toFixed(2)}`);
});

test("motion: Pedro crawls through a low passage, Isabela is blocked", () => {
  const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 3, h: 2, kind: Physics.LOW, gap: 0.8, id: "tunnel" });
  const ped = Motion.create(w, Tuning.characters.pedro, 0.5, 0); run(ped, 200, { moveX: 1, downHeld: true });
  check(ped.body.x > 5.2, `pedro x=${ped.body.x.toFixed(2)} state=${ped.fsm.state}`);
  const isa = Motion.create(w, Tuning.characters.isabela, 0.5, 0); run(isa, 200, { moveX: 1, downHeld: true });
  check(isa.body.x < 2, `isabela x=${isa.body.x.toFixed(2)}`);
});

test("motion: ladder climb", () => {
  const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 0.8, h: 4, kind: Physics.LADDER, id: "ladder" }); Physics.addSolid(w, { x: 2.8, y: 3.8, w: 3, h: 0.2, id: "top" });
  const c = Motion.create(w, Tuning.characters.pedro, 2.4, 0); run(c, 3, {});
  run(c, 240, { moveY: 1, moveX: 0.3 });
  check(c.body.y > 3.5, `y=${c.body.y.toFixed(2)} state=${c.fsm.state}`);
});

test("courage: hurt, invulnerability, depletion and refill", () => {
  const w = flatWorld(); const isa = Motion.create(w, Tuning.characters.isabela, 0, 0); const ped = Motion.create(w, Tuning.characters.pedro, 2, 0);
  const st = Courage.create([isa, ped]); run(isa, 3, {});
  check(Courage.touch(st, isa, 1) === "hurt" && isa.courage === 2, "first touch hurts");
  check(Courage.touch(st, isa, 1) === "ignored", "invulnerable right after");
  run(isa, 120, {}); check(Courage.touch(st, isa, 1) === "hurt" && isa.courage === 1, "second touch");
  run(isa, 120, {}); check(Courage.touch(st, isa, 1) === "depleted" && st.depleted, "third touch depletes");
  Courage.refill(st); check(isa.courage === 3 && !st.depleted, "refill");
  check(Courage.encourage(st, ped, 1) === 0 && Courage.encourage(st, isa, 1) === 0, "full courage gains nothing");
  isa.courage = 1; check(Courage.encourage(st, isa, 1) === 1 && isa.courage === 2, "star restores one");
});

test("companion: follows the leader, waits at wide gaps, teleports when far", () => {
  const w = Physics.makeWorld(); Physics.addSolid(w, { x: -5, y: -1, w: 15, h: 1 }); Physics.addSolid(w, { x: 12, y: -1, w: 10, h: 1 });
  const lead = Motion.create(w, Tuning.characters.isabela, 6, 0), fol = Motion.create(w, Tuning.characters.pedro, 0, 0);
  const ai = Companion.create(); run(lead, 3, {}); run(fol, 3, {});
  for (let i = 0; i < 240; ++i) { Motion.setInput(lead, Motion.emptyInput()); Motion.update(lead, DT); const r = Companion.think(ai, fol, lead, w, DT, {}); Motion.setInput(fol, r.input); Motion.update(fol, DT); }
  check(Math.abs(lead.body.x - fol.body.x) < Tuning.companion.followDistance + 0.3, `follow gap=${(lead.body.x - fol.body.x).toFixed(2)}`);
  // leader across a 2 m gap (jumpable): follower should jump over
  Motion.teleport(lead, 14, 0); Motion.teleport(fol, 8, 0); run(lead, 3, {}); run(fol, 3, {});
  let fell = false;
  for (let i = 0; i < 400; ++i) { Motion.setInput(lead, Motion.emptyInput()); Motion.update(lead, DT); const r = Companion.think(ai, fol, lead, w, DT, {}); if (r.teleport) Motion.teleport(fol, r.teleport.x, r.teleport.y); Motion.setInput(fol, r.input); Motion.update(fol, DT); if (fol.body.y < -3) fell = true; }
  check(!fell && fol.body.x > 12, `crossed gap: x=${fol.body.x.toFixed(2)} fell=${fell}`);
  // far away -> teleport
  Motion.teleport(lead, 60, 0); lead.lastSafe = { x: 18, y: 0 }; lead.body.grounded = true;
  const r = Companion.think(ai, fol, lead, w, DT, {});
  check(r.teleport && Math.abs(r.teleport.x - 18) < 2, `teleport=${JSON.stringify(r.teleport)}`);
});

test("level: data is consistent (counts, references, section order)", () => {
  const report = LevelCheck.validate(Level.level);
  for (const e of report.errors) console.log("  level error:", e);
  check(report.errors.length === 0, `${report.errors.length} level errors`);
  check(report.stars === 40, `stars=${report.stars}`);
  check(report.pencils === 6, `pencils=${report.pencils}`);
  check(report.memories === 1, `memories=${report.memories}`);
  check(report.checkpoints === 4, `checkpoints=${report.checkpoints}`);
  check(report.sections === 6, `sections=${report.sections}`);
});

test("strings: every pt-BR key has an English fallback and tr() resolves", () => {
  const missing = Object.keys(Strings.pt_BR).filter(k => !(k in Strings.en));
  check(missing.length === 0, `missing en: ${missing.join(", ")}`);
  check(Strings.tr("menu.newGame", "pt_BR").length > 0 && Strings.tr("does.not.exist", "pt_BR") === "does.not.exist", "tr fallback");
});

test("assets: every level asset id resolves in the manifest", () => {
  const ids = LevelCheck.assetIds(Level.level);
  const unknown = ids.filter(id => !Assets.get(id));
  check(unknown.length === 0, `unknown asset ids: ${unknown.join(", ")}`);
});

console.log(`\n${passes} checks passed, ${failures} failed`);
process.exit(failures ? 1 : 0);
