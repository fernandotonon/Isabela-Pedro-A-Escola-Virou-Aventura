// Side-plane kinematics for the platformer: axis-aligned boxes on the X/Y plane (Z is visual
// depth only). Qt Quick 3D Physics is not used - it crashes in WebAssembly and a platformer
// wants deterministic, tunable collision anyway (coyote time, one-way platforms, crawl gaps).
//
// Coordinates: metres, +X right, +Y up. A body's (x, y) is its bottom centre; a solid's (x, y)
// is its bottom-left corner. Pure JS, no Qt: tests/tst_physics.qml exercises it directly.
.pragma library

var SOLID = "solid"     // blocks everything
var ONEWAY = "oneway"   // blocks only bodies landing on it from above
var LOW = "low"         // a passage: blocks bodies taller than `gap` (Pedro crawls through)
var LADDER = "ladder"   // never blocks; a body overlapping it may climb
var EPS = 0.001

function makeWorld(gravity) {
    return { solids: [], nextId: 1, gravity: gravity !== undefined ? gravity : -30 }
}

function addSolid(world, s) {
    if (!s.id) s.id = "s" + (world.nextId++)
    if (s.kind === undefined) s.kind = SOLID
    if (s.enabled === undefined) s.enabled = true
    if (s.gap === undefined) s.gap = 0.8
    s.dx = 0; s.dy = 0                       // per-step motion of moving solids (carry)
    world.solids.push(s)
    return s
}

function removeSolid(world, s) {
    const i = world.solids.indexOf(s)
    if (i >= 0) world.solids.splice(i, 1)
}

function findSolid(world, id) {
    for (const s of world.solids) if (s.id === id) return s
    return null
}

function makeBody(x, y, w, h) {
    return { x: x, y: y, w: w, h: h, vx: 0, vy: 0, grounded: false, ground: null,
             hitWall: 0, hitCeiling: false, ownSolid: null, stepHeight: 0, mantleHeight: 0 }
}

function box(b) { return { x: b.x - b.w / 2, y: b.y, w: b.w, h: b.h } }

function overlap(a, b) {
    return a.x < b.x + b.w - EPS && a.x + a.w > b.x + EPS && a.y < b.y + b.h - EPS && a.y + a.h > b.y + EPS
}

// Does `solid` stop `body` moving in direction dirY (-1 down, +1 up, 0 horizontal)?
function blocks(solid, body, dirY, prevBottom) {
    if (!solid.enabled || solid === body.ownSolid) return false
    if (solid.kind === SOLID) return true
    if (solid.kind === LOW) return body.h > solid.gap + EPS
    if (solid.kind === ONEWAY) return dirY < 0 && prevBottom >= solid.y + solid.h - 0.06
    return false
}

// Move a body by (dx, dy) resolving against the world's solids. Sets grounded/ground/hitWall/
// hitCeiling. Horizontal first, then vertical - the classic order for platformers.
function step(world, body, dx, dy) {
    body.hitWall = 0
    body.hitCeiling = false
    const prevBottom = body.y
    if (dx !== 0) {
        const bx = box(body); bx.x += dx
        const wasGrounded = body.grounded
        for (const s of world.solids) {
            if (s.kind === ONEWAY || !blocks(s, body, 0, prevBottom)) continue
            if (overlap(bx, s)) {
                // a low step (kerb, stair) is walked up instead of blocking
                const stepTop = s.y + s.h
                // ...and a body in the air that has almost cleared an edge mantles onto it (ledge forgiveness)
                const mantle = !wasGrounded && body.vy < 3 && body.mantleHeight > 0 && stepTop - body.y <= body.mantleHeight
                if (body.stepHeight > 0 && stepTop > body.y && ((wasGrounded && stepTop - body.y <= body.stepHeight + EPS) || mantle)) {
                    const lifted = { x: bx.x, y: stepTop + EPS, w: bx.w, h: bx.h }
                    let free = true
                    for (const o of world.solids) { if (o === s || o.kind === ONEWAY || !blocks(o, body, 0, prevBottom)) continue; if (overlap(lifted, o)) { free = false; break } }
                    if (free) { bx.y = lifted.y; body.y = lifted.y; continue }
                }
                if (dx > 0) { bx.x = s.x - bx.w - EPS; body.hitWall = 1 } else { bx.x = s.x + s.w + EPS; body.hitWall = -1 }
                // walking into a wall stops you; in the air the speed is kept so a jump from right next
                // to a ledge still carries over its edge once the body clears the top
                if (wasGrounded) body.vx = 0
            }
        }
        body.x = bx.x + bx.w / 2
    }
    body.grounded = false
    body.ground = null
    if (dy !== 0) {
        const by = box(body); by.y += dy
        for (const s of world.solids) {
            if (!blocks(s, body, dy < 0 ? -1 : 1, prevBottom)) continue
            if (overlap(by, s)) {
                if (dy < 0) { by.y = s.y + s.h; body.grounded = true; body.ground = s; body.vy = 0 }
                else { by.y = s.y - by.h - EPS; body.hitCeiling = true; body.vy = Math.min(body.vy, 0) }
            }
        }
        body.y = by.y
    }
    if (!body.grounded) {
        const g = groundBelow(world, body, 0.04)
        if (g) { body.grounded = true; body.ground = g; body.y = g.y + g.h; if (body.vy < 0) body.vy = 0 }
    }
}

