// The visual abstraction for a level object: a QtMeshEditor model (balsam QML), a sprite sheet
// rendered by QtMeshEditor, or toon placeholder boxes - chosen by the manifest entry, never by
// gameplay code. Origin: bottom centre, like Clayground's Box3D.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import "scripts/PlaceholderShapes.js" as Shapes
import "config/assets.js" as Assets

Node {
    id: root
    property string assetId: ""
    property var def: Assets.get(assetId)
    property real w: 1; property real h: 1; property real d: 1          // box size in metres
    property string representation: def ? def.representation : "placeholder"   // model | sprite | placeholder
    property string assetBase: ""
    property bool useModels: true
    property real tint: 0                                                // 0..1 highlight (mechanisms)
    property bool castShadows: def && def.shadow ? def.shadow.cast : true
    property string shape: def && def.placeholder && def.placeholder.shape ? def.placeholder.shape : "box"
    readonly property bool modelReady: modelLoader.status === Loader3D.Ready
    readonly property bool wantsModel: useModels && representation === "model" && def && def.model !== ""
    readonly property bool wantsSprite: representation === "sprite" && def && def.sprite

    // --- 3D model -------------------------------------------------------------------------------
    Loader3D {
        id: modelLoader
        active: root.wantsModel
        source: !active ? "" : (root.assetBase ? root.assetBase + root.def.model : Qt.resolvedUrl(root.def.model))
        property real s: root.def ? (root.def.scale || 1) : 1
        scale: Qt.vector3d(s, s, s)
        y: root.def ? (root.def.footOffset || 0) * s : 0
        eulerRotation.y: root.def ? (root.def.rotation || 0) : 0
        onStatusChanged: if (status === Loader3D.Error) console.warn("PropVisual: failed to load", source)
    }

    // --- sprite sheet ---------------------------------------------------------------------------
    Loader3D {
        active: root.wantsSprite
        sourceComponent: Sprite3D {
            sheet: root.assetBase ? root.assetBase + root.def.sprite.sheet : Qt.resolvedUrl(root.def.sprite.sheet)
            columns: root.def.sprite.columns; rows: root.def.sprite.rows
            worldHeight: root.def.scale || root.h
            fps: root.def.sprite.fps || 0
            frameFrom: 0; frameTo: root.def.sprite.frames ? root.def.sprite.frames - 1 : 0
        }
    }

    // --- placeholder -----------------------------------------------------------------------------
    Node {
        visible: !root.modelReady && !root.wantsSprite
        Repeater3D {
            model: root.def ? Shapes.parts(root.shape, root.w, root.h, root.d, root.def.placeholder || {}) : [{ type: "box", x: 0, y: 0, z: 0, w: root.w, h: root.h, d: root.d, color: "#c98a3e", edges: true }]
            delegate: Node {
                id: partNode
                required property var modelData
                position: Qt.vector3d(modelData.x, modelData.y, modelData.z)
                readonly property color tinted: Qt.tint(modelData.color, Qt.rgba(1, 1, 0.6, root.tint * 0.6))
                Box3D {
                    visible: partNode.modelData.type === "box"
                    width: partNode.modelData.w; height: partNode.modelData.h; depth: partNode.modelData.d
                    color: partNode.tinted
                    useToonShading: true
                    showEdges: partNode.modelData.edges
                    edgeColor: "#26221f"
                    edgeThickness: 1.4

                    castsShadows: root.castShadows
                    receivesShadows: true
                }
                Model {
                    visible: partNode.modelData.type !== "box"
                    source: partNode.modelData.type === "sphere" ? "#Sphere" : "#Cylinder"
                    y: partNode.modelData.h / 2
                    scale: Qt.vector3d(partNode.modelData.w / 100, partNode.modelData.h / 100, partNode.modelData.d / 100)
                    materials: PrincipledMaterial { baseColor: partNode.tinted; roughness: 0.85; metalness: 0 }
                    castsShadows: root.castShadows
                    receivesShadows: true
                }
            }
        }
    }
}
