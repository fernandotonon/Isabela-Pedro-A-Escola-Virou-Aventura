// A static level object: platform, wall, ground slab, low passage, ladder or pure decoration.
// Its collision box (if any) lives in the Physics world as `solid`; here is only the look.
import QtQuick
import QtQuick3D

Node {
    id: root
    property var spec: ({})                 // level entity description
    property var solid: null                // Physics solid (null for decoration)
    property string assetBase: ""
    property bool useModels: true
    property bool hidden: false             // hidden platforms (revealed by Isabela's notebook)
    property bool revealed: false
    property real surfaceTint: 0

    readonly property real w: spec.w !== undefined ? spec.w : (visual.def && visual.def.collider ? visual.def.collider.w : 1)
    readonly property real h: spec.h !== undefined ? spec.h : (visual.def && visual.def.collider ? visual.def.collider.h : 1)
    readonly property real d: spec.d !== undefined ? spec.d : (visual.def && visual.def.collider ? visual.def.collider.d : Math.min(1.6, Math.max(0.8, h)))

    visible: !hidden || revealed
    function reveal() { revealed = true; if (solid) solid.enabled = true; revealPulse.restart() }
    SequentialAnimation {
        id: revealPulse
        NumberAnimation { target: root; property: "scale.y"; from: 0.2; to: 1.15; duration: 220; easing.type: Easing.OutBack }
        NumberAnimation { target: root; property: "scale.y"; to: 1; duration: 140 }
    }

    // ground slabs are long boxes tinted by surface; everything else goes through the manifest
    PropVisual {
        id: visual
        assetId: root.spec.asset || (root.spec.type === "ground" ? "" : "push_box")
        representation: root.spec.type === "ground" || !root.spec.asset ? "placeholder" : (def ? def.representation : "placeholder")
        w: root.w; h: root.h; d: root.d
        assetBase: root.assetBase
        useModels: root.useModels
        tint: root.surfaceTint
        visible: root.spec.type !== "ground"
    }
    // a ground segment: a wide slab whose top colour depends on the surface type
    Loader3D {
        active: root.spec.type === "ground"
        z: -1.8                                   // the slab reaches further back than forward
        sourceComponent: GroundSlab { w: root.w; h: root.h; surface: root.spec.surface || "grass" }
    }
}
