// A platform travelling between path points (linear with pauses) or swinging like gym
// equipment (smooth pendulum between two points). Predictable, slow, safe for children. The
// Physics solid is moved with moveSolid() so riders are carried.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics

Node {
    id: root
    property var spec: ({})
    property var solid: null
    property string assetBase: ""
    property bool useModels: true
    property real speedScale: 1            // dev tools
    property bool active: true             // swings that need Pedro's push start inactive

    property var path: spec.path || []
    property real speed: spec.speed || 1.6
    property real pause: spec.pause || 0.6
    property bool swing: spec.swing === true
    property int segment: 0
    property real progress: 0              // 0..1 along the current segment
    property int direction: 1
    property real waiting: 0
    property real phase: 0                 // swing

    readonly property real w: spec.w || 2
    readonly property real h: spec.h || 0.35

    function step(dt) {
        if (!solid || path.length < 2 || !active) return
        const s = speed * speedScale
        let nx, ny
        if (swing) {
            const a = path[0], b = path[1]
            const len = Math.hypot(b.x - a.x, b.y - a.y)
            phase += dt * s / Math.max(0.5, len) * Math.PI
            const t = (1 - Math.cos(phase)) / 2      // eased 0..1..0
            nx = a.x + (b.x - a.x) * t; ny = a.y + (b.y - a.y) * t
        } else {
            if (waiting > 0) { waiting -= dt; Physics.moveSolid(solid, solid.x, solid.y); sync(); return }
            const a = path[segment], b = path[segment + direction] || path[segment]
            const len = Math.max(0.001, Math.hypot(b.x - a.x, b.y - a.y))
            progress += dt * s / len
            if (progress >= 1) {
                progress = 0; segment += direction
                if (segment >= path.length - 1 || segment <= 0) direction = -direction
                waiting = pause
                nx = b.x; ny = b.y
            } else { nx = a.x + (b.x - a.x) * progress; ny = a.y + (b.y - a.y) * progress }
        }
        Physics.moveSolid(solid, nx, ny)
        sync()
    }
    function sync() { if (solid) position = Qt.vector3d(solid.x + solid.w / 2, solid.y, 0) }
    function reset() {
        segment = 0; progress = 0; direction = 1; waiting = 0; phase = 0
        if (solid && path.length) { Physics.moveSolid(solid, path[0].x, path[0].y); solid.dx = 0; solid.dy = 0 }
        sync()
    }

    PropVisual {
        assetId: root.spec.asset || "moving_platform"
        w: root.w; h: root.h; d: root.spec.d || 1.3
        assetBase: root.assetBase; useModels: root.useModels
        tint: root.active ? 0 : 0.25
    }
}
