// One sibling in the scene. The simulation state lives in a CharacterMotion JS object (`motion`)
// stepped by the game at a fixed rate; this Node mirrors it into properties the visual and HUD
// bind to. Nothing here depends on how the character is drawn.
import QtQuick
import QtQuick3D
import "scripts/CharacterMotion.js" as Motion
import "config/tuning.js" as Tuning

Node {
    id: root
    property string characterId: "isabela"
    property var world: null               // Physics world (JS object)
    property var motion: null              // CharacterMotion object
    property string assetBase: ""
    property bool useModels: true

    // mirrored state (written by sync())
    property string state: "Idle"
    property real facing: 1
    property real speed: 0
    property bool crouched: false
    property bool controlled: false
    property int courage: 3
    property bool invulnerable: false
    property bool grounded: true
    readonly property real px: position.x
    readonly property real py: position.y
    readonly property var def: Tuning.character(characterId)
    readonly property string displayName: def ? def.displayName : characterId

    function create(x, y) {
        motion = Motion.create(world, def, x, y)
        sync()
    }
    function sync() {
        if (!motion) return
        const b = motion.body
        position = Qt.vector3d(b.x, b.y, 0)
        state = motion.fsm.state
        facing = motion.facing
        speed = Math.abs(b.vx)
        crouched = motion.crouched
        courage = motion.courage
        invulnerable = motion.invulnerable > 0
        grounded = b.grounded
        controlled = motion.controlled
    }

    CharacterVisual {
        id: visual
        characterId: root.characterId
        state: root.state
        facing: root.facing
        speed: root.speed
        crouched: root.crouched
        invulnerable: root.invulnerable
        controlled: root.controlled
        assetBase: root.assetBase
        useModels: root.useModels
        bodyHeight: root.def ? root.def.height : 1.5
        bodyWidth: root.def ? root.def.width : 0.6
    }

    // cheap blob shadow: reads as grounded even when real shadows are off
    Model {
        source: "#Cylinder"
        y: 0.006
        scale: Qt.vector3d((root.def ? root.def.width : 0.6) * 0.016, 0.0001, (root.def ? root.def.width : 0.6) * 0.012)
        opacity: root.grounded ? 0.28 : 0.14
        materials: PrincipledMaterial { baseColor: "#102030"; lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend }
        castsShadows: false; receivesShadows: false
    }
}
