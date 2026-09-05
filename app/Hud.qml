// In-game HUD: Courage of both siblings, the active one, stars and pencils, the contextual
// interaction prompt, tutorial hints, toasts and the section banner. Nothing else, by design.
import QtQuick
import QtQuick.Layouts

Item {
    id: hud
    property var game: null
    readonly property color ink: "#2b2622"
    readonly property color paper: "#fff8ea"
    readonly property real ui: Math.max(0.8, Math.min(1.35, width / 1280))

    // ---- top-left: the siblings' Courage -----------------------------------------------------------
    Row {
        anchors { left: parent.left; top: parent.top; margins: 16 * hud.ui }
        spacing: 12 * hud.ui
        Repeater {
            model: game ? game.characters : []
            delegate: Rectangle {
                required property var modelData
                readonly property bool isActive: game && game.active === modelData
                width: 190 * hud.ui; height: 62 * hud.ui; radius: 16 * hud.ui
                color: isActive ? hud.paper : Qt.rgba(1, 0.97, 0.92, 0.55)
                border.color: isActive ? modelData.def.color : "transparent"; border.width: 3
                scale: isActive ? 1 : 0.9
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 160 } }
                Row {
                    anchors.fill: parent; anchors.margins: 8 * hud.ui; spacing: 8 * hud.ui
                    Rectangle { width: 44 * hud.ui; height: width; radius: width / 2; color: modelData.def.color; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: modelData.displayName.charAt(0); color: "white"; font.pixelSize: 24 * hud.ui; font.bold: true } }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 3 * hud.ui
                        Text { text: modelData.displayName; color: hud.ink; font.pixelSize: 15 * hud.ui; font.bold: true }
                        Row {
                            spacing: 3 * hud.ui
                            Repeater {
                                model: modelData.def.courageMax
                                delegate: Text { required property int index; text: "★"; font.pixelSize: 19 * hud.ui
                                    color: index < modelData.courage ? "#ffb400" : "#c9c1b4"
                                    scale: index < modelData.courage ? 1 : 0.85
                                    Behavior on color { ColorAnimation { duration: 200 } } }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- top-right: collectibles --------------------------------------------------------------------
    Rectangle {
        anchors { right: parent.right; top: parent.top; margins: 16 * hud.ui }
        width: col.width + 28 * hud.ui; height: 62 * hud.ui; radius: 16 * hud.ui; color: Qt.rgba(1, 0.97, 0.92, 0.85)
        Row {
            id: col
            anchors.centerIn: parent; spacing: 18 * hud.ui
            Row { spacing: 6 * hud.ui; Text { text: "★"; color: "#ffb400"; font.pixelSize: 26 * hud.ui; anchors.verticalCenter: parent.verticalCenter }
                  Text { text: (game ? game.director_stars() : 0) + " / " + (game ? game.director_starsTotal() : 40); color: hud.ink; font.pixelSize: 20 * hud.ui; font.bold: true; anchors.verticalCenter: parent.verticalCenter } }
            Row { spacing: 6 * hud.ui; Text { text: "✎"; color: "#e33f3f"; font.pixelSize: 26 * hud.ui; anchors.verticalCenter: parent.verticalCenter }
                  Text { text: (game ? game.director_pencils() : 0) + " / " + (game ? game.director_pencilsTotal() : 6); color: hud.ink; font.pixelSize: 20 * hud.ui; font.bold: true; anchors.verticalCenter: parent.verticalCenter } }
            Text { visible: game && game.director_memory(); text: "♥"; color: "#e64b7a"; font.pixelSize: 26 * hud.ui; anchors.verticalCenter: parent.verticalCenter }
        }
    }

    // ---- gamepad indicator ----------------------------------------------------------------------------
    Text {
        anchors { right: parent.right; top: parent.top; topMargin: 84 * hud.ui; rightMargin: 20 * hud.ui }
        visible: game && game.inputGamepad()
        text: "🎮 " + (game ? game.inputGamepadName() : "")
        color: hud.ink; font.pixelSize: 13 * hud.ui; opacity: 0.7
    }

    // ---- section banner -------------------------------------------------------------------------------
    Text {
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 90 * hud.ui }
        text: game ? game.sectionBanner : ""
        visible: text.length > 0
        color: hud.paper; font.pixelSize: 34 * hud.ui; font.bold: true
        style: Text.Outline; styleColor: hud.ink
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // ---- interaction prompt (follows the active sibling) ----------------------------------------------
    Rectangle {
        visible: game && game.interactables.length > 0 && game.phase === "playing"
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 130 * hud.ui }
        width: prompt.width + 28 * hud.ui; height: 40 * hud.ui; radius: 20 * hud.ui; color: hud.paper; border.color: "#f2c530"; border.width: 2
        Row { id: prompt; anchors.centerIn: parent; spacing: 8 * hud.ui
            Rectangle { width: 28 * hud.ui; height: 28 * hud.ui; radius: 6; color: hud.ink; anchors.verticalCenter: parent.verticalCenter
                Text { anchors.centerIn: parent; text: game && game.inputGamepad() ? "X" : "E"; color: "white"; font.bold: true; font.pixelSize: 15 * hud.ui } }
            Text { text: game ? game.tr("hud.interact") : ""; color: hud.ink; font.pixelSize: 17 * hud.ui; font.bold: true; anchors.verticalCenter: parent.verticalCenter } }
        SequentialAnimation on scale { loops: Animation.Infinite; NumberAnimation { to: 1.05; duration: 500 } NumberAnimation { to: 1; duration: 500 } }
    }

    // ---- tutorial hint --------------------------------------------------------------------------------
    Rectangle {
        visible: game && game.hintText.length > 0
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 60 * hud.ui }
        width: Math.min(hud.width - 40, hintLabel.implicitWidth + 40 * hud.ui); height: hintLabel.implicitHeight + 24 * hud.ui
        radius: 14 * hud.ui; color: Qt.rgba(0.17, 0.15, 0.13, 0.86)
        Text { id: hintLabel; anchors.centerIn: parent; width: parent.width - 40 * hud.ui; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
               text: game ? game.hintText : ""; color: "#fff8ea"; font.pixelSize: 18 * hud.ui }
    }

    // ---- toast (events) ---------------------------------------------------------------------------------
    Rectangle {
        visible: game && game.toastText.length > 0
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 140 * hud.ui }
        width: Math.min(hud.width - 40, toastLabel.implicitWidth + 40 * hud.ui); height: toastLabel.implicitHeight + 20 * hud.ui
        radius: 12 * hud.ui; color: Qt.rgba(1, 0.97, 0.92, 0.92); border.color: "#f2c530"; border.width: 2
        Text { id: toastLabel; anchors.centerIn: parent; width: parent.width - 40 * hud.ui; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
               text: game ? game.toastText : ""; color: hud.ink; font.pixelSize: 18 * hud.ui; font.bold: true }
    }

    // screen shake for landings/hurt
    Connections { target: game; function onShake(strength) { shakeAnim.amp = strength * 10; shakeAnim.restart() } }
    SequentialAnimation { id: shakeAnim; property real amp: 4
        NumberAnimation { target: hud; property: "y"; to: shakeAnim.amp; duration: 40 }
        NumberAnimation { target: hud; property: "y"; to: -shakeAnim.amp; duration: 60 }
        NumberAnimation { target: hud; property: "y"; to: 0; duration: 60 } }
}
