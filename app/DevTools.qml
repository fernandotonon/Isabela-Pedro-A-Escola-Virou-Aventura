// Development tools (compiled only into development builds - see app/CMakeLists.txt):
// F1 toggles the panel. Colliders, character state, FPS, coordinates, checkpoint teleport,
// section restart, active character, collectible unlock, manual mechanisms, platform/hazard speed.
import QtQuick
import QtQuick3D
import QtQuick.Layouts
import "scripts/Physics.js" as Physics
import "scripts/LevelCheck.js" as LevelCheck
import "config/level.js" as Level

Item {
    id: dev
    property var game: null
    property var director: null
    property var world3d: null
    property var input: null
    property bool open: false
    property bool showColliders: false
    property var colliderList: []
    readonly property color ink: "#e8e8e8"

    focus: false
    Keys.onPressed: (e) => { if (e.key === Qt.Key_F1) { open = !open; e.accepted = true } }
    // F1 must work while the game has focus: hook the game item's key handling
    Connections { target: dev.input; function onAnyKey() {} }
    Shortcut { sequence: "F1"; onActivated: dev.open = !dev.open }
    Shortcut { sequence: "F2"; onActivated: dev.showColliders = !dev.showColliders }

    // ---- collider visualisation: translucent boxes over every Physics solid --------------------------
    Timer { interval: 400; repeat: true; running: dev.showColliders && dev.game && dev.game.world
        onTriggered: dev.colliderList = dev.game.world.solids.map(function (s) { return { x: s.x, y: s.y, w: s.w, h: s.h, kind: s.kind, enabled: s.enabled } }) }
    onShowCollidersChanged: if (!showColliders) colliderList = []
    Repeater3D {
        parent: dev.world3d ? dev.world3d.fxRoot : null
        model: dev.colliderList
        Model {
            required property var modelData
            source: "#Cube"
            visible: modelData.enabled
            position: Qt.vector3d(modelData.x + modelData.w / 2, modelData.y + modelData.h / 2, 0.55)
            scale: Qt.vector3d(modelData.w / 100, modelData.h / 100, 0.002)
            castsShadows: false; receivesShadows: false; pickable: false
            materials: PrincipledMaterial { lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend; opacity: 0.35
                baseColor: modelData.kind === "solid" ? "#ff3b3b" : (modelData.kind === "oneway" ? "#3bff6a" : (modelData.kind === "low" ? "#ffb13b" : "#3ba9ff")) }
        }
    }
    // character bodies
    Repeater3D {
        parent: dev.world3d ? dev.world3d.fxRoot : null
        model: dev.showColliders && dev.game ? dev.game.characters : []
        Model {
            required property var modelData
            source: "#Cube"
            position: Qt.vector3d(modelData.px, modelData.py + (modelData.motion ? modelData.motion.body.h / 2 : 0.75), 0.6)
            scale: Qt.vector3d((modelData.motion ? modelData.motion.body.w : 0.6) / 100, (modelData.motion ? modelData.motion.body.h : 1.5) / 100, 0.002)
            castsShadows: false; receivesShadows: false; pickable: false
            materials: PrincipledMaterial { lighting: PrincipledMaterial.NoLighting; alphaMode: PrincipledMaterial.Blend; opacity: 0.4; baseColor: "#ffffff" }
        }
    }

    // ---- always-on mini readout -------------------------------------------------------------------------
    Text {
        anchors { left: parent.left; bottom: parent.bottom; margins: 8 }
        color: dev.ink; font.pixelSize: 12; font.family: "Menlo"
        style: Text.Outline; styleColor: "#000"
        text: game ? ("FPS " + game.fps + "  x " + game.active.px.toFixed(2) + "  y " + game.active.py.toFixed(2) + "  " + game.active.characterId + ":" + game.active.state +
                      "  vx " + (game.active.motion ? game.active.motion.body.vx.toFixed(1) : "") + "  " + (game.currentSection ? game.currentSection.id : "") +
                      "  cp " + game.checkpoint.id + "  F1 tools  F2 colliders") : ""
    }

    // ---- panel ----------------------------------------------------------------------------------------------
    Rectangle {
        visible: dev.open
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom; margins: 8 }
        width: 330; radius: 10; color: Qt.rgba(0.08, 0.08, 0.1, 0.9)
        MouseArea { anchors.fill: parent }
        Flickable {
            anchors.fill: parent; anchors.margins: 10; contentHeight: col.implicitHeight; clip: true
            ColumnLayout {
                id: col; width: parent.width; spacing: 6
                Text { text: game ? game.tr("dev.title") : "Dev"; color: dev.ink; font.bold: true; font.pixelSize: 16 }
                Text { color: dev.ink; font.pixelSize: 12; font.family: "Menlo"; wrapMode: Text.Wrap; Layout.fillWidth: true
                       text: game ? ("phase " + game.phase + "\nisabela " + isaState() + "\npedro " + pedState() + "\nsolids " + game.world.solids.length + "  collected " + Object.keys(director.collected).length) : "" }
                Row { spacing: 6
                    DevButton { text: "colliders " + (dev.showColliders ? "on" : "off"); onClicked: dev.showColliders = !dev.showColliders }
                    DevButton { text: "isabela"; onClicked: game.setActive(game.isabelaRef(), true) }
                    DevButton { text: "pedro"; onClicked: game.setActive(game.pedroRef(), true) } }
                Text { text: "Checkpoints"; color: dev.ink; font.bold: true }
                Flow { Layout.fillWidth: true; spacing: 4
                    Repeater { model: director ? director.checkpointList() : []
                        DevButton { required property var modelData; text: modelData.id; onClicked: game.teleportTo(modelData.x, modelData.y) } } }
                Text { text: "Sections (restart at start)"; color: dev.ink; font.bold: true }
                Flow { Layout.fillWidth: true; spacing: 4
                    Repeater { model: Level.level.sections
                        DevButton { required property var modelData; text: modelData.id; onClicked: { game.teleportTo(modelData.x0 + 2, 0); director.resetTriggersAfter(modelData.x0) } } } }
                Text { text: "Mechanisms"; color: dev.ink; font.bold: true }
                Flow { Layout.fillWidth: true; spacing: 4
                    Repeater { model: director ? Object.keys(director.switches) : []
                        DevButton { required property var modelData; text: modelData + (director.switches[modelData].active ? " ✓" : ""); onClicked: director.switches[modelData].press() } } }
                Row { spacing: 6
                    DevButton { text: "unlock all collectibles"; onClicked: { for (const c of director.collectibles) if (!c.collected) c.collect() } }
                    DevButton { text: "refill courage"; onClicked: { for (const c of game.characters) c.motion.courage = c.def.courageMax } } }
                Text { text: "Platform speed " + director.platformSpeedScale.toFixed(2); color: dev.ink }
                Row { spacing: 6; DevButton { text: "-"; onClicked: director.platformSpeedScale = Math.max(0, director.platformSpeedScale - 0.25) } DevButton { text: "+"; onClicked: director.platformSpeedScale += 0.25 } DevButton { text: "1"; onClicked: director.platformSpeedScale = 1 } }
                Text { text: "Hazard speed " + director.hazardSpeedScale.toFixed(2); color: dev.ink }
                Row { spacing: 6; DevButton { text: "-"; onClicked: director.hazardSpeedScale = Math.max(0, director.hazardSpeedScale - 0.25) } DevButton { text: "+"; onClicked: director.hazardSpeedScale += 0.25 } DevButton { text: "1"; onClicked: director.hazardSpeedScale = 1 } }
                Text { text: "Level check"; color: dev.ink; font.bold: true }
                Text { color: dev.ink; font.pixelSize: 11; font.family: "Menlo"; wrapMode: Text.Wrap; Layout.fillWidth: true
                       text: { const r = LevelCheck.validate(Level.level); return "stars " + r.stars + " pencils " + r.pencils + " memories " + r.memories + " checkpoints " + r.checkpoints + " gates " + r.gates + "\n" + (r.errors.length ? r.errors.join("\n") : "no errors") } }
            }
        }
    }
    function isaState() { const c = game.isabelaRef(); return c.state + " (" + c.px.toFixed(1) + ", " + c.py.toFixed(1) + ") courage " + c.courage }
    function pedState() { const c = game.pedroRef(); return c.state + " (" + c.px.toFixed(1) + ", " + c.py.toFixed(1) + ") courage " + c.courage }

    component DevButton: Rectangle {
        property alias text: label.text
        signal clicked()
        width: label.implicitWidth + 14; height: 24; radius: 5; color: ma.containsMouse ? "#4a6fa5" : "#2c3e5a"
        Text { id: label; anchors.centerIn: parent; color: "#fff"; font.pixelSize: 11 }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
    }
}
