// Warm every unique balsam model package once, sequentially, while the title screen is up.
// Level entities still create their own Loader3Ds, but meshes/QML hit a warm cache instead of
// hitching the first time you walk into a section. Kept instances stay alive so GPU uploads stick.
import QtQuick
import QtQuick3D
import "config/assets.js" as Assets

Node {
    id: root
    property string assetBase: ""
    property bool enabled: true
    property bool ready: false
    property real progress: 0
    property int total: 0
    property int loaded: 0

    property var _queue: []
    property var _keepers: []

    Component {
        id: keepComp
        Loader3D {
            visible: false
            asynchronous: true
        }
    }

    Timer {
        id: pumpTimer
        interval: 16
        onTriggered: root.pump()
    }

    Component.onCompleted: begin()

    function resolve(path) {
        return root.assetBase ? root.assetBase + path : Qt.resolvedUrl(path)
    }

    function begin() {
        if (!enabled) {
            ready = true
            progress = 1
            return
        }
        _queue = Assets.modelPaths()
        _keepers = []
        loaded = 0
        total = _queue.length
        ready = total === 0
        progress = 0
        console.log("ModelPreloader: warming", total, "packages")
        Qt.callLater(pump)
    }

    function pump() {
        if (ready) return
        if (loaded >= total) {
            ready = true
            progress = 1
            console.log("ModelPreloader: ready (", total, "kept)")
            return
        }
        const path = _queue[loaded]
        const L = keepComp.createObject(root, { source: resolve(path) })
        if (!L) {
            console.warn("ModelPreloader: createObject failed for", path)
            loaded++
            progress = total ? loaded / total : 1
            pumpTimer.start()
            return
        }
        _keepers.push(L)
        function advance() {
            if (L.status === Loader3D.Loading)
                return
            L.statusChanged.disconnect(advance)
            if (L.status === Loader3D.Error)
                console.warn("ModelPreloader: failed", path)
            loaded++
            progress = total ? loaded / total : 1
            pumpTimer.start()
        }
        L.statusChanged.connect(advance)
        if (L.status !== Loader3D.Loading)
            advance()
    }
}
