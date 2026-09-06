// Touch controls for phones and tablets: a floating stick on the left half (appears where the
// finger lands, like Clayground's TouchscreenGamepad, but multi-touch so you can steer and jump at
// once) and action buttons on the right (jump, ability, interact) plus pause. Everything is routed
// through the InputManager's press()/release() and touch axes, so gameplay never knows the source.
// The layer shows itself on the first touch, so mouse/keyboard players never see it.
import QtQuick

Item {
    id: tc
    property var input: null
    property var game: null
    property bool shown: Qt.platform.os === "android" || Qt.platform.os === "ios"
    readonly property real ui: Math.max(0.8, Math.min(1.35, width / 1280))
    readonly property bool gameplay: game && game.phase === "playing"
    readonly property color ink: "#2b2622"
    readonly property color paper: "#fff8ea"

    // ---- stick state --------------------------------------------------------------------------------------
    property int stickId: -1
    property real stickX: 0; property real stickY: 0          // origin (where the finger landed)
    property real knobX: 0; property real knobY: 0
    readonly property real stickRadius: 46 * ui
    property var buttonOf: ({})                               // touch pointId -> button action

    function actionAt(x, y) {
        for (const b of [jumpBtn, abilityBtn, interactBtn, pauseBtn]) {
            const p = b.mapFromItem(tc, x, y)
            if (p.x >= -8 && p.y >= -8 && p.x <= b.width + 8 && p.y <= b.height + 8) return b.action
        }
        return ""
    }
    function setStick(px, py) {
        let dx = px - stickX, dy = py - stickY
        const len = Math.hypot(dx, dy)
        if (len > stickRadius) { dx *= stickRadius / len; dy *= stickRadius / len }
        knobX = dx; knobY = dy
        const nx = dx / stickRadius, ny = -dy / stickRadius
        if (input) {
            input.touchMoveX = Math.abs(nx) < 0.18 ? 0 : (Math.abs(nx) > 0.75 ? Math.sign(nx) : nx * 1.2)
            input.touchMoveY = Math.abs(ny) < 0.35 ? 0 : Math.sign(ny)
            input.touchDown = ny < -0.45
        }
    }
    function clearStick() { stickId = -1; knobX = 0; knobY = 0; if (input) { input.touchMoveX = 0; input.touchMoveY = 0; input.touchDown = false } }

    MultiPointTouchArea {
        anchors.fill: parent
        enabled: tc.gameplay
        mouseEnabled: false
        minimumTouchPoints: 1
        maximumTouchPoints: 4
        touchPoints: [ TouchPoint {}, TouchPoint {}, TouchPoint {}, TouchPoint {} ]
        onPressed: (points) => {
            if (!tc.shown) tc.shown = true
            for (const p of points) {
                const action = tc.actionAt(p.x, p.y)
                if (action) { const m = Object.assign({}, tc.buttonOf); m[p.pointId] = action; tc.buttonOf = m; if (tc.input) tc.input.press(action) }
                else if (tc.stickId < 0 && p.x < tc.width * 0.5 && p.y > 90 * tc.ui) { tc.stickId = p.pointId; tc.stickX = p.x; tc.stickY = p.y; tc.setStick(p.x, p.y) }
            }
        }
        onUpdated: (points) => { for (const p of points) if (p.pointId === tc.stickId) tc.setStick(p.x, p.y) }
        onReleased: (points) => { for (const p of points) tc.release(p.pointId) }
        onCanceled: (points) => { for (const p of points) tc.release(p.pointId) }
    }
    function release(pointId) {
        if (pointId === stickId) clearStick()
        if (buttonOf[pointId]) { if (input) input.release(buttonOf[pointId]); const m = Object.assign({}, buttonOf); delete m[pointId]; buttonOf = m }
    }
    function pressedAction(action) { for (const k in buttonOf) if (buttonOf[k] === action) return true; return false }
    onGameplayChanged: if (!gameplay) { clearStick(); for (const k in buttonOf) if (input) input.release(buttonOf[k]); buttonOf = ({}) }

    // ---- visuals -------------------------------------------------------------------------------------------
    // stick: a faint resting circle on the left, the live stick where the finger is
    Rectangle {
        visible: tc.shown && tc.gameplay && tc.stickId < 0
        x: 70 * tc.ui; y: tc.height - height - 60 * tc.ui
        width: tc.stickRadius * 2.2; height: width; radius: width / 2
        color: Qt.rgba(1, 0.97, 0.92, 0.18); border.color: Qt.rgba(1, 0.97, 0.92, 0.5); border.width: 2
        Text { anchors.centerIn: parent; text: "✥"; color: tc.paper; opacity: 0.7; font.pixelSize: 30 * tc.ui }
    }
    Rectangle {
        visible: tc.stickId >= 0
        x: tc.stickX - width / 2; y: tc.stickY - height / 2
        width: tc.stickRadius * 2.2; height: width; radius: width / 2
        color: Qt.rgba(1, 0.97, 0.92, 0.25); border.color: tc.paper; border.width: 2
        Rectangle { x: parent.width / 2 - width / 2 + tc.knobX; y: parent.height / 2 - height / 2 + tc.knobY
                    width: tc.stickRadius * 0.9; height: width; radius: width / 2; color: "#f2c530"; border.color: tc.ink; border.width: 2 }
    }

    component ActionButton: Rectangle {
        property string action: ""
        property string label: ""
        property string caption: ""
        property bool down: tc.pressedAction(action)
        visible: tc.shown && tc.gameplay
        width: 74 * tc.ui; height: width; radius: width / 2
        color: down ? "#f2c530" : Qt.rgba(1, 0.97, 0.92, 0.55); border.color: tc.ink; border.width: 2
        scale: down ? 0.92 : 1
        Text { anchors.centerIn: parent; text: parent.label; color: tc.ink; font.pixelSize: 26 * tc.ui; font.bold: true }
        Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.bottom; anchors.topMargin: 2; text: parent.caption; color: tc.paper; font.pixelSize: 12 * tc.ui; style: Text.Outline; styleColor: tc.ink }
    }
    ActionButton { id: jumpBtn; action: "jump"; label: "▲"; caption: game ? game.tr("touch.jump") : ""; width: 96 * tc.ui
                   anchors { right: parent.right; bottom: parent.bottom; rightMargin: 40 * tc.ui; bottomMargin: 60 * tc.ui } }
    ActionButton { id: abilityBtn; action: "ability"; label: "✦"; caption: game ? game.tr("touch.ability") : ""
                   anchors { right: jumpBtn.left; bottom: parent.bottom; rightMargin: 24 * tc.ui; bottomMargin: 66 * tc.ui } }
    ActionButton { id: interactBtn; action: "interact"; label: "E"; caption: game ? game.tr("touch.interact") : ""
                   anchors { right: parent.right; bottom: jumpBtn.top; rightMargin: 52 * tc.ui; bottomMargin: 26 * tc.ui } }
    ActionButton { id: pauseBtn; action: "pause"; label: "❚❚"; width: 44 * tc.ui
                   anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 18 * tc.ui } }
}
