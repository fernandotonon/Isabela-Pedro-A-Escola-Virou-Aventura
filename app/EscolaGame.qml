// Game root (an Item, so it runs inside the desktop Window and under the Clayground Web Runtime).
// Composition: GameWorld (3D) + two Characters + LevelDirector (level scripting) + InputManager +
// AudioManager + SaveSystem + Hud + MenuOverlay (+ DevTools in development builds).
// A fixed 60 Hz simulation step drives physics, characters, companion AI and mechanisms;
// rendering and the camera are frame-driven.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics
import "scripts/CharacterMotion.js" as Motion
import "scripts/CompanionAI.js" as Companion
import "scripts/Courage.js" as Courage
import "config/tuning.js" as Tuning
import "config/strings.js" as Strings
import "config/level.js" as Level
import "config/build.js" as Build
import "scripts/Walkthrough.js" as Walkthrough
import "config/walkthrough.js" as WalkSteps

Item {
    id: game
    focus: true

    // ---- configuration -------------------------------------------------------------------------
    readonly property var args: Qt.application.arguments
    readonly property bool devMode: Build.devTools && args.indexOf("--no-dev") < 0
    readonly property bool autotest: args.indexOf("--autotest") >= 0
    readonly property bool walkthrough: args.indexOf("--walkthrough") >= 0
    property var wt: null
    property int wtLogged: 0
    property bool useModels: args.indexOf("--no-models") < 0
    // Model files: qrc:/ (relative) on desktop; on WebAssembly they are preloaded into the
    // in-memory filesystem under /game/ (own build: Qt loader `preload`; Web Runtime: assets-manifest.json).
    property string assetBase: Qt.platform.os === "wasm" ? "file:///game/" : ""
    property string language: save.settings.language || "pt_BR"
    function tr(key) { return Strings.tr(key, language) }

    // ---- state ---------------------------------------------------------------------------------------
    property string phase: "title"            // title | loading | playing | paused | complete
    property var world: Physics.makeWorld(Tuning.base.gravity)
    readonly property var characters: [isabela, pedro]
    property var active: isabela
    property var companion: pedro
    property var courageState: null
    property var companionAI: Companion.create()
    property var checkpoint: ({ id: "start", x: Level.level.start.x, y: Level.level.start.y })
    property var checkpointSnapshot: null
    property var currentSection: null
    property real elapsed: 0
    property real accumulator: 0
    property bool narrativeHold: false
    property real stepDistance: 0
    property int fps: 0
    property int frames: 0
    property real fpsClock: 0
    property string hintText: ""
    property string toastText: ""
    property string sectionBanner: ""
    property bool respawning: false
    property var interactables: []
    property int completionStars: 0
    // (a function, not a binding: the body/fsm are plain JS objects the binding system cannot observe)
    function canSwitch() { const m = companion.motion; return m && m.body.grounded && ["Scared", "Hang", "Climb"].indexOf(m.fsm.state) < 0 }

    signal shake(real strength)

    Component.onCompleted: {
        console.log("EscolaGame: boot", Qt.platform.os, "args", JSON.stringify(args), "save backend", save.backend)
        save.load()
        applySettings()
        if (autotest) { startNewGame(); autotestTimer.start() }
        if (walkthrough) { wt = Walkthrough.create(WalkSteps.steps); startNewGame(); wtGuard.start() }
    }

    function applySettings() {
        audio.musicVolume = save.settings.musicVolume
        audio.sfxVolume = save.settings.sfxVolume
        world3d.quality = save.settings.quality === undefined ? 1 : save.settings.quality
        if (save.settings.keys) input.keys = save.settings.keys
    }

    // ---- lifecycle -------------------------------------------------------------------------------------
    function ensureBuilt() {
        if (director.built) return
        director.build()
        isabela.create(Level.level.start.x, Level.level.start.y)
        pedro.create(Level.level.start.x - 1.6, Level.level.start.y)
        courageState = Courage.create([isabela.motion, pedro.motion])
    }
    function startNewGame() {
        phase = "loading"
        loadTimer.mode = "new"; loadTimer.start()
    }
    function continueGame() {
        if (!save.hasProgress) { startNewGame(); return }
        phase = "loading"
        loadTimer.mode = "continue"; loadTimer.start()
    }
    Timer {
        id: loadTimer
        property string mode: "new"
        interval: 60
        onTriggered: {
            game.ensureBuilt()
            if (mode === "new") {
                save.clearProgress()
                game.checkpoint = { id: "start", x: Level.level.start.x, y: Level.level.start.y }
                director.restore({})
                director.resetTriggersAfter(-1)
                game.placeAt(game.checkpoint.x, game.checkpoint.y)
                game.setActive(isabela, true)
                Courage.refill(game.courageState)
                game.elapsed = 0
                game.checkpointSnapshot = director.snapshot()
                game.toast(game.tr("story.intro"), 4000)
            } else {
                const p = save.profile
                game.checkpoint = { id: p.checkpoint, x: p.x, y: p.y }
                director.restore(p.world || {})
                director.markCheckpointsUpTo(p.x)
                director.resetTriggersAfter(p.x)
                for (const t of director.triggers) if (t.spec.x <= p.x) t.fired = true
                game.placeAt(p.x, p.y)
                game.setActive(p.activeCharacter === "pedro" ? pedro : isabela, true)
                Courage.apply(game.courageState, p.courage)
                game.elapsed = p.elapsed || 0
                game.checkpointSnapshot = director.snapshot()
            }
            game.enterSection(director.sectionAt(game.active.motion.body.x), true)
            game.phase = "playing"
            game.playSectionMusic()
        }
    }
    function placeAt(x, y) {
        Motion.teleport(isabela.motion, x, y); Motion.teleport(pedro.motion, x - 1.6, y)
        isabela.motion.frozen = false; pedro.motion.frozen = false
        isabela.sync(); pedro.sync()
        world3d.rig.snap(x, y)
    }
    function setActive(c, silent) {
        active = c
        companion = c === isabela ? pedro : isabela
        isabela.motion.controlled = c === isabela
        pedro.motion.controlled = c === pedro
        companionAI = Companion.create()
        isabela.sync(); pedro.sync()
        if (!silent) audio.play("switch_char")
    }
    function switchCharacter() {
        if (phase !== "playing" || respawning) return
        if (!canSwitch()) return
        setActive(companion, false)
    }
    function pause() { if (phase === "playing") { phase = "paused"; audio.pauseMusic() } }
    function resume() { if (phase === "paused") { phase = "playing"; audio.resumeMusic(); input.forceActiveFocus() } }
    function quitToTitle() { audio.stopMusic(); phase = "title" }

    // ---- the fixed-step loop ---------------------------------------------------------------------
    FrameAnimation {
        running: game.phase === "playing" || game.phase === "complete"
        onTriggered: game.frame(Math.min(0.1, frameTime))
    }
    function frame(dt) {
        frames++; fpsClock += dt
        if (fpsClock >= 0.5) { fps = Math.round(frames / fpsClock); frames = 0; fpsClock = 0 }
        if (phase === "playing") {
            accumulator += dt
            let steps = 0
            while (accumulator >= Tuning.level.fixedStep && steps < Tuning.level.maxStepsPerFrame) { fixedStep(Tuning.level.fixedStep); accumulator -= Tuning.level.fixedStep; steps++ }
            if (steps === Tuning.level.maxStepsPerFrame) accumulator = 0
        } else if (phase === "complete") {
            for (const c of characters) { Motion.update(c.motion, dt); c.sync() }
            if (wt && !wt.done) { const r = Walkthrough.tick(wt, game, dt); while (wtLogged < wt.log.length) console.log("WALKTHROUGH", wt.log[wtLogged++]); if (wt.done) finishWalkthrough() }
        }
        // camera follows the active sibling
        const rig = world3d.rig
        rig.targetX = active.px; rig.targetVx = active.motion ? active.motion.body.vx : 0
        if (active.grounded || active.py < rig.targetGroundY) rig.targetGroundY = active.py
        rig.companionX = companion.px; rig.companionY = companion.py
        rig.update(dt)
    }

    function fixedStep(dt) {
        director.step(dt, active)
        let snap = input.snapshot()
        if (wt && !wt.done) {
            const r = Walkthrough.tick(wt, game, dt)
            snap = r.input
            if (r.switchTo && active.characterId !== r.switchTo) switchCharacter()
            if (r.interact) snap.interactPressed = true
            if (r.ability) snap.abilityPressed = true
            while (wtLogged < wt.log.length) console.log("WALKTHROUGH", wt.log[wtLogged++])
            if (wt.done) finishWalkthrough()
        }
        if (narrativeHold || respawning) { snap.moveX = 0; snap.moveY = 0; snap.jumpPressed = false; snap.jumpHeld = false; snap.interactPressed = false; snap.abilityPressed = false; snap.downHeld = false }
        Motion.setInput(active.motion, snap)
        // companion AI
        const blocked = director.blockedFor(companion, active)
        const r = Companion.think(companionAI, companion.motion, active.motion, world, dt, { blockedZone: blocked, hold: narrativeHold || respawning })
        if (r.teleport) { Motion.teleport(companion.motion, r.teleport.x, r.teleport.y); fx.puff(r.teleport.x, r.teleport.y) }
        if (r.wave) Motion.wave(companion.motion)
        Motion.setInput(companion.motion, r.input)
        // characters
        for (const c of characters) {
            const m = c.motion
            Motion.update(m, dt)
            for (const ev of m.events) onCharacterEvent(c, ev)
            if (m.pushing) { m.pushing.push(m.pushSign); if (c === active) audio.play("push", 0.5) }
            if (m.body.y < Tuning.level.killY) fell(c)
        }
        if (snap.abilityPressed) useAbility(active)
        if (snap.interactPressed) tryInteract(active)
        director.afterCharacters(dt, active)
        interactables = director.interactablesNear(active)
        footsteps(dt)
        const sec = director.sectionAt(active.motion.body.x)
        if (sec !== currentSection) enterSection(sec, false)
        elapsed += dt
        for (const c of characters) c.sync()
    }

    function onCharacterEvent(c, ev) {
        switch (ev.name) {
        case "jump": audio.play("jump", c === active ? 0.8 : 0.4); break
        case "land": audio.play("land", Math.min(1, ev.speed / 14)); fx.landPuff(c.px, c.py, ev.speed); if (c === active && ev.speed > 12) shake(0.25); break
        case "grab": audio.play("grab"); break
        case "climb": audio.play("metal", 0.35); break
        case "hurt": break
        }
    }

    function footsteps(dt) {
        const m = active.motion
        if (!m.body.grounded || (m.fsm.state !== "Walk" && m.fsm.state !== "Run" && m.fsm.state !== "Push")) { stepDistance = 0; return }
        stepDistance += Math.abs(m.body.vx) * dt
        if (stepDistance > 1.35) {
            stepDistance = 0
            const g = m.body.ground
            audio.footstep(g ? (g.tag === "moving" ? "metal" : (g.tag === "ground" ? (director.sectionAt(m.body.x).id === "corredor" ? "tile" : "grass") : "concrete")) : "grass")
        }
    }

    // ---- abilities & interaction -------------------------------------------------------------------
    function useAbility(c) {
        const m = c.motion
        if (m.abilityCooldown > 0 || m.frozen) return
        m.abilityCooldown = c.def.abilityCooldown
        if (c.def.ability === "notebook") {
            const n = director.revealNear(m.body.x, c.def.abilityRadius)
            Motion.interact(m)
            fx.pulse(c.px, c.py + 1, "#f2c530")
            if (n > 0) { audio.play("reveal"); toast(tr("hud.revealed"), 2500) } else { audio.play("ui_move"); toast(tr("hud.nothingHere"), 1500) }
        } else {
            const n = director.curiosityNear(m.body.x, c.def.abilityRadius)
            fx.pulse(c.px, c.py + 0.8, "#27b3c6")
            if (m.body.grounded) m.body.vx = m.facing * 10.5      // a curious little dash
            if (n > 0) { audio.play("reveal"); toast(tr("hud.curiosity"), 2500) } else audio.play("whoosh", 0.6)
        }
    }
    function tryInteract(c) {
        const list = director.interactablesNear(c)
        if (!list.length) return
        const target = list[0]
        Motion.interact(c.motion)
        if (target === director.finalDoor) {
            target.interact(c.characterId)
            audio.play("ui_accept")
            if (!target.open) toast(tr("hud.needBoth"), 1500)
        } else {
            target.interact()
        }
    }

    // ---- Courage, falls, respawn -------------------------------------------------------------------
    function hazardHit(characterId, fromX) {
        const c = characterId === "isabela" ? isabela : pedro
        const res = Courage.touch(courageState, c.motion, fromX)
        if (res === "ignored") return
        audio.play("courage_lose")
        shake(0.35)
        if (res === "depleted") loseAllCourage()
        else toast(tr("hud.courageLost"), 1200)
    }
    function fell(c) {
        const res = Courage.touch(courageState, c.motion, c.motion.body.x + 1)
        if (res === "depleted") { loseAllCourage(); return }
        Motion.teleport(c.motion, c.motion.lastSafe.x, c.motion.lastSafe.y)
        if (c === active) { audio.play("courage_lose"); toast(tr("hud.courageLost"), 1200); world3d.rig.snap(c.px, c.py) }
    }
    function loseAllCourage() {
        if (respawning) return
        respawning = true
        audio.play("courage_out")
        toast(tr("hud.courageOut"), 2200)
        fade.respawn()
    }
    function respawnAtCheckpoint() {
        director.restore(checkpointSnapshot || {})
        director.markCheckpointsUpTo(checkpoint.x)
        placeAt(checkpoint.x, checkpoint.y)
        Courage.refill(courageState)
        for (const c of characters) c.sync()
        respawning = false
    }
    function restartCheckpoint() { if (phase === "paused") { resume() } if (phase === "playing") { respawning = true; fade.respawn() } }

    // ---- level events ---------------------------------------------------------------------------------
    function onCheckpoint(id, x, y) {
        checkpoint = { id: id, x: x, y: y }
        checkpointSnapshot = director.snapshot()
        save.saveCheckpoint({ level: Level.level.id, checkpoint: id, x: x, y: y, activeCharacter: active.characterId,
                              courage: Courage.snapshot(courageState), world: checkpointSnapshot, collected: director.collected,
                              memoryFound: director.memoryFound, elapsed: elapsed })
        audio.play("checkpoint")
        toast(tr("hud.checkpoint"), 1800)
    }
    function onCollected(kind, id, x, y) {
        if (kind === "star") { audio.play("collect_star"); fx.sparkle(x, y, "#ffd23f"); const c = Math.abs(isabela.px - x) < Math.abs(pedro.px - x) ? isabela : pedro; Courage.encourage(courageState, c.motion) }
        else if (kind === "pencil") { audio.play("collect_pencil"); fx.sparkle(x, y, "#e33f3f"); toast(tr("hud.pencilFound"), 1800) }
        else { audio.play("collect_memory"); fx.sparkle(x, y, "#e64b7a"); toast(tr("hud.memoryFound"), 3000); save.writeProfile(Object.assign({}, save.profile || {}, { memoryFound: true })) }
    }
    function onTrigger(id, spec) {
        if (spec.narrative) {
            const key = "story." + spec.narrative
            toast(tr(key), 4200)
            if (spec.narrative === "bell") { audio.play("bell"); world3d.rig.zoom = 1.12; zoomBack.restart() }
            if (spec.narrative === "gate_far") { world3d.rig.zoom = 1.18; zoomBack.restart() }
            if (spec.narrative === "corridor_grows") { world3d.rig.zoom = 0.9; zoomBack.restart() }
            return
        }
        if (id.indexOf("hint.") === 0) hint(tr(id), 5200)
    }
    Timer { id: zoomBack; interval: 2600; onTriggered: world3d.rig.zoom = 1 }
    function onGateOpened(id, spec) {
        audio.play("gate_open")
        if (spec.narrative) toast(tr("story." + spec.narrative), 4000); else toast(tr("hud.gateOpen"), 1600)
        world3d.rig.focusX = spec.x; world3d.rig.focusY = spec.y; world3d.rig.zoom = 0.85
        focusBack.restart()
    }
    Timer { id: focusBack; interval: 1700; onTriggered: { world3d.rig.focusX = NaN; world3d.rig.focusY = NaN; world3d.rig.zoom = 1 } }
    function onSwitch(id) { audio.play("mechanism"); toast(tr("hud.mechanism"), 1200) }
    function onRevealed(gid, n) { }
    function onLevelFinished() {
        phase = "complete"
        completionStars = director.stars
        for (const c of characters) Motion.celebrate(c.motion)
        audio.stopMusic(); audio.play("level_complete"); audio.playMusic("end")
        world3d.rig.focusX = director.finalDoor.spec.x - 0.2; world3d.rig.focusY = director.finalDoor.spec.y + 0.4; world3d.rig.zoom = 0.5
        toast(tr("story.finished"), 5000)
        backToNormal.start()
        save.recordCompletion(elapsed, director.stars, director.pencils, director.memoryFound)
        save.clearProgress()
        completeTimer.start()
    }
    // "the objects go back to their normal size": the props shrink toward the ground
    SequentialAnimation { id: backToNormal; PauseAnimation { duration: 800 }
        ParallelAnimation {
            Vector3dAnimation { target: world3d.propRoot; property: "scale"; to: Qt.vector3d(1, 0.72, 1); duration: 1600; easing.type: Easing.InOutQuad }
            Vector3dAnimation { target: world3d.platformRoot; property: "scale"; to: Qt.vector3d(1, 0.9, 1); duration: 1600; easing.type: Easing.InOutQuad }
        } }
    Timer { id: completeTimer; interval: 3600; onTriggered: menu.showCompletion() }
    function resetWorldScale() { world3d.propRoot.scale = Qt.vector3d(1, 1, 1); world3d.platformRoot.scale = Qt.vector3d(1, 1, 1) }

    // ---- sections -----------------------------------------------------------------------------------------
    function enterSection(sec, silent) {
        currentSection = sec
        const rig = world3d.rig
        rig.boundsX0 = sec.x0; rig.boundsX1 = sec.x1
        rig.sectionDistance = sec.camera.distance; rig.sectionHeight = sec.camera.height
        world3d.skyColor = sec.sky; world3d.farColor = sec.far; world3d.indoor = sec.indoor === true
        if (!silent) { sectionBanner = tr(sec.nameKey); bannerTimer.restart(); playSectionMusic() }
        else sectionBanner = tr(sec.nameKey), bannerTimer.restart()
    }
    function playSectionMusic() { if (currentSection) audio.playMusic(currentSection.music) }
    Timer { id: bannerTimer; interval: 2600; onTriggered: game.sectionBanner = "" }

    // ---- messages ---------------------------------------------------------------------------------------------
    function toast(text, ms) { toastText = text; toastTimer.interval = ms || 2000; toastTimer.restart() }
    Timer { id: toastTimer; onTriggered: game.toastText = "" }
    function hint(text, ms) { hintText = text; hintTimer.interval = ms || 4000; hintTimer.restart() }
    Timer { id: hintTimer; onTriggered: game.hintText = "" }

    // ---- walkthrough support ----------------------------------------------------------------------------
    function activeX() { return active.motion.body.x }
    function activeY() { return active.motion.body.y }
    function activeGrounded() { return active.motion.body.grounded }
    function activeVx() { return active.motion.body.vx }
    function activeState() { return active.motion.fsm.state }
    function activeId() { return active.characterId }
    function companionState() { return companion.motion.fsm.state }
    function companionX() { return companion.motion.body.x }
    function describeBlockers() {
        const b = active.motion.body
        const probe = { x: b.x - b.w / 2 - 0.5, y: b.y - 0.1, w: b.w + 1.0, h: b.h + 0.2 }
        const out = []
        for (const s of world.solids) if (Physics.overlap(probe, s)) out.push((s.id || "?") + ":" + s.kind + (s.enabled ? "" : "(off)") + "@" + s.x.toFixed(1) + "," + s.y.toFixed(1) + " " + s.w.toFixed(1) + "x" + s.h.toFixed(1) + (s.tag ? " " + s.tag : ""))
        for (const pu of director.pushables) if (Math.abs(pu.body.x - b.x) < 12) out.push("pushable " + pu.spec.id + "@" + pu.body.x.toFixed(2) + "," + pu.body.y.toFixed(2))
        return out.join(" | ")
    }
    function check(s) {
        if (s.gateOpen !== undefined) { for (const g of director.gates) if (g.spec.id === s.gateOpen) return g.open ? true : "gate " + s.gateOpen + " closed"; return "no gate " + s.gateOpen }
        if (s.switchOn !== undefined) { const sw = director.switches[s.switchOn]; return sw ? (sw.active ? true : "switch off") : "no switch " + s.switchOn }
        if (s.xMin !== undefined) return activeX() >= s.xMin ? true : "x=" + activeX().toFixed(2)
        if (s.yMin !== undefined) return activeY() >= s.yMin && activeGrounded() ? true : "y=" + activeY().toFixed(2) + " grounded=" + activeGrounded()
        if (s.yMax !== undefined) return activeY() <= s.yMax && activeGrounded() ? true : "y=" + activeY().toFixed(2)
        if (s.stars !== undefined) return director.stars >= s.stars ? true : "stars=" + director.stars
        if (s.memory !== undefined) return director.memoryFound === s.memory ? true : "memory=" + director.memoryFound
        if (s.checkpoint !== undefined) return checkpoint.id === s.checkpoint ? true : "checkpoint=" + checkpoint.id
        if (s.finished !== undefined) return (phase === "complete") === s.finished ? true : "phase=" + phase
        return "unknown expectation"
    }
    function finishWalkthrough() {
        while (wtLogged < wt.log.length) console.log("WALKTHROUGH", wt.log[wtLogged++])
        console.log("WALKTHROUGH done:", wt.failures.length, "failures,", wt.steps.length, "steps; stars", director.stars, "/", director.starsTotal, "pencils", director.pencils, "memory", director.memoryFound, "phase", phase, "elapsed", elapsed.toFixed(1))
        for (const f of wt.failures) console.log("WALKTHROUGH FAILURE", f)
        if (Qt.platform.os !== "wasm") Qt.exit(wt.failures.length ? 1 : 0)
    }
    Timer { id: wtGuard; interval: 420000; onTriggered: { console.log("WALKTHROUGH guard timeout at step", game.wt ? game.wt.index : -1); game.wt.done = true; game.finishWalkthrough() } }

    // ---- accessors for the HUD / menus (they must not reach into the director directly) ------------------
    function director_stars() { return director.stars }
    function director_starsTotal() { return director.starsTotal || 40 }
    function director_pencils() { return director.pencils }
    function director_pencilsTotal() { return director.pencilsTotal || 6 }
    function director_memory() { return director.memoryFound }
    function inputGamepad() { return input.gamepadConnected }
    function inputGamepadName() { return input.gamepadName }
    function version() { return Build.version }
    function isabelaRef() { return isabela }
    function pedroRef() { return pedro }

    // ---- dev helpers (also used by --autotest) ----------------------------------------------------------------
    function teleportTo(x, y) { placeAt(x, y); enterSection(director.sectionAt(x), true) }
    readonly property string shotDir: { const i = args.indexOf("--shots"); return i >= 0 && i + 1 < args.length ? args[i + 1] : "" }
    function saveShot(name) {
        if (!shotDir) return
        game.grabToImage(function (result) { const p = shotDir + "/" + name + ".png"; result.saveToFile(p); console.log("AUTOTEST shot", p) })
    }
    function screenshotInfo() { return { x: active.px.toFixed(2), y: active.py.toFixed(2), state: active.state, section: currentSection ? currentSection.id : "" } }

    // ================================================================================================
    GameWorld {
        id: world3d
        anchors.fill: parent
        debugColliders: devTools.item ? devTools.item.showColliders : false
    }
    Character { id: isabela; parent: world3d.characterRoot; characterId: "isabela"; world: game.world; assetBase: game.assetBase; useModels: game.useModels }
    Character { id: pedro; parent: world3d.characterRoot; characterId: "pedro"; world: game.world; assetBase: game.assetBase; useModels: game.useModels }
    LevelDirector {
        id: director
        world: game.world
        characters: [isabela, pedro]
        propRoot: world3d.propRoot; platformRoot: world3d.platformRoot; entityRoot: world3d.entityRoot
        assetBase: game.assetBase; useModels: game.useModels
        onCollectedItem: (kind, id, x, y) => game.onCollected(kind, id, x, y)
        onCheckpointReached: (id, x, y) => game.onCheckpoint(id, x, y)
        onGateOpened: (id, spec) => game.onGateOpened(id, spec)
        onTriggerFired: (id, spec) => game.onTrigger(id, spec)
        onSwitchActivated: (id) => game.onSwitch(id)
        onHazardHit: (characterId, fromX) => game.hazardHit(characterId, fromX)
        onRevealed: (gid, n) => game.onRevealed(gid, n)
        onLevelFinished: game.onLevelFinished()
    }
    Effects { id: fx; parent: world3d.fxRoot }
    AudioManager { id: audio }
    SaveSystem { id: save }
    InputManager {
        id: input
        anchors.fill: parent
        gameplayEnabled: game.phase === "playing"
        onSwitchRequested: if (game.phase === "playing") game.switchCharacter()
        onPauseRequested: { if (game.phase === "playing") game.pause(); else if (game.phase === "paused") game.resume() }
    }
    MouseArea { anchors.fill: parent; onPressed: (mouse) => { input.forceActiveFocus(); mouse.accepted = false } }

    Hud {
        id: hud
        anchors.fill: parent
        visible: game.phase === "playing" || game.phase === "complete"
        game: game
    }
    ScreenFade { id: fade; anchors.fill: parent; onRespawnMidpoint: game.respawnAtCheckpoint() }
    MenuOverlay {
        id: menu
        anchors.fill: parent
        game: game
        input: input
        save: save
        audio: audio
    }
    Loader {
        id: devTools
        anchors.fill: parent
        active: game.devMode
        source: game.devMode ? "DevTools.qml" : ""
        onLoaded: { item.game = game; item.director = director; item.world3d = world3d; item.input = input }
    }

    // ---- --autotest: a scripted 25 s run through the first section (headless smoke check) ----------------
    Timer {
        id: autotestTimer
        interval: 250; repeat: true
        property int ticks: 0
        onTriggered: {
            ticks++
            if (game.phase !== "playing") return
            if (ticks % 4 === 0) console.log("AUTOTEST", JSON.stringify(game.screenshotInfo()), "fps", game.fps, "stars", director.stars)
            if (ticks % 20 === 6) game.saveShot("autotest-" + ticks)
            if (ticks === 8) game.switchCharacter()
            if (ticks === 40) game.teleportTo(130, 0)
            if (ticks === 60) game.teleportTo(240, 0)
            if (ticks === 80) game.teleportTo(470, 0)
            if (ticks >= 100) { console.log("AUTOTEST done: stars", director.stars, "/", director.starsTotal, "checkpoint", game.checkpoint.id, "section", game.currentSection.id); stop(); if (Qt.platform.os !== "wasm") Qt.quit() }
        }
    }
    Timer {
        // scripted input for the autotest: hold right, hop periodically
        running: game.autotest && game.phase === "playing"
        interval: 50; repeat: true
        property int n: 0
        onTriggered: { n++; input.press("right"); if (n % 14 === 0) { input.press("jump"); input.release("jump") } }
    }
}
