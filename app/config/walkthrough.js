// The intended route through "O Caminho para a Sala", as walkthrough steps (scripts/Walkthrough.js).
// `escola_aventura --walkthrough` plays it against the real game and reports every step; it is the
// executable proof that the level can be completed with the two siblings' abilities.
.pragma library

var steps = [
    // ---- 1. pracinha: tutorial ----------------------------------------------------------------
    { do: "move", x: 12.8 }, { do: "jump", x: 13.4, dir: 1 }, { do: "move", x: 17.6 },
    { do: "jump", x: 23.5, dir: 1, hold: 0.35 }, { do: "expect", xMin: 26.5 },
    { do: "jump", x: 29.2, dir: 1, hold: 0.45 }, { do: "move", x: 33.6 },                    // over the bench
    { do: "jump", x: 34.2, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 }, { do: "move", x: 36.2 }, { do: "move", x: 38.2 },
    // challenge 1: parallel bars - Isabela up to the lever, Pedro under to the button
    { do: "move", x: 41.2 }, { do: "jump", x: 41.7, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 },
    { do: "move", x: 49.5 }, { do: "interact" }, { do: "expect", switchOn: "lever_bars" },
    { do: "switch", to: "pedro" }, { do: "move", x: 41.5 }, { do: "crawl", x: 47 }, { do: "expect", switchOn: "button_bars" },
    { do: "crawl", x: 52 }, { do: "expect", gateOpen: "gate_bars" },
    { do: "switch", to: "isabela" }, { do: "move", x: 52.5 }, { do: "move", x: 57 },
    // challenge 2: the ladder (Isabela) and the box route (Pedro)
    { do: "jump", x: 62.8, dir: 0, stand: true, hold: 0.4, up: true }, { do: "climb", seconds: 1.4 }, { do: "expect", yMin: 3.9 },
    { do: "move", x: 71.2 }, { do: "jump", x: 71.3, dir: 1, hold: 0.3 }, { do: "expect", yMin: 2.5 }, { do: "move", x: 77.5 }, { do: "expect", yMax: 0.1 }, { do: "move", x: 81.5 },
    { do: "switch", to: "pedro" }, { do: "jump", x: 70.2, dir: -1, hold: 0.35 }, { do: "move", x: 66.8 }, { do: "hold", moveX: 1, seconds: 3.6 },
    { do: "hopOnto", pushable: "box_ladder" }, { do: "jump", fromPushable: "box_ladder", offset: -0.5, dir: 1, hold: 0.4 }, { do: "expect", yMin: 2.5 },
    { do: "move", x: 77.5 }, { do: "expect", yMax: 0.1 }, { do: "move", x: 81.5 },
    // challenge 3: the swing - the easy route through the pit, plus the Family Memory
    { do: "switch", to: "isabela" }, { do: "move", x: 84.7 }, { do: "expect", yMax: -2.0 },
    { do: "jump", x: 84.7, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 }, { do: "expect", yMin: -0.1 },
    { do: "move", x: 89.1, dropFromLedge: true }, { do: "expect", yMax: -2.0 },
    { do: "expect", memory: true },
    { do: "jump", x: 89.3, dir: 1, hold: 0.25, air: 0.3 }, { do: "expect", yMin: -1.3 }, { do: "jump", x: 90.3, dir: 1, hold: 0.45, air: 0.4 }, { do: "expect", yMin: -0.1 }, { do: "move", x: 94 },
    // challenge 4: the distant gate - hops, then both on the marks
    { do: "hopOnto", left: 99, right: 101.4, top: 1.0 }, { do: "move", x: 101.8 }, { do: "hopOnto", left: 103, right: 105.2, top: 0.8 }, { do: "move", x: 105.6 },
    { do: "jump", x: 106.0, dir: 1, hold: 0.25, air: 0.25 }, { do: "move", x: 109.4 }, { do: "hopOnto", left: 110, right: 111.4, top: 1.2 }, { do: "move", x: 111.9 },
    { do: "move", x: 122.4 }, { do: "hopOnto", left: 123, right: 125.5, top: 1.0 }, { do: "move", x: 125.9 }, { do: "move", x: 126.2 },
    { do: "switch", to: "pedro" }, { do: "move", x: 127.8 }, { do: "expect", gateOpen: "gate_school" },
    { do: "move", x: 132.6 }, { do: "expect", checkpoint: "cp_gate" },

    // ---- 2. jardim ------------------------------------------------------------------------------
    { do: "switch", to: "isabela" }, { do: "move", x: 143.6 }, { do: "hold", moveX: 1, seconds: 2.5 },
    { do: "hopOnto", pushable: "bench_garden" }, { do: "jump", fromPushable: "bench_garden", dir: 1, hold: 0.45, air: 0.45 }, { do: "expect", yMin: 2.1 }, { do: "move", x: 151.5 },
    { do: "switch", to: "pedro" }, { do: "hopOnto", pushable: "bench_garden" }, { do: "jump", fromPushable: "bench_garden", dir: 1, hold: 0.45, air: 0.45 }, { do: "expect", yMin: 2.1 },
    { do: "move", x: 155.5 }, { do: "move", x: 158.6 }, { do: "expect", yMax: 0.1 },
    // main challenge: Pedro crawls through the planter passage to the button and out the far side;
    // Isabela climbs over, pushes the bench under the high planter and grabs up to the lever
    { do: "move", x: 159.6 }, { do: "crawl", x: 162 }, { do: "expect", switchOn: "button_garden" }, { do: "crawl", x: 164.7 }, { do: "expect", xMin: 164.3 },
    { do: "switch", to: "isabela" }, { do: "move", x: 159.5 }, { do: "jump", x: 159.6, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 },
    { do: "move", x: 164.8 }, { do: "hold", moveX: 1, seconds: 2.8 },
    { do: "hopOnto", pushable: "bench_garden2" }, { do: "jump", fromPushable: "bench_garden2", dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 },
    { do: "expect", yMin: 4.3 }, { do: "move", x: 173 }, { do: "interact" }, { do: "expect", gateOpen: "gate_garden" }, { do: "move", x: 176.5 }, { do: "move", x: 182 },
    // the notebook secret
    { do: "move", x: 183.4 }, { do: "ability" }, { do: "jump", x: 183.4, dir: 1, hold: 0.45, air: 0.3 }, { do: "expect", yMin: 1.8 },
    { do: "jump", x: 185.2, dir: 1, hold: 0.45 }, { do: "expect", yMin: 3.4 }, { do: "jump", x: 188.2, dir: 1, hold: 0.45 }, { do: "expect", yMin: 5.0 },
    { do: "move", x: 191 }, { do: "move", x: 192.8 }, { do: "move", x: 196 },

    // ---- 3. playground --------------------------------------------------------------------------
    { do: "move", x: 206 }, { do: "climb", seconds: 1.6 }, { do: "expect", yMin: 3.4 },
    { do: "jump", x: 206.4, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 }, { do: "move", x: 209.5 }, { do: "move", x: 212.6 },
    { do: "move", x: 216.4 }, { do: "expect", yMin: 3.3 }, { do: "jump", x: 216.6, dir: 1, hold: 0.35, air: 0.4 }, { do: "expect", yMin: 3.3 },
    { do: "move", x: 220 }, { do: "jump", x: 221, dir: 1, hold: 0.45, air: 0.45 }, { do: "expect", yMin: 5.2 }, { do: "move", x: 223.5 }, { do: "interact" },
    { do: "expect", switchOn: "lever_play" },
    { do: "switch", to: "pedro" }, { do: "move", x: 224.5 }, { do: "crawl", x: 231.2 }, { do: "expect", switchOn: "button_play" }, { do: "expect", gateOpen: "gate_play" },
    { do: "jump", x: 231.6, dir: 1, hold: 0.45 }, { do: "move", x: 239.5 }, { do: "move", x: 242.6 }, { do: "expect", checkpoint: "cp_playground" },
    { do: "move", x: 262.5 },

    // ---- 4. patio -------------------------------------------------------------------------------
    { do: "hopOnto", left: 270, right: 272.4, top: 1.0 }, { do: "move", x: 272 }, { do: "hopOnto", left: 274.5, right: 277.5, top: 1.5, hold: 0.35 }, { do: "move", x: 277.9 },
    { do: "hopOnto", left: 279.5, right: 281.9, top: 1.0 }, { do: "move", x: 282.4 },
    { do: "hopOnto", left: 287, right: 289.4, top: 1.0 }, { do: "move", x: 289.6 }, { do: "jump", x: 293.6, dir: 1, hold: 0.4, air: 0.25 }, { do: "expect", yMin: 1.3 }, { do: "move", x: 297.6 },
    { do: "move", x: 301.8 }, { do: "hopOnto", left: 302.5, right: 304.1, top: 1.2, hold: 0.3 }, { do: "move", x: 304.6 },
    { do: "move", x: 306.2 }, { do: "hold", moveX: 1, seconds: 4.5 }, { do: "expect", switchOn: "button_patio" }, { do: "expect", gateOpen: "gate_patio" },
    { do: "jump", x: 313.4, dir: 1, hold: 0.4 }, { do: "move", x: 319.6 }, { do: "expect", yMax: -2.2 },
    { do: "hopOnto", left: 324.5, right: 325.5, top: -1.4, hold: 0.3 }, { do: "jump", x: 325.3, dir: 1, hold: 0.45, air: 0.3 }, { do: "expect", yMin: -0.1 }, { do: "move", x: 334 },

    // ---- 5. quadra ------------------------------------------------------------------------------
    { do: "switch", to: "isabela" }, { do: "move", x: 351.2 }, { do: "hold", moveX: 1, seconds: 4.8 },
    { do: "hopOnto", pushable: "bench_court" }, { do: "jump", fromPushable: "bench_court", dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.4 },
    { do: "jump", x: 360.3, dir: 1, hold: 0.5, air: 0.3 }, { do: "expect", yMin: 4.5 }, { do: "move", x: 362.3 }, { do: "move", x: 364.4 }, { do: "expect", yMax: 0.1 },
    { do: "switch", to: "pedro" }, { do: "hopOnto", pushable: "bench_court" }, { do: "jump", fromPushable: "bench_court", dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.4 },
    { do: "move", x: 361.3 }, { do: "move", x: 365.0 }, { do: "crawl", x: 387.6, timeout: 20 }, { do: "expect", switchOn: "plate_goal", timeout: 5 },
    { do: "jump", x: 387.6, dir: 1, hold: 0.4 }, { do: "move", x: 394.6 }, { do: "expect", switchOn: "button_court" }, { do: "expect", gateOpen: "gate_court" },
    { do: "move", x: 399.6 }, { do: "expect", checkpoint: "cp_court" },

    // ---- 6. corredor ----------------------------------------------------------------------------
    { do: "hopOnto", left: 407, right: 408.4, top: 1.0 }, { do: "jump", x: 408.2, dir: 1, hold: 0.3, air: 0.3 }, { do: "expect", yMin: 1.7 }, { do: "move", x: 411.5 }, { do: "hopOnto", left: 412, right: 413.4, top: 1.0 }, { do: "move", x: 414 },
    { do: "switch", to: "isabela" }, { do: "hopOnto", left: 407, right: 408.4, top: 1.0, skipIfPast: true }, { do: "hopOnto", left: 409.5, right: 410.9, top: 1.8, hold: 0.3, skipIfPast: true }, { do: "move", x: 411.5 }, { do: "hopOnto", left: 412, right: 413.4, top: 1.0, skipIfPast: true }, { do: "move", x: 414 },
    { do: "move", x: 418.2 }, { do: "hold", moveX: 1, seconds: 3.4 },
    { do: "switch", to: "pedro" }, { do: "hopOnto", pushable: "desk_hall", hold: 0.35 }, { do: "jump", fromPushable: "desk_hall", dir: 1, hold: 0.45, air: 0.3 }, { do: "expect", yMin: 2.7 },
    { do: "move", x: 429 }, { do: "move", x: 431.5 }, { do: "move", x: 435 },
    { do: "crawl", x: 438 }, { do: "expect", switchOn: "button_hall" }, { do: "crawl", x: 440.8 },
    { do: "switch", to: "isabela" }, { do: "move", x: 435.5 }, { do: "jump", x: 435.6, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 }, { do: "move", x: 441.2 }, { do: "expect", yMax: 0.1 },
    { do: "move", x: 443 }, { do: "jump", x: 443.3, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 },
    { do: "move", x: 445 }, { do: "interact" }, { do: "expect", gateOpen: "gate_hall" }, { do: "move", x: 447 }, { do: "move", x: 450.6 }, { do: "expect", checkpoint: "cp_final" },
    { do: "ability" }, { do: "jump", x: 452.4, dir: 1, hold: 0.25, air: 0.3 }, { do: "expect", yMin: 0.8 }, { do: "jump", x: 454.1, dir: 1, hold: 0.4, air: 0.3 }, { do: "expect", yMin: 2.0 },
    { do: "jump", x: 456.4, dir: 1, hold: 0.45 }, { do: "expect", xMin: 457.5 },
    { do: "hopOnto", left: 460, right: 461.4, top: 1.2, hold: 0.3 }, { do: "jump", x: 461.0, dir: 1, hold: 0.35, air: 0.35, avoid: "plane_hz_3" }, { do: "expect", yMin: 1.9 }, { do: "move", x: 464.9 },
    { do: "hopOnto", left: 466.5, right: 467.9, top: 1.2, hold: 0.3, avoid: "plane_hz_3" }, { do: "jump", x: 467.6, dir: 1, hold: 0.35, air: 0.4, avoid: "plane_hz_3" }, { do: "expect", yMin: 2.0 }, { do: "move", x: 472.5 },
    { do: "move", x: 475.3 },
    // the classroom door: both siblings, both interact
    // bring Pedro across the last hops too (books -> desk -> books -> desk row), then both interact
    { do: "switch", to: "pedro" }, { do: "hopOnto", left: 460, right: 461.4, top: 1.2, hold: 0.3 },
    { do: "jump", x: 461.0, dir: 1, hold: 0.35, air: 0.35, avoid: "plane_hz_3" }, { do: "expect", yMin: 1.9 }, { do: "move", x: 464.9 },
    { do: "hopOnto", left: 466.5, right: 467.9, top: 1.2, hold: 0.3, skipIfPast: true, avoid: "plane_hz_3" }, { do: "move", x: 468.3 },
    { do: "crawl", x: 472.7 }, { do: "expect", xMin: 472.3 },
    { do: "move", x: 477.7 }, { do: "expect", bothAtDoor: true, timeout: 12 }, { do: "interact" },
    { do: "switch", to: "isabela" }, { do: "move", x: 475.3 }, { do: "expect", bothAtDoor: true, timeout: 12 }, { do: "interact" }, { do: "expect", finished: true, timeout: 4 }
]
