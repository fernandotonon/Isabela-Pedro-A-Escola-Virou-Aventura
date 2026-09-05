// Static validation of a level description (config/level.js): counts, id references, section
// order. Runs in Node (tests/run-node.mjs) and under qmltestrunner; the dev tools show its report.
.pragma library

var SWITCH_TYPES = ["button", "lever", "plate"]

function validate(level) {
    const r = { errors: [], stars: 0, pencils: 0, memories: 0, checkpoints: 0, sections: 0, switches: {}, gates: 0 }
    let lastX1 = null
    const ids = {}
    for (const s of level.sections) {
        r.sections++
        if (lastX1 !== null && Math.abs(s.x0 - lastX1) > 1e-6) r.errors.push("section " + s.id + " starts at " + s.x0 + ", previous ended at " + lastX1)
        if (!(s.x1 > s.x0)) r.errors.push("section " + s.id + " has no width")
        lastX1 = s.x1
        for (const e of s.entities) {
            if (e.id) { if (ids[e.id]) r.errors.push("duplicate id " + e.id); ids[e.id] = e }
            if (SWITCH_TYPES.indexOf(e.type) >= 0) r.switches[e.id] = e.type
            if (e.type === "star") r.stars++
            else if (e.type === "pencil") r.pencils++
            else if (e.type === "memory") r.memories++
            else if (e.type === "checkpoint") r.checkpoints++
            if (e.x === undefined || e.y === undefined) r.errors.push("entity without position in " + s.id + ": " + JSON.stringify(e).slice(0, 60))
            if (e.type !== "prop" && e.type !== "trigger" && e.type !== "wall" && (e.x < s.x0 - 0.01 || e.x > s.x1 + 0.01))
                r.errors.push(e.type + (e.id ? " " + e.id : "") + " at x=" + e.x + " is outside section " + s.id)
        }
    }
    for (const s of level.sections) for (const e of s.entities) {
        if (e.type === "gate") {
            r.gates++
            if (!e.requires || !e.requires.length) r.errors.push("gate " + e.id + " requires nothing")
            for (const req of e.requires || []) if (!r.switches[req]) r.errors.push("gate " + e.id + " requires unknown switch " + req)
        }
        if (e.type === "moving" && (!e.path || e.path.length < 2)) r.errors.push("moving " + e.id + " needs a path of 2+ points")
        if (e.type === "ball" && (!e.range || e.range[1] <= e.range[0])) r.errors.push("ball " + e.id + " has no range")
    }
    const pencilsPerSection = level.sections.map(s => s.entities.filter(e => e.type === "pencil").length)
    pencilsPerSection.forEach((n, i) => { if (n !== 1) r.errors.push("section " + level.sections[i].id + " has " + n + " pencils (expected 1)") })
    return r
}

function assetIds(level) {
    const set = {}
    for (const s of level.sections) for (const e of s.entities) if (e.asset) set[e.asset] = true
    for (const s of level.sections) for (const e of s.entities) { if (e.type === "star") set["star"] = true; if (e.type === "pencil") set["pencil_collectible"] = true; if (e.type === "memory") set["memory"] = true; if (e.type === "checkpoint") set["checkpoint_marker"] = true; if (e.type === "button") set["floor_button"] = true; if (e.type === "lever") set["lever"] = true; if (e.type === "plate") set["plate"] = true; if (e.type === "ball") set["soccer_ball"] = true; if (e.type === "plane") set["paper_plane"] = true }
    return Object.keys(set).sort()
}

function starsPerSection(level) { return level.sections.map(s => ({ id: s.id, stars: s.entities.filter(e => e.type === "star").length })) }
