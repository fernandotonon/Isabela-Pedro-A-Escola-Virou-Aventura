// Walkable ground: a wide slab, coloured by surface (grass, concrete, rubber, court, tile),
// with a deeper dark base so gaps read as depth. Origin: bottom centre of the slab.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D

Node {
    id: root
    property real w: 10
    property real h: 1.5
    property real d: 7
    property string surface: "grass"
    readonly property var palette: ({
        grass: { top: "#6cbf4b", side: "#8a6a3a" }, concrete: { top: "#cfc9bc", side: "#8f8a7f" },
        rubber: { top: "#e0605a", side: "#7d8288" }, court: { top: "#3f7fd0", side: "#7d8288" },
        tile: { top: "#5a5560", side: "#3a3640" }, wood: { top: "#c98a3e", side: "#8a5a2a" }
    })
    readonly property var colors: palette[surface] || palette.grass

    Box3D { width: root.w; height: root.h - 0.1; depth: root.d; color: root.colors.side; useToonShading: true; edgeThickness: 1.2; edgeColor: "#26221f"; receivesShadows: true }
    Box3D { y: root.h - 0.1; width: root.w + 0.04; height: 0.1; depth: root.d + 0.04; color: root.colors.top; useToonShading: true; edgeThickness: 1.0; edgeColor: "#26221f"; receivesShadows: true }
    // court markings / tile joints as thin lines
    Box3D { visible: root.surface === "court"; y: root.h - 0.075; width: root.w * 0.9; height: 0.005; depth: 0.08; color: "#f4f4f8"; showEdges: false; castsShadows: false }
    Box3D { visible: root.surface === "court"; y: root.h - 0.075; z: 1.4; width: root.w * 0.9; height: 0.005; depth: 0.08; color: "#f2c530"; showEdges: false; castsShadows: false }
}
