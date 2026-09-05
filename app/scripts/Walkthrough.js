// Scripted walkthrough runner (--walkthrough): drives the real game with high-level steps so the
// route from the square to the classroom door can be verified headless. Each step produces the
// input snapshot for the active sibling every fixed step until it completes or times out.
//
// Steps (config/walkthrough.js):
//   { do: "switch", to: "pedro" }                 switch the controlled sibling
//   { do: "move", x: 47 }                         walk towards x until within 0.3 m and grounded
//   { do: "jump", x: 24.2, dir: 1, hold: 0.35 }   walk to x, jump, keep holding dir for `hold` s, done on landing
//   { do: "crawl", x: 51 }                        walk with down held (Pedro crawls) until x
//   { do: "climb", seconds: 2 }                   hold up (ladder / ledge climb)
//   { do: "hold", moveX: 1, seconds: 1 }          hold a direction for a while
//   { do: "interact" } | { do: "ability" }        one press
//   { do: "wait", seconds: 1 }
//   { do: "expect", gateOpen: "id" } | { switchOn: "id" } | { xMin: 100 } | { stars: 3 } | { finished: true }
.pragma library
.import "CharacterMotion.js" as Motion

function create(steps) {
    return { steps: steps, index: 0, time: 0, phase: 0, failures: [], log: [], done: false, jumped: false, timeout: 14 }
}

function current(w) { return w.steps[w.index] }

function finish(w, ok, msg) {
    const s = current(w)
    w.log.push((ok ? "ok   " : "FAIL ") + w.index + " " + JSON.stringify(s) + (msg ? " - " + msg : ""))
    if (!ok) w.failures.push(w.index + ": " + JSON.stringify(s) + " " + (msg || ""))
    w.index++; w.time = 0; w.phase = 0; w.jumped = false
    if (w.index >= w.steps.length) w.done = true
}

// Returns { input, switchTo, interact, ability } for this fixed step.
function tick(w, game, dt) {
    const out = { input: Motion.emptyInput(), switchTo: null, interact: false, ability: false }
    if (w.done) return out
    const s = current(w)
    w.time += dt
    if (w.time > (s.timeout || w.timeout) && s.do !== "wait") { finish(w, false, "timeout at x=" + game.activeX().toFixed(2) + " y=" + game.activeY().toFixed(2) + " state=" + game.activeState() + " blockers=" + game.describeBlockers()); return out }
    const x = game.activeX(), grounded = game.activeGrounded()
    switch (s.do) {
    case "switch":
        if (game.activeId() === s.to) { finish(w, true); break }
        out.switchTo = s.to
        if (w.time > 4) finish(w, false, "could not switch (companion not safe? state=" + game.companionState() + " x=" + game.companionX().toFixed(1) + ")")
        break
    case "move": {
        const dx = s.x - x
        if (Math.abs(dx) < 0.3 && grounded) { finish(w, true); break }
        if (game.activeState() === "Hang") { out.input.moveY = s.dropFromLedge ? 0 : 1; out.input.downHeld = !!s.dropFromLedge; break }
        out.input.moveX = Math.abs(dx) < 1.2 ? Math.sign(dx) * 0.45 : Math.sign(dx)
        if (s.down) out.input.downHeld = true
        break
    }
    case "crawl": {
        const dx = s.x - x
        out.input.downHeld = true
        if (Math.abs(dx) < 0.3) { finish(w, true); break }
        out.input.moveX = Math.abs(dx) < 1.2 ? Math.sign(dx) * 0.5 : Math.sign(dx)
        break
    }
    case "jump": {
        const dir = s.dir === undefined ? Math.sign((s.x || x) - x) || 1 : s.dir
        if (w.phase === 0) {                       // walk to the take-off point
            const dx = (s.x === undefined ? x : s.x) - x
            if (Math.abs(dx) < 0.25) { w.phase = 1; w.time = 0 } else out.input.moveX = Math.abs(dx) < 1.0 ? Math.sign(dx) * 0.45 : Math.sign(dx)
        } else if (w.phase === 1) {                // press jump (with a running start if asked)
            out.input.moveX = s.run ? dir : (s.stand ? 0 : dir * 0.9)
            out.input.jumpPressed = true; out.input.jumpHeld = true; w.phase = 2; w.time = 0; w.jumped = true
        } else {                                   // in the air: hold direction / jump for `hold`
            const hold = s.hold === undefined ? 0.3 : s.hold
            out.input.jumpHeld = w.time < hold
            if (s.up) out.input.moveY = 1
            out.input.moveX = w.time < (s.air === undefined ? 1.2 : s.air) ? dir * (s.airMove === undefined ? 1 : s.airMove) : 0
            if (s.grab && game.activeState() === "Hang") { finish(w, true); break }
            if (w.time > 0.15 && grounded) finish(w, true, "landed at x=" + x.toFixed(2) + " y=" + game.activeY().toFixed(2))
        }
        break
    }
    case "climb":
        out.input.moveY = 1
        if (s.moveX) out.input.moveX = s.moveX
        if (w.time >= (s.seconds || 1.5)) finish(w, true)
        break
    case "hold":
        out.input.moveX = s.moveX || 0; out.input.moveY = s.moveY || 0; out.input.downHeld = !!s.down; out.input.jumpHeld = !!s.jump
        if (w.time >= (s.seconds || 1)) finish(w, true)
        break
    case "interact":
        if (w.phase === 0) { out.interact = true; w.phase = 1 } else if (w.time > 0.3) finish(w, true)
        break
    case "ability":
        if (w.phase === 0) { out.ability = true; w.phase = 1 } else if (w.time > 0.5) finish(w, true)
        break
    case "wait":
        if (w.time >= (s.seconds || 1)) finish(w, true)
        break
    case "expect": {
        const r = game.check(s)
        if (r === true) finish(w, true)
        else if (w.time > (s.timeout || 3)) finish(w, false, r)
        break
    }
    default:
        finish(w, false, "unknown step")
    }
    return out
}
