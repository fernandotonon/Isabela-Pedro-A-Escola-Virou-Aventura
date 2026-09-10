// "O Caminho para a Sala" - the one level of the MVP, as data. Metres; +X is the way to the
// classroom, +Y up, z is visual depth (negative = behind the play plane). Boxes are given by
// their bottom-left corner. Gameplay code never names an asset file: `asset` ids resolve
// through config/assets.js, so replacing a placeholder by a QtMeshEditor model is a manifest edit.
.pragma library

// ---- small builders so the data below stays readable --------------------------------------
function ground(x0, x1, surface, opts) {           // walkable ground, top at y = 0 (or opts.top)
    const top = opts && opts.top !== undefined ? opts.top : 0
    return Object.assign({ type: "ground", x: x0, y: top - 1.5, w: x1 - x0, h: 1.5, surface: surface || "grass" }, opts || {})
}
function platform(x, y, w, h, asset, opts) { return Object.assign({ type: "platform", x: x, y: y, w: w, h: h, asset: asset || "" }, opts || {}) }
function prop(asset, x, opts) { return Object.assign({ type: "prop", asset: asset, x: x, y: 0, z: -3 }, opts || {}) }
function wall(x, y, w, h, opts) { return Object.assign({ type: "wall", x: x, y: y, w: w, h: h }, opts || {}) }
function lowpass(x, y, w, h, opts) { return Object.assign({ type: "lowpass", x: x, y: y, w: w, h: h, gap: 0.8 }, opts || {}) }
function ladder(x, y, h, opts) { return Object.assign({ type: "ladder", x: x, y: y, w: 0.8, h: h }, opts || {}) }
function moving(id, x, y, w, h, path, speed, opts) { return Object.assign({ type: "moving", id: id, x: x, y: y, w: w, h: h, path: path, speed: speed || 1.6, pause: 0.6 }, opts || {}) }
function pushable(id, x, y, w, h, weight, asset, opts) { return Object.assign({ type: "pushable", id: id, x: x, y: y, w: w, h: h, weight: weight, asset: asset || "push_box" }, opts || {}) }
function button(id, x, opts) { return Object.assign({ type: "button", id: id, x: x, y: 0, w: 0.9, h: 0.22 }, opts || {}) }
function lever(id, x, y, opts) { return Object.assign({ type: "lever", id: id, x: x, y: y, w: 0.5, h: 1.2 }, opts || {}) }
function plate(id, x, y, opts) { return Object.assign({ type: "plate", id: id, x: x, y: y === undefined ? 0 : y, w: 1.2, h: 0.12 }, opts || {}) }
function gate(id, x, y, w, h, requires, opts) { return Object.assign({ type: "gate", id: id, x: x, y: y, w: w, h: h, requires: requires, asset: "" }, opts || {}) }
function star(x, y) { return { type: "star", x: x, y: y } }
function pencil(x, y) { return { type: "pencil", x: x, y: y } }
function memory(x, y) { return { type: "memory", x: x, y: y } }
function checkpoint(id, x) { return { type: "checkpoint", id: id, x: x, y: 0 } }
function trigger(id, x, w, opts) { return Object.assign({ type: "trigger", id: id, x: x, y: -1, w: w, h: 8, once: true }, opts || {}) }
function zone(x, y, w, h, only) { return { type: "zone", x: x, y: y, w: w, h: h, only: only } }
function ball(id, x, range, speed, opts) { return Object.assign({ type: "ball", id: id, x: x, y: 0, r: 0.45, range: range, speed: speed || 3.2 }, opts || {}) }
function plane(id, path, speed, opts) { return Object.assign({ type: "plane", id: id, x: path[0].x, y: path[0].y, path: path, speed: speed || 3.5 }, opts || {}) }

