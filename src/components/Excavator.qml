import QtQuick
import QtQuick3D

Node {
    id: node

    // IMU servisi bağlantısı için property'ler
    property real boomAngle: 0.0
    property real armAngle: 0.0
    property real bucketAngle: 0.0

    // Resources
    PrincipledMaterial {
        id: dynamic_Rust_material
        objectName: "Dynamic Rust"
        metalness: 1
        roughness: 0.7100736498832703
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: material_material
        objectName: "Material"
        baseColor: "#ff444143"
        metalness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: master_Glass_material
        objectName: "Master Glass"
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
        transmissionFactor: 1
        indexOfRefraction: 1.4500000476837158
    }
    PrincipledMaterial {
        id: material_001_material
        objectName: "Material.001"
        baseColor: "#ff000000"
        roughness: 0.5
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: metal_material
        objectName: "metal"
        baseColor: "#ffa1a1a1"
        metalness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
    }
    PrincipledMaterial {
        id: level_1_material
        objectName: "Level_1"
        baseColor: "#fffff85f"
        roughness: 1
        cullMode: PrincipledMaterial.NoCulling
        alphaMode: PrincipledMaterial.Opaque
        indexOfRefraction: 1.4500000476837158
    }

    // Nodes:
    Node {
        id: root
        objectName: "ROOT"
        Model {
            id: mainBase
            objectName: "MainBase"
            position: Qt.vector3d(-0.00665526, 2.82167, 1.61977)
            rotation: Qt.quaternion(-1.62921e-07, 1, 0, 0)
            scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
            source: "../../resources/meshes/caterpillar_390F_LME__UNDERCARRIAGE_FRAME_390F_mesh.mesh"
            materials: [
                level_1_material
            ]
            Node {
                id: armature
                objectName: "Armature"
                position: Qt.vector3d(6.6553, -3720.32, -2691.99)
                rotation: Qt.quaternion(1.62921e-07, 1, 0, 0)
                scale: Qt.vector3d(1000, 1000, 1000)
                Node {
                    id: bone_007
                    objectName: "Bone.007"
                    position: Qt.vector3d(-0.0066553, -3.72031, -2.69199)
                    Node {
                        id: bottom_
                        objectName: "bottom"
                        position: Qt.vector3d(0.00262427, 0.947969, 1.24945)
                        rotation: Qt.quaternion(0.707107, -2.66925e-08, -2.66925e-08, -0.707107)
                        scale: Qt.vector3d(1, 1, 1)
                        Node {
                            id: bottom1
                            objectName: "bottom1"
                            position: Qt.vector3d(-2.60217e-07, -4.65661e-10, 2.846e-07)
                            rotation: Qt.quaternion(-0.166287, -0.685881, 0.688123, 0.168529)
                            scale: Qt.vector3d(1, 1, 1)
                            Model {
                                id: caterpillar_390F_LME__BOOM_CYLINDER_BORE_390F_LME
                                objectName: "Caterpillar_390F_LME:_BOOM_CYLINDER_BORE_390F_LME"
                                position: Qt.vector3d(4.65661e-10, 3.82535e-07, -3.65522e-07)
                                rotation: Qt.quaternion(-0.00187059, 0.000770314, 0.99781, 0.0661224)
                                scale: Qt.vector3d(1, 1, 1)
                                source: "../../resources/meshes/caterpillar_390F_LME__BOOM_CYLINDER_BORE_390F_LME_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                        }
                    }
                    Node {
                        id: bone
                        objectName: "Bone"
                        position: Qt.vector3d(0.00653788, 1.64764, 0.198732)

                        // BOOM ROTATION - IMU'dan gelen boomAngle değeriyle kontrol edilecek
                        rotation: Qt.quaternion(0.802259 + boomAngle * 0.01, 0.596976, 0.000129593, 0.000129569)

                        // Smooth animasyon için Behavior ekle
                        Behavior on rotation {
                            QuaternionAnimation {
                                duration: 50
                                easing.type: Easing.OutQuad
                            }
                        }

                        Node {
                            id: top_
                            objectName: "top"
                            position: Qt.vector3d(0.000736282, 2.98354, -1.26916)
                            rotation: Qt.quaternion(0.567191, -0.422035, -0.422218, -0.567374)
                            Node {
                                id: top1
                                objectName: "top1"
                                position: Qt.vector3d(-5.68173e-07, -5.96047e-08, 2.1157e-08)
                                rotation: Qt.quaternion(-0.168426, 0.686394, 0.687349, -0.167471)
                                scale: Qt.vector3d(1, 1, 1)
                                Model {
                                    id: caterpillar_390F_LME__BOOM_PISTON_ROB_390F_LME__BOOM_ROB_CLEVIS
                                    objectName: "Caterpillar_390F_LME:_BOOM_PISTON_ROB_390F_LME:_BOOM_ROB_CLEVIS"
                                    position: Qt.vector3d(-6.5255e-10, 3.57585e-07, 7.74834e-07)
                                    rotation: Qt.quaternion(0.237596, 0.971364, -0.000744172, 0.000328117)
                                    scale: Qt.vector3d(1, 1, 1)
                                    source: "../../resources/meshes/caterpillar_390F_LME__BOOM_PISTON_ROB_390F_LME__BOOM_ROB_CLEVIS_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                    Model {
                                        id: caterpillar_390F_LME__BOOM_390F_LME__BOOM_CYLINDER_PIN_390F
                                        objectName: "Caterpillar_390F_LME:_BOOM_390F_LME:_BOOM_CYLINDER_PIN_390F"
                                        rotation: Qt.quaternion(-5.1659e-07, 1, 0, 0)
                                        scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BOOM_390F_LME__BOOM_CYLINDER_PIN_390F_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                    }
                                    Model {
                                        id: caterpillar_390F_LME__BOOM_390F_LME__BOOM_CYLINDER_PIN_390F__PI
                                        objectName: "Caterpillar_390F_LME:_BOOM_390F_LME:_BOOM_CYLINDER_PIN_390F:_PI"
                                        position: Qt.vector3d(0.000635513, 0.000184923, 0.000442439)
                                        rotation: Qt.quaternion(-5.1659e-07, 1, 0, 0)
                                        scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BOOM_390F_LME__BOOM_CYLINDER_PIN_390F__PI_mesh.mesh"
                                        materials: [
                                            metal_material
                                        ]
                                    }
                                    Model {
                                        id: caterpillar_390F_LME__BOOM_PISTON_ROB_390F_LME
                                        objectName: "Caterpillar_390F_LME:_BOOM_PISTON_ROB_390F_LME"
                                        position: Qt.vector3d(0.00245119, -1.3318, -0.692694)
                                        rotation: Qt.quaternion(-5.1659e-07, 1, 0, 0)
                                        scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BOOM_PISTON_ROB_390F_LME_mesh.mesh"
                                        materials: [
                                            metal_material
                                        ]
                                    }
                                }
                            }
                        }
                        Node {
                            id: b1c
                            objectName: "b1c"
                            position: Qt.vector3d(0.00105774, 3.47948, -2.08301)
                            rotation: Qt.quaternion(0.567191, -0.422034, -0.422218, -0.567374)
                            Node {
                                id: b1
                                objectName: "b1"
                                position: Qt.vector3d(6.59264e-08, 5.96048e-08, 1.58546e-07)
                                rotation: Qt.quaternion(0.508798, 0.494409, -0.491093, -0.505482)
                                scale: Qt.vector3d(1, 1, 1)
                                Model {
                                    id: caterpillar_390F_LME__ARM_CYLINDER_BORE_390F_LME
                                    objectName: "Caterpillar_390F_LME:_ARM_CYLINDER_BORE_390F_LME"
                                    position: Qt.vector3d(-0.00020796, 2.29553, -0.00167447)
                                    rotation: Qt.quaternion(0.00237754, 0.00231171, 0.71695, -0.697117)
                                    scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                    source: "../../resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_BORE_390F_LME_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                }
                            }
                            Model {
                                id: caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME_001
                                objectName: "Caterpillar_390F_LME:_ARM_CYLINDER_PIN_390F_LME.001"
                                position: Qt.vector3d(0.0667304, 0.000278098, 2.41318)
                                rotation: Qt.quaternion(5.69511e-05, 0.707109, 0.707104, 7.22573e-05)
                                scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                source: "../../resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME_001_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME__PIN_BOLT_3
                                objectName: "Caterpillar_390F_LME:_ARM_CYLINDER_PIN_390F_LME:_PIN_BOLT_3"
                                position: Qt.vector3d(0.0670012, -0.000253329, 2.41721)
                                rotation: Qt.quaternion(5.69511e-05, 0.707109, 0.707104, 7.22573e-05)
                                scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                source: "../../resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME__PIN_BOLT_3_mesh.mesh"
                                materials: [
                                    metal_material
                                ]
                            }
                        }
                        Node {
                            id: bone_001
                            objectName: "Bone.001"
                            position: Qt.vector3d(1.45519e-10, 6.98916, -1.77318e-07)

                            // ARM ROTATION - IMU'dan gelen armAngle değeriyle kontrol edilecek
                            rotation: Qt.quaternion(0.505364 + armAngle * 0.01, 0.862906, 0.000107602, 0.000354555)

                            // Smooth animasyon için Behavior ekle
                            Behavior on rotation {
                                QuaternionAnimation {
                                    duration: 50
                                    easing.type: Easing.OutQuad
                                }
                            }

                            scale: Qt.vector3d(1, 1, 1)
                            Node {
                                id: bone_002
                                objectName: "Bone.002"
                                position: Qt.vector3d(-5.5298e-10, 2.88263, 7.7486e-07)

                                // BUCKET ROTATION - IMU'dan gelen bucketAngle değeriyle kontrol edilecek
                                rotation: Qt.quaternion(0.81802 + bucketAngle * 0.01, -0.575189, -2.93699e-08, -0.000304044)

                                // Smooth animasyon için Behavior ekle
                                Behavior on rotation {
                                    QuaternionAnimation {
                                        duration: 50
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                scale: Qt.vector3d(1, 1, 1)
                                Model {
                                    id: caterpillar_390F_LME__BUCKET_390F_LME
                                    objectName: "Caterpillar_390F_LME:_BUCKET_390F_LME"
                                    position: Qt.vector3d(-0.00206844, 0.339205, 1.65607)
                                    rotation: Qt.quaternion(0.876183, 0.481979, -0.000310527, 0.000170818)
                                    scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                    source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_390F_LME_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                    Model {
                                        id: caterpillar_390F_LME__BUCKET_390F_LME__BUCKET_BOLT_390F
                                        objectName: "Caterpillar_390F_LME:_BUCKET_390F_LME:_BUCKET_BOLT_390F"
                                        position: Qt.vector3d(0.69155, -80.2353, 417.3)
                                        rotation: Qt.quaternion(0.999999, 0.0010576, -0.000134365, -8.18506e-05)
                                        scale: Qt.vector3d(1, 1, 1)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_390F_LME__BUCKET_BOLT_390F_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                    }
                                    Model {
                                        id: caterpillar_390F_LME__BUCKET_PIN_390F_LME_001
                                        objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME.001"
                                        position: Qt.vector3d(0.573625, -1696.91, -1006.43)
                                        rotation: Qt.quaternion(0.999999, 0.0010576, -0.000134365, -8.18506e-05)
                                        scale: Qt.vector3d(1, 1, 1)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_001_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                        Model {
                                            id: caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_002
                                            objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME:_PIN_BOLT_390F.002"
                                            position: Qt.vector3d(0.642499, 0.155141, -0.0879661)
                                            source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_002_mesh.mesh"
                                            materials: [
                                                metal_material
                                            ]
                                        }
                                    }
                                    Model {
                                        id: caterpillar_390F_LME__BUCKET_PIN_390F_LME_002
                                        objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME.002"
                                        position: Qt.vector3d(0.573625, -1696.91, -1006.43)
                                        rotation: Qt.quaternion(0.999999, 0.0010576, -0.000134365, -8.18506e-05)
                                        scale: Qt.vector3d(1, 1, 1)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_002_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                        Model {
                                            id: caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_003
                                            objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME:_PIN_BOLT_390F.003"
                                            position: Qt.vector3d(0.642499, 0.155141, -0.0879661)
                                            source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_003_mesh.mesh"
                                            materials: [
                                                metal_material
                                            ]
                                        }
                                    }
                                }
                            }
                            Node {
                                id: t1c
                                objectName: "t1c"
                                position: Qt.vector3d(0.00105584, -1.02164, -0.667503)
                                rotation: Qt.quaternion(0.0777851, 0.702802, 0.702876, -0.0773576)
                                scale: Qt.vector3d(1, 1, 1)
                                Node {
                                    id: t1
                                    objectName: "t1"
                                    position: Qt.vector3d(5.85035e-07, 5.96046e-08, -2.40202e-07)
                                    rotation: Qt.quaternion(0.506708, -0.493201, -0.493201, 0.506708)
                                    scale: Qt.vector3d(1, 1, 1)
                                    Model {
                                        id: caterpillar_390F_LME__ARM_PISTON_ROB_390F_LME__ARM_ROB_CLEVIS_3
                                        objectName: "Caterpillar_390F_LME:_ARM_PISTON_ROB_390F_LME:_ARM_ROB_CLEVIS_3"
                                        position: Qt.vector3d(-0.000131843, 0.0860066, 0.00149551)
                                        rotation: Qt.quaternion(0.697044, -0.717028, 1.40266e-05, 3.17258e-07)
                                        scale: Qt.vector3d(0.000999999, 0.001, 0.001)
                                        source: "../../resources/meshes/caterpillar_390F_LME__ARM_PISTON_ROB_390F_LME__ARM_ROB_CLEVIS_3_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                        Model {
                                            id: caterpillar_390F_LME__ARM_PISTON_ROB_390F_LME
                                            objectName: "Caterpillar_390F_LME:_ARM_PISTON_ROB_390F_LME"
                                            position: Qt.vector3d(-0.000205949, -52.4471, 1944)
                                            source: "../../resources/meshes/caterpillar_390F_LME__ARM_PISTON_ROB_390F_LME_mesh.mesh"
                                            materials: [
                                                metal_material
                                            ]
                                        }
                                    }
                                }
                                Model {
                                    id: caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME
                                    objectName: "Caterpillar_390F_LME:_ARM_CYLINDER_PIN_390F_LME"
                                    position: Qt.vector3d(-0.0686386, 0.000290569, -2.42131)
                                    rotation: Qt.quaternion(0.000117861, 0.707114, 0.707099, 0.000133066)
                                    scale: Qt.vector3d(0.000999999, 0.001, 0.001)
                                    source: "../../resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                }
                                Model {
                                    id: caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME__PIN_BOLT_390F
                                    objectName: "Caterpillar_390F_LME:_ARM_CYLINDER_PIN_390F_LME:_PIN_BOLT_390F"
                                    position: Qt.vector3d(-0.0683692, -0.000240863, -2.41729)
                                    rotation: Qt.quaternion(0.000117861, 0.707114, 0.707099, 0.000133066)
                                    scale: Qt.vector3d(0.000999999, 0.001, 0.001)
                                    source: "../../resources/meshes/caterpillar_390F_LME__ARM_CYLINDER_PIN_390F_LME__PIN_BOLT_390F_mesh.mesh"
                                    materials: [
                                        metal_material
                                    ]
                                }
                            }
                            Node {
                                id: bone_003
                                objectName: "Bone.003"
                                position: Qt.vector3d(0.000158719, 2.35573, -0.117419)
                                rotation: Qt.quaternion(0.736328, -0.67661, -0.00296278, 0.00321845)
                                Node {
                                    id: bone_005
                                    objectName: "Bone.005"
                                    position: Qt.vector3d(1.10595e-09, 0.720088, 5.86629e-07)
                                    rotation: Qt.quaternion(0.569177, 0.822189, 2.04533e-08, -0.00658536)
                                    scale: Qt.vector3d(1, 1, 1)
                                    Model {
                                        id: caterpillar_390F_LME__BUCKET_LINK_390F_LME
                                        objectName: "Caterpillar_390F_LME:_BUCKET_LINK_390F_LME"
                                        position: Qt.vector3d(0.000570237, 0.24018, 0.00662743)
                                        rotation: Qt.quaternion(0.945936, -0.324334, 0.00322139, 0.00149809)
                                        scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_LINK_390F_LME_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                        Model {
                                            id: caterpillar_390F_LME__BUCKET_PIN_390F_LME
                                            objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME"
                                            position: Qt.vector3d(-0.398945, -30.5747, 357.935)
                                            source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_mesh.mesh"
                                            materials: [
                                                level_1_material
                                            ]
                                            Model {
                                                id: caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F
                                                objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME:_PIN_BOLT_390F"
                                                position: Qt.vector3d(0.642499, 0.155062, -0.0891523)
                                                source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_mesh.mesh"
                                                materials: [
                                                    metal_material
                                                ]
                                            }
                                        }
                                    }
                                }
                                Node {
                                    id: b2c
                                    objectName: "b2c"
                                    position: Qt.vector3d(1.10595e-09, 0.720088, 5.86629e-07)
                                    rotation: Qt.quaternion(-0.420579, 0.572156, 0.567857, 0.41628)
                                    scale: Qt.vector3d(1, 1, 1)
                                    Node {
                                        id: b2
                                        objectName: "b2"
                                        position: Qt.vector3d(3.33609e-07, 2.38493e-07, 2.34632e-07)
                                        rotation: Qt.quaternion(-0.128173, -0.69504, 0.695636, 0.128769)
                                        scale: Qt.vector3d(1, 1, 1)
                                        Model {
                                            id: caterpillar_390F_LME__BUCKET_PISTON_ROB_390F_LME
                                            objectName: "Caterpillar_390F_LME:_BUCKET_PISTON_ROB_390F_LME"
                                            position: Qt.vector3d(-6.10774e-05, 1.39163, 0.000820818)
                                            rotation: Qt.quaternion(0.000226238, 0.000281927, -0.181983, 0.983302)
                                            scale: Qt.vector3d(0.000999998, 0.001, 0.000999999)
                                            source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PISTON_ROB_390F_LME_mesh.mesh"
                                            materials: [
                                                metal_material
                                            ]
                                        }
                                        Model {
                                            id: caterpillar_390F_LME__BUCKET_PISTON_ROB_390F_LME__BUCKET_ROB_CL
                                            objectName: "Caterpillar_390F_LME:_BUCKET_PISTON_ROB_390F_LME:_BUCKET_ROB_CL"
                                            position: Qt.vector3d(-0.000340511, 0.103617, -0.000157159)
                                            rotation: Qt.quaternion(0.000226238, 0.000281927, -0.181983, 0.983302)
                                            scale: Qt.vector3d(0.000999998, 0.001, 0.000999999)
                                            source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PISTON_ROB_390F_LME__BUCKET_ROB_CL_mesh.mesh"
                                            materials: [
                                                level_1_material
                                            ]
                                        }
                                    }
                                }
                                Model {
                                    id: caterpillar_390F_LME__TIPPING_LINK_390F_LME
                                    objectName: "Caterpillar_390F_LME:_TIPPING_LINK_390F_LME"
                                    position: Qt.vector3d(-0.00211514, 0.360877, -0.0021516)
                                    rotation: Qt.quaternion(0.806245, 0.591567, 0.00295921, -0.00278216)
                                    scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                    source: "../../resources/meshes/caterpillar_390F_LME__TIPPING_LINK_390F_LME_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                }
                            }
                            Node {
                                id: t2c
                                objectName: "t2c"
                                position: Qt.vector3d(0.00137122, -0.0739095, -1.20065)
                                rotation: Qt.quaternion(0.0777851, 0.702802, 0.702876, -0.0773576)
                                Node {
                                    id: t2
                                    objectName: "t2"
                                    position: Qt.vector3d(1.50293e-08, -2.38401e-07, 1.10742e-06)
                                    rotation: Qt.quaternion(-0.128515, 0.695401, 0.695227, -0.128689)
                                    scale: Qt.vector3d(1, 1, 1)
                                    Model {
                                        id: caterpillar_390F_LME__BUCKET_CYLINDER_BORE_390F_LME
                                        objectName: "Caterpillar_390F_LME:_BUCKET_CYLINDER_BORE_390F_LME"
                                        position: Qt.vector3d(-7.27721e-05, 1.60483, 0.00049801)
                                        rotation: Qt.quaternion(0.983302, -0.181983, 0.000141637, -0.000147898)
                                        scale: Qt.vector3d(0.000999999, 0.001, 0.001)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_CYLINDER_BORE_390F_LME_mesh.mesh"
                                        materials: [
                                            level_1_material
                                        ]
                                    }
                                }
                            }
                            Model {
                                id: caterpillar_390F_LME__ARM_390F_LME
                                objectName: "Caterpillar_390F_LME:_ARM_390F_LME"
                                position: Qt.vector3d(0.00130689, 0.428133, -0.55311)
                                rotation: Qt.quaternion(0.993964, -0.109702, -0.000302333, 5.19608e-05)
                                scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                                source: "../../resources/meshes/caterpillar_390F_LME__ARM_390F_LME_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                                Model {
                                    id: caterpillar_390F_LME__BUCKET_CYLINDER_PIN_390F_LME
                                    objectName: "Caterpillar_390F_LME:_BUCKET_CYLINDER_PIN_390F_LME"
                                    position: Qt.vector3d(-0.0751127, -352.509, -740.86)
                                    rotation: Qt.quaternion(1, -0.00017754, 1.10227e-05, 1.03254e-05)
                                    source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_CYLINDER_PIN_390F_LME_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                }
                                Model {
                                    id: caterpillar_390F_LME__BUCKET_CYLINDER_PIN_390F_LME__PIN_BOLT_39
                                    objectName: "Caterpillar_390F_LME:_BUCKET_CYLINDER_PIN_390F_LME:_PIN_BOLT_39"
                                    position: Qt.vector3d(-0.10693, -351.938, -741.061)
                                    rotation: Qt.quaternion(1, -0.00017754, 1.10227e-05, 1.03254e-05)
                                    source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_CYLINDER_PIN_390F_LME__PIN_BOLT_39_mesh.mesh"
                                    materials: [
                                        metal_material
                                    ]
                                }
                                Model {
                                    id: caterpillar_390F_LME__BUCKET_PIN_390F_LME_004
                                    objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME.004"
                                    position: Qt.vector3d(-0.981896, 2157.21, 669.09)
                                    rotation: Qt.quaternion(1, -0.00017754, 1.10227e-05, 1.03254e-05)
                                    source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME_004_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                    Model {
                                        id: caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_001
                                        objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME:_PIN_BOLT_390F.001"
                                        position: Qt.vector3d(0.642499, 0.154464, -0.0895012)
                                        source: "../../resources/meshes/caterpillar_390F_LME__BUCKET_PIN_390F_LME__PIN_BOLT_390F_001_mesh.mesh"
                                        materials: [
                                            metal_material
                                        ]
                                    }
                                }
                            }
                        }
                        Model {
                            id: caterpillar_390F_LME__BOOM_390F_LME
                            objectName: "Caterpillar_390F_LME:_BOOM_390F_LME"
                            position: Qt.vector3d(0.000117625, 0.000228763, -0.000641465)
                            rotation: Qt.quaternion(0.596976, 0.802259, -0.000129569, 0.000129593)
                            scale: Qt.vector3d(0.000999999, 0.001, 0.000999999)
                            source: "../../resources/meshes/caterpillar_390F_LME__BOOM_390F_LME_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                            Model {
                                id: caterpillar_390F_LME__ARM_PIN_390F_LME
                                objectName: "Caterpillar_390F_LME:_ARM_PIN_390F_LME"
                                position: Qt.vector3d(-0.488975, -2006.88, -6694.6)
                                source: "../../resources/meshes/caterpillar_390F_LME__ARM_PIN_390F_LME_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__ARM_PIN_390F_LME__PIN_BOLT_390F
                                objectName: "Caterpillar_390F_LME:_ARM_PIN_390F_LME:_PIN_BOLT_390F"
                                position: Qt.vector3d(-0.00485976, -2007.26, -6694.81)
                                source: "../../resources/meshes/caterpillar_390F_LME__ARM_PIN_390F_LME__PIN_BOLT_390F_mesh.mesh"
                                materials: [
                                    metal_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__BOOM_PIN_390F
                                objectName: "Caterpillar_390F_LME:_BOOM_PIN_390F"
                                position: Qt.vector3d(-0.11138, 0.669593, 0.118124)
                                rotation: Qt.quaternion(1, -9.10237e-05, 1.26771e-05, 5.24809e-06)
                                source: "../../resources/meshes/caterpillar_390F_LME__BOOM_PIN_390F_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__BOOM_PIN_390F__PIN_BOLT_390F
                                objectName: "Caterpillar_390F_LME:_BOOM_PIN_390F:_PIN_BOLT_390F"
                                position: Qt.vector3d(0.00601559, -0.0379262, 0.374594)
                                rotation: Qt.quaternion(1, -9.10237e-05, 1.26771e-05, 5.24809e-06)
                                source: "../../resources/meshes/caterpillar_390F_LME__BOOM_PIN_390F__PIN_BOLT_390F_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                        }
                    }
                    Node {
                        id: bone_004
                        objectName: "Bone.004"
                        position: Qt.vector3d(0.00665526, 0.542544, 6.73705)
                        rotation: Qt.quaternion(3.39807e-08, 6.74184e-08, 0.450088, 0.892984)
                        scale: Qt.vector3d(1, 1, 1)
                    }
                    Model {
                        id: base
                        objectName: "base"
                        position: Qt.vector3d(0.00830829, 1.18383, 0.73331)
                        rotation: Qt.quaternion(-1.62921e-07, 1, 0, 0)
                        scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
                        source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__SUPERSTRUCTURE_FRAME_mesh.mesh"
                        materials: [
                            level_1_material
                        ]
                        Model {
                            id: caterpillar_390F_LME__BOOM_BORE_PIN_390F
                            objectName: "Caterpillar_390F_LME:_BOOM_BORE_PIN_390F"
                            position: Qt.vector3d(-1.6912, 235.526, -515.115)
                            source: "../../resources/meshes/caterpillar_390F_LME__BOOM_BORE_PIN_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__BOOM_BORE_PIN_390F__PIN_BOLT_390F
                            objectName: "Caterpillar_390F_LME:_BOOM_BORE_PIN_390F:_PIN_BOLT_390F"
                            position: Qt.vector3d(-1.76023, 235.411, -515.548)
                            source: "../../resources/meshes/caterpillar_390F_LME__BOOM_BORE_PIN_390F__PIN_BOLT_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__BONNET_390F
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_BONNET_390F"
                            position: Qt.vector3d(1751.46, -1011.78, 3815.69)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__BONNET_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__FUEL_TANK_390F
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_FUEL_TANK_390F"
                                position: Qt.vector3d(-3253.18, 648.23, -3347.95)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__FUEL_TANK_390F_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_DOOR_390F_01
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_RIGHT_DOOR_390F_01"
                                position: Qt.vector3d(-3745.78, 671.45, -1250.9)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_DOOR_390F_01_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_DOOR_390F_02
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_RIGHT_DOOR_390F_02"
                                position: Qt.vector3d(-3745.84, 797.116, 288.769)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_DOOR_390F_02_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                            }
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__COUGHTERWEIGHT_390F
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_COUGHTERWEIGHT_390F"
                            position: Qt.vector3d(8.79341, -94.0914, 5159.82)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__COUGHTERWEIGHT_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__COUGHTERWEIGHT_390F_
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_COUGHTERWEIGHT_390F:"
                            position: Qt.vector3d(-1.74222, -344.734, 5381.97)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__COUGHTERWEIGHT_390F__mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_DOOR_390F_01
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_LEFT_DOOR_390F_01"
                            position: Qt.vector3d(1988.31, -210.476, 2706.34)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_DOOR_390F_01_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_DOOR_390F_02
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_LEFT_DOOR_390F_02"
                            position: Qt.vector3d(1988.28, -210.31, 4106.6)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_DOOR_390F_02_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_MODULE_390F
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_LEFT_MODULE_390F"
                            position: Qt.vector3d(1498.33, 15.4647, 1274.51)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__LEFT_MODULE_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F"
                                position: Qt.vector3d(13.7908, -458.468, -1610.11)
                                rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F_mesh.mesh"
                                materials: [
                                    level_1_material
                                ]
                                Model {
                                    id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__CABINE_
                                    objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_CABINE_"
                                    position: Qt.vector3d(473.643, 249.803, -3.63031)
                                    rotation: Qt.quaternion(1, -2.51765e-05, 8.66816e-06, 2.86611e-06)
                                    source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__CABINE__mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                }
                                Model {
                                    id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_003
                                    objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_GLA.003"
                                    position: Qt.vector3d(-498.791, -27.2443, -37.3992)
                                    rotation: Qt.quaternion(1, -2.51765e-05, 8.66816e-06, 2.86611e-06)
                                    source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_003_mesh.mesh"
                                    materials: [
                                        master_Glass_material
                                    ]
                                }
                                Model {
                                    id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_004
                                    objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_GLA.004"
                                    position: Qt.vector3d(-498.779, -47.5064, 620.125)
                                    rotation: Qt.quaternion(1, -2.51765e-05, 8.66816e-06, 2.86611e-06)
                                    source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_004_mesh.mesh"
                                    materials: [
                                        level_1_material
                                    ]
                                }
                            }
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_GLA"
                                position: Qt.vector3d(20.0229, 124.924, -2215.03)
                                rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_mesh.mesh"
                                materials: [
                                    master_Glass_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_001
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_GLA.001"
                                position: Qt.vector3d(484.998, -554.154, -968.06)
                                rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_001_mesh.mesh"
                                materials: [
                                    master_Glass_material
                                ]
                            }
                            Model {
                                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLASS_3
                                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_GLASS_3"
                                position: Qt.vector3d(20.0182, -516.679, -2123.41)
                                rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLASS_3_mesh.mesh"
                                materials: [
                                    master_Glass_material
                                ]
                            }
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__MAIN_EXHAUST_390F
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_MAIN_EXHAUST_390F"
                            position: Qt.vector3d(-659.459, -1286.02, 4004.41)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__MAIN_EXHAUST_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__MAIN_EXHAUST_390F__S
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_MAIN_EXHAUST_390F:_S"
                            position: Qt.vector3d(-659.462, -1492.76, 4079.4)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__MAIN_EXHAUST_390F__S_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_MODULE_390F
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_RIGHT_MODULE_390F"
                            position: Qt.vector3d(-1501.64, 132.958, -541.524)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__RIGHT_MODULE_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                        Model {
                            id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__TOP_SIDEWALK_390F
                            objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_TOP_SIDEWALK_390F"
                            position: Qt.vector3d(562.138, -671.01, 2156.89)
                            rotation: Qt.quaternion(1, 2.51765e-05, -8.66816e-06, -2.86611e-06)
                            source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__TOP_SIDEWALK_390F_mesh.mesh"
                            materials: [
                                level_1_material
                            ]
                        }
                    }
                }
            }
            Model {
                id: caterpillar_390F_LME__CENTER_BEARING_390F
                objectName: "Caterpillar_390F_LME:_CENTER_BEARING_390F"
                position: Qt.vector3d(7.34523, -577.781, 5.21327)
                source: "../../resources/meshes/caterpillar_390F_LME__CENTER_BEARING_390F_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__CENTER_BEARING_390F__BEARING_BOLT_390F
                objectName: "Caterpillar_390F_LME:_CENTER_BEARING_390F:_BEARING_BOLT_390F"
                position: Qt.vector3d(5.0789, -500.806, 1.92332)
                source: "../../resources/meshes/caterpillar_390F_LME__CENTER_BEARING_390F__BEARING_BOLT_390F_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__LEFT_TRACK_390F__DRIVE_SPROCKET_390F
                objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_DRIVE_SPROCKET_390F"
                position: Qt.vector3d(1766.67, 371.369, 2451.13)
                rotation: Qt.quaternion(0.998507, 0.0546209, 0, 0)
                scale: Qt.vector3d(1, 1, 1)
                source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__DRIVE_SPROCKET_390F_mesh.mesh"
                materials: [
                    material_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__LEFT_TRACK_390F__DRIVE_SPROCKET_390F__DRI
                objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_DRIVE_SPROCKET_390F:_DRI"
                position: Qt.vector3d(2032.62, 371.424, 2451.3)
                source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__DRIVE_SPROCKET_390F__DRI_mesh.mesh"
                materials: [
                    dynamic_Rust_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__LEFT_TRACK_390F__FRONT_IDLER_390F
                objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_FRONT_IDLER_390F"
                position: Qt.vector3d(1707.26, 370.382, -2421.2)
                source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__FRONT_IDLER_390F_mesh.mesh"
                materials: [
                    material_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_FRAME_390F
                objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_TRACK_FRAME_390F"
                position: Qt.vector3d(1430.37, 271.185, 1538.16)
                source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_FRAME_390F_mesh.mesh"
                materials: [
                    material_material
                ]
                Model {
                    id: caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F
                    objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_TRACK_ROLLER_390F"
                    position: Qt.vector3d(276.28, 390.229, -1536.93)
                    source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F_mesh.mesh"
                    materials: [
                        dynamic_Rust_material
                    ]
                }
                Model {
                    id: caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F__ROLLE
                    objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_TRACK_ROLLER_390F:_ROLLE"
                    position: Qt.vector3d(276.236, 430.684, -1537.78)
                    source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F__ROLLE_mesh.mesh"
                    materials: [
                        level_1_material
                    ]
                }
                Model {
                    id: caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F__TRACK
                    objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_TRACK_ROLLER_390F:_TRACK"
                    position: Qt.vector3d(276.324, 361.528, -1536.97)
                    source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_ROLLER_390F__TRACK_mesh.mesh"
                    materials: [
                        level_1_material
                    ]
                }
            }
            Model {
                id: caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_FRAME_390F__TRACK_
                objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_TRACK_FRAME_390F:_TRACK_"
                position: Qt.vector3d(1318.37, 342.76, 2323.89)
                source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__TRACK_FRAME_390F__TRACK__mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__CARRIER_ROLLER_390F
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_CARRIER_ROLLER_390F"
                position: Qt.vector3d(-1666.12, -158.158, 4.35205)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CARRIER_ROLLER_390F_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_BUSH_
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_CHAIN_390F:_TRACK_BUSH_"
                position: Qt.vector3d(-1693.35, 300.976, 14.9956)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_BUSH__mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_S_001
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_CHAIN_390F:_TRACK_S.001"
                position: Qt.vector3d(-1824.47, 517.658, 3801)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_S_001_mesh.mesh"
                materials: [
                    material_001_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__DRIVE_SPROCKET_390F
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_DRIVE_SPROCKET_390F"
                position: Qt.vector3d(-1753.36, 371.371, 2451.13)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__DRIVE_SPROCKET_390F_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__DRIVE_SPROCKET_390F__DR
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_DRIVE_SPROCKET_390F:_DR"
                position: Qt.vector3d(-2019.25, 371.672, 2451.23)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__DRIVE_SPROCKET_390F__DR_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__FRONT_IDLER_390F
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_FRONT_IDLER_390F"
                position: Qt.vector3d(-1693.34, 371.673, -2421.61)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__FRONT_IDLER_390F_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__RIGHT_TRACK_FRAME_390F
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_RIGHT_TRACK_FRAME_390F"
                position: Qt.vector3d(-1413.5, 265.985, 1583.5)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__RIGHT_TRACK_FRAME_390F_mesh.mesh"
                materials: [
                    level_1_material
                ]
                Model {
                    id: caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_LINK_
                    objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_CHAIN_390F:_TRACK_LINK_"
                    position: Qt.vector3d(-279.65, 33.896, -1570.39)
                    source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_LINK__mesh.mesh"
                    materials: [
                        level_1_material
                    ]
                }
                Model {
                    id: caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_S
                    objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_CHAIN_390F:_TRACK_S"
                    position: Qt.vector3d(-279.789, 34.9719, -1567.81)
                    source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__CHAIN_390F__TRACK_S_mesh.mesh"
                    materials: [
                        level_1_material
                    ]
                }
                Model {
                    id: caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F
                    objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_TRACK_ROLLER_390F"
                    position: Qt.vector3d(-279.848, 395.268, -1582.27)
                    source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F_mesh.mesh"
                    materials: [
                        level_1_material
                    ]
                }
                Model {
                    id: caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F__TRAC
                    objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_TRACK_ROLLER_390F:_TRAC"
                    position: Qt.vector3d(-280.182, 366.62, -1579.8)
                    source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F__TRAC_mesh.mesh"
                    materials: [
                        level_1_material
                    ]
                }
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__RIGHT_TRACK_FRAME_390F_
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_RIGHT_TRACK_FRAME_390F:"
                position: Qt.vector3d(-1305.07, 342.626, 2323.51)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__RIGHT_TRACK_FRAME_390F__mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F__ROLL
                objectName: "Caterpillar_390F_LME:_RIGHT_TRACK_390F:_TRACK_ROLLER_390F:_ROLL"
                position: Qt.vector3d(-1693.36, 701.598, 1.51766)
                source: "../../resources/meshes/caterpillar_390F_LME__RIGHT_TRACK_390F__TRACK_ROLLER_390F__ROLL_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_002
                objectName: "Caterpillar_390F_LME:_SUPERSTRUCTURE_390F:_CABINE_390F:_GLA.002"
                position: Qt.vector3d(1506.66, -1848.33, -203.767)
                source: "../../resources/meshes/caterpillar_390F_LME__SUPERSTRUCTURE_390F__CABINE_390F__GLA_002_mesh.mesh"
                materials: [
                    master_Glass_material
                ]
            }
            Model {
                id: caterpillar_390F_LME__UNDERCARRIAGE_FRAME_390F__UNDERCARRIAGE_F
                objectName: "Caterpillar_390F_LME:_UNDERCARRIAGE_FRAME_390F:_UNDERCARRIAGE_F"
                position: Qt.vector3d(0.16784, -3.58622, 1.59699)
                source: "../../resources/meshes/caterpillar_390F_LME__UNDERCARRIAGE_FRAME_390F__UNDERCARRIAGE_F_mesh.mesh"
                materials: [
                    level_1_material
                ]
            }
            Node {
                id: trackPath
                objectName: "TrackPath"
                position: Qt.vector3d(1707.26, 370.382, -2421.2)
                rotation: Qt.quaternion(1.15202e-07, 0.707107, 0.707107, 0)
                scale: Qt.vector3d(1000, 1000, 1000)
            }
            Node {
                id: trackPath2
                objectName: "TrackPath2"
                position: Qt.vector3d(-1678.11, 370.382, -2421.2)
                rotation: Qt.quaternion(1.15202e-07, 0.707107, 0.707107, 0)
                scale: Qt.vector3d(1000, 1000, 1000)
            }
        }
        Node {
            id: caterpillar_390F_LME__BUCKET_PIN_390F_LME_003
            objectName: "Caterpillar_390F_LME:_BUCKET_PIN_390F_LME.003"
            position: Qt.vector3d(-0.000235012, 3.78007, 8.85135)
            rotation: Qt.quaternion(-1.62921e-07, 1, 0, 0)
            scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
        }
        Node {
            id: empty
            objectName: "Empty"
            position: Qt.vector3d(1.5451, 2.37381, 2.18)
        }
        Model {
            id: caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_SH
            objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_CHAIN_390F:_TRACK_SH"
            position: Qt.vector3d(1.7, 2.55216, 0.593266)
            source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_SH_mesh.mesh"
            materials: [
                material_001_material
            ]
        }
        Model {
            id: caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_BU
            objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_CHAIN_390F:_TRACK_BU"
            position: Qt.vector3d(1.69997, 2.5208, 2.16612)
            rotation: Qt.quaternion(-1.62921e-07, 1, 0, 0)
            scale: Qt.vector3d(0.000999999, 0.000999999, 0.000999999)
            source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_BU_mesh.mesh"
            materials: [
                level_1_material
            ]
        }
        Model {
            id: caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_SH_001
            objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_CHAIN_390F:_TRACK_SH.001"
            position: Qt.vector3d(2.32929, 2.51478, 0)
            source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_SH_001_mesh.mesh"
            materials: [
                material_001_material
            ]
            Model {
                id: caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_LI
                objectName: "Caterpillar_390F_LME:_LEFT_TRACK_390F:_CHAIN_390F:_TRACK_LI"
                position: Qt.vector3d(-2.46499, -2.94245, -2.21978)
                source: "../../resources/meshes/caterpillar_390F_LME__LEFT_TRACK_390F__CHAIN_390F__TRACK_LI_mesh.mesh"
                materials: [
                    material_001_material
                ]
            }
        }
    }

    // Animations:
}
