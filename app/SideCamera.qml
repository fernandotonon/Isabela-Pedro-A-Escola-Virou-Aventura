// Side-scrolling camera: follows the active sibling with smoothing, looks ahead in the movement
// direction, ignores small jumps (vertical window), frames both siblings when they spread out,
// clamps to the section bounds and can zoom for key moments. No free rotation.
import QtQuick
import QtQuick3D
import "config/tuning.js" as Tuning

Node {
    id: rig
    readonly property alias camera: cam
    property real aspect: 16 / 9

    // targets (set by the game each frame)
    property real targetX: 0
    property real targetGroundY: 0          // the y the camera treats as "ground" (last grounded y)
    property real targetVx: 0
    property real companionX: 0
    property real companionY: 0
    property bool frameBoth: true
    property real sectionDistance: Tuning.camera.distance
    property real sectionHeight: Tuning.camera.baseHeight
    property real boundsX0: -1e9
    property real boundsX1: 1e9
    property real zoom: 1                   // < 1 closer, > 1 farther (events)
    property real focusX: NaN               // when set, the camera aims here instead of the target
    property real focusY: NaN

    // smoothed state
    property real cx: 0
    property real cy: Tuning.camera.baseHeight
    property real lookAhead: 0
    property real dist: Tuning.camera.distance

    readonly property real halfWidthAtPlane: dist * Math.tan(cam.fieldOfView * Math.PI / 360) * aspect

    function snap(x, y) {
        cx = x; cy = y + sectionHeight; lookAhead = 0; dist = sectionDistance
        apply()
    }
    function update(dt) {
        const T = Tuning.camera
        const k = 1 - Math.exp(-T.smooth * dt)
        const focusing = !isNaN(focusX)
        // look-ahead follows the velocity direction, slowly
        const wantLook = focusing ? 0 : Math.max(-1, Math.min(1, targetVx / 5)) * T.lookAhead
        lookAhead += (wantLook - lookAhead) * (1 - Math.exp(-T.lookAheadSmooth * dt))
        // horizontal: aim between the siblings when they spread, otherwise on the leader
        let aimX = focusing ? focusX : targetX + lookAhead
        let wantDist = sectionDistance * zoom
        if (!focusing && frameBoth) {
            const spread = Math.abs(companionX - targetX)
            const room = halfWidthAtPlane * 1.5
            if (spread > room) { aimX = (targetX + companionX) / 2; wantDist = Math.min(T.maxDistance, sectionDistance * zoom + (spread - room) * 0.55 + T.frameBothPadding) }
        }
        dist += (wantDist - dist) * (1 - Math.exp(-3.0 * dt))
        const halfW = halfWidthAtPlane
        aimX = Math.max(boundsX0 + halfW, Math.min(boundsX1 - halfW, aimX))
        if (boundsX1 - boundsX0 < 2 * halfW) aimX = (boundsX0 + boundsX1) / 2
        cx += (aimX - cx) * k
        // vertical: only leave the window when the ground line really moves
        const aimY = (focusing ? focusY : targetGroundY) + sectionHeight
        const dy = aimY - cy
        if (Math.abs(dy) > T.verticalWindow || focusing) cy += dy * (1 - Math.exp(-T.verticalSmooth * dt))
        else cy += dy * (1 - Math.exp(-1.2 * dt))
        apply()
    }
    function apply() {
        rig.position = Qt.vector3d(cx, cy, 0)
        cam.position = Qt.vector3d(0, 0, dist)
    }

    PerspectiveCamera {
        id: cam
        fieldOfView: Tuning.camera.fov
        eulerRotation.x: Tuning.camera.pitch
        clipNear: 0.5
        clipFar: 400
    }
}
