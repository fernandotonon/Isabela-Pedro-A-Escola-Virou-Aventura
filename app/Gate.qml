// A gate / grid / door that opens when every switch in `requires` is active. Solid while closed;
// slides up when opened. The director evaluates `requires`, this component only shows it.
import QtQuick
import QtQuick3D

Node {
    id: root
    property var spec: ({})
    property var solid: null
    property bool open: false
    property string assetBase: ""
    property bool useModels: true
    signal opened(string id)

    readonly property real w: spec.w || 0.8
    readonly property real h: spec.h || 3.2

    function setOpen(o) {
        if (o === open) return
        open = o
        if (solid) solid.enabled = !o
        else console.warn("Gate", spec.id, "has no solid")
        if (o) opened(spec.id)
    }
    function reset() { open = false; if (solid) solid.enabled = true }
    function serialize() { return { open: open } }
    function restore(s) { if (s && s.open) setOpen(true) }

    position: Qt.vector3d(spec.x + w / 2, spec.y, 0)
    PropVisual {
        id: visual
        assetId: root.spec.asset || "school_gate_small"
        w: root.w; h: root.h; d: root.spec.d || 0.3
        assetBase: root.assetBase; useModels: root.useModels
        y: root.open ? root.h * 0.92 : 0
        Behavior on y { NumberAnimation { duration: 900; easing.type: Easing.InOutCubic } }
    }
    // posts stay in place so the opening reads
    PropVisual { assetId: "fence_yellow"; w: 0.25; h: root.h + 0.3; d: 0.25; x: -root.w / 2 - 0.15; representation: "placeholder" }
    PropVisual { assetId: "fence_yellow"; w: 0.25; h: root.h + 0.3; d: 0.25; x: root.w / 2 + 0.15; representation: "placeholder" }
}
