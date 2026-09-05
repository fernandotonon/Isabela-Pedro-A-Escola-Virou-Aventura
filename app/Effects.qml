// Tiny visual feedback: landing puffs, sparkles on pickups, ability pulses, teleport puffs.
// Pooled boxes animated in place; no particle system needed for the MVP.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D

Node {
    id: fx
    readonly property int poolSize: 24
    property int next: 0

    Repeater3D {
        id: pool
        model: fx.poolSize
        Node {
            id: p
            visible: false
            property color tone: "#ffffff"
            property real size: 0.2
            property real life: 0
            property real dx: 0; property real dy: 0
            property real t: 0
            scale: Qt.vector3d(size, size, size)
            opacity: Math.max(0, 1 - t)
            Model { source: "#Sphere"; scale: Qt.vector3d(0.01, 0.01, 0.01); castsShadows: false; receivesShadows: false; pickable: false
                    materials: PrincipledMaterial { baseColor: p.tone; lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend } }
            function fire(x, y, z, c, s, vx, vy, lifeSec) { position = Qt.vector3d(x, y, z); tone = c; size = s; dx = vx; dy = vy; life = lifeSec; t = 0; visible = true }
            FrameAnimation {
                running: p.visible
                onTriggered: {
                    p.t += frameTime / Math.max(0.05, p.life)
                    p.position = Qt.vector3d(p.position.x + p.dx * frameTime, p.position.y + p.dy * frameTime, p.position.z)
                    p.dy -= 6 * frameTime
                    if (p.t >= 1) p.visible = false
                }
            }
        }
    }
    function spawn(x, y, c, s, vx, vy, life) {
        const p = pool.objectAt(next); next = (next + 1) % poolSize
        if (p) p.fire(x, y, 0.3, c, s, vx, vy, life)
    }
    function landPuff(x, y, speed) { const n = speed > 10 ? 6 : 3; for (let i = 0; i < n; ++i) spawn(x + (Math.random() - 0.5) * 0.5, y + 0.05, "#e9e2d0", 0.5 + Math.random() * 0.4, (i - n / 2) * 0.9, 1.2 + Math.random(), 0.45) }
    function sparkle(x, y, c) { for (let i = 0; i < 8; ++i) { const a = i / 8 * Math.PI * 2; spawn(x, y + 0.3, c, 0.35 + Math.random() * 0.3, Math.cos(a) * 2.2, Math.sin(a) * 2.2 + 1.5, 0.55) } }
    function pulse(x, y, c) { for (let i = 0; i < 10; ++i) { const a = i / 10 * Math.PI * 2; spawn(x, y, c, 0.4, Math.cos(a) * 5, Math.sin(a) * 5 + 3, 0.7) } }
    function puff(x, y) { for (let i = 0; i < 6; ++i) spawn(x + (Math.random() - 0.5) * 0.6, y + Math.random() * 1.2, "#cfe8f6", 0.6, (Math.random() - 0.5) * 2, 1 + Math.random(), 0.5) }
}
