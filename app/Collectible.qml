// Courage Star, coloured pencil or the Family Memory. Floats and spins; collected once (ids are
// persisted by the save system). The director tests overlap against the characters.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics

Node {
    id: root
    property var spec: ({})
    property string collectibleId: ""      // "<section>:<type>:<index>"
    property bool collected: false
    property string assetBase: ""
    property bool useModels: true
    readonly property string kind: spec.type || ""       // star | pencil | memory
    readonly property real size: kind === "star" ? 0.55 : 0.75
    readonly property var sensor: ({ x: spec.x - size / 2, y: spec.y, w: size, h: size })
    signal taken(string kind, string id)

    function test(body) {
        if (collected) return false
        if (Physics.overlap(Physics.box(body), sensor)) { collect(); return true }
        return false
    }
    function collect() { collected = true; taken(kind, collectibleId); pop.restart() }
    function restore(taken) { collected = taken }

    position: Qt.vector3d(spec.x, spec.y, 0)
    visible: !collected || pop.running

    Node {
        id: inner
        property real t: 0
        FrameAnimation { running: root.visible; onTriggered: inner.t = elapsedTime }
        y: 0.12 + Math.sin(inner.t * 2.4 + root.spec.x) * 0.08
        // generated models are single-view (their back is plain): sway instead of a full spin; the toon
        // placeholders keep spinning
        eulerRotation.y: look.representation === "model" ? Math.sin(inner.t * 1.8 + root.spec.x) * 32 : (inner.t * 70) % 360
        PropVisual {
            id: look
            assetId: root.kind === "star" ? "star" : (root.kind === "pencil" ? "pencil_collectible" : "memory")
            w: root.size; h: root.size; d: root.size
            assetBase: root.assetBase; useModels: root.useModels
            eulerRotation.z: representation === "model" ? 0 : (root.kind === "star" ? 45 : (root.kind === "pencil" ? 30 : 0))
        }
    }
    SequentialAnimation {
        id: pop
        ParallelAnimation {
            NumberAnimation { target: inner; property: "scale.x"; to: 1.8; duration: 220 }
            NumberAnimation { target: inner; property: "scale.y"; to: 1.8; duration: 220 }
            NumberAnimation { target: inner; property: "y"; to: 1.4; duration: 220 }
            NumberAnimation { target: inner; property: "opacity"; to: 0; duration: 220 }
        }
        ScriptAction { script: { inner.scale = Qt.vector3d(1, 1, 1); inner.opacity = 1 } }
    }
}
