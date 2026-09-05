// Companion AI: produces an input snapshot for the character the player is NOT controlling.
// Rules (design brief): follow the leader, wait when it cannot advance, avoid basic obstacles,
// never fall on purpose, do not block passages, teleport to the last safe spot when stuck or
// far away, stay close during narrative moments.
// Pure JS over the CharacterMotion / Physics objects; tests/tst_companion.qml drives it.
.pragma library
.import "Physics.js" as Physics
.import "CharacterMotion.js" as Motion
.import "../config/tuning.js" as Tuning

function create() {
    return { stuckTime: 0, lastX: 0, waiting: false, waveTimer: 0, jumpCooldown: 0, lastTeleport: 0, holdBack: false }
}

// Returns { input, teleport: {x,y}|null, wave: bool }
function think(ai, follower, leader, world, dt, options) {
    const T = Tuning.companion
    const opts = options || {}
    const inp = Motion.emptyInput()
    const fb = follower.body, lb = leader.body
    let teleport = null
    ai.jumpCooldown = Math.max(0, ai.jumpCooldown - dt)
    ai.waveTimer = Math.max(0, ai.waveTimer - dt)

    if (follower.frozen || opts.hold) { ai.stuckTime = 0; return { input: inp, teleport: null, wave: false } }
    // hanging on a ledge: climb up
    if (follower.fsm && follower.fsm.state === "Hang") { inp.moveY = 1; return { input: inp, teleport: null, wave: false } }
    if (follower.fsm && follower.fsm.state === "Climb") { inp.moveY = 1; return { input: inp, teleport: null, wave: false } }

    const dx = lb.x - fb.x
    const dist = Math.abs(dx)
    const dir = dx >= 0 ? 1 : -1
    const dy = lb.y - fb.y

    // far away or fell: teleport next to the leader's last safe ground
    const tooFar = dist > T.teleportDistance || dy > T.fallKillOffset || fb.y < lb.y - T.fallKillOffset
    if (tooFar && leader.body.grounded && ai.lastTeleport <= 0) {
        teleport = { x: leader.lastSafe.x - leader.facing * 1.2, y: leader.lastSafe.y }
        ai.stuckTime = 0; ai.lastTeleport = 1.0
        return { input: inp, teleport: teleport, wave: false }
    }
    ai.lastTeleport = Math.max(0, ai.lastTeleport - dt)

    // in an exclusive zone the follower cannot enter: wait and wave now and then
    if (opts.blockedZone) {
        ai.waiting = true
        if (ai.waveTimer <= 0) { ai.waveTimer = 4.5; return { input: inp, teleport: null, wave: true } }
        return { input: inp, teleport: null, wave: false }
    }

    // close enough: idle, but step aside if the leader walks into us
    if (dist < T.stopDistance) {
        ai.stuckTime = 0
        if (dist < 0.7 && Math.abs(lb.vx) > 0.5 && Math.sign(lb.vx) === -dir) inp.moveX = -dir * 0.6
        return { input: inp, teleport: null, wave: false }
    }

    // follow
    const wantMove = dist > T.followDistance
    if (wantMove) {
        inp.moveX = dir * Math.min(1, (dist - T.stopDistance) / 2.5 + 0.35)
        // never run into a hazard zone the leader marked as "avoid"
        if (opts.hazardAhead && opts.hazardAhead(fb.x + dir * T.gapLookahead)) inp.moveX = 0
    }

    // a gap ahead? measure how wide; jump if the leader is beyond it and it is jumpable
    if (wantMove && fb.grounded) {
        const aheadX = fb.x + dir * (fb.w / 2 + T.gapLookahead)
        const ground = Physics.groundAt(world, aheadX, fb.y, 0.6)
        if (!ground) {
            let width = 0
            for (let s = 0.4; s <= T.jumpGapMax + 0.5; s += 0.4) {
                width = s
                if (Physics.groundAt(world, fb.x + dir * (fb.w / 2 + T.gapLookahead + s), fb.y, 2.2)) break
            }
            const leaderBeyond = dir > 0 ? lb.x > aheadX : lb.x < aheadX
            const dropBelow = Physics.groundAt(world, aheadX, fb.y, 6)  // a safe drop counts as ground
            if (dropBelow && (dropBelow.y + dropBelow.h) >= lb.y - 0.5) { /* walking down is fine */ }
            else if (width <= T.jumpGapMax && leaderBeyond && ai.jumpCooldown <= 0) { inp.jumpPressed = true; inp.jumpHeld = true; ai.jumpCooldown = 0.6 }
            else { inp.moveX = 0; ai.waiting = true }      // wait: the leader must open the way
        }
        // a step or wall ahead: jump over low walls, otherwise wait
        const wallProbe = { x: fb.x + dir * (fb.w / 2 + 0.15) - 0.05, y: fb.y + 0.12, w: 0.1, h: fb.h - 0.14 }
        for (const s of world.solids) {
            if (!s.enabled || s.kind === Physics.LADDER || s.kind === Physics.ONEWAY || s === fb.ownSolid) continue
            if (s.kind === Physics.LOW && fb.h <= s.gap) continue
            if (Physics.overlap(wallProbe, s)) {
                const top = s.y + s.h - fb.y
                if (top <= T.stepHeightMax) break
                const apex = follower.def.jumpVelocity * follower.def.jumpVelocity / (2 * -Tuning.base.gravity)
                const canJump = top <= apex - 0.15
                const canGrab = follower.def.canLedgeGrab && top <= apex + follower.def.height + 0.4
                if ((canJump || canGrab) && ai.jumpCooldown <= 0) { inp.jumpPressed = true; inp.jumpHeld = true; ai.jumpCooldown = 0.9 }
                else if (s.kind === Physics.LOW && follower.def.canCrawl) { inp.downHeld = true }
                else { inp.moveX = 0; ai.waiting = true }
                break
            }
        }
    }
    // keep holding jump for the arc, keep crawling through a passage
    if (!fb.grounded && fb.vy > 0) inp.jumpHeld = true
    if (follower.crouched) {
        const probe = { x: fb.x - fb.w / 2 - 0.3, y: fb.y + 0.05, w: fb.w + 0.6, h: follower.def.height }
        for (const s of world.solids) if (s.enabled && s.kind === Physics.LOW && Physics.overlap(probe, s)) { inp.downHeld = true; break }
    }

    // stuck detection: wants to move but does not
    if (wantMove && Math.abs(fb.x - ai.lastX) < 0.02 && !ai.waiting) ai.stuckTime += dt; else ai.stuckTime = 0
    ai.lastX = fb.x
    ai.waiting = false
    if (ai.stuckTime > T.stuckSeconds && leader.body.grounded) {
        teleport = { x: leader.lastSafe.x - leader.facing * 1.2, y: leader.lastSafe.y }
        ai.stuckTime = 0; ai.lastTeleport = 1.0
    }
    return { input: inp, teleport: teleport, wave: false }
}