var level = {
    id: "caminho_para_a_sala",
    nameKey: "level.caminho.name",
    start: { x: 4, y: 0 },
    sections: [

    // =========================================================================================
    // 1. A pracinha externa - movement tutorial, the gym equipment, the distant gate
    // =========================================================================================
    { id: "pracinha", nameKey: "section.pracinha", x0: 0, x1: 133, music: "outdoor",
      camera: { distance: 15, height: 2.8 }, sky: "#8fd0f4", far: "#cfe8f6",
      entities: [
        // ground & bounds - the street is behind a hedge line and an invisible wall; the player
        // never reaches it (the hedge is at z = -4 visually, the wall is the left level bound)
        wall(-1, -2, 1, 8),
        ground(0, 24, "grass"), ground(26.5, 84, "grass"), ground(91, 133, "grass"),
        // the pit under the swinging equipment: an easy alternative route along its floor
        ground(84, 91, "grass", { top: -2.2 }),
        // background: trees, benches, bins, hedges, the street far behind, the school wall
        prop("outdoor_tree", 3, { z: -6, scale: 1.2 }), prop("outdoor_tree", 21, { z: -7 }), prop("outdoor_tree", 37, { z: -6.5, scale: 1.1 }),
        prop("outdoor_tree", 77, { z: -6 }), prop("outdoor_tree", 101, { z: -7, scale: 1.25 }), prop("outdoor_tree", 118, { z: -6 }),
        prop("bush", 9, { z: -3.5 }), prop("bush", 31, { z: -3.2 }), prop("bush", 71, { z: -3.4 }), prop("bush", 108, { z: -3.4 }),
        prop("school_bench", 8, { z: -2.5 }), prop("school_bin", 11.5, { z: -2.6 }), prop("lamp_post", 34, { z: -4 }), prop("lamp_post", 96, { z: -4 }),
        prop("sidewalk", 0, { z: -4.6, w: 133 }), prop("street", 0, { z: -9, w: 133 }), prop("fence", 0, { z: -4.2, w: 84 }),
        prop("school_wall", 128, { z: -3, w: 6 }),
        // tutorial hints
        trigger("hint.move", 1, 6), trigger("hint.jump", 12, 4), trigger("hint.stars", 19, 3), trigger("hint.switch", 28, 4),
        trigger("hint.abilities", 40, 3), trigger("hint.crawl", 42.5, 2), trigger("hint.ledge", 42.5, 2), trigger("bell", 16, 2, { narrative: "bell" }),
        // first steps: a small step, a small gap
        platform(14, 0, 3, 0.6, "stone_platform"),
        star(15.5, 1.4),
        // switch characters: a low passage only Pedro fits and a step only Isabela reaches
        // a giant bench: its own legs already show the gap under the seat
        lowpass(30, 0, 3.4, 1.5, { asset: "school_bench" }), star(31.5, 0.3),
        platform(35, 2.6, 2.5, 0.4, "stone_platform", { ledge: true }), star(36.2, 3.4),
        // --- Challenge 1: the parallel bars ------------------------------------------------
        prop("exercise_bars", 47, { z: -1.4, scale: 1.0, decor: true }),
        lowpass(43, 0, 8, 1.7, { asset: "parallel_bars", gap: 0.8 }),              // low frame: Pedro ducks under, Isabela climbs over
        button("button_bars", 47, { hint: "hint.button" }),                                                  // a floor button inside
        platform(43, 2.6, 8, 0.3, "stone_platform", { ledge: true }),           // Isabela grabs the walkway above the bars
        lever("lever_bars", 49.5, 2.9, { hint: "hint.lever" }),
        star(45, 3.6), pencil(50.5, 6.4),                                          // the pencil sits high above the bars
        platform(48.5, 5.2, 1.4, 0.25, "book_stack", { ledge: true }),
        gate("gate_bars", 54, 0, 0.8, 3.2, ["button_bars", "lever_bars"], { asset: "school_gate_small" }),
        // --- Challenge 2: the vertical ladder ----------------------------------------------
        ladder(62.4, 2.5, 1.5, { asset: "climbing_ladder", visualFrom: 0 }),        // starts out of Pedro's reach
        platform(60, 3.65, 11.8, 0.35, "stone_platform"),                       // the upper walkway (top 4.0), ends before the block
        pushable("box_ladder", 68, 0, 1.0, 1.2, 1, "backpack", { hint: "hint.push" }),    // Pedro's route: push, climb
        // the step block: one 3 m x 2.6 m box, drawn as a wall of planters (tile: true repeats the model,
        // so the collision and the visual now cover the same volume)
        wall(73, 0, 3, 2.6, { asset: "tire_planter" }),
        star(66, 1.2),
        // --- Challenge 3: the swinging equipment -------------------------------------------
        moving("swing_1", 84, 1.9, 2.2, 0.35, [{ x: 84, y: 1.9 }, { x: 89, y: 2.6 }], 1.7, { asset: "moving_platform", swing: true }),
        trigger("hint.moving", 80, 2),
        platform(89.7, -2.2, 1.0, 1.0, "tire_planter"), platform(91, -2.2, 1.0, 2.2, "tire_planter"),   // steps out of the pit
        lowpass(85, -2.2, 3, 2.2, { gap: 0.8, asset: "garden_planter", secret: true }),      // secret tunnel in the pit
        wall(88, -2.2, 0.5, 2.2), memory(89.1, -1.6),
        star(87, 3.2),
        // --- Challenge 4: the distant gate -------------------------------------------------
        trigger("story.gate", 96, 3, { narrative: "gate_far" }),
        platform(99, 0, 2.4, 1.0, "school_bench"), platform(103, 0, 2.2, 0.8, "stone_platform"),
        platform(106.5, 1.2, 2.6, 0.3, "stone_platform", { ledge: true }), platform(110, 0, 1.4, 1.2, "backpack"),
        moving("plane_1", 113, 2.4, 2.0, 0.3, [{ x: 113, y: 2.4 }, { x: 121, y: 3.4 }], 2.2, { asset: "paper_plane" }),
        platform(123, 0, 2.5, 1.0, "school_bench"),
        star(107.8, 2.4), star(117, 4.1),
        // both siblings on the marks open the gate
        plate("plate_gate_a", 126.2), plate("plate_gate_b", 127.8), trigger("hint.plates", 124, 2),
        gate("gate_school", 129.2, 0, 1.0, 3.6, ["plate_gate_a", "plate_gate_b"], { asset: "school_gate", narrative: "gate_open" }),
        prop("school_wall", 0, { z: -2.2, w: 0, hidden: true }),
        checkpoint("cp_gate", 132)
      ] },

    // =========================================================================================
    // 2. Entrance and garden - pushing, mechanisms, objects as platforms, a secret
    // =========================================================================================
    { id: "jardim", nameKey: "section.jardim", x0: 133, x1: 195, music: "outdoor",
      camera: { distance: 13.5, height: 2.6 }, sky: "#8fd0f4", far: "#d8ecf7",
      entities: [
        ground(133, 195, "concrete"),
        prop("outdoor_tree", 140, { z: -4.2, scale: 1.3 }), prop("outdoor_tree", 176, { z: -4.2 }), prop("garden_planter", 137, { z: -2.6 }),
        prop("tire_planter", 148.5, { z: -2.4 }), prop("bush", 155, { z: -3 }), prop("school_bin", 190, { z: -2.5 }), prop("bush", 183, { z: -3.2 }),
        prop("school_wall", 133, { z: -4.5, w: 62 }),
        trigger("hint.pushmedium", 141, 3),
        // Isabela pushes the medium bench so Pedro can climb the planter ledge
        pushable("bench_garden", 144.5, 0, 2.4, 1.0, 2, "school_bench"),
        platform(150, 1.8, 6, 0.4, "stone_platform"), star(152.5, 2.9), star(141, 1.2),
        // a stack of planters: one box per visible planter, so the collision matches what is drawn
        wall(157.4, 0, 1.0, 1.0, { asset: "tire_planter" }), wall(157.4, 1.0, 1.0, 1.0, { asset: "tire_planter" }),
        // --- main challenge: Pedro through the planters, Isabela moves a bench ------------
        lowpass(160, 0, 4, 2.4, { gap: 0.8, asset: "garden_planter", raised: true, legColor: "#8a7d6a" }),            // Pedro crawls in; Isabela climbs over
        button("button_garden", 162, {}),                                          // inside the passage
        pushable("bench_garden2", 165.4, 0, 2.4, 1.0, 2, "school_bench"),            // Isabela slides it under the high planter for a boost
        wall(169.4, 0, 0.8, 0.8, { asset: "tire_planter" }),                       // stops the bench under the planter's edge
        platform(169.6, 4.0, 6, 0.4, "stone_platform", { ledge: true }), lever("lever_garden", 173, 4.4, {}),
        star(165.9, 5.0), star(171, 5.4), star(162, 0.3),
        gate("gate_garden", 180, 0, 0.8, 3.4, ["button_garden", "lever_garden"], { asset: "school_gate_small" }),
        // --- secret: Isabela's notebook reveals a hidden stair to a pencil -----------------
        trigger("hint.notebook", 183, 3),
        platform(184, 1.6, 1.6, 0.3, "book_stack", { hidden: true, revealId: "garden_secret" }),
        platform(187, 3.2, 1.6, 0.3, "book_stack", { hidden: true, revealId: "garden_secret" }),
        platform(190, 4.8, 2.2, 0.3, "book_stack", { hidden: true, revealId: "garden_secret" }),
        pencil(191, 5.6), star(187.8, 4.2),
        platform(186.2, 1.9, 1.6, 0.3, "stone_platform", { ledge: true }),         // visible steps up to the high star and the pencil
        platform(189.2, 3.6, 1.6, 0.3, "stone_platform", { ledge: true })          // (the notebook stairs remain the secret shortcut)
      ] },

    // =========================================================================================
    // 3. Playground - bigger vertical challenges
    // =========================================================================================
    { id: "playground", nameKey: "section.playground", x0: 195, x1: 265, music: "outdoor",
      camera: { distance: 14, height: 3.2 }, sky: "#8fd0f4", far: "#d8ecf7",
      entities: [
        ground(195, 265, "rubber"),
        prop("playground", 210, { z: -2.2, scale: 1.0, decor: true }), prop("outdoor_tree", 200, { z: -4.6 }), prop("outdoor_tree", 258, { z: -4.6, scale: 1.2 }),
        prop("tire_planter", 198, { z: -2.5 }), prop("soccer_ball", 249, { z: -2 }), prop("school_wall", 195, { z: -5, w: 70 }),
        prop("fence_yellow", 195, { z: -3.4, w: 70 }),
        trigger("hint.playground", 199, 3),
        // Isabela: up the structure, across the narrow beam, up to the high lever
        ladder(205.6, 0, 3.2, { asset: "climbing_ladder" }), platform(204.5, 3.2, 3, 0.3, "playground_deck"),
        platform(209, 3.2, 8, 0.2, "stone_platform", { narrow: true }), star(213, 4.2),
        platform(218.5, 3.1, 3, 0.3, "playground_deck", { ledge: true }),
        platform(222.5, 5.0, 2.6, 0.3, "playground_deck", { ledge: true }), lever("lever_play", 223.5, 5.3, {}),
        platform(207, 6.2, 5, 0.3, "playground_roof", { ledge: true }), pencil(209.5, 7.1),
        // Pedro: through the tunnel, down the slide, to the floor button
        lowpass(208, 0, 6, 2.6, { gap: 0.8, asset: "play_tunnel", raised: true, legColor: "#2a5bd7" }), star(211, 0.3),
        platform(215, 0, 1, 0.5, "slide_step"), platform(216, 0, 1, 1.0, "slide_step"), platform(217, 0, 1, 1.5, "slide_step", { slideTop: true }),
        platform(218, 0, 1, 1.0, "slide_step"), platform(219, 0, 1, 0.5, "slide_step"),
        lowpass(226, 0, 4, 2.2, { gap: 0.8, asset: "fence_yellow_low", raised: true, legColor: "#f2c530" }), button("button_play", 231.2, {}), wall(232.2, 0, 0.5, 1.4, { asset: "fence_yellow" }),
        star(228, 0.3), star(224, 1.2), star(202, 1.2),
        gate("gate_play", 238, 0, 0.8, 3.4, ["lever_play", "button_play"], { asset: "colored_grid" }),
        checkpoint("cp_playground", 242),
        // the ramp and stairs, tyre planters, a stray ball
        // the ramp is the way up: the model is decor in the play plane, the slope is walked over invisible
        // half-metre steps (within stepHeight); the grey blocks on the right are the way down
        prop("ramp_and_stairs", 248.4, { z: 0, w: 6.2, h: 2.0 }),
        platform(248.7, 0, 0.5, 0.5, "", { invisible: true }), platform(249.2, 0, 0.5, 1.0, "", { invisible: true }),
        platform(249.7, 0, 0.5, 1.5, "", { invisible: true }), platform(250.2, 0, 4.4, 2.0, "", { invisible: true }),
        platform(254.6, 0, 1.2, 1.5, "stair_step"), platform(255.8, 0, 1.2, 1.0, "stair_step"), platform(257, 0, 1.2, 0.5, "stair_step"),
        star(252.5, 3.0), star(245, 1.2), star(261, 1.2)
      ] },

    // =========================================================================================
    // 4. The games yard - familiar objects as platforms and obstacles
    // =========================================================================================
    { id: "patio", nameKey: "section.patio", x0: 265, x1: 335, music: "outdoor",
      camera: { distance: 13.5, height: 2.6 }, sky: "#8fd0f4", far: "#e0eef7",
      entities: [
        ground(265, 319, "concrete"), ground(327, 335, "concrete"), ground(319, 327, "concrete", { top: -2.4 }),
        prop("school_wall", 265, { z: -4.5, w: 70 }), prop("giant_pencil", 296, { z: -3, scale: 1.0 }), prop("school_bin", 268, { z: -2.5 }),
        prop("backpack", 312, { z: -2.4 }), prop("book_stack", 316, { z: -2.6 }),
        trigger("hint.patio", 267, 3),
        platform(270, 0, 2.4, 1.0, "school_bench"), platform(274.5, 0, 3.0, 1.5, "foosball_table"), platform(279.5, 0, 2.4, 1.0, "school_bench"),
        star(275.8, 2.5), star(271, 2.0),
        // the ball rolls back and forth; benches are safe
        ball("ball_patio", 292, [284.5, 300], 3.4), trigger("hint.ball", 282, 2),
        platform(287, 0, 2.4, 1.0, "school_bench"), platform(294, 0, 3.2, 1.4, "ping_pong_table"), star(295.6, 2.4),
        platform(298.8, 3.6, 2.2, 0.3, "stone_platform", { ledge: true }), pencil(299.9, 4.5),
        platform(302.5, 0, 1.6, 1.2, "book_stack"), star(303.3, 2.2),
        // push the lunchbox onto the button
        pushable("lunchbox", 307, 0, 1.0, 0.8, 1, "lunchbox", { hint: "hint.pushbutton" }), button("button_patio", 313.5, { byPushable: true }),
        wall(314.6, 0, 0.8, 0.9, { asset: "tire_planter" }),                      // stops the lunchbox on the button
        gate("gate_patio", 331.5, 0, 0.8, 3.4, ["button_patio"], { asset: "school_gate_small" }),
        // paper plane over the pit (the pit floor has tyre steps: easy route)
        moving("plane_2", 316.5, 2.2, 2.0, 0.3, [{ x: 316.5, y: 2.2 }, { x: 325.5, y: 3.0 }], 2.4, { asset: "paper_plane" }),
        platform(324.5, -2.4, 1.0, 1.0, "tire_planter"), platform(325.8, -2.4, 1.0, 1.0, "tire_planter"), platform(325.8, -1.4, 1.0, 1.0, "tire_planter"), star(321, -1.4),
        plane("plane_hz_1", [{ x: 266, y: 4.6 }, { x: 283, y: 5.2 }], 3.0),          // above the hop arcs; a full jump from the tables still meets it
        star(319.5, 4.1)
      ] },

    // =========================================================================================
    // 5. The covered court - transition between outside and inside
    // =========================================================================================
    { id: "quadra", nameKey: "section.quadra", x0: 335, x1: 400, music: "outdoor",
      camera: { distance: 13, height: 2.6 }, sky: "#9fc7dc", far: "#c6d9e2",
      entities: [
        ground(335, 400, "court"),
        prop("sports_court", 367, { z: -3.5, scale: 1.0, decor: true }), prop("basket_hoop", 362, { z: -3 }), prop("fence_yellow", 335, { z: -3.2, w: 65 }),
        prop("court_roof", 335, { z: -2, w: 65 }),
        trigger("hint.quadra", 337, 3),
        star(341, 1.2), star(349, 1.2),
        // Isabela puts the bench under the wall so Pedro can get over it
        pushable("bench_court", 352, 0, 2.4, 1.0, 2, "school_bench"),
        wall(360, 0, 1.0, 2.5, { asset: "fence_yellow" }), star(360.5, 3.6),
        platform(361.5, 4.3, 1.6, 0.3, "stone_platform", { ledge: true }), pencil(362.3, 5.2),   // up by the hoop: Isabela only
        // Pedro pushes the ball into the goal; the goal plate reacts to the ball
        pushable("ball_goal", 366, 0, 0.9, 0.9, 1, "soccer_ball", { round: true }),
        plate("plate_goal", 389, 0, { w: 2.6, byPushable: true, asset: "goal" }), prop("goal", 390.3, { z: 0.6, decor: true }),
        // under the stands: only Pedro (and the ball) fit
        lowpass(376, 0, 10, 1.6, { gap: 1.05, asset: "bleachers", raised: true, legColor: "#8f949a" }), star(381, 0.4),
        platform(376, 1.6, 10, 0.4, "bleachers_top"), star(380, 2.8),
        button("button_court", 394.6, {}),
        gate("gate_court", 397, 0, 0.8, 3.6, ["plate_goal", "button_court"], { asset: "school_gate_small" }),
        checkpoint("cp_court", 399)
      ] },

    // =========================================================================================
    // 6/7. The giant corridor - and the classroom door
    // =========================================================================================
    { id: "corredor", nameKey: "section.corredor", x0: 400, x1: 480, music: "indoor",
      camera: { distance: 10.5, height: 2.2 }, sky: "#f3ead6", far: "#e9dcc3", indoor: true,
      entities: [
        ground(400, 452, "tile"), ground(457, 480, "tile"), ground(452, 457, "tile", { top: -2.0 }),
        prop("school_corridor", 400, { z: -2.5, w: 80, decor: true }), prop("school_clock", 468, { z: -2.2, y: 4.2, scale: 1.4 }),
        prop("student_desk", 405, { z: -2.2 }), prop("backpack", 448, { z: -2.2 }),
        trigger("hint.corridor", 402, 3, { narrative: "corridor_grows" }),
        platform(407, 0, 1.4, 1.0, "book_stack"), platform(409.5, 0, 1.4, 1.8, "book_stack"), platform(412, 0, 1.4, 1.0, "book_stack"),
        star(410.2, 3.0),
        plane("plane_hz_2", [{ x: 414, y: 2.4 }, { x: 424, y: 1.6 }], 3.4),
        // the desk under the window
        pushable("desk_hall", 419, 0, 1.6, 1.4, 2, "student_desk", { hint: "hint.desk" }), wall(424.6, 0, 0.4, 1.0, { asset: "book_stack" }),
        platform(424.6, 2.4, 5.4, 0.4, "window_ledge", { ledge: true }), star(426.5, 3.6), pencil(429, 3.6),
        // low obstacles and a high lever
        lowpass(436, 0, 4, 2.0, { gap: 0.8, asset: "student_desk_row", raised: true, legColor: "#2a5bd7" }), button("button_hall", 438, {}), star(437.5, 0.3),
        // a taller pile so the lever rests on it and the ledge Isabela grabs matches the books
        platform(443.6, 2.0, 3.0, 1.7, "book_stack", { ledge: true }), lever("lever_hall", 445, 3.7, {}), star(445, 4.6),
        checkpoint("cp_final", 450),
        // final challenge: platforms at different heights appear with the mechanisms, planes cross
        gate("gate_hall", 451.4, 0, 0.6, 3.0, ["button_hall", "lever_hall"], { asset: "school_gate_small" }),
        platform(453, 0.6, 1.4, 0.3, "book_stack", { hidden: true, revealId: "hall_stairs" }),
        platform(455.5, 1.8, 1.4, 0.3, "book_stack", { hidden: true, revealId: "hall_stairs" }),
        platform(456, -2.0, 1.0, 1.2, "tire_planter"),                             // a way out of the pit for whoever falls in
        trigger("hint.notebook2", 451.5, 1.2),
        plane("plane_hz_3", [{ x: 458, y: 3.9 }, { x: 470, y: 4.3 }], 3.8),   // flies above siblings standing on the desks; threatens the hops
        platform(460, 0, 1.4, 1.2, "book_stack"), platform(463, 0, 1.6, 2.0, "student_desk"), platform(466.5, 0, 1.4, 1.2, "book_stack"),
        lowpass(469, 0, 3, 1.8, { gap: 0.8, asset: "student_desk_row", raised: true, legColor: "#2a5bd7" }), platform(469, 1.8, 3, 0.3, "student_desk_top", { ledge: true }),
        star(461, 2.4), star(464, 3.2), star(470.5, 3.0),
        // the classroom door: two interaction points, both siblings needed
        { type: "finaldoor", id: "door_final", x: 476.5, y: 0, w: 1.6, h: 3.0, asset: "final_door" },
        wall(479, -2, 1, 10)
      ] }
    ]
}

function section(id) { for (const s of level.sections) if (s.id === id) return s; return null }
function sectionAt(x) { for (const s of level.sections) if (x >= s.x0 && x < s.x1) return s; return level.sections[level.sections.length - 1] }
function checkpoints() {
    const out = [{ id: "start", x: level.start.x, y: level.start.y, section: level.sections[0].id }]
    for (const s of level.sections) for (const e of s.entities) if (e.type === "checkpoint") out.push({ id: e.id, x: e.x, y: e.y, section: s.id })
    return out
}
