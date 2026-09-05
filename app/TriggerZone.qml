// An invisible area that fires once (or every time) when a sibling enters: tutorial hints,
// narrative beats, character-exclusive zones. Data-only; the director does the overlap test.
import QtQuick
import "scripts/Physics.js" as Physics

QtObject {
    id: root
    property var spec: ({})
    property bool fired: false
    readonly property var box: ({ x: spec.x, y: spec.y, w: spec.w || 1, h: spec.h || 6 })
    signal triggered(string id, var spec)

    function test(body) {
        if (fired && spec.once !== false) return false
        if (Physics.overlap(Physics.box(body), box)) { fired = true; triggered(spec.id, spec); return true }
        return false
    }
    function reset() { fired = false }
}
