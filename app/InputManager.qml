// Unified input: keyboard (own key handling - the platformer needs more than two buttons),
// physical gamepad (GamepadBridge: browser Gamepad API on WebAssembly) and the on-screen
// TouchControls on phones/tablets (stick + buttons, fed in through touchMoveX/press()). The game reads one snapshot per fixed step; menus listen to the
// edge signals. Bindings are data (`keys`) so the Settings screen can change them later.
import QtQuick

Item {
    id: input
    property bool gameplayEnabled: true

    // ---- bindings (saved by SaveSystem) --------------------------------------------------------
    property var keys: ({
        left: [Qt.Key_A, Qt.Key_Left], right: [Qt.Key_D, Qt.Key_Right],
        up: [Qt.Key_W, Qt.Key_Up], down: [Qt.Key_S, Qt.Key_Down],
        jump: [Qt.Key_Space], interact: [Qt.Key_E, Qt.Key_Return],
        switchChar: [Qt.Key_Q, Qt.Key_Tab], ability: [Qt.Key_Shift],
        pause: [Qt.Key_Escape, Qt.Key_P]
    })

    // ---- continuous state ------------------------------------------------------------------------
    property var held: ({})                       // action -> bool (keyboard)
    readonly property real keyX: (held.right ? 1 : 0) - (held.left ? 1 : 0)
    readonly property real keyY: (held.up ? 1 : 0) - (held.down ? 1 : 0)
    property real touchMoveX: 0                   // written by TouchControls (on-screen stick)
    property real touchMoveY: 0
    property bool touchDown: false
    readonly property real moveX: clamp(keyX + gamepad.axisX + touchMoveX)
    readonly property real moveY: clamp(keyY - gamepad.axisY + touchMoveY)
    readonly property bool jumpHeld: !!held.jump || gamepad.south
    readonly property bool downHeld: !!held.down || gamepad.axisY > 0.5 || touchDown
    readonly property bool abilityHeld: !!held.ability || gamepad.east || gamepad.rightTrigger
    readonly property bool gamepadConnected: gamepad.connected
    readonly property string gamepadName: gamepad.name

    // one-shot flags, consumed by snapshot()
    property bool jumpPressed: false
    property bool interactPressed: false
    property bool abilityPressed: false

    signal switchRequested()
    signal pauseRequested()
    signal interactRequested()
    signal menuUp(); signal menuDown(); signal menuLeft(); signal menuRight(); signal menuAccept(); signal menuBack()
    signal anyKey()

    function clamp(v) { return Math.max(-1, Math.min(1, v)) }

    // The fixed-step controller consumes one snapshot per step; pressed flags are edge events.
    function snapshot() {
        const s = { moveX: moveX, moveY: moveY, jumpPressed: jumpPressed, jumpHeld: jumpHeld,
                    interactPressed: interactPressed, abilityPressed: abilityPressed, downHeld: downHeld }
        jumpPressed = false; interactPressed = false; abilityPressed = false
        return s
    }

    function actionFor(key) { for (const a in keys) if (keys[a].indexOf(key) >= 0) return a; return "" }

    property bool logActions: false
    function press(action) {
        if (!action) return
        if (logActions) console.log("INPUT press", action)
        const h = Object.assign({}, held); h[action] = true; held = h
        anyKey()
        switch (action) {
        case "jump": jumpPressed = true; menuAccept(); break
        case "interact": interactPressed = true; interactRequested(); menuAccept(); break
        case "ability": abilityPressed = true; break
        case "switchChar": switchRequested(); break
        case "pause": pauseRequested(); menuBack(); break
        case "up": menuUp(); break
        case "down": menuDown(); break
        case "left": menuLeft(); break
        case "right": menuRight(); break
        }
    }
    function release(action) {
        if (!action) return
        const h = Object.assign({}, held); h[action] = false; held = h
    }

    Keys.onPressed: (event) => {
        if (event.isAutoRepeat) return
        const a = actionFor(event.key)
        if (!a && event.key === Qt.Key_Backtab) { press("switchChar"); event.accepted = true; return }
        if (a) { press(a); event.accepted = true }
    }
    Keys.onReleased: (event) => {
        if (event.isAutoRepeat) return
        const a = actionFor(event.key)
        if (!a && event.key === Qt.Key_Backtab) { release("switchChar"); return }
        if (a) { release(a); event.accepted = true }
    }
    onActiveFocusChanged: if (!activeFocus) held = ({})       // no stuck keys after a menu

    // ---- physical gamepad (W3C standard mapping) ----------------------------------------------------
    GamepadBridge {
        id: gamepad
        property bool pSouth: false; property bool pWest: false; property bool pNorth: false; property bool pEast: false
        property bool pStart: false; property bool pLB: false; property bool pRB: false; property bool pUp: false; property bool pDown: false
        property bool pLeft: false; property bool pRight: false; property bool pSelect: false
        property real pAxisY: 0
        onStateChanged: {
            if (south && !pSouth) { input.jumpPressed = true; input.menuAccept(); input.anyKey() }
            if (west && !pWest) { input.interactPressed = true; input.interactRequested(); input.menuAccept() }
            if (east && !pEast) input.abilityPressed = true
            if ((north && !pNorth) || (leftShoulder && !pLB) || (rightShoulder && !pRB)) input.switchRequested()
            if (start && !pStart) { input.pauseRequested(); input.menuBack() }
            if (select && !pSelect) input.menuBack()
            if (dpadUp && !pUp) input.menuUp(); if (dpadDown && !pDown) input.menuDown()
            if (dpadLeft && !pLeft) input.menuLeft(); if (dpadRight && !pRight) input.menuRight()
            if (axisY < -0.6 && pAxisY >= -0.6) input.menuUp(); if (axisY > 0.6 && pAxisY <= 0.6) input.menuDown()
            pSouth = south; pWest = west; pNorth = north; pEast = east; pStart = start; pLB = leftShoulder; pRB = rightShoulder
            pUp = dpadUp; pDown = dpadDown; pLeft = dpadLeft; pRight = dpadRight; pSelect = select; pAxisY = axisY
        }
    }

    focus: true
}
