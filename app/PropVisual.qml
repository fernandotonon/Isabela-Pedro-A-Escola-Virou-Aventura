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
    readonly property bool wantsModel: useModels && representation === "model" && def && def.model !== ""
    readonly property bool wantsSprite: representation === "sprite" && def && def.sprite

    // --- 3D model -------------------------------------------------------------------------------
    // The model is fitted into the entity's box by its tighter dimension; when that leaves a wide
    // platform mostly empty (a row of planters, a long bench top), the model is repeated along X.
    readonly property real unitW: def && def.unitWidth ? def.unitWidth : 1
    readonly property real unitH: def && def.unitHeight ? def.unitHeight : 1
    // manifest `fit`: "height" (gates, levers, flags: match the box height, width may exceed), "width"
    // (a swing seat with hangers above it), default: the tighter dimension
    readonly property real fitScale: !def || !def.unitHeight ? (def ? def.scale || 1 : 1)
                                     : def.fit === "height" ? h / unitH : def.fit === "width" ? w / unitW : Math.min(w / unitW, h / unitH)
    // only assets marked `tile: true` (platform blocks, stands) repeat along a wide box; decor never does
    readonly property int copies: def && def.tile && def.unitWidth && def.fit !== "width" && unitW * fitScale < 0.7 * w ? Math.max(1, Math.round(w / (unitW * fitScale))) : 1
    readonly property bool modelReady: modelRepeater.count > 0 && modelRepeater.objectAt(0) && modelRepeater.objectAt(0).status === Loader3D.Ready
    Repeater3D {
        id: modelRepeater
        model: root.wantsModel ? root.copies : 0
        delegate: Loader3D {
            required property int index
            source: root.assetBase ? root.assetBase + root.def.model : Qt.resolvedUrl(root.def.model)
            x: root.copies > 1 ? -root.w / 2 + (index + 0.5) * root.w / root.copies : 0
            scale: Qt.vector3d(root.fitScale, root.fitScale, root.fitScale)
            y: (root.def.footOffset || 0) * root.fitScale
            eulerRotation.y: root.def.rotation || 0
            onStatusChanged: if (status === Loader3D.Error) console.warn("PropVisual: failed to load", source)
        }
    }

    // --- sprite sheet ---------------------------------------------------------------------------
    Loader3D {
        active: root.wantsSprite
        sourceComponent: Sprite3D {
            sheet: root.assetBase ? root.assetBase + root.def.sprite.sheet : Qt.resolvedUrl(root.def.sprite.sheet)
            columns: root.def.sprite.columns; rows: root.def.sprite.rows
            worldHeight: root.def.height || root.h
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
