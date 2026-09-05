// How a sibling looks: the QtMeshEditor rig (balsam QML with a `clip` property), a sprite sheet
// rendered from the same rig, or a toon placeholder with a tiny procedural animation. Physics
// and control never look in here; they only set state/facing/speed.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import "config/assets.js" as Assets

Node {
    id: root
    property string characterId: "isabela"
    property var def: Assets.get(characterId)
    property string state: "Idle"          // CharacterMotion FSM state name
    property real facing: 1
    property real speed: 0                 // |vx| for animation pacing
    property bool crouched: false
    property bool invulnerable: false
    property bool controlled: false
    property string assetBase: ""
    property bool useModels: true
    property real bodyHeight: def ? def.collider.h : 1.5
    property real bodyWidth: def ? def.collider.w : 0.6

    readonly property string representation: def ? def.representation : "placeholder"
    readonly property bool modelReady: modelLoader.status === Loader3D.Ready
    readonly property string clipName: def && def.clips && def.clips[state] ? def.clips[state] : "Idle"

    // blink while invulnerable
    property real blinkT: 0
    opacity: invulnerable ? (Math.floor(blinkT * 12) % 2 ? 0.35 : 1) : 1
    NumberAnimation on blinkT { running: root.invulnerable; loops: Animation.Infinite; from: 0; to: 10; duration: 10000 }

    // face +X (yaw 90) or -X (yaw -90), tilted a little toward the camera for the 2.5D look
    eulerRotation.y: (facing >= 0 ? 68 : -68) + (def ? (def.rotation || 0) : 0)
    Behavior on eulerRotation.y { NumberAnimation { duration: 110 } }

    // --- QtMeshEditor rig ------------------------------------------------------------------------
    Loader3D {
        id: modelLoader
        active: root.useModels && root.representation === "model" && root.def && root.def.model !== ""
        source: !active ? "" : (root.assetBase ? root.assetBase + root.def.model : Qt.resolvedUrl(root.def.model))
        property real s: root.def ? (root.def.scale || 1) : 1
        scale: Qt.vector3d(s, s, s)
        y: root.def ? (root.def.footOffset || 0) * s : 0
        onLoaded: applyClip()
        onStatusChanged: if (status === Loader3D.Error) console.warn("CharacterVisual: failed to load", source)
        function applyClip() {
            if (!item || item.clip === undefined) return
            const has = !item.clips || item.clips.indexOf(root.clipName) >= 0
            item.clip = has ? root.clipName : "Idle"
        }
    }
    onClipNameChanged: modelLoader.applyClip()

    // --- sprite sheet ------------------------------------------------------------------------------
    Loader3D {
        id: spriteLoader
        active: root.representation === "sprite" && root.def && root.def.sprite
        sourceComponent: Sprite3D {
            id: sprite
            sheet: root.assetBase ? root.assetBase + root.def.sprite.sheet : Qt.resolvedUrl(root.def.sprite.sheet)
            columns: root.def.sprite.columns; rows: root.def.sprite.rows
            worldHeight: root.bodyHeight * (root.def.sprite.heightScale || 1.25)
            aspect: root.def.sprite.aspect || 1
            flipX: root.facing < 0
            tiltTowardCamera: -root.eulerRotation.y      // the billboard must not turn with the node
            property var clipRow: root.def.sprite.clips ? root.def.sprite.clips[root.clipName] || root.def.sprite.clips["Idle"] : null
            row: clipRow ? clipRow.row : 0
            Component.onCompleted: restart()
            function restart() { if (clipRow) play(clipRow.from, clipRow.to, clipRow.fps || 10, clipRow.loop !== false) }
            onClipRowChanged: restart()
        }
    }

    // --- placeholder: a toon kid ---------------------------------------------------------------------
    Node {
        id: placeholder
        visible: !root.modelReady && !spriteLoader.active
        property color shirt: root.def ? root.def.placeholder.color : "#e64b7a"
        property color skin: root.def ? root.def.placeholder.skin : "#f1c7a8"
        property color hair: root.def ? root.def.placeholder.hair : "#3b2418"
        property real hh: root.crouched ? root.bodyHeight * 0.55 : root.bodyHeight
        property real legH: hh * 0.32
        property real torsoH: hh * 0.36
        property real headH: hh * 0.3
        property real bob: 0
        property real squash: root.state === "Land" || root.state === "JumpStart" ? 0.88 : 1
        Behavior on squash { NumberAnimation { duration: 80 } }
        Behavior on hh { NumberAnimation { duration: 90 } }
        scale: Qt.vector3d(1 / squash, squash, 1)

        FrameAnimation {
            running: placeholder.visible
            onTriggered: {
                const walking = root.state === "Walk" || root.state === "Run" || root.state === "Push" || root.state === "Crawl"
                placeholder.bob = walking ? Math.sin(elapsedTime * (8 + root.speed * 1.4)) : (root.state === "Idle" ? Math.sin(elapsedTime * 2) * 0.25 : 0)
            }
        }
        // legs
        Box3D { x: -root.bodyWidth * 0.2; z: placeholder.bob * 0.18; width: root.bodyWidth * 0.32; height: placeholder.legH; depth: root.bodyWidth * 0.32; color: "#2b2b2b"; useToonShading: true; edgeThickness: 1.2 }
        Box3D { x: root.bodyWidth * 0.2; z: -placeholder.bob * 0.18; width: root.bodyWidth * 0.32; height: placeholder.legH; depth: root.bodyWidth * 0.32; color: "#2b2b2b"; useToonShading: true; edgeThickness: 1.2 }
        // torso
        Box3D { y: placeholder.legH; width: root.bodyWidth; height: placeholder.torsoH; depth: root.bodyWidth * 0.6; color: placeholder.shirt; useToonShading: true; edgeThickness: 1.4 }
        // arms
        Box3D { x: -root.bodyWidth * 0.62; y: placeholder.legH + placeholder.torsoH * 0.15; z: -placeholder.bob * 0.15; width: root.bodyWidth * 0.22; height: placeholder.torsoH * 0.85; depth: root.bodyWidth * 0.22; color: placeholder.skin; useToonShading: true; edgeThickness: 1.1
               eulerRotation.x: root.state === "Celebrate" ? 160 : (root.state === "Wave" ? 140 : 0) }
        Box3D { x: root.bodyWidth * 0.62; y: placeholder.legH + placeholder.torsoH * 0.15; z: placeholder.bob * 0.15; width: root.bodyWidth * 0.22; height: placeholder.torsoH * 0.85; depth: root.bodyWidth * 0.22; color: placeholder.skin; useToonShading: true; edgeThickness: 1.1
               eulerRotation.x: root.state === "Celebrate" ? 160 : (root.state === "Hang" ? 170 : 0) }
        // head + hair + eyes
        Box3D { y: placeholder.legH + placeholder.torsoH + Math.abs(placeholder.bob) * 0.03; width: root.bodyWidth * 0.95; height: placeholder.headH; depth: root.bodyWidth * 0.85; color: placeholder.skin; useToonShading: true; edgeThickness: 1.4 }
        Box3D { y: placeholder.legH + placeholder.torsoH + placeholder.headH * 0.78; width: root.bodyWidth * 1.02; height: placeholder.headH * 0.32; depth: root.bodyWidth * 0.92; color: placeholder.hair; useToonShading: true; edgeThickness: 1.2 }
        Box3D { x: root.bodyWidth * 0.18; y: placeholder.legH + placeholder.torsoH + placeholder.headH * 0.45; z: root.bodyWidth * 0.43; width: 0.09; height: 0.11; depth: 0.02; color: "#1b1b1b"; showEdges: false }
        Box3D { x: -root.bodyWidth * 0.18; y: placeholder.legH + placeholder.torsoH + placeholder.headH * 0.45; z: root.bodyWidth * 0.43; width: 0.09; height: 0.11; depth: 0.02; color: "#1b1b1b"; showEdges: false }
        // Isabela's notebook / Pedro's cap as a quick silhouette difference
        Box3D { visible: root.characterId === "isabela"; x: -root.bodyWidth * 0.55; y: placeholder.legH + placeholder.torsoH * 0.3; z: root.bodyWidth * 0.2; width: 0.08; height: 0.3; depth: 0.24; color: "#f2c530"; useToonShading: true }
        Box3D { visible: root.characterId === "pedro"; y: placeholder.legH + placeholder.torsoH + placeholder.headH * 0.95; z: root.bodyWidth * 0.2; width: root.bodyWidth * 0.9; height: 0.05; depth: root.bodyWidth * 1.1; color: "#e33f3f"; useToonShading: true }
    }

    // active-character marker: a soft ring on the ground
    Model {
        visible: root.controlled
        source: "#Cylinder"
        y: 0.012
        scale: Qt.vector3d(root.bodyWidth * 0.022, 0.0002, root.bodyWidth * 0.022)
        materials: PrincipledMaterial { baseColor: "#fff3a0"; lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend; opacity: 0.55 }
        castsShadows: false; receivesShadows: false
    }
}
