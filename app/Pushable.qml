// A box, bench, lunchbox, desk or ball a sibling can push. weight 1 = light (Pedro and Isabela),
// weight 2 = medium (Isabela only). It has its own Physics body (gravity, blocked by solids) and
// a matching solid so characters can stand on it and be blocked by it.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics

Node {
    id: root
    property var spec: ({})
    property var world: null
    property var body: null
    property var solid: null
    property string assetBase: ""
    property bool useModels: true
    property int weight: spec.weight || 1
    property bool round: spec.round === true
    property real pushSpeed: round ? 3.2 : (weight > 1 ? 1.6 : 2.2)
    property real pushVx: 0                 // set by the character controller each step it pushes
    property bool beingPushed: false
    property real spin: 0

    readonly property real w: spec.w || 1
    readonly property real h: spec.h || 1

    function create() {
        body = Physics.makeBody(spec.x + w / 2, spec.y, w, h)
        solid = Physics.addSolid(world, { x: spec.x, y: spec.y, w: w, h: h, kind: Physics.SOLID, id: spec.id })
        solid.pushable = root
        body.ownSolid = solid
        sync()
    }
    function push(sign) { pushVx = sign * pushSpeed; beingPushed = true }
    function step(dt) {
        if (!body) return
        if (!beingPushed) {
            // slide to a stop (balls roll a little longer)
            const decel = round ? 4.5 : 30
            if (Math.abs(pushVx) <= decel * dt) pushVx = 0; else pushVx -= Math.sign(pushVx) * decel * dt
        }
        beingPushed = false
        // carried by whatever it stands on
        if (body.grounded && body.ground && (body.ground.dx !== 0 || body.ground.dy !== 0)) { body.x += body.ground.dx; body.y += body.ground.dy }
        body.vy = Math.max(-20, body.vy - 30 * dt)
        const px = body.x, py = body.y
        Physics.step(world, body, pushVx * dt, body.vy * dt)
        if (body.hitWall !== 0) pushVx = 0
        if (round) spin -= (body.x - px) / (h / 2) * 180 / Math.PI
        Physics.moveSolid(solid, body.x - w / 2, body.y)
        sync()
    }
    function reset() { if (body) { body.x = spec.x + w / 2; body.y = spec.y; body.vy = 0; pushVx = 0; Physics.moveSolid(solid, spec.x, spec.y); solid.dx = 0; solid.dy = 0; sync() } }
    function sync() { position = Qt.vector3d(body.x, body.y, 0) }
    function serialize() { return body ? { x: body.x, y: body.y } : null }
    function restore(s) { if (s && body) { body.x = s.x; body.y = s.y; body.vy = 0; pushVx = 0; Physics.moveSolid(solid, body.x - w / 2, body.y); solid.dx = 0; solid.dy = 0; sync() } }

    Node {
        y: root.round ? root.h / 2 : 0
        eulerRotation.z: root.round ? root.spin : 0
        PropVisual {
            assetId: root.spec.asset || "push_box"
            w: root.w; h: root.h; d: root.spec.d || Math.max(0.8, root.w * 0.8)
            assetBase: root.assetBase; useModels: root.useModels
            y: root.round ? -root.h / 2 : 0
        }
    }
}
