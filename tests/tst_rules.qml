// Game rules: Courage, companion AI, level data consistency, strings, asset manifest.
import QtQuick
import QtTest
import "../app/scripts/Physics.js" as Physics
import "../app/scripts/CharacterMotion.js" as Motion
import "../app/scripts/CompanionAI.js" as Companion
import "../app/scripts/Courage.js" as Courage
import "../app/scripts/LevelCheck.js" as LevelCheck
import "../app/scripts/StateMachine.js" as FSM
import "../app/config/tuning.js" as Tuning
import "../app/config/level.js" as Level
import "../app/config/strings.js" as Strings
import "../app/config/assets.js" as Assets

TestCase {
    name: "Rules"
    readonly property real dt: 1 / 60
    function flatWorld() { const w = Physics.makeWorld(); Physics.addSolid(w, { x: -50, y: -1, w: 200, h: 1 }); return w }
    function run(c, frames, input) { for (let i = 0; i < frames; ++i) { Motion.setInput(c, Object.assign(Motion.emptyInput(), input || {})); Motion.update(c, dt) } }

    function test_state_machine() {
        let entered = []
        const fsm = FSM.create("A", { A: { update: function () { return "B" } }, B: { enter: function () { entered.push("B") } } })
        compare(FSM.update(fsm, {}, dt), "B"); compare(entered.length, 1); verify(FSM.is(fsm, ["B", "C"]))
        let threw = false; try { FSM.set(fsm, {}, "Nope") } catch (e) { threw = true } verify(threw)
    }
    function test_courage() {
        const w = flatWorld(); const isa = Motion.create(w, Tuning.characters.isabela, 0, 0); const ped = Motion.create(w, Tuning.characters.pedro, 2, 0)
        const st = Courage.create([isa.motion ? isa.motion : isa, ped]); run(isa, 3)
        compare(Courage.touch(st, isa, 1), "hurt"); compare(isa.courage, 2)
        compare(Courage.touch(st, isa, 1), "ignored")
        run(isa, 120); compare(Courage.touch(st, isa, 1), "hurt")
        run(isa, 120); compare(Courage.touch(st, isa, 1), "depleted"); verify(st.depleted)
        Courage.refill(st); compare(isa.courage, 3); verify(!st.depleted)
        isa.courage = 1; compare(Courage.encourage(st, isa, 1), 1)
        const snap = Courage.snapshot(st); compare(snap.isabela, 2); isa.courage = 0; Courage.apply(st, snap); compare(isa.courage, 2)
    }
    function test_companion_follows_and_jumps_gaps() {
        const w = Physics.makeWorld(); Physics.addSolid(w, { x: -5, y: -1, w: 15, h: 1 }); Physics.addSolid(w, { x: 12, y: -1, w: 10, h: 1 })
        const lead = Motion.create(w, Tuning.characters.isabela, 6, 0), fol = Motion.create(w, Tuning.characters.pedro, 0, 0)
        const ai = Companion.create(); run(lead, 3); run(fol, 3)
        for (let i = 0; i < 240; ++i) { Motion.setInput(lead, Motion.emptyInput()); Motion.update(lead, dt); const r = Companion.think(ai, fol, lead, w, dt, {}); Motion.setInput(fol, r.input); Motion.update(fol, dt) }
        verify(Math.abs(lead.body.x - fol.body.x) < Tuning.companion.followDistance + 0.3, "followed")
        Motion.teleport(lead, 14, 0); Motion.teleport(fol, 8, 0); run(lead, 3); run(fol, 3)
        let fell = false
        for (let i = 0; i < 400; ++i) { Motion.setInput(lead, Motion.emptyInput()); Motion.update(lead, dt); const r = Companion.think(ai, fol, lead, w, dt, {}); if (r.teleport) Motion.teleport(fol, r.teleport.x, r.teleport.y); Motion.setInput(fol, r.input); Motion.update(fol, dt); if (fol.body.y < -3) fell = true }
        verify(!fell && fol.body.x > 12, "crossed the gap")
        Motion.teleport(lead, 60, 0); lead.lastSafe = { x: 18, y: 0 }; lead.body.grounded = true
        const r = Companion.think(ai, fol, lead, w, dt, {})
        verify(r.teleport && Math.abs(r.teleport.x - 18) < 2, "teleports when far")
        const rb = Companion.think(ai, fol, lead, w, dt, { blockedZone: true })
        compare(rb.input.moveX, 0)
    }
    function test_level_data() {
        const r = LevelCheck.validate(Level.level)
        compare(r.errors.join("\n"), "")
        compare(r.stars, 40); compare(r.pencils, 6); compare(r.memories, 1); compare(r.checkpoints, 4); compare(r.sections, 6)
        compare(Level.checkpoints().length, 5)   // start + 4
        compare(Level.sectionAt(10).id, "pracinha"); compare(Level.sectionAt(470).id, "corredor")
    }
    function test_strings() {
        const missing = Object.keys(Strings.pt_BR).filter(k => !(k in Strings.en))
        compare(missing.join(","), "")
        verify(Strings.tr("menu.newGame", "pt_BR").length > 0); compare(Strings.tr("nope.key"), "nope.key")
    }
    function test_assets_manifest_covers_level() {
        const ids = LevelCheck.assetIds(Level.level)
        const unknown = ids.filter(id => !Assets.get(id))
        compare(unknown.join(","), "")
        verify(Assets.get("isabela").clips.Idle !== undefined)
    }
}
