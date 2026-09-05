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
    { do: "move", x: 79.5 }, { do: "move", x: 81.5 },
    { do: "switch", to: "pedro" }, { do: "jump", x: 70.2, dir: -1, hold: 0.35 }, { do: "move", x: 66.8 }, { do: "hold", moveX: 1, seconds: 3.6 },
    { do: "jump", x: 71.0, dir: 1, hold: 0.35 }, { do: "expect", yMin: 1.1 }, { do: "jump", x: 72.3, dir: 1, hold: 0.4 }, { do: "expect", yMin: 2.5 },
    { do: "jump", x: 75.3, dir: 1, hold: 0.45 }, { do: "expect", yMin: 3.9 }, { do: "move", x: 79.5 }, { do: "move", x: 81.5 },
    // challenge 3: the swing - the easy route through the pit, plus the Family Memory
    { do: "switch", to: "isabela" }, { do: "move", x: 85.4 }, { do: "expect", yMin: -0.1 }, { do: "move", x: 89.3 }, { do: "expect", yMax: -2.0 },
    { do: "expect", memory: true },
    { do: "jump", x: 89.1, dir: 1, hold: 0.4 }, { do: "jump", x: 90.2, dir: 1, hold: 0.4 }, { do: "expect", yMin: -0.1 }, { do: "move", x: 94 },
    // challenge 4: the distant gate - hops, then both on the marks
    { do: "jump", x: 98.3, dir: 1 }, { do: "move", x: 101.8 }, { do: "jump", x: 102.4, dir: 1 }, { do: "move", x: 105.6 },
    { do: "jump", x: 105.9, dir: 1, hold: 0.45 }, { do: "move", x: 109.4 }, { do: "jump", x: 109.5, dir: 1, hold: 0.4 }, { do: "move", x: 111.9 },
    { do: "move", x: 122.4 }, { do: "jump", x: 122.4, dir: 1 }, { do: "move", x: 125.9 }, { do: "move", x: 126.2 },
    { do: "switch", to: "pedro" }, { do: "move", x: 127.8 }, { do: "expect", gateOpen: "gate_school" },
    { do: "move", x: 132.6 }, { do: "expect", checkpoint: "cp_gate" },

    // ---- 2. jardim ------------------------------------------------------------------------------
    { do: "switch", to: "isabela" }, { do: "move", x: 143.6 }, { do: "hold", moveX: 1, seconds: 2.5 },
    { do: "jump", x: 147.5, dir: 1, hold: 0.3 }, { do: "jump", x: 148.9, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.1 }, { do: "move", x: 151.5 },
    { do: "switch", to: "pedro" }, { do: "jump", x: 147.5, dir: 1, hold: 0.3 }, { do: "expect", yMin: 1.0 }, { do: "jump", x: 148.9, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.1 },
    { do: "move", x: 155.5 }, { do: "move", x: 157.2 }, { do: "expect", yMax: 0.1 },
    // main challenge: Pedro presses the button in the planter passage, Isabela makes him a step
    { do: "move", x: 159.6 }, { do: "crawl", x: 162 }, { do: "expect", switchOn: "button_garden" }, { do: "crawl", x: 159.6 },
    { do: "jump", x: 159.5, dir: -1, hold: 0.4 }, { do: "move", x: 156.7 },
    { do: "switch", to: "isabela" }, { do: "move", x: 156.5 }, { do: "hold", moveX: 1, seconds: 1.6 },
    { do: "switch", to: "pedro" }, { do: "jump", x: 157.6, dir: 1, hold: 0.35 }, { do: "expect", yMin: 1.0 },
    { do: "jump", x: 159.4, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.3 }, { do: "move", x: 164.6 }, { do: "move", x: 167 },
    { do: "switch", to: "isabela" }, { do: "move", x: 167.2 }, { do: "jump", x: 167.3, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 },
    { do: "move", x: 173 }, { do: "interact" }, { do: "expect", gateOpen: "gate_garden" }, { do: "move", x: 176 }, { do: "move", x: 182 },
    // the notebook secret
    { do: "move", x: 183.4 }, { do: "ability" }, { do: "jump", x: 183.4, dir: 1, hold: 0.45 }, { do: "expect", yMin: 1.8 },
    { do: "jump", x: 185.2, dir: 1, hold: 0.45 }, { do: "expect", yMin: 3.4 }, { do: "jump", x: 188.2, dir: 1, hold: 0.45 }, { do: "expect", yMin: 5.0 },
    { do: "move", x: 191 }, { do: "move", x: 192.8 }, { do: "move", x: 196 },

    // ---- 3. playground --------------------------------------------------------------------------
    { do: "move", x: 206 }, { do: "climb", seconds: 1.6 }, { do: "expect", yMin: 3.4 },
    { do: "jump", x: 206.4, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 }, { do: "move", x: 209.5 }, { do: "move", x: 212.6 },
    { do: "move", x: 220 }, { do: "jump", x: 221, dir: 1, hold: 0.45 }, { do: "expect", yMin: 5.2 }, { do: "move", x: 223.5 }, { do: "interact" },
    { do: "expect", switchOn: "lever_play" },
    { do: "switch", to: "pedro" }, { do: "move", x: 224.5 }, { do: "crawl", x: 231.2 }, { do: "expect", switchOn: "button_play" }, { do: "expect", gateOpen: "gate_play" },
    { do: "jump", x: 231.6, dir: 1, hold: 0.45 }, { do: "move", x: 239.5 }, { do: "move", x: 242.6 }, { do: "expect", checkpoint: "cp_playground" },
    { do: "move", x: 262.5 },

    // ---- 4. patio -------------------------------------------------------------------------------
    { do: "jump", x: 269.4, dir: 1 }, { do: "move", x: 272 }, { do: "jump", x: 272.2, dir: 1, hold: 0.35 }, { do: "expect", yMin: 1.4 }, { do: "move", x: 277.9 },
    { do: "jump", x: 278.9, dir: 1 }, { do: "move", x: 282.4 },
    { do: "jump", x: 286.4, dir: 1 }, { do: "move", x: 289.6 }, { do: "jump", x: 293.4, dir: 1, hold: 0.4 }, { do: "expect", yMin: 1.3 }, { do: "move", x: 297.6 },
    { do: "move", x: 301.8 }, { do: "jump", x: 301.9, dir: 1 }, { do: "move", x: 304.6 },
    { do: "move", x: 306.2 }, { do: "hold", moveX: 1, seconds: 4.5 }, { do: "expect", switchOn: "button_patio" }, { do: "expect", gateOpen: "gate_patio" },
    { do: "jump", x: 313.4, dir: 1, hold: 0.4 }, { do: "move", x: 319.6 }, { do: "expect", yMax: -2.2 },
    { do: "jump", x: 324, dir: 1, hold: 0.4 }, { do: "jump", x: 325.2, dir: 1, hold: 0.45 }, { do: "expect", yMin: -0.1 }, { do: "move", x: 334 },

    // ---- 5. quadra ------------------------------------------------------------------------------
    { do: "switch", to: "isabela" }, { do: "move", x: 351.2 }, { do: "hold", moveX: 1, seconds: 4.8 },
    { do: "jump", x: 357.4, dir: 1, hold: 0.3 }, { do: "jump", x: 359.4, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.4 },
    { do: "jump", x: 360.3, dir: 1, hold: 0.5 }, { do: "expect", yMin: 4.5 }, { do: "move", x: 362.3 }, { do: "move", x: 363.6 }, { do: "expect", yMax: 0.1 },
    { do: "switch", to: "pedro" }, { do: "jump", x: 357.4, dir: 1, hold: 0.35 }, { do: "expect", yMin: 1.0 }, { do: "jump", x: 359.4, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.4 },
    { do: "move", x: 361.3 }, { do: "move", x: 365.0 }, { do: "crawl", x: 387.6, timeout: 20 }, { do: "expect", switchOn: "plate_goal", timeout: 5 },
    { do: "jump", x: 387.6, dir: 1, hold: 0.4 }, { do: "move", x: 394.6 }, { do: "expect", switchOn: "button_court" }, { do: "expect", gateOpen: "gate_court" },
    { do: "move", x: 399.6 }, { do: "expect", checkpoint: "cp_court" },

    // ---- 6. corredor ----------------------------------------------------------------------------
    { do: "jump", x: 406.4, dir: 1 }, { do: "jump", x: 408.2, dir: 1, hold: 0.4 }, { do: "expect", yMin: 1.7 }, { do: "move", x: 411.5 }, { do: "move", x: 414 },
    { do: "switch", to: "isabela" }, { do: "move", x: 418.2 }, { do: "hold", moveX: 1, seconds: 3.4 },
    { do: "switch", to: "pedro" }, { do: "jump", x: 422.2, dir: 1, hold: 0.35 }, { do: "expect", yMin: 1.3 }, { do: "jump", x: 424, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.7 },
    { do: "move", x: 429 }, { do: "move", x: 431.5 }, { do: "move", x: 435 },
    { do: "crawl", x: 438 }, { do: "expect", switchOn: "button_hall" }, { do: "crawl", x: 440.8 },
    { do: "switch", to: "isabela" }, { do: "move", x: 443 }, { do: "jump", x: 443.3, dir: 1, hold: 0.45, grab: true }, { do: "climb", seconds: 0.8 },
    { do: "move", x: 445 }, { do: "interact" }, { do: "expect", gateOpen: "gate_hall" }, { do: "move", x: 447 }, { do: "move", x: 450.6 }, { do: "expect", checkpoint: "cp_final" },
    { do: "ability" }, { do: "jump", x: 452.2, dir: 1, hold: 0.45 }, { do: "expect", yMin: 0.8 }, { do: "jump", x: 454.0, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.0 },
    { do: "jump", x: 456.4, dir: 1, hold: 0.45 }, { do: "expect", xMin: 457.5 },
    { do: "jump", x: 459.4, dir: 1 }, { do: "jump", x: 461.2, dir: 1, hold: 0.4 }, { do: "expect", yMin: 1.9 }, { do: "move", x: 464.9 },
    { do: "jump", x: 465.9, dir: 1 }, { do: "move", x: 468.2 }, { do: "jump", x: 468.4, dir: 1, hold: 0.45 }, { do: "expect", yMin: 2.0 }, { do: "move", x: 472.5 },
    { do: "move", x: 475.3 },
    // the classroom door: both siblings, both interact
    { do: "wait", seconds: 2.5 }, { do: "switch", to: "pedro" }, { do: "move", x: 477.7 }, { do: "interact" },
    { do: "switch", to: "isabela" }, { do: "move", x: 475.3 }, { do: "interact" }, { do: "expect", finished: true, timeout: 4 }
]