// The solid directly under the body within `reach` metres, or null.
function groundBelow(world, body, reach) {
    const probe = { x: body.x - body.w / 2 + 0.02, y: body.y - reach, w: body.w - 0.04, h: reach + 0.02 }
    let best = null
    for (const s of world.solids) {
        if (!blocks(s, body, -1, body.y + 0.05)) continue
        if (overlap(probe, s) && s.y + s.h <= body.y + 0.05) {
            if (!best || s.y + s.h > best.y + best.h) best = s
        }
    }
    return best
}

// Free vertical space for a body of height `h` at the body's position (crouch -> stand check).
function fits(world, body, h) {
    const test = { x: body.x - body.w / 2 + 0.01, y: body.y + 0.02, w: body.w - 0.02, h: h - 0.02 }
    const probe = { h: h }
    for (const s of world.solids) {
        if (s.kind === ONEWAY || !blocks(s, probe, 1, body.y)) continue
        if (overlap(test, s)) return false
    }
    return true
}

// Is there ground somewhere below x within `depth` metres? (companion AI, gap detection)
function groundAt(world, x, yTop, depth) {
    let best = null
    for (const s of world.solids) {
        if (!s.enabled || s.kind === LADDER) continue
        if (s.kind === LOW) continue
        if (x >= s.x && x <= s.x + s.w) {
            const top = s.y + s.h
            if (top <= yTop + 0.05 && top >= yTop - depth) {
                if (!best || top > best.y + best.h) best = s
            }
        }
    }
    return best
}

// Zones (ladders, triggers) the body overlaps, filtered by kind.
function overlapping(world, body, kind) {
    const bx = box(body); const out = []
    for (const s of world.solids) if (s.enabled && s.kind === kind && overlap(bx, s)) out.push(s)
    return out
}

// A ledge the body could grab: the top edge of a solid just in front of it, roughly at hand
// height, with standing room on top. Returns {x, y, solid, dir} or null.
function ledgeAhead(world, body, dir, opts) {
    const reach = (opts && opts.reach) || 0.45
    const front = body.x + dir * body.w / 2
    const handMin = body.y + body.h * 0.55
    const handMax = body.y + body.h + 0.45
    for (const s of world.solids) {
        if (!s.enabled || s.kind === LADDER || s === body.ownSolid) continue
        if (s.kind === LOW && body.h <= s.gap) continue          // a passage this body fits through is not a wall to grab
        const top = s.y + s.h
        if (top < handMin || top > handMax) continue
        const edgeX = dir > 0 ? s.x : s.x + s.w
        if (Math.abs(edgeX - front) > reach) continue
        if (dir > 0 && front > edgeX + reach) continue
        if (dir < 0 && front < edgeX - reach) continue
        // standing room on top of the ledge
        const stand = { x: body.x, y: top, w: body.w, h: body.h }
        const standBox = { x: edgeX + dir * body.w / 2 - body.w / 2 + 0.02, y: top + 0.02, w: body.w - 0.04, h: body.h - 0.02 }
        let free = true
        for (const o of world.solids) {
            if (o === s || !o.enabled || o.kind === ONEWAY || o.kind === LADDER) continue
            if (o.kind === LOW && body.h <= o.gap) continue
            if (overlap(standBox, o)) { free = false; break }
        }
        if (!free) continue
        return { x: edgeX, y: top, solid: s, dir: dir }
    }
    return null
}

// Move a solid (moving platform / pushable's collision box) and record its motion so bodies
// standing on it can be carried.
function moveSolid(s, nx, ny) {
    s.dx = nx - s.x; s.dy = ny - s.y
    s.x = nx; s.y = ny
}

function clearSolidMotion(world) {
    for (const s of world.solids) { s.dx = 0; s.dy = 0 }
}
