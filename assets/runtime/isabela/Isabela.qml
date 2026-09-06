import QtQuick
import QtQuick3D

import QtQuick.Timeline

Node {
    id: node
    // --- game runtime API (added by scripts/import-runtime.py) ---
    property string clip: "Idle"
    readonly property var clips: ["Cheer", "Climb", "Crawl", "Crouch", "Hang", "Hit", "Idle", "Jump", "Land", "Pickup", "Push", "Run", "Walk", "Wave"]
    signal clipFinished(string name)

    // Resources
    Texture {
        id: qtmesh_gen3d_1_1788650620559_diffuse_png_texture
        objectName: "qtmesh_gen3d_1_1788650620559_diffuse.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788650620559_diffuse.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788650620559_roughness_png_texture
        objectName: "qtmesh_gen3d_1_1788650620559_roughness.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788650620559_roughness.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788650620559_normal_png_texture
        objectName: "qtmesh_gen3d_1_1788650620559_normal.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788650620559_normal.png"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_1_1788650620559_mesh_mat_material
        objectName: "qtmesh_gen3d_1_1788650620559_mesh_mat"
        baseColorMap: qtmesh_gen3d_1_1788650620559_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_1_1788650620559_roughness_png_texture
        roughnessMap: qtmesh_gen3d_1_1788650620559_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_1_1788650620559_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin
        joints: [
            hips,
            spine,
            chest,
            leftShoulder,
            rightShoulder,
            leftArm,
            rightArm,
            leftUpLeg,
            rightUpLeg,
            neck,
            leftForeArm,
            rightForeArm,
            leftLeg,
            rightLeg,
            head,
            leftHand,
            rightHand,
            leftFoot,
            rightFoot
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, -0.0134207, 0, 1, 0, -0.0200836, 0, 0, 1, 0.000163692, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00784752, 0, 1, 0, -0.120289, 0, 0, 1, 0.000517115, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0185753, 0, 1, 0, -0.220494, 0, 0, 1, -0.0300869, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0376045, 0, 1, 0, -0.280617, 0, 0, 1, -0.0492233, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.000122163, 0, 1, 0, -0.280617, 0, 0, 1, -0.0492233, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.150888, 0, 1, 0, -0.280617, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.150925, 0, 1, 0, -0.280617, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0285751, 0, 1, 0, -4.26173e-05, 0, 0, 1, -0.000267189, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.00160621, 0, 1, 0, -4.26173e-05, 0, 0, 1, -0.000267189, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0164265, 0, 1, 0, -0.34074, 0, 0, 1, -0.0433676, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.241432, 0, 1, 0, -0.280617, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.241469, 0, 1, 0, -0.280617, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0603439, 0, 1, 0, 0.230429, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0603813, 0, 1, 0, 0.230429, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00875692, 0, 1, 0, -0.420904, 0, 0, 1, -0.0156311, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.32443, 0, 1, 0, -0.280617, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.324468, 0, 1, 0, -0.280617, 0, 0, 1, 0.00192911, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0603439, 0, 1, 0, 0.460901, 0, 0, 1, -0.0110271, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0603813, 0, 1, 0, 0.460901, 0, 0, 1, -0.0110271, 0, 0, 0, 1)
        ]
    }

    // Nodes:
    Node {
        id: h1
        objectName: "h1"
        Node {
            id: isabela
            objectName: "isabela"
            Node {
                id: hips
                objectName: "Hips"
                position: Qt.vector3d(0.0134207, 0.0200836, -0.000163692)
                Node {
                    id: spine
                    objectName: "Spine"
                    position: Qt.vector3d(-0.00557313, 0.100205, -0.000353423)
                    Node {
                        id: chest
                        objectName: "Chest"
                        position: Qt.vector3d(0.0107278, 0.100205, 0.030604)
                        Node {
                            id: neck
                            objectName: "Neck"
                            position: Qt.vector3d(-0.00214884, 0.120246, 0.0132807)
                            Node {
                                id: head
                                objectName: "Head"
                                position: Qt.vector3d(-0.00766955, 0.080164, -0.0277365)
                            }
                        }
                        Node {
                            id: leftShoulder
                            objectName: "LeftShoulder"
                            position: Qt.vector3d(0.0190292, 0.060123, 0.0191364)
                            Node {
                                id: leftArm
                                objectName: "LeftArm"
                                position: Qt.vector3d(0.113283, 0, -0.0511524)
                                Node {
                                    id: leftForeArm
                                    objectName: "LeftForeArm"
                                    position: Qt.vector3d(0.0905439, 0, 0)
                                    Node {
                                        id: leftHand
                                        objectName: "LeftHand"
                                        position: Qt.vector3d(0.0829986, 0, 0)
                                    }
                                }
                            }
                        }
                        Node {
                            id: rightShoulder
                            objectName: "RightShoulder"
                            position: Qt.vector3d(-0.0186975, 0.060123, 0.0191364)
                            Node {
                                id: rightArm
                                objectName: "RightArm"
                                position: Qt.vector3d(-0.150803, 0, -0.0511524)
                                Node {
                                    id: rightForeArm
                                    objectName: "RightForeArm"
                                    position: Qt.vector3d(-0.0905439, 0, 0)
                                    Node {
                                        id: rightHand
                                        objectName: "RightHand"
                                        position: Qt.vector3d(-0.0829986, 0, 0)
                                    }
                                }
                            }
                        }
                    }
                }
                Node {
                    id: leftUpLeg
                    objectName: "LeftUpLeg"
                    position: Qt.vector3d(0.0151544, -0.020041, 0.00043088)
                    Node {
                        id: leftLeg
                        objectName: "LeftLeg"
                        position: Qt.vector3d(0.0317688, -0.230472, -0.0021963)
                        Node {
                            id: leftFoot
                            objectName: "LeftFoot"
                            position: Qt.vector3d(0, -0.230472, 0.0129563)
                        }
                    }
                }
                Node {
                    id: rightUpLeg
                    objectName: "RightUpLeg"
                    position: Qt.vector3d(-0.0150269, -0.020041, 0.00043088)
                    Node {
                        id: rightLeg
                        objectName: "RightLeg"
                        position: Qt.vector3d(-0.0587751, -0.230472, -0.0021963)
                        Node {
                            id: rightFoot
                            objectName: "RightFoot"
                            position: Qt.vector3d(0, -0.230472, 0.0129563)
                        }
                    }
                }
            }
        }
        Model {
            id: h1_mesh
            objectName: "h1_mesh"
            source: "meshes/meshes_0__mesh.mesh"
            skin: skin
            materials: [
                qtmesh_gen3d_1_1788650620559_mesh_mat_material
            ]
        }
    }

    // Animations:
    Timeline {
        id: cheer_timeline
        objectName: "Cheer"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1967
        currentFrame: 0
        enabled: node.clip === "Cheer"
        animations: TimelineAnimation {
            duration: 1967
            from: 0
            to: 1967
            running: node.clip === "Cheer"
            loops: 1
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Cheer") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_0.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_0.qad"
        }
    }
    Timeline {
        id: climb_timeline
        objectName: "Climb"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1167
        currentFrame: 0
        enabled: node.clip === "Climb"
        animations: TimelineAnimation {
            duration: 1167
            from: 0
            to: 1167
            running: node.clip === "Climb"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_1.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_1.qad"
        }
    }
    Timeline {
        id: crawl_timeline
        objectName: "Crawl"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 967
        currentFrame: 0
        enabled: node.clip === "Crawl"
        animations: TimelineAnimation {
            duration: 967
            from: 0
            to: 967
            running: node.clip === "Crawl"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_2.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_2.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_2.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_2.qad"
        }
    }
    Timeline {
        id: crouch_timeline
        objectName: "Crouch"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 967
        currentFrame: 0
        enabled: node.clip === "Crouch"
        animations: TimelineAnimation {
            duration: 967
            from: 0
            to: 967
            running: node.clip === "Crouch"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_3.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_3.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_3.qad"
        }
    }
    Timeline {
        id: hang_timeline
        objectName: "Hang"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1967
        currentFrame: 0
        enabled: node.clip === "Hang"
        animations: TimelineAnimation {
            duration: 1967
            from: 0
            to: 1967
            running: node.clip === "Hang"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_4.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_4.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_4.qad"
        }
    }
    Timeline {
        id: hit_timeline
        objectName: "Hit"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 667
        currentFrame: 0
        enabled: node.clip === "Hit"
        animations: TimelineAnimation {
            duration: 667
            from: 0
            to: 667
            running: node.clip === "Hit"
            loops: 1
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Hit") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_5.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_5.qad"
        }
    }
    Timeline {
        id: idle_timeline
        objectName: "Idle"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 2967
        currentFrame: 0
        enabled: node.clip === "Idle"
        animations: TimelineAnimation {
            duration: 2967
            from: 0
            to: 2967
            running: node.clip === "Idle"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.822596, -0.568626, -2.06836e-07, 1.78452e-07)
            }
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.791185, 0.234899, 0.545555, 0.145665)
            }
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.62635, -0.646514, 0.314823, -0.300986)
            }
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.981504, -0.0388558, 0.153252, 0.107957)
            }
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.974398, -0.0432685, -0.202285, -0.0880734)
            }
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.993381, 0.0979366, 0.00758413, -0.0595358)
            }
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.986425, -0.144085, -0.00899808, 0.0782645)
            }
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.998545, 0.049225, 0.00266072, -0.0218452)
            }
        }
    }
    Timeline {
        id: jump_timeline
        objectName: "Jump"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 867
        currentFrame: 0
        enabled: node.clip === "Jump"
        animations: TimelineAnimation {
            duration: 867
            from: 0
            to: 867
            running: node.clip === "Jump"
            loops: 1
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Jump") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_7.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_7.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_7.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_7.qad"
        }
    }
    Timeline {
        id: land_timeline
        objectName: "Land"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 467
        currentFrame: 0
        enabled: node.clip === "Land"
        animations: TimelineAnimation {
            duration: 467
            from: 0
            to: 467
            running: node.clip === "Land"
            loops: 1
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Land") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_8.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_8.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_8.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_8.qad"
        }
    }
    Timeline {
        id: pickup_timeline
        objectName: "Pickup"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 967
        currentFrame: 0
        enabled: node.clip === "Pickup"
        animations: TimelineAnimation {
            duration: 967
            from: 0
            to: 967
            running: node.clip === "Pickup"
            loops: 1
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Pickup") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_9.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_9.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_9.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_9.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_9.qad"
        }
    }
    Timeline {
        id: push_timeline
        objectName: "Push"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1167
        currentFrame: 0
        enabled: node.clip === "Push"
        animations: TimelineAnimation {
            duration: 1167
            from: 0
            to: 1167
            running: node.clip === "Push"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_10.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_10.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_10.qad"
        }
    }
    Timeline {
        id: run_timeline
        objectName: "Run"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 767
        currentFrame: 0
        enabled: node.clip === "Run"
        animations: TimelineAnimation {
            duration: 767
            from: 0
            to: 767
            running: node.clip === "Run"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_11.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_11.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_11.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_11.qad"
        }
    }
    Timeline {
        id: walk_timeline
        objectName: "Walk"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 967
        currentFrame: 0
        enabled: node.clip === "Walk"
        animations: TimelineAnimation {
            duration: 967
            from: 0
            to: 967
            running: node.clip === "Walk"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_12.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_12.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_12.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_12.qad"
        }
    }
    Timeline {
        id: wave_timeline
        objectName: "Wave"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1567
        currentFrame: 0
        enabled: node.clip === "Wave"
        animations: TimelineAnimation {
            duration: 1567
            from: 0
            to: 1567
            running: node.clip === "Wave"
            loops: 1
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Wave") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_13.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_13.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_13.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_13.qad"
        }
    }
}
