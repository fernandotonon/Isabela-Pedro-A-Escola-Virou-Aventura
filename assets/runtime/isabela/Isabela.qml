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
        id: qtmesh_gen3d_6_1788751927380_diffuse_png_texture
        objectName: "qtmesh_gen3d_6_1788751927380_diffuse.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_6_1788751927380_diffuse.png"
    }
    Texture {
        id: qtmesh_gen3d_6_1788751927380_roughness_png_texture
        objectName: "qtmesh_gen3d_6_1788751927380_roughness.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_6_1788751927380_roughness.png"
    }
    Texture {
        id: qtmesh_gen3d_6_1788751927380_normal_png_texture
        objectName: "qtmesh_gen3d_6_1788751927380_normal.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_6_1788751927380_normal.png"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_6_1788751927380_mesh_mat_material
        objectName: "qtmesh_gen3d_6_1788751927380_mesh_mat"
        baseColorMap: qtmesh_gen3d_6_1788751927380_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_6_1788751927380_roughness_png_texture
        roughnessMap: qtmesh_gen3d_6_1788751927380_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_6_1788751927380_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin
        joints: [
            hips,
            spine,
            spine1,
            spine2,
            neck,
            head,
            leftArm,
            leftForeArm,
            leftHand,
            joint_9,
            joint_10,
            joint_11,
            joint_12,
            joint_13,
            joint_14,
            joint_15,
            joint_16,
            joint_17,
            joint_18,
            joint_19,
            joint_20,
            joint_21,
            joint_22,
            joint_23,
            joint_24,
            rightArm,
            rightForeArm,
            rightHand,
            joint_28,
            joint_29,
            joint_30,
            joint_31,
            joint_32,
            joint_33,
            joint_34,
            joint_35,
            joint_36,
            joint_37,
            joint_38,
            joint_39,
            joint_40,
            joint_41,
            joint_42,
            joint_43,
            leftUpLeg,
            leftLeg,
            leftFoot,
            joint_47,
            rightUpLeg,
            rightLeg,
            rightFoot,
            joint_51
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, -0.0016388, 0, 1, 0, 0.0402686, 0, 0, 1, 0.00619021, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0016388, 0, 1, 0, -0.0145146, 0, 0, 1, 0.00619021, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0016388, 0, 1, 0, -0.081037, 0, 0, 1, 0.00619021, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0016388, 0, 1, 0, -0.159299, 0, 0, 1, 0.00619021, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0016388, 0, 1, 0, -0.245386, 0, 0, 1, 0.00227712, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0016388, 0, 1, 0, -0.296256, 0, 0, 1, -0.0133752, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0296659, 0, 1, 0, -0.241473, 0, 0, 1, 0.00227712, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0883621, 0, 1, 0, -0.225821, 0, 0, 1, 0.00227712, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.190102, 0, 1, 0, -0.221908, 0, 0, 1, 0.0179295, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.307495, 0, 1, 0, -0.221908, 0, 0, 1, 0.0414079, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.319234, 0, 1, 0, -0.23756, 0, 0, 1, 0.0492341, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.32706, 0, 1, 0, -0.2493, 0, 0, 1, 0.0570603, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.330973, 0, 1, 0, -0.264952, 0, 0, 1, 0.0648864, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.350539, 0, 1, 0, -0.23756, 0, 0, 1, 0.0570603, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.362278, 0, 1, 0, -0.23756, 0, 0, 1, 0.0687995, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.374017, 0, 1, 0, -0.23756, 0, 0, 1, 0.0805388, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.350539, 0, 1, 0, -0.225821, 0, 0, 1, 0.0570603, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.366191, 0, 1, 0, -0.221908, 0, 0, 1, 0.0648864, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.37793, 0, 1, 0, -0.217995, 0, 0, 1, 0.0766257, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.350539, 0, 1, 0, -0.210169, 0, 0, 1, 0.0570603, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.362278, 0, 1, 0, -0.206256, 0, 0, 1, 0.0648864, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.374017, 0, 1, 0, -0.202343, 0, 0, 1, 0.0766257, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.342712, 0, 1, 0, -0.198429, 0, 0, 1, 0.0570603, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.354452, 0, 1, 0, -0.194516, 0, 0, 1, 0.0648864, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.362278, 0, 1, 0, -0.190603, 0, 0, 1, 0.0766257, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0329435, 0, 1, 0, -0.241473, 0, 0, 1, 0.00227712, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0916397, 0, 1, 0, -0.225821, 0, 0, 1, 0.00227712, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.19338, 0, 1, 0, -0.221908, 0, 0, 1, 0.0179295, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.310772, 0, 1, 0, -0.221908, 0, 0, 1, 0.0414079, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.322512, 0, 1, 0, -0.23756, 0, 0, 1, 0.0492341, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.330338, 0, 1, 0, -0.2493, 0, 0, 1, 0.0570603, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.334251, 0, 1, 0, -0.264952, 0, 0, 1, 0.0648864, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.353816, 0, 1, 0, -0.23756, 0, 0, 1, 0.0609734, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.365555, 0, 1, 0, -0.23756, 0, 0, 1, 0.0727126, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.377295, 0, 1, 0, -0.23756, 0, 0, 1, 0.0844519, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.353816, 0, 1, 0, -0.221908, 0, 0, 1, 0.0609734, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.369469, 0, 1, 0, -0.221908, 0, 0, 1, 0.0687995, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.381208, 0, 1, 0, -0.217995, 0, 0, 1, 0.0805388, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.353816, 0, 1, 0, -0.210169, 0, 0, 1, 0.0609734, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.365555, 0, 1, 0, -0.206256, 0, 0, 1, 0.0687995, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.377295, 0, 1, 0, -0.202343, 0, 0, 1, 0.0805388, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.34599, 0, 1, 0, -0.198429, 0, 0, 1, 0.0609734, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.357729, 0, 1, 0, -0.194516, 0, 0, 1, 0.0687995, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.365555, 0, 1, 0, -0.190603, 0, 0, 1, 0.0805388, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0531443, 0, 1, 0, 0.0715732, 0, 0, 1, 0.00619021, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0687967, 0, 1, 0, 0.237278, 0, 0, 1, -0.0251145, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0766228, 0, 1, 0, 0.439403, 0, 0, 1, -0.0133752, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0766228, 0, 1, 0, 0.498099, 0, 0, 1, 0.0766257, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.056422, 0, 1, 0, 0.0715732, 0, 0, 1, -0.00554904, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0720743, 0, 1, 0, 0.237684, 0, 0, 1, -0.0368537, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0799004, 0, 1, 0, 0.439403, 0, 0, 1, -0.0290275, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0799004, 0, 1, 0, 0.498099, 0, 0, 1, 0.0687995, 0, 0, 0, 1)
        ]
    }

    // Nodes:
    Node {
        id: bela
        objectName: "bela"
        Node {
            id: hips
            objectName: "Hips"
            position: Qt.vector3d(0.0016388, -0.0402686, -0.00619021)
            Node {
                id: spine
                objectName: "Spine"
                position: Qt.vector3d(0, 0.0547832, 0)
                Node {
                    id: spine1
                    objectName: "Spine1"
                    position: Qt.vector3d(0, 0.0665224, 0)
                    Node {
                        id: spine2
                        objectName: "Spine2"
                        position: Qt.vector3d(0, 0.0782616, 0)
                        Node {
                            id: neck
                            objectName: "Neck"
                            position: Qt.vector3d(0, 0.0860878, 0.00391308)
                            Node {
                                id: head
                                objectName: "Head"
                                position: Qt.vector3d(0, 0.0508701, 0.0156523)
                            }
                        }
                        Node {
                            id: leftArm
                            objectName: "LeftArm"
                            position: Qt.vector3d(-0.0313047, 0.0821747, 0.00391308)
                            Node {
                                id: leftForeArm
                                objectName: "LeftForeArm"
                                position: Qt.vector3d(-0.0586962, -0.0156523, 0)
                                Node {
                                    id: leftHand
                                    objectName: "LeftHand"
                                    position: Qt.vector3d(-0.10174, -0.00391309, -0.0156523)
                                    Node {
                                        id: joint_9
                                        objectName: "joint_9"
                                        position: Qt.vector3d(-0.117392, 0, -0.0234785)
                                        Node {
                                            id: joint_10
                                            objectName: "joint_10"
                                            position: Qt.vector3d(-0.0117392, 0.0156523, -0.00782616)
                                            Node {
                                                id: joint_11
                                                objectName: "joint_11"
                                                position: Qt.vector3d(-0.00782618, 0.0117393, -0.00782616)
                                                Node {
                                                    id: joint_12
                                                    objectName: "joint_12"
                                                    position: Qt.vector3d(-0.00391307, 0.0156523, -0.00782616)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_13
                                            objectName: "joint_13"
                                            position: Qt.vector3d(-0.0430439, 0.0156523, -0.0156523)
                                            Node {
                                                id: joint_14
                                                objectName: "joint_14"
                                                position: Qt.vector3d(-0.0117393, 0, -0.0117393)
                                                Node {
                                                    id: joint_15
                                                    objectName: "joint_15"
                                                    position: Qt.vector3d(-0.0117393, 0, -0.0117392)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_16
                                            objectName: "joint_16"
                                            position: Qt.vector3d(-0.0430439, 0.00391309, -0.0156523)
                                            Node {
                                                id: joint_17
                                                objectName: "joint_17"
                                                position: Qt.vector3d(-0.0156523, -0.00391309, -0.00782616)
                                                Node {
                                                    id: joint_18
                                                    objectName: "joint_18"
                                                    position: Qt.vector3d(-0.0117393, -0.00391307, -0.0117393)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_19
                                            objectName: "joint_19"
                                            position: Qt.vector3d(-0.0430439, -0.0117392, -0.0156523)
                                            Node {
                                                id: joint_20
                                                objectName: "joint_20"
                                                position: Qt.vector3d(-0.0117393, -0.00391309, -0.00782616)
                                                Node {
                                                    id: joint_21
                                                    objectName: "joint_21"
                                                    position: Qt.vector3d(-0.0117393, -0.00391307, -0.0117393)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_22
                                            objectName: "joint_22"
                                            position: Qt.vector3d(-0.0352177, -0.0234785, -0.0156523)
                                            Node {
                                                id: joint_23
                                                objectName: "joint_23"
                                                position: Qt.vector3d(-0.0117393, -0.00391307, -0.00782616)
                                                Node {
                                                    id: joint_24
                                                    objectName: "joint_24"
                                                    position: Qt.vector3d(-0.00782615, -0.00391309, -0.0117393)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Node {
                            id: rightArm
                            objectName: "RightArm"
                            position: Qt.vector3d(0.0313047, 0.0821747, 0.00391308)
                            Node {
                                id: rightForeArm
                                objectName: "RightForeArm"
                                position: Qt.vector3d(0.0586962, -0.0156523, 0)
                                Node {
                                    id: rightHand
                                    objectName: "RightHand"
                                    position: Qt.vector3d(0.10174, -0.00391309, -0.0156523)
                                    Node {
                                        id: joint_28
                                        objectName: "joint_28"
                                        position: Qt.vector3d(0.117392, 0, -0.0234785)
                                        Node {
                                            id: joint_29
                                            objectName: "joint_29"
                                            position: Qt.vector3d(0.0117393, 0.0156523, -0.00782616)
                                            Node {
                                                id: joint_30
                                                objectName: "joint_30"
                                                position: Qt.vector3d(0.00782615, 0.0117393, -0.00782616)
                                                Node {
                                                    id: joint_31
                                                    objectName: "joint_31"
                                                    position: Qt.vector3d(0.00391307, 0.0156523, -0.00782616)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_32
                                            objectName: "joint_32"
                                            position: Qt.vector3d(0.0430439, 0.0156523, -0.0195654)
                                            Node {
                                                id: joint_33
                                                objectName: "joint_33"
                                                position: Qt.vector3d(0.0117392, 0, -0.0117392)
                                                Node {
                                                    id: joint_34
                                                    objectName: "joint_34"
                                                    position: Qt.vector3d(0.0117393, 0, -0.0117393)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_35
                                            objectName: "joint_35"
                                            position: Qt.vector3d(0.0430439, 0, -0.0195654)
                                            Node {
                                                id: joint_36
                                                objectName: "joint_36"
                                                position: Qt.vector3d(0.0156523, 0, -0.00782617)
                                                Node {
                                                    id: joint_37
                                                    objectName: "joint_37"
                                                    position: Qt.vector3d(0.0117392, -0.00391307, -0.0117392)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_38
                                            objectName: "joint_38"
                                            position: Qt.vector3d(0.0430439, -0.0117392, -0.0195654)
                                            Node {
                                                id: joint_39
                                                objectName: "joint_39"
                                                position: Qt.vector3d(0.0117392, -0.00391309, -0.00782617)
                                                Node {
                                                    id: joint_40
                                                    objectName: "joint_40"
                                                    position: Qt.vector3d(0.0117393, -0.00391307, -0.0117392)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_41
                                            objectName: "joint_41"
                                            position: Qt.vector3d(0.0352177, -0.0234785, -0.0195654)
                                            Node {
                                                id: joint_42
                                                objectName: "joint_42"
                                                position: Qt.vector3d(0.0117393, -0.00391307, -0.00782617)
                                                Node {
                                                    id: joint_43
                                                    objectName: "joint_43"
                                                    position: Qt.vector3d(0.00782615, -0.00391309, -0.0117392)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Node {
                id: leftUpLeg
                objectName: "LeftUpLeg"
                position: Qt.vector3d(-0.0547832, -0.0313047, 0)
                Node {
                    id: leftLeg
                    objectName: "LeftLeg"
                    position: Qt.vector3d(-0.0156523, -0.165705, 0.0313047)
                    Node {
                        id: leftFoot
                        objectName: "LeftFoot"
                        position: Qt.vector3d(-0.00782616, -0.202125, -0.0117392)
                        Node {
                            id: joint_47
                            objectName: "joint_47"
                            position: Qt.vector3d(0, -0.0586962, -0.0900009)
                        }
                    }
                }
            }
            Node {
                id: rightUpLeg
                objectName: "RightUpLeg"
                position: Qt.vector3d(0.0547832, -0.0313047, 0.0117392)
                Node {
                    id: rightLeg
                    objectName: "RightLeg"
                    position: Qt.vector3d(0.0156523, -0.166111, 0.0313047)
                    Node {
                        id: rightFoot
                        objectName: "RightFoot"
                        position: Qt.vector3d(0.00782616, -0.201719, -0.00782616)
                        Node {
                            id: joint_51
                            objectName: "joint_51"
                            position: Qt.vector3d(0, -0.0586962, -0.0978271)
                        }
                    }
                }
            }
        }
        Model {
            id: bela_mesh
            objectName: "bela_mesh"
            source: "meshes/meshes_0__mesh.mesh"
            skin: skin
            materials: [
                qtmesh_gen3d_6_1788751927380_mesh_mat_material
            ]
        }
    }

    // Animations:
    Timeline {
        id: cheer_timeline
        objectName: "Cheer"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1100
        currentFrame: 0
        enabled: node.clip === "Cheer"
        animations: TimelineAnimation {
            duration: 1100
            from: 0
            to: 1100
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_0.qad"
        }
    }
    Timeline {
        id: climb_timeline
        objectName: "Climb"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1200
        currentFrame: 0
        enabled: node.clip === "Climb"
        animations: TimelineAnimation {
            duration: 1200
            from: 0
            to: 1200
            running: node.clip === "Climb"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_1.qad"
        }
    }
    Timeline {
        id: crawl_timeline
        objectName: "Crawl"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 767
        currentFrame: 0
        enabled: node.clip === "Crawl"
        animations: TimelineAnimation {
            duration: 767
            from: 0
            to: 767
            running: node.clip === "Crawl"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_2.qad"
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
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_2.qad"
        }
    }
    Timeline {
        id: crouch_timeline
        objectName: "Crouch"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 534
        currentFrame: 0
        enabled: node.clip === "Crouch"
        animations: TimelineAnimation {
            duration: 534
            from: 0
            to: 534
            running: node.clip === "Crouch"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_3.qad"
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
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_3.qad"
        }
    }
    Timeline {
        id: hang_timeline
        objectName: "Hang"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3967
        currentFrame: 0
        enabled: node.clip === "Hang"
        animations: TimelineAnimation {
            duration: 3967
            from: 0
            to: 3967
            running: node.clip === "Hang"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_4.qad"
        }
    }
    Timeline {
        id: hit_timeline
        objectName: "Hit"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 934
        currentFrame: 0
        enabled: node.clip === "Hit"
        animations: TimelineAnimation {
            duration: 934
            from: 0
            to: 934
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_5.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_5.qad"
        }
    }
    Timeline {
        id: idle_timeline
        objectName: "Idle"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 2867
        currentFrame: 0
        enabled: node.clip === "Idle"
        animations: TimelineAnimation {
            duration: 2867
            from: 0
            to: 2867
            running: node.clip === "Idle"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_6.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_6.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_6.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_6.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_6.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_6.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_6.qad"
        }
    }
    Timeline {
        id: jump_timeline
        objectName: "Jump"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1134
        currentFrame: 0
        enabled: node.clip === "Jump"
        animations: TimelineAnimation {
            duration: 1134
            from: 0
            to: 1134
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_7.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.999528, 0.0307242, 0, 0.000165968)
            }
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_7.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.999999, 0.00171237, 4.72823e-06, 0.00016307)
            }
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_7.qad"
        }
    }
    Timeline {
        id: land_timeline
        objectName: "Land"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1100
        currentFrame: 0
        enabled: node.clip === "Land"
        animations: TimelineAnimation {
            duration: 1100
            from: 0
            to: 1100
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_8.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_8.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_8.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_8.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_8.qad"
        }
    }
    Timeline {
        id: pickup_timeline
        objectName: "Pickup"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3967
        currentFrame: 0
        enabled: node.clip === "Pickup"
        animations: TimelineAnimation {
            duration: 3967
            from: 0
            to: 3967
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_9.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_9.qad"
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
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_9.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_9.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_9.qad"
        }
    }
    Timeline {
        id: push_timeline
        objectName: "Push"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 767
        currentFrame: 0
        enabled: node.clip === "Push"
        animations: TimelineAnimation {
            duration: 767
            from: 0
            to: 767
            running: node.clip === "Push"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_10.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_10.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_10.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_10.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_10.qad"
        }
    }
    Timeline {
        id: run_timeline
        objectName: "Run"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 634
        currentFrame: 0
        enabled: node.clip === "Run"
        animations: TimelineAnimation {
            duration: 634
            from: 0
            to: 634
            running: node.clip === "Run"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_11.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_11.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            Keyframe {
                frame: 100
                value: Qt.quaternion(0.999703, 0.0243712, 0, -0.000498954)
            }
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_11.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_11.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_11.qad"
        }
    }
    Timeline {
        id: walk_timeline
        objectName: "Walk"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1200
        currentFrame: 0
        enabled: node.clip === "Walk"
        animations: TimelineAnimation {
            duration: 1200
            from: 0
            to: 1200
            running: node.clip === "Walk"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_12.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_12.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_12.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_12.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_12.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_12.qad"
        }
    }
    Timeline {
        id: wave_timeline
        objectName: "Wave"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3534
        currentFrame: 0
        enabled: node.clip === "Wave"
        animations: TimelineAnimation {
            duration: 3534
            from: 0
            to: 3534
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_13.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_13.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_13.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_13.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_13.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_13.qad"
        }
    }
}
