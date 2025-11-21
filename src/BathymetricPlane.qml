import QtQuick
import QtQuick3D

Node {
    id: bathymetricPlaneRoot

    property real gridSize: 1000
    property int gridResolution: 25  // 25x25 grid hücreleri
    property real cellSize: gridSize / gridResolution
    property real minDepth: 20  // Minimum derinlik
    property real maxDepth: 80  // Maksimum derinlik

    // Derinlik değeri hesaplama fonksiyonu
    function getDepth(x, z) {
        // Daha belirgin dalgalar
        var wave1 = Math.sin(x * 0.4) * Math.cos(z * 0.3) * 20
        var wave2 = Math.sin(x * 0.2 + z * 0.25) * 15
        var wave3 = Math.cos(x * 0.15) * Math.sin(z * 0.2) * 25

        // Noise ekle
        var noise = (Math.sin(x * 12.9898 + z * 78.233) * 43758.5453) % 10

        var totalDepth = minDepth + Math.abs(wave1 + wave2 + wave3) + noise
        return Math.min(totalDepth, maxDepth)
    }

    // Derinliğe göre gri ton hesaplama
    function getColorForDepth(depth) {
        var normalizedDepth = (depth - minDepth) / (maxDepth - minDepth)
        // Derin = koyu gri (0.3), Sığ = açık gri (0.7)
        var gray = 0.7 - (normalizedDepth * 0.4)
        return Qt.rgba(gray, gray, gray, 1.0)
    }

    // Izgara hücreleri - Üstten başlayıp aşağı inen
    Repeater {
        model: gridResolution * gridResolution

        Node {
            property int gridX: index % gridResolution
            property int gridZ: Math.floor(index / gridResolution)
            property real posX: -gridSize/2 + gridX * cellSize + cellSize/2
            property real posZ: -gridSize/2 + gridZ * cellSize + cellSize/2
            property real depth: bathymetricPlaneRoot.getDepth(gridX, gridZ)

            Model {
                id: cell
                source: "#Cube"

                // Üst yüzey y=0'da (deniz seviyesi), aşağı doğru uzanıyor
                position: Qt.vector3d(parent.posX, -parent.depth/2, parent.posZ)
                scale: Qt.vector3d(cellSize, parent.depth, cellSize)

                materials: PrincipledMaterial {
                    baseColor: bathymetricPlaneRoot.getColorForDepth(parent.depth)
                    metalness: 0.1
                    roughness: 0.8
                }
            }
        }
    }

    // Dikey X ekseni boyunca grid çizgileri
    Repeater {
        model: gridResolution + 1

        Node {
            property real linePos: -gridSize/2 + index * cellSize

            Model {
                source: "#Cube"
                position: Qt.vector3d(parent.linePos, -(minDepth + maxDepth) / 4, 0)
                scale: Qt.vector3d(1.5, (minDepth + maxDepth) / 2, gridSize + 2)

                materials: PrincipledMaterial {
                    baseColor: Qt.rgba(0.1, 0.1, 0.1, 1.0)
                    metalness: 0.3
                    roughness: 0.8
                }
            }
        }
    }

    // Dikey Z ekseni boyunca grid çizgileri
    Repeater {
        model: gridResolution + 1

        Node {
            property real linePos: -gridSize/2 + index * cellSize

            Model {
                source: "#Cube"
                position: Qt.vector3d(0, -(minDepth + maxDepth) / 4, parent.linePos)
                scale: Qt.vector3d(gridSize + 2, (minDepth + maxDepth) / 2, 1.5)

                materials: PrincipledMaterial {
                    baseColor: Qt.rgba(0.1, 0.1, 0.1, 1.0)
                    metalness: 0.3
                    roughness: 0.8
                }
            }
        }
    }

    // Deniz seviyesi referans çerçevesi
    Repeater {
        model: 4

        Node {
            property real angle: index * 90 * Math.PI / 180
            property real offset: gridSize / 2

            Model {
                source: "#Cube"
                position: Qt.vector3d(
                    Math.cos(parent.angle) * parent.offset,
                    0,
                    Math.sin(parent.angle) * parent.offset
                )
                eulerRotation.y: index * 90
                scale: Qt.vector3d(gridSize, 2, 2)

                materials: PrincipledMaterial {
                    baseColor: Qt.rgba(0.0, 0.9, 1.0, 1.0)
                    metalness: 0.8
                    roughness: 0.2
                }
            }
        }
    }
}
