// Character controller: turns an input snapshot into motion on a Physics body and drives the
// explicit animation state machine. Pure JS over plain objects so tests can run it headless;
// Character.qml wraps one of these per character.
//
// Input snapshot: { moveX: -1..1, moveY: -1..1 (up positive), jumpPressed, jumpHeld,
//                   interactPressed, abilityPressed, downHeld }
.pragma library
.import "Physics.js" as Physics
.import "StateMachine.js" as FSM
.import "../config/tuning.js" as Tuning

var STATES = ["Idle", "Walk", "Run", "JumpStart", "JumpLoop", "Land", "Push", "Interact",
              "Climb", "Hang", "Crawl", "Scared", "Celebrate", "Wave"]

function create(world, def, x, y) {
    const t = Object.assign({}, Tuning.base, def)
    const body = Physics.makeBody(x, y, def.width, def.height)
    body.stepHeight = t.stepHeight !== undefined ? t.stepHeight : 0.55
    body.mantleHeight = def.mantle !== undefined ? def.mantle : 0      // Pedro pops onto edges he nearly cleared; Isabela grabs them
    const c = {
        id: def.id, def: def, t: t, world: world, body: body,
        facing: 1, input: emptyInput(), lastInput: emptyInput(),
        coyote: 0, buffer: 0, jumpHeldTime: 0, jumping: false,
        crouched: false, hangCooldown: 0, hang: null, climbZone: null,
        pushing: null, pushSign: 0,
        courage: def.courageMax, invulnerable: 0,
        frozen: false,            // narrative moments / menus: no input
        controlled: false,        // active player character
        lastSafe: { x: x, y: y }, safeTimer: 0,
        events: [],               // one-frame event names for audio/FX: jump, land, hurt, ...
        interactTarget: null,
        abilityCooldown: 0,
        fsm: null
    }
    c.fsm = FSM.create("Idle", states())
    return c
}

function emptyInput() {
    return { moveX: 0, moveY: 0, jumpPressed: false, jumpHeld: false, interactPressed: false,
             abilityPressed: false, downHeld: false }
}

function setInput(c, input) { c.lastInput = c.input; c.input = input }

function emit(c, name, data) { c.events.push(data ? Object.assign({ name: name }, data) : { name: name }) }

function is(c, names) { return FSM.is(c.fsm, names) }

// Height the body should currently have (crouch/crawl lowers it).
function targetHeight(c) { return c.crouched ? c.def.crouchHeight : c.def.height }

