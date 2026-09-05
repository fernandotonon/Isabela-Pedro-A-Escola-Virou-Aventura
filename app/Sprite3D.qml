// A sprite-sheet billboard in the 3D scene: one quad, one texture, the frame selected through
// the texture's UV offset/scale. Sheets come from QtMeshEditor (`qtmesh isometric` writes a grid
// of rows = directions, columns = animation frames; `qtmesh turntable` one row). Origin: bottom
// centre, so it drops in where a model or a Box3D placeholder would stand.
import QtQuick
import QtQuick3D

Node {
    id: root
    property url sheet
    property int columns: 1
    property int rows: 1
    property int row: 0                    // which row (direction) to show
    property int frame: 0                  // column
    property int frameFrom: 0
    property int frameTo: 0
    property real fps: 0                   // > 0 animates frameFrom..frameTo
    property bool loop: true
    property real worldHeight: 1.5         // metres
    property real aspect: 1.0              // frame width / frame height
    property bool flipX: false
    property real tiltTowardCamera: 0      // degrees around Y to fake a 3/4 view

    signal finished()

    readonly property real worldWidth: worldHeight * aspect

    Timer {
        running: root.fps > 0 && root.frameTo > root.frameFrom
        interval: 1000 / Math.max(1, root.fps)
        repeat: true
        onTriggered: {
            if (root.frame < root.frameFrom || root.frame >= root.frameTo) {
                if (root.frame >= root.frameTo && !root.loop) { root.finished(); stop(); return }
                root.frame = root.frameFrom
            } else root.frame++
        }
    }
    function play(from, to, framesPerSecond, looping) {
        frameFrom = from; frameTo = to; fps = framesPerSecond; loop = looping === undefined ? true : looping; frame = from
    }

    Model {
        source: "#Rectangle"
        y: root.worldHeight / 2
        eulerRotation.y: root.tiltTowardCamera
        scale: Qt.vector3d(root.worldWidth / 100 * (root.flipX ? -1 : 1), root.worldHeight / 100, 1)
        castsShadows: false
        receivesShadows: false
        pickable: false
        materials: PrincipledMaterial {
            lighting: PrincipledMaterial.NoLighting
            alphaMode: PrincipledMaterial.Mask
            alphaCutoff: 0.35
            cullMode: Material.NoCulling
            baseColorMap: Texture {
                source: root.sheet
                tilingModeHorizontal: Texture.ClampToEdge
                tilingModeVertical: Texture.ClampToEdge
                scaleU: 1 / Math.max(1, root.columns)
                scaleV: 1 / Math.max(1, root.rows)
                positionU: (root.frame % Math.max(1, root.columns)) / Math.max(1, root.columns)
                positionV: 1 - (root.row + 1) / Math.max(1, root.rows)
                magFilter: Texture.Linear
                minFilter: Texture.Linear
                generateMipmaps: false
            }
        }
    }
}
