// The Courage system replaces hit points. Touching an obstacle costs one Courage point with a
// gentle knockback; at zero both siblings return to the last checkpoint (nobody is hurt).
// Pure bookkeeping around CharacterMotion.hurt/restore so it can be tested headless.
.pragma library
.import "CharacterMotion.js" as Motion
.import "../config/tuning.js" as Tuning

function create(characters) {
    return { characters: characters, depleted: false, hits: 0, restored: 0 }
}

// Character `c` touched an obstacle at fromX. Returns "hurt", "ignored" or "depleted".
function touch(state, c, fromX) {
    if (!Motion.hurt(c, fromX)) return "ignored"
    state.hits++
    if (c.courage <= 0) { state.depleted = true; return "depleted" }
    return "hurt"
}

// A star / drawing / word of encouragement: restore Courage of the character that took it.
function encourage(state, c, amount) {
    const gained = Motion.restore(c, amount === undefined ? Tuning.courage.starRestore : amount)
    state.restored += gained
    return gained
}

// After a respawn: everyone back to full Courage.
function refill(state) {
    for (const c of state.characters) c.courage = c.def.courageMax
    state.depleted = false
}

function snapshot(state) {
    const out = {}
    for (const c of state.characters) out[c.id] = c.courage
    return out
}

function apply(state, snap) {
    for (const c of state.characters) if (snap && snap[c.id] !== undefined) c.courage = snap[c.id]
}