function update(c, dt) {
    const t = c.t, b = c.body, inp = c.frozen ? emptyInput() : c.input
    c.events.length = 0
    if (c.invulnerable > 0) c.invulnerable -= dt
    if (c.hangCooldown > 0) c.hangCooldown -= dt
    if (c.abilityCooldown > 0) c.abilityCooldown -= dt
    if (inp.jumpPressed) c.buffer = t.jumpBuffer; else if (c.buffer > 0) c.buffer -= dt
    if (b.grounded) c.coyote = t.coyoteTime; else if (c.coyote > 0) c.coyote -= dt

    // carried by a moving solid (platform, pushed box)
    if (b.grounded && b.ground && (b.ground.dx !== 0 || b.ground.dy !== 0)) {
        b.x += b.ground.dx; b.y += b.ground.dy
    }

    const st = c.fsm.state
    if (st === "Hang") { updateHang(c, dt, inp); FSM.update(c.fsm, c, dt); return }
    if (st === "Climb") { updateClimb(c, dt, inp); FSM.update(c.fsm, c, dt); return }
    if (st === "Celebrate" || st === "Wave" || st === "Interact") {
        applyGravity(c, dt, inp); Physics.step(c.world, b, 0, b.vy * dt); FSM.update(c.fsm, c, dt); return
    }

    // crouch / crawl (Pedro) - hold down while grounded; stand up when there is room
    if (c.def.canCrawl) {
        if (inp.downHeld && b.grounded && !c.crouched) { c.crouched = true; b.h = c.def.crouchHeight }
        else if (!inp.downHeld && c.crouched && Physics.fits(c.world, b, c.def.height)) { c.crouched = false; b.h = c.def.height }
    }

    // horizontal
    const maxSpeed = c.crouched ? t.maxSpeed * 0.55 : (c.pushing ? t.maxSpeed * t.pushSpeedScale : t.maxSpeed)
    const want = inp.moveX * maxSpeed
    const acc = b.grounded ? (Math.abs(want) > 0.01 ? t.accel : t.decel) : (Math.abs(want) > 0.01 ? t.airAccel : t.airDecel)
    if (Math.abs(want - b.vx) <= acc * dt) b.vx = want
    else b.vx += Math.sign(want - b.vx) * acc * dt
    if (Math.abs(inp.moveX) > 0.05 && st !== "Scared") c.facing = inp.moveX > 0 ? 1 : -1

    // jump: buffered press, grounded or coyote
    const canStand = !c.crouched || Physics.fits(c.world, b, c.def.height)
    if (c.buffer > 0 && (b.grounded || c.coyote > 0) && canStand && st !== "Scared") {
        if (c.crouched) { c.crouched = false; b.h = c.def.height }
        b.vy = c.def.jumpVelocity; c.buffer = 0; c.coyote = 0; c.jumping = true; c.jumpHeldTime = 0
        b.grounded = false; b.ground = null
        emit(c, "jump")
        FSM.set(c.fsm, c, "JumpStart")
    }
    if (c.jumping) c.jumpHeldTime += dt
    applyGravity(c, dt, inp)

    const wasGrounded = b.grounded, prevVy = b.vy
    Physics.step(c.world, b, b.vx * dt, b.vy * dt)
    // walked off an edge (no jump): do not grab the ledge just left behind
    if (wasGrounded && !b.grounded && !c.jumping) c.hangCooldown = Math.max(c.hangCooldown, 0.35)
    if (b.grounded && !wasGrounded) { c.jumping = false; emit(c, "land", { speed: -prevVy }) ; if (st !== "Scared") FSM.set(c.fsm, c, "Land") }
    if (b.grounded && st !== "Scared") { c.safeTimer += dt; if (c.safeTimer > 0.25 && b.ground && b.ground.dx === 0 && b.ground.dy === 0 && !b.ground.unsafe) { c.lastSafe.x = b.x; c.lastSafe.y = b.y; c.safeTimer = 0 } }
    else c.safeTimer = 0

    // pushing: walking into a pushable we are strong enough for
    c.pushing = null
    if (b.hitWall !== 0 && b.grounded && Math.abs(inp.moveX) > 0.3 && Math.sign(inp.moveX) === b.hitWall) {
        const target = wallSolid(c, b.hitWall)
        if (target && target.pushable && target.pushable.weight <= c.def.pushStrength) { c.pushing = target.pushable; c.pushSign = b.hitWall }
    }

    // ledge grab (Isabela)
    if (c.def.canLedgeGrab && !b.grounded && c.hangCooldown <= 0 && b.vy < 4 && st !== "Scared") {
        const dir = Math.abs(inp.moveX) > 0.2 ? Math.sign(inp.moveX) : c.facing
        const ledge = Physics.ledgeAhead(c.world, b, dir)
        if (ledge && (Math.abs(inp.moveX) > 0.2 || b.vy < 0)) startHang(c, ledge)
    }

    // ladders
    if (st !== "Hang" && inp.moveY > 0.5) {
        // the waist must reach the ladder: Pedro's jump does not get him onto a raised ladder
        const ladders = Physics.overlapping(c.world, b, Physics.LADDER).filter(function (z) { return b.y + b.h * 0.5 >= z.y - 0.1 })
        if (ladders.length) { c.climbZone = ladders[0]; b.vx = 0; b.vy = 0; FSM.set(c.fsm, c, "Climb") }
    }

    FSM.update(c.fsm, c, dt)
}

function applyGravity(c, dt, inp) {
    const b = c.body, t = c.t
    if (b.grounded) return
    let g = t.gravity
    if (b.vy < 0) g *= t.fallGravityScale
    else if (c.jumping && !inp.jumpHeld && c.jumpHeldTime > t.minJumpHold) g *= t.jumpCutScale
    b.vy = Math.max(t.maxFallSpeed, b.vy + g * dt)
}

function wallSolid(c, dir) {
    const b = c.body
    const probe = { x: dir > 0 ? b.x + b.w / 2 : b.x - b.w / 2 - 0.05, y: b.y + 0.05, w: 0.05, h: b.h - 0.1 }
    for (const s of c.world.solids) {
        if (!s.enabled || s === b.ownSolid || s.kind === Physics.LADDER || s.kind === Physics.ONEWAY) continue
        if (Physics.overlap(probe, s)) return s
    }
    return null
}

function startHang(c, ledge) {
    const b = c.body
    c.hang = ledge
    b.vx = 0; b.vy = 0; c.jumping = false
    b.x = ledge.x - ledge.dir * (b.w / 2 + 0.02)
    // hang from the hands: the rig raises the arms overhead, so the body hangs a full height below the
    // ledge (at 0.82 the ledge lined up with the shoulders and the arms stuck through it)
    b.y = ledge.y - b.h * 1.02
    c.facing = ledge.dir
    emit(c, "grab")
    FSM.set(c.fsm, c, "Hang")
}

function updateHang(c, dt, inp) {
    const b = c.body
    if (!c.hang || !c.hang.solid.enabled) { FSM.set(c.fsm, c, "JumpLoop"); return }
    // moving ledge: follow it
    b.x += c.hang.solid.dx; b.y += c.hang.solid.dy; c.hang.x += c.hang.solid.dx; c.hang.y += c.hang.solid.dy
    if (inp.downHeld || (inp.moveX !== 0 && Math.sign(inp.moveX) === -c.hang.dir)) {
        c.hang = null; c.hangCooldown = c.t.hangDropCooldown; FSM.set(c.fsm, c, "JumpLoop"); return
    }
    if (inp.jumpPressed || inp.moveY > 0.5) {
        c.climbTarget = { x: c.hang.x + c.hang.dir * (b.w / 2 + 0.05), y: c.hang.y }
        c.hang = null
        emit(c, "climb")
        FSM.set(c.fsm, c, "Climb")
    }
}

