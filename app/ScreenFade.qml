// Quick fade to a warm colour and back, used for the Courage respawn transition.
import QtQuick

Rectangle {
    id: fade
    color: "#f7e7c4"
    opacity: 0
    signal respawnMidpoint()
    function respawn() { anim.restart() }
    SequentialAnimation {
        id: anim
        NumberAnimation { target: fade; property: "opacity"; to: 1; duration: 280; easing.type: Easing.InQuad }
        ScriptAction { script: fade.respawnMidpoint() }
        PauseAnimation { duration: 150 }
        NumberAnimation { target: fade; property: "opacity"; to: 0; duration: 420; easing.type: Easing.OutQuad }
    }
}
