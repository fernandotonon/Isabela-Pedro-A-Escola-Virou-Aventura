// A mechanism input: floor button (latches when stepped on), lever (interact with E) or pressure
// plate (active only while something stands on it; `byPushable` plates also react to pushed
// objects - the ball in the goal). Gates read `active` through the LevelDirector's switch table.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import "scripts/Physics.js" as Physics

Node {
    id: root
    property var spec: ({})
    property string kind: spec.type || ""        // button | lever | plate
    property bool active: false
    property bool latching: kind !== "plate"
    property string assetBase: ""
    property bool useModels: true
    property var world: null
    signal activated(string id)
    signal deactivated(string id)

    readonly property real w: spec.w || 0.9
    readonly property real h: spec.h || 0.22
    readonly property bool interactable: kind === "lever"

    // sensor box above the switch: who stands here?
    readonly property var sensor: ({ x: spec.x - w / 2, y: spec.y, w: w, h: h + 0.35 })

    function press() { if (!active) { active = true; activated(spec.id) } }
    function release() { if (active && !latching) { active = false; deactivated(spec.id) } }
    function toggle() { if (kind === "lever") { active = !active; if (active) activated(spec.id); else deactivated(spec.id) } }
    function interact() { if (kind === "lever" && !active) press() }
    function reset() { if (active) { active = false; deactivated(spec.id) } }
    function serialize() { return { active: active } }
    function restore(s) { if (s && s.active && !active) { active = true } }

    // evaluate standing bodies (called by the director each step with the list of bodies)
    function evaluate(bodies) {
        if (kind === "lever") return
        let pressed = false
        for (const b of bodies) {
            if (b.isPushable && !spec.byPushable) continue
            if (Physics.overlap(Physics.box(b), sensor)) { pressed = true; break }
        }
        if (pressed) press(); else release()
    }

    position: Qt.vector3d(spec.x, spec.y, 0)
    PropVisual {
        assetId: root.kind === "button" ? "floor_button" : (root.kind === "lever" ? "lever" : "plate")
        w: root.w; h: root.h; d: root.kind === "plate" ? 1.0 : root.w
        assetBase: root.assetBase; useModels: root.useModels
        tint: root.active ? 0.9 : 0
        scale: Qt.vector3d(1, root.active && root.kind !== "lever" ? 0.55 : 1, 1)
        eulerRotation.z: root.kind === "lever" ? (root.active ? -35 : 35) : 0
        Behavior on scale { Vector3dAnimation { duration: 120 } }
        Behavior on eulerRotation.z { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
    }
    // active glow ring
    Model {
        visible: root.active
        source: "#Cylinder"; y: 0.02
        scale: Qt.vector3d(root.w * 0.016, 0.0002, root.w * 0.016)
        materials: PrincipledMaterial { baseColor: "#9cff8a"; lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend; opacity: 0.6 }
        castsShadows: false; receivesShadows: false
    }
}
