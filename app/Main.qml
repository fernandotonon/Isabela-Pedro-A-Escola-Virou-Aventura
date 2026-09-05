// Isabela & Pedro: A Escola Virou Aventura - desktop / own-WASM-build entry point.
// Built with Clayground; assets made with QtMeshEditor.
import QtQuick
import QtQuick.Window

Window {
    id: win
    width: 1280
    height: 720
    visible: true
    color: "#87c5ea"
    title: "Isabela & Pedro: A Escola Virou Aventura"

    // Clayground convention: every clay_app is a headless ctest smoke test (QT_QPA_PLATFORM=minimal);
    // loading without warnings is the pass criterion, so quit right after the scene is up.
    Component.onCompleted: if (Qt.platform.pluginName === "minimal") Qt.quit()

    EscolaGame {
        anchors.fill: parent
        focus: true
    }
}
