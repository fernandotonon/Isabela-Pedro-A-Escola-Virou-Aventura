// Level scripting: builds the level from config/level.js (solids in the Physics world + QML
// entities), runs mechanisms (switches -> gates), collectibles, checkpoints, triggers, hazards
// and the final door, and snapshots/restores everything a checkpoint must preserve.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics
import "config/level.js" as Level
import "config/assets.js" as Assets

Item {
    id: director
    property var world: null
    property var level: Level.level
    property var characters: []             // Character items (motion objects inside)
    property Node propRoot: null
    property Node platformRoot: null
    property Node entityRoot: null
    property string assetBase: ""
    property bool useModels: true
    property real hazardSpeedScale: 1
    property real platformSpeedScale: 1

    // runtime tables
    property var switches: ({})             // id -> Switch
    property var gates: []
    property var movers: []
    property var pushables: []
    property var hazards: []
    property var collectibles: []
    property var checkpoints: []
    property var triggers: []
    property var props: []
    property var hiddenGroups: ({})         // revealId -> [Prop]
    property var secretPassages: []         // lowpass solids hidden until Pedro's curiosity
    property var zones: []                  // { box, only }
    property var lowSolids: []
    property var finalDoor: null
    property var collected: ({})            // collectibleId -> true (persisted)
    property int starsTotal: 0
    property int pencilsTotal: 0
    property int stars: 0
    property int pencils: 0
    property bool memoryFound: false
    property bool built: false

    signal collectedItem(string kind, string id, real x, real y)
    signal checkpointReached(string id, real x, real y)
    signal gateOpened(string id, var spec)
    signal triggerFired(string id, var spec)
    signal switchActivated(string id)
    signal hazardHit(string characterId, real fromX)
    signal revealed(string groupId, int count)
    signal levelFinished()

    Component { id: propComp; Prop {} }
    Component { id: moverComp; MovingPlatform {} }
    Component { id: pushComp; Pushable {} }
    Component { id: switchComp; Switch {} }
    Component { id: gateComp; Gate {} }
    Component { id: collectibleComp; Collectible {} }
    Component { id: checkpointComp; Checkpoint {} }
    Component { id: hazardComp; Hazard {} }
    Component { id: triggerComp; TriggerZone {} }
    Component { id: doorComp; FinalDoor {} }

    function sectionAt(x) { return Level.sectionAt(x) }
    function checkpointList() { return Level.checkpoints() }

    function build() {
        if (built) return
        const common = { assetBase: assetBase, useModels: useModels }
        let starCount = 0, pencilCount = 0, memCount = 0
        for (const s of level.sections) {
            for (const e of s.entities) {
                switch (e.type) {
                case "ground": case "platform": case "wall": case "lowpass": case "ladder": {
                    let kind = Physics.SOLID
                    if (e.type === "lowpass" && !e.secret) kind = Physics.LOW      // a secret passage is a plain block until found
                    else if (e.type === "ladder") kind = Physics.LADDER
                    else if (e.oneway) kind = Physics.ONEWAY
                    const solid = Physics.addSolid(world, { x: e.x, y: e.y, w: e.w, h: e.h, kind: kind, gap: e.gap || 0.8, id: e.id, enabled: !e.hidden, tag: e.type })
                    if (e.type === "lowpass") { lowSolids.push(solid); if (e.secret) secretPassages.push(solid) }
                    const item = propComp.createObject(platformRoot, Object.assign({}, common, {
                        hidden: e.hidden === true,
                        position: Qt.vector3d(e.x + e.w / 2, e.type === "ladder" && e.visualFrom !== undefined ? e.visualFrom : e.y, e.z || 0) }))
                    item.spec = e; item.solid = solid
                    if (e.type === "ladder" && e.visualFrom !== undefined) item.scale = Qt.vector3d(1, (e.y + e.h - e.visualFrom) / e.h, 1)
                    if (e.hidden && e.revealId) { const g = hiddenGroups[e.revealId] || []; g.push(item); hiddenGroups[e.revealId] = g }
                    if (e.secret) { const g = hiddenGroups["secret:" + s.id] || []; g.push(item); hiddenGroups["secret:" + s.id] = g }
                    props.push(item)
                    break
                }
                case "prop": {
                    const def = Assets.get(e.asset)
                    const col = def && def.collider ? def.collider : null
                    const sc = e.scale || 1
                    const w = e.w || (col ? col.w * sc : (def ? def.scale : 1))
                    const h = e.h || (col ? col.h * sc : (def ? def.scale * sc : 1))
                    const d = e.d || (col ? col.d * sc : Math.max(0.5, Math.min(2, h * 0.6)))
                    const item = propComp.createObject(propRoot, Object.assign({}, common, { spec: Object.assign({}, e, { w: w, h: h, d: d, type: "prop" }),
                        position: Qt.vector3d(e.w ? e.x + e.w / 2 : e.x, e.y || 0, e.z !== undefined ? e.z : -3) }))
                    props.push(item)
                    break
                }
                case "moving": {
                    const solid = Physics.addSolid(world, { x: e.path[0].x, y: e.path[0].y, w: e.w, h: e.h, kind: Physics.SOLID, id: e.id, tag: "moving", unsafe: true })
                    const m = moverComp.createObject(entityRoot, Object.assign({}, common, { active: !e.requiresAbility }))
                    m.spec = e; m.solid = solid
                    m.speedScale = Qt.binding(function () { return director.platformSpeedScale })
                    m.sync(); movers.push(m)
                    break
                }
                case "pushable": {
                    const p = pushComp.createObject(entityRoot, Object.assign({}, common, {}))
                    p.spec = e; p.world = world
                    p.create(); p.body.isPushable = true; p.solid.unsafe = true
                    pushables.push(p)
                    break
                }
                case "button": case "lever": case "plate": {
                    const sw = switchComp.createObject(entityRoot, Object.assign({}, common, {}))
                    sw.spec = e; sw.world = world
                    sw.activated.connect(function (id) { director.switchActivated(id); director.evaluateGates() })
                    sw.deactivated.connect(function () { director.evaluateGates() })
                    switches[e.id] = sw
                    break
                }
                case "gate": {
                    const solid = Physics.addSolid(world, { x: e.x, y: e.y, w: e.w, h: e.h, kind: Physics.SOLID, id: e.id, tag: "gate" })
                    const g = gateComp.createObject(entityRoot, Object.assign({}, common, {}))
                    g.spec = e; g.solid = solid
                    g.opened.connect(function (id) { director.gateOpened(id, e) })
                    gates.push(g)
                    break
                }
                case "star": case "pencil": case "memory": {
                    const n = e.type === "star" ? ++starCount : (e.type === "pencil" ? ++pencilCount : ++memCount)
                    const id = s.id + ":" + e.type + ":" + n
                    const c = collectibleComp.createObject(entityRoot, Object.assign({}, common, { collectibleId: id }))
                    c.spec = e
                    c.taken.connect(function (kind, cid) { director.onTaken(kind, cid, e.x, e.y) })
                    collectibles.push(c)
                    break
                }
                case "checkpoint": {
                    const cp = checkpointComp.createObject(entityRoot, Object.assign({}, common, {}))
                    cp.spec = e
                    cp.activated.connect(function (id) { director.checkpointReached(id, e.x, e.y) })
                    checkpoints.push(cp)
                    break
                }
                case "ball": case "plane": {
                    const hz = hazardComp.createObject(entityRoot, Object.assign({}, common, {}))
                    hz.spec = e
                    hz.speedScale = Qt.binding(function () { return director.hazardSpeedScale })
                    hz.reset(); hazards.push(hz)
                    break
                }
                case "trigger": {
                    const t = triggerComp.createObject(director, {})
                    t.spec = e
                    t.triggered.connect(function (id, spec) { director.triggerFired(id, spec) })
                    triggers.push(t)
                    break
                }
                case "zone":
                    zones.push({ box: { x: e.x, y: e.y, w: e.w, h: e.h }, only: e.only })
                    break
                case "finaldoor": {
                    finalDoor = doorComp.createObject(entityRoot, Object.assign({}, common, {}))
                    finalDoor.spec = e
                    finalDoor.opened.connect(function () { director.levelFinished() })
                    break
                }
                }
            }
        }
        starsTotal = starCount; pencilsTotal = pencilCount
        built = true
    }

    // ---- per fixed step -------------------------------------------------------------------------
    function step(dt, active) {
        Physics.clearSolidMotion(world)
        for (const m of movers) m.step(dt)
        for (const p of pushables) p.step(dt)
        for (const h of hazards) h.step(dt)
    }

    // after the characters moved: sensors, pickups, hazards
    function afterCharacters(dt, active) {
        const bodies = []
        for (const c of characters) bodies.push(c.motion.body)
        for (const p of pushables) bodies.push(p.body)
        for (const id in switches) switches[id].evaluate(bodies)
        for (const c of characters) {
            const b = c.motion.body
            for (const col of collectibles) if (!col.collected && Math.abs(col.spec.x - b.x) < 3) col.test(b)
            if (c.motion.invulnerable <= 0) for (const h of hazards) if (Math.abs(h.cx - b.x) < 4 && h.hitbox && Physics.overlap(Physics.box(b), h.hitbox)) { hazardHit(c.characterId, h.cx); break }
        }
        if (active) {
            const ab = active.motion.body
            for (const cp of checkpoints) if (!cp.reached && Math.abs(cp.spec.x - ab.x) < 3) cp.test(ab)
            for (const t of triggers) if (Math.abs(t.spec.x + (t.spec.w || 1) / 2 - ab.x) < 8) t.test(ab)
        }
        if (finalDoor) finalDoor.evaluate(characters.map(function (c) { return c.motion }))
    }

    function evaluateGates() {
        for (const g of gates) {
            let all = true
            for (const req of g.spec.requires) { const sw = switches[req]; if (!sw || !sw.active) { all = false; break } }
            if (all) g.setOpen(true)
        }
    }

    function onTaken(kind, id, x, y) {
        const c = Object.assign({}, collected); c[id] = true; collected = c
        recount()
        collectedItem(kind, id, x, y)
    }
    function recount() {
        let s = 0, p = 0, m = false
        for (const c of collectibles) if (collected[c.collectibleId]) { if (c.kind === "star") s++; else if (c.kind === "pencil") p++; else m = true }
        stars = s; pencils = p; memoryFound = m
    }

    // Isabela's notebook: reveal hidden platform groups within radius. Returns how many.
    function revealNear(x, radius) {
        let n = 0
        for (const gid in hiddenGroups) {
            if (gid.indexOf("secret:") === 0) continue
            const items = hiddenGroups[gid]
            let near = false
            for (const it of items) if (!it.revealed && Math.abs(it.spec.x + it.spec.w / 2 - x) < radius) near = true
            if (near) { for (const it of items) it.reveal(); n += items.length; revealed(gid, items.length) }
        }
        return n
    }
    // Pedro's curiosity: secret passages open, idle swings start moving.
    function curiosityNear(x, radius) {
        let n = 0
        for (const gid in hiddenGroups) {
            if (gid.indexOf("secret:") !== 0) continue
            const items = hiddenGroups[gid]
            let near = false
            for (const it of items) if (!it.revealed && Math.abs(it.spec.x + it.spec.w / 2 - x) < radius) near = true
            if (near) { for (const it of items) { it.revealed = true; it.solid.kind = Physics.LOW; it.surfaceTint = 0.6 }; n += items.length; revealed(gid, items.length) }
        }
        for (const m of movers) if (!m.active && Math.abs(m.position.x - x) < radius) { m.active = true; n++ }
        return n
    }

    // things the active sibling may interact with (E)
    function interactablesNear(c) {
        const out = []
        const b = c.motion.body
        for (const id in switches) {
            const sw = switches[id]
            if (sw.kind !== "lever" || sw.active) continue
            if (Math.abs(sw.spec.x - b.x) < 1.4 && sw.spec.y > b.y - 1.2 && sw.spec.y < b.y + b.h) out.push(sw)
        }
        if (finalDoor && finalDoor.interactable && Physics.overlap(Physics.box(b), finalDoor.zone) && !finalDoor.confirmed[c.characterId]) out.push(finalDoor)
        return out
    }

    // does the follower fit where the leader stands? (character-exclusive passages)
    function blockedFor(follower, leader) {
        const lb = Physics.box(leader.motion.body)
        const minH = follower.def.canCrawl ? follower.def.crouchHeight : follower.def.height
        for (const s of lowSolids) if (s.enabled && Physics.overlap(lb, s) && minH > s.gap) return true
        for (const z of zones) if (Physics.overlap(lb, z.box) && z.only && z.only !== follower.characterId) return true
        return false
    }

    // ---- checkpoint state -----------------------------------------------------------------------
    function snapshot() {
        const sw = {}; for (const id in switches) sw[id] = switches[id].serialize()
        const gt = {}; for (const g of gates) gt[g.spec.id] = g.serialize()
        const pu = {}; for (const p of pushables) pu[p.spec.id] = p.serialize()
        const hg = []; for (const gid in hiddenGroups) if (hiddenGroups[gid].length && hiddenGroups[gid][0].revealed) hg.push(gid)
        const mv = []; for (const m of movers) if (m.active) mv.push(m.spec.id)
        return { switches: sw, gates: gt, pushables: pu, revealed: hg, activeMovers: mv, collected: Object.assign({}, collected) }
    }
    function restore(snap) {
        if (!snap) return
        for (const id in switches) { switches[id].reset(); if (snap.switches && snap.switches[id]) switches[id].restore(snap.switches[id]) }
        for (const g of gates) { g.reset(); if (snap.gates && snap.gates[g.spec.id]) g.restore(snap.gates[g.spec.id]) }
        for (const p of pushables) { p.reset(); if (snap.pushables && snap.pushables[p.spec.id]) p.restore(snap.pushables[p.spec.id]) }
        for (const gid in hiddenGroups) for (const it of hiddenGroups[gid]) {
            it.revealed = false
            if (gid.indexOf("secret:") === 0) { it.solid.kind = Physics.SOLID; it.surfaceTint = 0 } else if (it.solid) it.solid.enabled = false
        }
        for (const gid of (snap.revealed || [])) if (hiddenGroups[gid]) for (const it of hiddenGroups[gid]) {
            it.revealed = true
            if (gid.indexOf("secret:") === 0) { it.solid.kind = Physics.LOW; it.surfaceTint = 0.6 } else if (it.solid) it.solid.enabled = true
        }
        for (const m of movers) { m.reset(); m.active = !m.spec.requiresAbility || (snap.activeMovers || []).indexOf(m.spec.id) >= 0 }
        for (const h of hazards) h.reset()
        collected = Object.assign({}, snap.collected || {})
        for (const c of collectibles) c.restore(collected[c.collectibleId] === true)
        for (const cp of checkpoints) cp.reached = false
        if (finalDoor) finalDoor.reset()
        recount()
        evaluateGates()
    }
    function markCheckpointsUpTo(x) { for (const cp of checkpoints) cp.reached = cp.spec.x <= x + 0.5 }
    function resetTriggersAfter(x) { for (const t of triggers) if (t.spec.x > x) t.reset() }
}
