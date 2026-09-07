// Title, pause, controls, volume, gallery and completion screens. Navigable with keyboard,
// gamepad (menu signals from InputManager) and mouse/touch. Strings come from config/strings.js.
import QtQuick
import QtQuick.Layouts
import "config/strings.js" as Strings

Item {
    id: menu
    property var game: null
    property var input: null
    property var save: null
    property var audio: null
    // a sub-screen (controls / volume / gallery / complete) wins over the phase screens; "" falls back to them
    property string screen: screenOverride !== "" ? screenOverride
                            : (game && game.phase === "title" ? "title" : (game && game.phase === "paused" ? "pause" : ""))
    property string screenOverride: ""
    property int cursor: 0
    property bool confirmNew: false
    readonly property bool active: screen !== ""
    readonly property color ink: "#2b2622"
    readonly property color paper: "#fff8ea"
    readonly property real ui: Math.max(0.8, Math.min(1.4, width / 1280))
    function tr(k) { return game ? game.tr(k) : Strings.tr(k) }

    visible: active
    onScreenChanged: cursor = 0

    // ---- menu model per screen --------------------------------------------------------------------------
    readonly property var entries: {
        if (confirmNew) return [{ label: tr("menu.yes"), action: "newConfirmed" }, { label: tr("menu.no"), action: "cancelNew" }]
        switch (screen) {
        case "title": {
            const e = [{ label: tr("menu.newGame"), action: "new" }]
            if (save && save.hasProgress) e.unshift({ label: tr("menu.continue"), action: "continue" })
            e.push({ label: tr("menu.controls"), action: "controls" }); e.push({ label: tr("menu.volume"), action: "volume" }); e.push({ label: tr("menu.gallery"), action: "gallery" })
            return e
        }
        case "pause": return [{ label: tr("menu.resume"), action: "resume" }, { label: tr("menu.restartCheckpoint"), action: "restart" }, { label: tr("menu.controls"), action: "controls" }, { label: tr("menu.volume"), action: "volume" }, { label: tr("menu.quitToTitle"), action: "quit" }]
        case "controls": case "gallery": return [{ label: tr("menu.back"), action: "back" }]
        case "volume": return [{ label: tr("menu.music"), action: "music", slider: true }, { label: tr("menu.effects"), action: "sfx", slider: true }, { label: tr("menu.language") + ": " + (game && game.language === "en" ? "English" : "Português (BR)"), action: "language" }, { label: tr("menu.back"), action: "back" }]
        case "complete": return [{ label: tr("menu.nextLevel"), action: "none", disabled: true }, { label: tr("menu.playAgain"), action: "new" }, { label: tr("menu.quitToTitle"), action: "quit" }]
        }
        return []
    }

    function activate(entry) {
        if (!entry || entry.disabled) return
        audio.play("ui_accept")
        switch (entry.action) {
        case "new": if (save.hasProgress && screen === "title") { confirmNew = true; cursor = 1 } else startNew(); break
        case "newConfirmed": confirmNew = false; startNew(); break
        case "cancelNew": confirmNew = false; break
        case "continue": game.continueGame(); break
        case "resume": game.resume(); break
        case "restart": game.restartCheckpoint(); break
        case "controls": screenOverride = "controls"; break
        case "volume": screenOverride = "volume"; break
        case "gallery": screenOverride = "gallery"; break
        case "language": save.writeSettings({ language: game.language === "en" ? "pt_BR" : "en" }); break
        case "back": screenOverride = game.phase === "complete" ? "complete" : ""; break
        case "quit": screenOverride = ""; game.resetWorldScale(); game.quitToTitle(); break
        }
    }
    function startNew() { screenOverride = ""; game.resetWorldScale(); game.startNewGame() }
    function showCompletion() { screenOverride = "complete" }
    function adjust(entry, delta) {
        if (!entry || !entry.slider) return
        if (entry.action === "music") { save.writeSettings({ musicVolume: Math.max(0, Math.min(1, save.settings.musicVolume + delta)) }); audio.musicVolume = save.settings.musicVolume }
        else { save.writeSettings({ sfxVolume: Math.max(0, Math.min(1, save.settings.sfxVolume + delta)) }); audio.sfxVolume = save.settings.sfxVolume; audio.play("ui_move") }
    }

    Connections {
        target: menu.input
        enabled: menu.active
        function onMenuUp() { if (menu.entries.length) { menu.cursor = (menu.cursor + menu.entries.length - 1) % menu.entries.length; menu.audio.play("ui_move") } }
        function onMenuDown() { if (menu.entries.length) { menu.cursor = (menu.cursor + 1) % menu.entries.length; menu.audio.play("ui_move") } }
        function onMenuLeft() { menu.adjust(menu.entries[menu.cursor], -0.1) }
        function onMenuRight() { menu.adjust(menu.entries[menu.cursor], 0.1) }
        function onMenuAccept() { if (menu.entries.length) menu.activate(menu.entries[menu.cursor]) }
        function onMenuBack() { if (menu.confirmNew) menu.confirmNew = false; else if (menu.screenOverride !== "" && menu.screenOverride !== "complete") menu.screenOverride = "" }
    }

    // ---- backdrop ---------------------------------------------------------------------------------------------
    Rectangle { anchors.fill: parent; color: screen === "title" ? "#4aa3d9" : Qt.rgba(0.1, 0.09, 0.08, 0.6)
        gradient: screen === "title" ? titleGrad : null
        Gradient { id: titleGrad; GradientStop { position: 0; color: "#5fb8ea" } GradientStop { position: 1; color: "#f3e7c9" } } }
    // playful title shapes
    Repeater { model: screen === "title" ? 9 : 0
        Rectangle { required property int index; width: 40 * menu.ui + index * 6; height: width; radius: width / 2; opacity: 0.16
            color: ["#e33f3f", "#f2c530", "#2a5bd7", "#3a9a4a"][index % 4]
            x: (index * 137) % menu.width; y: 60 + (index * 91) % (menu.height - 120)
            SequentialAnimation on y { loops: Animation.Infinite; NumberAnimation { to: 40 + (index * 91) % (menu.height - 120); duration: 2600 + index * 300; easing.type: Easing.InOutSine } NumberAnimation { to: 60 + (index * 91) % (menu.height - 120); duration: 2600 + index * 300; easing.type: Easing.InOutSine } } }
    }
    MouseArea { anchors.fill: parent; onPressed: (m) => { m.accepted = true } }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 40, 640 * menu.ui)
        spacing: 14 * menu.ui

        // title / heading
        Text { visible: menu.screen === "title"; Layout.alignment: Qt.AlignHCenter; text: tr("game.title"); color: menu.paper; font.pixelSize: 58 * menu.ui; font.bold: true; style: Text.Outline; styleColor: menu.ink }
        Text { visible: menu.screen === "title"; Layout.alignment: Qt.AlignHCenter; text: tr("game.subtitle"); color: "#f2c530"; font.pixelSize: 30 * menu.ui; font.bold: true; style: Text.Outline; styleColor: menu.ink }
        Text { visible: menu.screen === "title"; Layout.alignment: Qt.AlignHCenter; text: tr("level.caminho.name") + "  ·  " + tr("game.school"); color: menu.ink; font.pixelSize: 16 * menu.ui; opacity: 0.8 }
        Text { visible: menu.screen === "pause"; Layout.alignment: Qt.AlignHCenter; text: tr("menu.paused"); color: menu.paper; font.pixelSize: 44 * menu.ui; font.bold: true }
        Text { visible: menu.screen === "controls"; Layout.alignment: Qt.AlignHCenter; text: tr("controls.title"); color: menu.paper; font.pixelSize: 40 * menu.ui; font.bold: true }
        Text { visible: menu.screen === "volume"; Layout.alignment: Qt.AlignHCenter; text: tr("menu.volume"); color: menu.paper; font.pixelSize: 40 * menu.ui; font.bold: true }
        Text { visible: menu.screen === "gallery"; Layout.alignment: Qt.AlignHCenter; text: tr("gallery.title"); color: menu.paper; font.pixelSize: 40 * menu.ui; font.bold: true }
        Text { visible: menu.screen === "complete"; Layout.alignment: Qt.AlignHCenter; text: tr("end.title"); color: "#f2c530"; font.pixelSize: 46 * menu.ui; font.bold: true; style: Text.Outline; styleColor: menu.ink }
        Text { visible: menu.confirmNew; Layout.alignment: Qt.AlignHCenter; Layout.fillWidth: true; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; text: tr("menu.confirmNew"); color: menu.paper; font.pixelSize: 20 * menu.ui }

        // controls table
        Rectangle {
            visible: menu.screen === "controls"; Layout.fillWidth: true; implicitHeight: ctrlCol.implicitHeight + 28 * menu.ui; radius: 16 * menu.ui; color: menu.paper
            GridLayout {
                id: ctrlCol; anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 * menu.ui } columns: 3; columnSpacing: 16 * menu.ui; rowSpacing: 6 * menu.ui
                Text { text: ""; } Text { text: tr("controls.keyboard"); font.bold: true; color: menu.ink; font.pixelSize: 16 * menu.ui } Text { text: tr("controls.gamepad"); font.bold: true; color: menu.ink; font.pixelSize: 16 * menu.ui }
                Repeater {
                    model: [[tr("controls.move"), "A / D  ·  ← →", "◀ ▶  /  L-stick"], [tr("controls.jump"), "Espaço", "A / ✕"], [tr("controls.interact"), "E", "X / □"],
                            [tr("controls.switch"), "Q  ·  Tab", "Y / △  ·  LB / RB"], [tr("controls.ability"), "Shift", "B / ○"], [tr("controls.crouch"), "S / ↓", "▼ / L-stick ↓"], [tr("controls.pause"), "Esc / P", "Start"]]
                    delegate: Repeater { required property var modelData; model: modelData; delegate: Text { required property var modelData; required property int index; text: modelData; color: menu.ink; font.pixelSize: 16 * menu.ui; font.bold: index === 0; Layout.fillWidth: index === 0 } }
                }
                Text { Layout.columnSpan: 3; Layout.fillWidth: true; wrapMode: Text.WordWrap; text: tr("controls.gamepadNote"); color: menu.ink; opacity: 0.7; font.pixelSize: 13 * menu.ui }
            }
        }
        // gallery
        Rectangle {
            visible: menu.screen === "gallery"; Layout.fillWidth: true; implicitHeight: 220 * menu.ui; radius: 16 * menu.ui; color: menu.paper
            readonly property bool unlocked: save && save.profile && save.profile.memoryFound === true
            Column { anchors.centerIn: parent; spacing: 10 * menu.ui; width: parent.width - 40 * menu.ui
                Rectangle { visible: parent.parent.unlocked; width: 240 * menu.ui; height: 150 * menu.ui; anchors.horizontalCenter: parent.horizontalCenter; color: "#fbe9c7"; border.color: "#e64b7a"; border.width: 4; radius: 8
                    // a fictional drawing: bench, three round heads, a paper plane
                    Rectangle { x: 30 * menu.ui; y: 95 * menu.ui; width: 180 * menu.ui; height: 14 * menu.ui; color: "#8a4b2a" }
                    Repeater { model: 4; Rectangle { required property int index; x: (45 + index * 42) * menu.ui; y: 55 * menu.ui; width: 30 * menu.ui; height: width; radius: width / 2; color: ["#e64b7a", "#2f6fd6", "#3a9a4a", "#f2c530"][index] } }
                    Rectangle { x: 180 * menu.ui; y: 25 * menu.ui; width: 34 * menu.ui; height: 10 * menu.ui; color: "white"; rotation: -20 }
                    Rectangle { x: 20 * menu.ui; y: 20 * menu.ui; width: 26 * menu.ui; height: 26 * menu.ui; radius: 13; color: "#ffd23f" } }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.unlocked ? tr("gallery.memory1.title") : "🔒"; color: menu.ink; font.pixelSize: 20 * menu.ui; font.bold: true }
                Text { width: parent.width; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; text: parent.parent.unlocked ? tr("gallery.memory1.text") : tr("gallery.locked"); color: menu.ink; font.pixelSize: 15 * menu.ui } }
        }
        // completion summary
        Rectangle {
            visible: menu.screen === "complete"; Layout.fillWidth: true; implicitHeight: sumCol.implicitHeight + 28 * menu.ui; radius: 16 * menu.ui; color: menu.paper
            Column { id: sumCol; anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 * menu.ui } spacing: 8 * menu.ui
                Text { text: "★  " + tr("end.stars") + ": " + (game ? game.director_stars() + " / " + game.director_starsTotal() : ""); color: menu.ink; font.pixelSize: 22 * menu.ui; font.bold: true }
                Text { text: "✎  " + tr("end.pencils") + ": " + (game ? game.director_pencils() + " / " + game.director_pencilsTotal() : ""); color: menu.ink; font.pixelSize: 22 * menu.ui; font.bold: true }
                Text { text: "♥  " + tr("end.memory") + ": " + (game && game.director_memory() ? tr("end.found") : tr("end.notFound")); color: menu.ink; font.pixelSize: 22 * menu.ui; font.bold: true }
                Text { text: "⏱  " + tr("end.time") + ": " + (game ? menu.fmt(game.elapsed) : "") + (save && save.profile && save.profile.bestTime !== undefined ? "   ·   " + tr("end.best") + ": " + menu.fmt(save.profile.bestTime) : ""); color: menu.ink; font.pixelSize: 18 * menu.ui } }
        }

        // entries
        Repeater {
            model: menu.entries
            delegate: Rectangle {
                required property var modelData
                required property int index
                readonly property bool selected: index === menu.cursor
                Layout.fillWidth: true; Layout.alignment: Qt.AlignHCenter
                implicitHeight: 52 * menu.ui; radius: 14 * menu.ui
                color: modelData.disabled ? Qt.rgba(1, 0.97, 0.92, 0.35) : (selected ? "#f2c530" : menu.paper)
                border.color: selected ? menu.ink : "transparent"; border.width: 3
                scale: selected ? 1.03 : 1
                Behavior on scale { NumberAnimation { duration: 120 } }
                Text { anchors.centerIn: parent; text: modelData.label + (modelData.slider ? "   " + menu.bar(modelData.action) : ""); color: menu.ink; opacity: modelData.disabled ? 0.55 : 1; font.pixelSize: 21 * menu.ui; font.bold: true }
                MouseArea { anchors.fill: parent; hoverEnabled: true
                    onEntered: menu.cursor = index
                    onClicked: (m) => { if (modelData.slider) menu.adjust(modelData, m.x < width / 2 ? -0.1 : 0.1); else menu.activate(modelData) } }
            }
        }
        Text { visible: menu.screen === "title"; Layout.alignment: Qt.AlignHCenter; text: tr("menu.pressStart"); color: menu.ink; opacity: 0.6; font.pixelSize: 14 * menu.ui }
        Text { visible: menu.screen === "title" && save; Layout.alignment: Qt.AlignHCenter; text: "v" + (game ? game.version() : "") + "  ·  save: " + (save ? save.backend : ""); color: menu.ink; opacity: 0.45; font.pixelSize: 11 * menu.ui }
    }
    Rectangle { visible: game && game.phase === "loading"; anchors.fill: parent; color: "#f3e7c9"
        Text { anchors.centerIn: parent; text: tr("menu.loading"); color: menu.ink; font.pixelSize: 28 * menu.ui; font.bold: true } }

    function bar(action) { const v = action === "music" ? save.settings.musicVolume : save.settings.sfxVolume; const n = Math.round(v * 10); return "◀ " + "●".repeat(n) + "○".repeat(10 - n) + " ▶" }
    function fmt(s) { s = Math.floor(s || 0); return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2) }
}
