# Architecture

The game is plain QML/JS on top of Clayground, one system per file. Gameplay is pure JavaScript
over plain objects (testable in Node in a second); QML is the view and the composition root.

```
Main.qml (Window)  ─┐                                web-runtime/Main.qml (Web Runtime) ─┐
                    ▼                                                                    ▼
             EscolaGame.qml  — game bootstrap, phases (title/loading/playing/paused/complete),
                    │          fixed 60 Hz step, character switching, Courage, abilities,
                    │          interaction, sections/music, checkpoints, messages, --autotest
     ┌──────────────┼───────────────────────┬────────────────┬──────────────┬────────────┐
     ▼              ▼                       ▼                ▼              ▼            ▼
 GameWorld     Character ×2            LevelDirector     InputManager   AudioManager  SaveSystem
 (View3D,      (Node mirror of a       (builds level.js  (keyboard,     (Sound +      (SaveStore:
  lights,       CharacterMotion         into Physics      GamepadBridge, Timer loops)   localStorage /
  SideCamera,   JS object)              solids + QML      touch pad)                    QSettings)
  roots)        │                       entities; runs
                ▼                       mechanisms,
          CharacterVisual               pickups, hazards,
          (model | sprite |             checkpoints,
           placeholder)                 snapshot/restore)
                                             │
              Prop · GroundSlab · MovingPlatform · Pushable · Switch (button/lever/plate) · Gate ·
              Collectible · Checkpoint · Hazard (ball/plane) · TriggerZone · FinalDoor  — each with a PropVisual
```

## Pure-JS systems (`app/scripts`)

| Module | Responsibility |
|---|---|
| `Physics.js` | side-plane AABB kinematics: solids (`solid`, `oneway`, `low` passages with a `gap`, `ladder` zones), swept step, ground probe, ledge detection, moving solids that carry riders |
| `StateMachine.js` | explicit FSM (`create/set/update/is`) |
| `CharacterMotion.js` | the character controller: acceleration/deceleration, coyote time, jump buffer, variable jump height, moderate air control, crouch/crawl (Pedro), ledge grab + climb (Isabela), ladders, pushing, hurt/knockback, safe-spot tracking; drives the FSM with states Idle, Walk, Run, JumpStart, JumpLoop, Land, Push, Interact, Climb, Hang, Crawl, Scared, Celebrate, Wave |
| `CompanionAI.js` | input for the inactive sibling: follow, keep distance, step aside, jump small gaps and low walls, crawl through passages, wait at wide gaps or exclusive zones (waving), teleport to the leader's last safe spot when far or stuck |
| `Courage.js` | Courage instead of hit points: touch → −1 + invulnerability, zero → respawn both at the checkpoint, stars restore |
| `LevelCheck.js` | validation of `config/level.js` (counts, references, section order) used by tests and the dev tools |
| `PlaceholderShapes.js` | toon-box compositions for every manifest `placeholder.shape` |

## Data (`app/config`)

* `level.js` — the level as data: sections with camera/sky/music and entity lists (ground, platform, wall,
  lowpass, ladder, moving, pushable, button/lever/plate, gate, star/pencil/memory, checkpoint, trigger,
  zone, ball/plane, finaldoor, prop). Positions in metres; `asset` ids only.
* `assets.js` — the manifest: id → model path, sprite sheet, representation, scale, footOffset, rotation,
  suggested collider, shadow, placeholder look, status. `scripts/update-asset-manifest.py` maintains it.
* `tuning.js` — movement feel, per-character abilities, companion, camera, Courage, fixed step.
* `strings.js` — pt-BR + en, `tr(key, lang)`.
* `build.js` (generated) — dev tools on/off, version.

## Coordinates, physics, camera

* +X is the way to the classroom, +Y up, Z is visual depth only (props at z < 0, play plane z = 0).
* Colliders are primitive boxes given in `level.js`, never the model geometry. Gym equipment gets
  separate solids for bars (`lowpass`), top platform and lever/button sensors.
* Sensors/triggers are boxes tested against body boxes each step; hazards have their own hit boxes.
* Camera (`SideCamera.qml`): exponential smoothing, velocity look-ahead, vertical window that ignores
  jumps, section bounds, both-sibling framing, event zoom/focus. No rotation.
* Qt Quick 3D Physics is not used (it crashes on WebAssembly and a platformer wants deterministic
  collision); the JS physics runs at a fixed 60 Hz with up to 4 catch-up steps per frame.

## Visual abstraction (3D ↔ sprites)

`PropVisual` and `CharacterVisual` pick, per manifest entry, a balsam-imported model (`Loader3D`,
`clip` property for skeletal clips), a `Sprite3D` billboard (UV-offset frames from a QtMeshEditor sheet)
or the placeholder. Physics, control and level logic never look at the representation. To flip an entity:

```js
school_bench: { representation: "sprite", sprite: { sheet: "assets/sprites/school_bench.png", columns: 8, rows: 1, frames: 8, fps: 0 }, ... }
```

## Save

`SaveSystem` keeps one JSON profile (checkpoint id/position, active character, Courage, the level
snapshot - switches, gates, pushable positions, revealed groups - collected ids, memory, elapsed,
best time) and settings (volumes, language, quality, key bindings) through `SaveStore` (C++):
browser `localStorage` on WebAssembly, `QSettings` on desktop.

## Future co-op

Each `Character` already owns an independent input snapshot per fixed step (`Motion.setInput`);
the companion AI is just another input source. A second local player means a second `InputManager`
feeding the other character instead of `CompanionAI.think()`, and a camera that always frames both.

## Walkthrough harness

`--walkthrough` plays `app/config/walkthrough.js` against the real game: high-level steps (`move`,
`jump`, `hopOnto` a pushed object from whichever side, `crawl`, `climb`, `switch`, `interact`,
`ability`, `expect` gate/switch/checkpoint/position) produce the input snapshot each fixed step, so the
route from the square to the classroom door is an executable specification (exit code 0 = completable).
Iterate on one section with `--wt-from <step> --wt-pos <x>,<y> --wt-active pedro|isabela` and
`--wt-trace` (per-frame body state for move/jump steps). Failure lines list the solids around the
character (`blockers=`) and the pushables nearby.

## Development tools (`DevTools.qml`, compiled only with `ESCOLA_DEV_TOOLS=ON`)

F1 panel: collider view (F2), character states, FPS, coordinates, teleport to checkpoints, restart a
section, pick the active character, unlock collectibles, press any mechanism, platform/hazard speed,
level validation report. `--autotest` runs a scripted pass for headless checks.
