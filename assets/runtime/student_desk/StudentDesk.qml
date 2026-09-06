import QtQuick
import QtQuick3D

Node {
    id: node
    // --- game runtime API (added by scripts/import-runtime.py) ---
    property string clip: "Idle"
    readonly property var clips: []
    signal clipFinished(string name)

    // Resources
    Texture {
        id: qtmesh_gen3d_1_1788648667867_diffuse_png_texture
        objectName: "qtmesh_gen3d_1_1788648667867_diffuse.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788648667867_diffuse.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788648667867_roughness_png_texture
        objectName: "qtmesh_gen3d_1_1788648667867_roughness.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788648667867_roughness.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788648667867_normal_png_texture
        objectName: "qtmesh_gen3d_1_1788648667867_normal.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788648667867_normal.png"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_1_1788648667867_mesh_mat_material
        objectName: "qtmesh_gen3d_1_1788648667867_mesh_mat"
        baseColorMap: qtmesh_gen3d_1_1788648667867_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_1_1788648667867_roughness_png_texture
        roughnessMap: qtmesh_gen3d_1_1788648667867_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_1_1788648667867_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }

    // Nodes:
    Model {
        id: qtmesh_gen3d_1_1788648667867
        objectName: "qtmesh_gen3d_1_1788648667867"
        source: "meshes/meshes_0__mesh.mesh"
        materials: [
            qtmesh_gen3d_1_1788648667867_mesh_mat_material
        ]
    }

    // Animations:
}
