// A small explicit finite state machine: named states, guarded transitions, enter/exit hooks,
// time-in-state. Used by the character controller for its animation/behaviour states.
.pragma library

function create(initial, states) {
    // states: { Name: { enter(ctx), exit(ctx), update(ctx, dt) -> nextStateName|null } }
    return { state: initial, prev: null, time: 0, states: states, history: [initial] }
}

function set(fsm, ctx, next) {
    if (!next || next === fsm.state) return false
    if (!fsm.states[next]) throw new Error("StateMachine: unknown state " + next)
    const cur = fsm.states[fsm.state]
    if (cur && cur.exit) cur.exit(ctx, next)
    fsm.prev = fsm.state
    fsm.state = next
    fsm.time = 0
    fsm.history.push(next)
    if (fsm.history.length > 16) fsm.history.shift()
    const s = fsm.states[next]
    if (s.enter) s.enter(ctx, fsm.prev)
    return true
}

function update(fsm, ctx, dt) {
    fsm.time += dt
    const s = fsm.states[fsm.state]
    const next = s && s.update ? s.update(ctx, dt) : null
    if (next) set(fsm, ctx, next)
    return fsm.state
}

function is(fsm, names) {
    if (typeof names === "string") return fsm.state === names
    return names.indexOf(fsm.state) >= 0
}
