// The classroom door: two interaction points, one per sibling. Both must be standing at the door
// and interact; then the level ends.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics

Node {
    id: root
    property var spec: ({})
    property string assetBase: ""
    property bool useModels: true
    property bool open: false
    property var present: ({})          // characterId -> bool (standing at the door)
    property var confirmed: ({})        // characterId -> bool (interacted)
    property var solid: null            // Physics solid: the closed door blocks
    signal opened()
    readonly property real w: spec.w || 1.6
    readonly property real h: spec.h || 3.0
    readonly property var zone: ({ x: spec.x - 2.4, y: spec.y - 0.2, w: 4.8, h: 3.2 })
    readonly property bool bothPresent: present.isabela === true && present.pedro === true
    readonly property bool interactable: bothPresent && !open

    function evaluate(chars) {
        const p = {}
        for (const c of chars) p[c.id] = Physics.overlap(Physics.box(c.body), zone)
        present = p
    }
    function interact(characterId) {
        if (!bothPresent || open) return false
        const c = Object.assign({}, confirmed); c[characterId] = true; confirmed = c
        if (confirmed.isabela && confirmed.pedro) { open = true; opened(); return true }
        return true
    }
    function reset() { open = false; confirmed = ({}); present = ({}) }

    position: Qt.vector3d(spec.x, spec.y, 0)
    PropVisual {
        assetId: "final_door"
        w: root.w; h: root.h; d: 0.3
        assetBase: root.assetBase; useModels: root.useModels
        eulerRotation.y: root.open ? -80 : 0
        x: root.open ? -root.w / 2 : 0
        Behavior on eulerRotation.y { NumberAnimation { duration: 1200; easing.type: Easing.InOutCubic } }
        Behavior on x { NumberAnimation { duration: 1200; easing.type: Easing.InOutCubic } }
    }
    // the two marks
    PropVisual { assetId: "plate"; x: -1.3; w: 1.0; h: 0.08; d: 0.9; tint: root.confirmed.isabela ? 1 : (root.present.isabela ? 0.4 : 0) }
    PropVisual { assetId: "plate"; x: 1.3; w: 1.0; h: 0.08; d: 0.9; tint: root.confirmed.pedro ? 1 : (root.present.pedro ? 0.4 : 0) }
    // door frame
    PropVisual { assetId: "corridor_wall"; x: -root.w / 2 - 0.2; w: 0.3; h: root.h + 0.3; d: 0.5; representation: "placeholder" }
    PropVisual { assetId: "corridor_wall"; x: root.w / 2 + 0.2; w: 0.3; h: root.h + 0.3; d: 0.5; representation: "placeholder" }
    PropVisual { assetId: "corridor_wall"; y: root.h; w: root.w + 0.7; h: 0.3; d: 0.5; representation: "placeholder" }
}