function updateClimb(c, dt, inp) {
    const b = c.body
    if (c.climbTarget) {                 // ledge climb-up: a short scripted move
        if (c.fsm.time >= c.t.ledgeClimbTime) {
            b.x = c.climbTarget.x; b.y = c.climbTarget.y + 0.01; b.vx = 0; b.vy = 0
            c.climbTarget = null; c.hangCooldown = c.t.hangDropCooldown
            Physics.step(c.world, b, 0, -0.02)
            FSM.set(c.fsm, c, "Idle")
        }
        return
    }
    // ladder
    if (!c.climbZone) { FSM.set(c.fsm, c, "JumpLoop"); return }
    b.vy = inp.moveY * c.t.climbSpeed
    b.vx = inp.moveX * c.t.climbSpeed * 0.4
    const z = c.climbZone
    const nextY = b.y + b.vy * dt
    if (inp.jumpPressed) { c.climbZone = null; b.vy = c.def.jumpVelocity * 0.7; c.jumping = true; FSM.set(c.fsm, c, "JumpLoop"); return }
    if (nextY + 0.2 >= z.y + z.h && inp.moveY > 0) {    // top: step onto whatever is above
        b.y = z.y + z.h + 0.02; b.vy = 0; c.climbZone = null
        Physics.step(c.world, b, 0, -0.05)
        FSM.set(c.fsm, c, "Idle"); return
    }
    b.y = Math.max(z.y, nextY)
    b.x = Math.min(z.x + z.w - b.w / 2, Math.max(z.x + b.w / 2, b.x + b.vx * dt))
    if (b.y <= z.y + 0.001 && inp.moveY < 0) { c.climbZone = null; FSM.set(c.fsm, c, "Idle") }
    const still = Physics.overlapping(c.world, b, Physics.LADDER)
    if (!still.length) { c.climbZone = null; FSM.set(c.fsm, c, "JumpLoop") }
}

// Courage loss: knock back away from `fromX`, short Scared state, invulnerability window.
function hurt(c, fromX) {
    if (c.invulnerable > 0 || c.fsm.state === "Scared") return false
    const b = c.body
    c.courage = Math.max(0, c.courage - 1)
    c.invulnerable = c.t.hurtInvulnerable
    const dir = b.x >= fromX ? 1 : -1
    b.vx = dir * c.t.hurtKnockback
    b.vy = c.t.hurtUpKick
    b.grounded = false; b.ground = null
    c.hang = null; c.climbZone = null; c.climbTarget = null; c.pushing = null
    emit(c, "hurt", { courage: c.courage })
    FSM.set(c.fsm, c, "Scared")
    return true
}

function restore(c, amount) {
    const before = c.courage
    c.courage = Math.min(c.def.courageMax, c.courage + amount)
    return c.courage - before
}

function teleport(c, x, y) {
    const b = c.body
    b.x = x; b.y = y; b.vx = 0; b.vy = 0; b.grounded = false
    c.hang = null; c.climbZone = null; c.climbTarget = null; c.pushing = null; c.jumping = false
    c.crouched = false; b.h = c.def.height
    c.lastSafe.x = x; c.lastSafe.y = y
    FSM.set(c.fsm, c, "Idle")
}

function celebrate(c) { c.frozen = true; c.body.vx = 0; FSM.set(c.fsm, c, "Celebrate") }
function wave(c) { FSM.set(c.fsm, c, "Wave") }
function interact(c) { c.body.vx = 0; FSM.set(c.fsm, c, "Interact") }

// ---- states ---------------------------------------------------------------------------------
function groundedNext(c) {
    const b = c.body, t = c.t
    if (!b.grounded) return "JumpLoop"
    if (c.pushing) return "Push"
    if (c.crouched) return "Crawl"
    const speed = Math.abs(b.vx)
    if (speed < 0.15) return "Idle"
    return speed < t.walkThreshold * t.maxSpeed ? "Walk" : "Run"
}

function states() {
    return {
        Idle: { update: function (c) { return groundedNext(c) } },
        Walk: { update: function (c) { return groundedNext(c) } },
        Run: { update: function (c) { return groundedNext(c) } },
        Crawl: { update: function (c) { return groundedNext(c) } },
        Push: { update: function (c) { return groundedNext(c) } },
        JumpStart: { update: function (c) { return c.fsm.time > 0.08 ? "JumpLoop" : null } },
        JumpLoop: { update: function (c) { return c.body.grounded ? "Land" : null } },
        Land: { update: function (c) { return c.fsm.time >= c.t.landTime ? groundedNext(c) : null } },
        Hang: {},
        Climb: {},
        Scared: { update: function (c) { return c.fsm.time >= c.t.scaredTime && c.body.grounded ? "Idle" : (c.fsm.time > 1.2 ? "JumpLoop" : null) } },
        Interact: { update: function (c) { return c.fsm.time >= 0.6 ? "Idle" : null } },
        Celebrate: {},
        Wave: { update: function (c) { return c.fsm.time >= 1.6 ? "Idle" : null } }
    }
}
