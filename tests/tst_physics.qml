// Side-plane physics and the character controller: landing, walls, one-way platforms, low
// passages, jump heights, coyote time, jump buffer, ledge grab, crawl, ladders.
import QtQuick
import QtTest
import "../app/scripts/Physics.js" as Physics
import "../app/scripts/CharacterMotion.js" as Motion
import "../app/config/tuning.js" as Tuning

TestCase {
    name: "Physics"
    readonly property real dt: 1 / 60

    function flatWorld() { const w = Physics.makeWorld(); Physics.addSolid(w, { x: -50, y: -1, w: 200, h: 1, id: "floor" }); return w }
    function run(c, frames, input) { for (let i = 0; i < frames; ++i) { Motion.setInput(c, Object.assign(Motion.emptyInput(), input || {})); Motion.update(c, dt) } }

    function test_body_lands_and_stays_grounded() {
        const w = flatWorld(); const b = Physics.makeBody(0, 3, 0.6, 1.5)
        for (let i = 0; i < 120; ++i) { b.vy = Math.max(-20, b.vy - 30 * dt); Physics.step(w, b, 0, b.vy * dt) }
        verify(b.grounded); fuzzyCompare(b.y, 0, 0.01)
    }
    function test_walls_and_oneway() {
        const w = flatWorld(); Physics.addSolid(w, { x: 3, y: 0, w: 1, h: 2, id: "wall" })
        const b = Physics.makeBody(2, 0, 0.6, 1.5); Physics.step(w, b, 2, 0)
        compare(b.hitWall, 1); verify(b.x <= 2.71)
        Physics.addSolid(w, { x: -2, y: 2, w: 2, h: 0.2, kind: Physics.ONEWAY, id: "shelf" })
        const j = Physics.makeBody(-1, 0, 0.6, 1.5); j.vy = 12
        let passed = false, landed = false
        for (let i = 0; i < 200; ++i) { j.vy = Math.max(-20, j.vy - 30 * dt); Physics.step(w, j, 0, j.vy * dt); if (j.y > 2.2) passed = true; if (j.grounded && j.ground && j.ground.id === "shelf") landed = true }
        verify(passed, "jumped through from below"); verify(landed, "landed on top")
    }
    function test_low_passage() {
        const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 3, h: 2, kind: Physics.LOW, gap: 0.8 })
        const tall = Physics.makeBody(1, 0, 0.6, 1.5); Physics.step(w, tall, 1.5, 0)
        const small = Physics.makeBody(1, 0, 0.5, 0.62); Physics.step(w, small, 1.5, 0)
        compare(tall.hitWall, 1); compare(small.hitWall, 0); verify(small.x > 2)
    }
    function test_jump_heights_and_variable_jump() {
        const w = flatWorld()
        const isa = Motion.create(w, Tuning.characters.isabela, 0, 0), ped = Motion.create(w, Tuning.characters.pedro, 3, 0)
        run(isa, 5); run(ped, 5)
        let maxI = 0, maxP = 0
        for (let i = 0; i < 90; ++i) {
            Motion.setInput(isa, Object.assign(Motion.emptyInput(), { jumpPressed: i === 0, jumpHeld: i < 40 })); Motion.update(isa, dt); maxI = Math.max(maxI, isa.body.y)
            Motion.setInput(ped, Object.assign(Motion.emptyInput(), { jumpPressed: i === 0, jumpHeld: i < 40 })); Motion.update(ped, dt); maxP = Math.max(maxP, ped.body.y)
        }
        verify(maxI > 2.2 && maxI < 2.9, "isabela apex " + maxI); verify(maxP > 1.4 && maxP < 1.9, "pedro apex " + maxP)
        let maxShort = 0; Motion.teleport(isa, 0, 0); run(isa, 5)
        for (let i = 0; i < 90; ++i) { Motion.setInput(isa, Object.assign(Motion.emptyInput(), { jumpPressed: i === 0, jumpHeld: i < 5 })); Motion.update(isa, dt); maxShort = Math.max(maxShort, isa.body.y) }
        verify(maxShort < maxI - 0.5, "short hop lower")
    }
    function test_jump_buffer_and_coyote() {
        const w = flatWorld(); const c = Motion.create(w, Tuning.characters.isabela, 0, 0.2)
        let jumps = 0
        for (let i = 0; i < 120; ++i) { Motion.setInput(c, Object.assign(Motion.emptyInput(), { jumpPressed: i === 2 })); Motion.update(c, dt); jumps += c.events.filter(e => e.name === "jump").length }
        compare(jumps, 1)
        const w2 = Physics.makeWorld(); Physics.addSolid(w2, { x: -5, y: -1, w: 5, h: 1 })
        const p = Motion.create(w2, Tuning.characters.pedro, -0.5, 0); run(p, 3)
        let fired = false, pressed = false
        for (let i = 0; i < 60 && !fired; ++i) {
            const off = !p.body.grounded
            Motion.setInput(p, Object.assign(Motion.emptyInput(), { moveX: 1, jumpPressed: off && !pressed && p.coyote > 0 && p.coyote < Tuning.base.coyoteTime - 0.03 }))
            if (p.input.jumpPressed) pressed = true
            Motion.update(p, dt)
            if (p.events.some(e => e.name === "jump")) fired = true
        }
        verify(fired, "coyote jump fired")
    }
    function test_ledge_grab_isabela_only() {
        const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 3, h: 2.4, id: "block" })
        const isa = Motion.create(w, Tuning.characters.isabela, 0.6, 0); run(isa, 3)
        let hung = false
        for (let i = 0; i < 120 && !hung; ++i) { Motion.setInput(isa, Object.assign(Motion.emptyInput(), { moveX: 1, jumpPressed: i === 0, jumpHeld: i < 30 })); Motion.update(isa, dt); hung = Motion.is(isa, "Hang") }
        verify(hung, "isabela hangs")
        for (let i = 0; i < 60 && !Motion.is(isa, "Idle"); ++i) { Motion.setInput(isa, Object.assign(Motion.emptyInput(), { moveY: 1 })); Motion.update(isa, dt) }
        verify(Motion.is(isa, "Idle") && isa.body.y > 2.3, "climbed up")
        const ped = Motion.create(w, Tuning.characters.pedro, 0.6, 0); run(ped, 3)
        let pedHung = false
        for (let i = 0; i < 120; ++i) { Motion.setInput(ped, Object.assign(Motion.emptyInput(), { moveX: 1, jumpPressed: i === 0, jumpHeld: i < 30 })); Motion.update(ped, dt); if (Motion.is(ped, "Hang")) pedHung = true }
        verify(!pedHung && ped.body.y < 0.1, "pedro cannot")
    }
    function test_crawl_pedro_only() {
        const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 3, h: 2, kind: Physics.LOW, gap: 0.8 })
        const ped = Motion.create(w, Tuning.characters.pedro, 0.5, 0); run(ped, 200, { moveX: 1, downHeld: true })
        verify(ped.body.x > 5.2, "pedro crawled through, x=" + ped.body.x)
        const isa = Motion.create(w, Tuning.characters.isabela, 0.5, 0); run(isa, 200, { moveX: 1, downHeld: true })
        verify(isa.body.x < 2, "isabela blocked")
    }
    function test_ladder() {
        const w = flatWorld(); Physics.addSolid(w, { x: 2, y: 0, w: 0.8, h: 4, kind: Physics.LADDER }); Physics.addSolid(w, { x: 2.8, y: 3.8, w: 3, h: 0.2 })
        const c = Motion.create(w, Tuning.characters.pedro, 2.4, 0); run(c, 3)
        let top = 0; for (let i = 0; i < 240; ++i) { Motion.setInput(c, Object.assign(Motion.emptyInput(), { moveY: 1, moveX: 0.3 })); Motion.update(c, dt); top = Math.max(top, c.body.grounded ? c.body.y : 0) }
        verify(top > 3.5, "reached the top, highest grounded y=" + top)
    }
    function test_moving_platform_carries_body() {
        const w = flatWorld(); const plat = Physics.addSolid(w, { x: 0, y: 2, w: 2, h: 0.3, id: "p" })
        const c = Motion.create(w, Tuning.characters.pedro, 1, 2.3); run(c, 10)
        verify(c.body.grounded && c.body.ground === plat)
        for (let i = 0; i < 60; ++i) { Physics.clearSolidMotion(w); Physics.moveSolid(plat, plat.x + 0.02, plat.y); Motion.setInput(c, Motion.emptyInput()); Motion.update(c, dt) }
        verify(c.body.x > 2.1, "carried along: x=" + c.body.x)
    }
}
