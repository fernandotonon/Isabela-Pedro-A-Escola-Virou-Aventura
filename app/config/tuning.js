// Gameplay numbers in one place: movement feel, Courage, camera, companion AI.
// Metres and seconds. Character-specific values override `base`.
.pragma library

var base = {
    gravity: -30,               // snappy platformer gravity (m/s^2)
    fallGravityScale: 1.35,     // heavier on the way down -> readable arcs
    jumpCutScale: 3.0,          // extra gravity while rising after the jump button is released
    maxFallSpeed: -22,
    accel: 34,                  // ground acceleration (m/s^2)
    decel: 46,                  // ground deceleration
    airAccel: 22,               // moderate air control
    airDecel: 8,
    walkThreshold: 0.35,        // |vx| / maxSpeed below which the animation is Walk, not Run
    coyoteTime: 0.10,           // seconds after leaving an edge in which a jump still works
    jumpBuffer: 0.12,           // seconds a jump press is remembered before landing
    landTime: 0.10,             // Land state duration
    minJumpHold: 0.06,
    pushSpeedScale: 0.45,       // speed while pushing
    stepHeight: 0.55,           // kerbs and stairs up to this are walked, not jumped
    hangDropCooldown: 0.25,     // seconds after dropping from a ledge before re-grabbing
    climbSpeed: 2.6,            // ladder climb speed
    ledgeClimbTime: 0.45,
    hurtInvulnerable: 1.4,
    hurtKnockback: 4.5,
    hurtUpKick: 6.5,
    scaredTime: 0.45,
    crouchToggle: false
}

var characters = {
    isabela: {
        id: "isabela", displayName: "Isabela",
        width: 0.6, height: 1.5, crouchHeight: 1.0,
        maxSpeed: 5.6, jumpVelocity: 12.2,     // ~2.5 m apex -> grabs high ledges
        canLedgeGrab: true, canCrawl: false, pushStrength: 2,   // 2 = medium objects
        ability: "notebook", abilityCooldown: 1.2, abilityRadius: 9,
        courageMax: 3, color: "#e64b7a", hair: "#3b2418"
    },
    pedro: {
        id: "pedro", displayName: "Pedro",
        width: 0.5, height: 1.15, crouchHeight: 0.62,
        maxSpeed: 7.2, jumpVelocity: 10.0,     // ~1.7 m apex
        canLedgeGrab: false, canCrawl: true, pushStrength: 1,   // 1 = light objects only
        ability: "curiosity", abilityCooldown: 1.0, abilityRadius: 7,
        courageMax: 3, color: "#2f6fd6", hair: "#2a1a10"
    }
}

var companion = {
    followDistance: 2.2,        // keep this far behind the leader
    stopDistance: 1.4,          // do not crowd the leader
    teleportDistance: 16,       // too far -> teleport to the leader's last safe spot
    stuckSeconds: 3.5,          // no progress while wanting to move -> teleport
    fallKillOffset: 12,         // below the leader by this much -> teleport
    gapLookahead: 0.9,          // how far ahead the AI checks for a gap
    jumpGapMax: 4.6,            // wider gaps are waited out (leader must come back / mechanism)
    stepHeightMax: 0.55         // ledges lower than this are walked, higher are jumped
}

var camera = {
    smooth: 6.5,                // exponential follow rate (1/s)
    lookAhead: 1.6,             // metres ahead in the movement direction at full speed
    lookAheadSmooth: 3.0,
    baseHeight: 2.6,            // camera aim height above the ground line
    verticalWindow: 1.6,        // jumps inside this window do not move the camera
    verticalSmooth: 4.0,
    distance: 13.5,             // default camera distance (metres)
    minDistance: 9,
    maxDistance: 19,
    pitch: -9,                  // slight downward tilt
    fov: 42,
    frameBothPadding: 3.5       // extra distance when the companion is far
}

var courage = {
    starRestore: 1,             // a Courage star restores this much
    respawnFade: 0.35
}

var level = {
    fixedStep: 1 / 60,
    maxStepsPerFrame: 4,
    killY: -8                   // below this -> fell into imagination, respawn
}

function character(id) { return characters[id] }
