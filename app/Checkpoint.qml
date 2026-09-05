// A checkpoint flag. Reached when the active sibling passes it; the director snapshots the state.
import QtQuick
import QtQuick3D
import "scripts/Physics.js" as Physics

Node {
    id: root
    property var spec: ({})
    property bool reached: false
    property string assetBase: ""
    property bool useModels: true
    readonly property var sensor: ({ x: spec.x - 0.8, y: spec.y - 0.5, w: 1.6, h: 4 })
    signal activated(string id)

    function test(body) {
        if (reached) return false
        if (Physics.overlap(Physics.box(body), sensor)) { reached = true; activated(spec.id); return true }
        return false
    }

    position: Qt.vector3d(spec.x, spec.y, 0)
    PropVisual {
        assetId: "checkpoint_marker"
        w: 0.4; h: 2.2; d: 0.4
        assetBase: root.assetBase; useModels: root.useModels
        tint: root.reached ? 0.8 : 0
    }
}
