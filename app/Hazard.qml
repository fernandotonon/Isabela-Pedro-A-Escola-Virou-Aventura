// Moving obstacles that cost Courage and push gently: a ball rolling back and forth on the floor
// (predictable interval) or a paper plane gliding along a path. No realistic damage.
import QtQuick
import QtQuick3D

Node {
    id: root
    property var spec: ({})
    property string assetBase: ""
    property bool useModels: true
    property real speedScale: 1
    readonly property string kind: spec.type || ""        // ball | plane
    property real cx: spec.x || 0
    property real cy: spec.y || 0
    property int dir: 1
    property real t: 0
    property real spin: 0
    readonly property real r: spec.r || 0.45
    readonly property var hitbox: kind === "ball" ? { x: cx - r * 0.85, y: cy, w: r * 1.7, h: r * 1.7 }
                                                   : { x: cx - 0.9, y: cy, w: 1.8, h: 0.35 }

    function step(dt) {
        const s = (spec.speed || 3) * speedScale
        if (kind === "ball") {
            cx += dir * s * dt
            spin -= dir * s * dt / r * 180 / Math.PI
            if (cx > spec.range[1]) { cx = spec.range[1]; dir = -1 }
            if (cx < spec.range[0]) { cx = spec.range[0]; dir = 1 }
        } else {
            const a = spec.path[0], b = spec.path[1]
            const len = Math.max(0.5, Math.hypot(b.x - a.x, b.y - a.y))
            t += dt * s / len
            const u = (1 - Math.cos(t * Math.PI)) / 2
            cx = a.x + (b.x - a.x) * u; cy = a.y + (b.y - a.y) * u + Math.sin(t * 6) * 0.15
            dir = Math.cos(t * Math.PI) > 0 ? (b.x > a.x ? 1 : -1) : (b.x > a.x ? -1 : 1)
        }
        position = Qt.vector3d(cx, cy, 0)
    }
    function reset() { cx = spec.x; cy = spec.y; dir = 1; t = 0; position = Qt.vector3d(cx, cy, 0) }

    Node {
        y: root.kind === "ball" ? root.r : 0
        eulerRotation.z: root.kind === "ball" ? root.spin : (root.dir > 0 ? -6 : 6)
        eulerRotation.y: root.kind === "plane" ? (root.dir > 0 ? 90 : -90) : 0
        PropVisual {
            assetId: root.kind === "ball" ? "soccer_ball" : "paper_plane"
            w: root.kind === "ball" ? root.r * 2 : 1.8; h: root.kind === "ball" ? root.r * 2 : 0.3; d: root.kind === "ball" ? root.r * 2 : 1.1
            assetBase: root.assetBase; useModels: root.useModels
            y: root.kind === "ball" ? -root.r : 0
        }
    }
}
