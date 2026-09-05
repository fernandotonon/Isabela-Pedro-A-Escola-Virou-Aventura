// The 3D scene: view, lights, sky/backdrop, and the roots entities are parented to.
// The play plane is z = 0; props sit behind it (negative z) for depth.
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import Clayground.Canvas3D

View3D {
    id: view3d
    property alias rig: rig
    readonly property alias propRoot: propRoot
    readonly property alias platformRoot: platformRoot
    readonly property alias entityRoot: entityRoot
    readonly property alias characterRoot: characterRoot
    readonly property alias fxRoot: fxRoot
    property color skyColor: "#8fd0f4"
    property color farColor: "#cfe8f6"
    property bool indoor: false
    property int quality: 1              // 0 low, 1 medium, 2 high
    property bool debugColliders: false

    camera: rig.camera
    environment: SceneEnvironment {
        clearColor: view3d.skyColor
        backgroundMode: SceneEnvironment.Color
        antialiasingMode: view3d.quality > 0 ? SceneEnvironment.MSAA : SceneEnvironment.NoAA
        antialiasingQuality: view3d.quality > 1 ? SceneEnvironment.High : SceneEnvironment.Medium
        Behavior on clearColor { ColorAnimation { duration: 900 } }
    }

    SideCamera { id: rig; aspect: view3d.width / Math.max(1, view3d.height) }

    // warm daylight outside, soft and bright inside
    DirectionalLight {
        eulerRotation.x: view3d.indoor ? -62 : -48
        eulerRotation.y: view3d.indoor ? 20 : -35
        brightness: view3d.indoor ? 1.15 : 1.35
        color: view3d.indoor ? "#fff6e8" : "#fff1d6"
        ambientColor: view3d.indoor ? "#6b6a66" : "#5c6a78"
        castsShadow: view3d.quality > 0
        shadowFactor: 55
        shadowMapQuality: view3d.quality > 1 ? Light.ShadowMapQualityHigh : Light.ShadowMapQualityMedium
        shadowBias: 8
        pcfFactor: 6
        csmNumSplits: view3d.quality > 1 ? 2 : 1
        shadowMapFar: 60
        Behavior on brightness { NumberAnimation { duration: 900 } }
    }
    DirectionalLight { eulerRotation.x: -20; eulerRotation.y: 150; brightness: 0.35; color: "#cfe0ff" }

    // a far backdrop plane so the horizon is not a flat clear colour
    Model {
        source: "#Rectangle"
        position: Qt.vector3d(rig.cx, 6, -28)
        scale: Qt.vector3d(3.2, 0.9, 1)
        castsShadows: false; receivesShadows: false; pickable: false
        materials: PrincipledMaterial { baseColor: view3d.farColor; lighting: PrincipledMaterial.NoLighting }
    }

    Node { id: propRoot }
    Node { id: platformRoot }
    Node { id: entityRoot }
    Node { id: characterRoot }
    Node { id: fxRoot }
}
