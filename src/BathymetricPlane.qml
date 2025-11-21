import QtQuick
import QtQuick3D

Node {
    id: bathymetricPlaneRoot

    property real gridSize: 1000
    property int gridResolution: 20  // 20x20 grid hücreleri
    property real cellSize: gridSize / gridResolution
    property real maxDepth: 50  // Maksimum derinlik

    // Derinlik değeri hesaplama fonksiyonu (basit perlin-benzeri)
    function getDepth(x, z) {
        // Basit sinüs dalgaları ile derinlik varyasyonu
        var wave1 = Math.sin(x * 0.15) * Math.cos(z * 0.1) * 15
        var wave2 = Math.sin(x * 0.3 + z * 0.2) * 10
        var wave3 = Math.cos(x * 0.05) * Math.sin(z * 0.08) * 20

        // Rastgele varyasyon ekle
        var random = (Math.sin(x * 12.9898 + z * 78.233) * 43758.5453) % 1.0
        var noise = random * 8

        return -(wave1 + wave2 + wave3 + noise + 15)  // Negatif = aşağı (derin)
    }

    // Derinliğe göre renk hesaplama
    function getColorForDepth(depth) {
        var normalizedDepth = Math.abs(depth) / maxDepth
        var gray = 0.3 + (0.5 * (1.0 - normalizedDepth))  // Derin yerler daha koyu
        return Qt.rgba(gray, gray, gray + 0.05, 1.0)
    }

    // Izgara hücreleri
    Repeater {
        model: gridResolution * gridResolution

        Model {
            id: cell
            source: "#Cube"

            property int gridX: index % gridResolution
            property int gridZ: Math.floor(index / gridResolution)
            property real posX: -gridSize/2 + gridX * cellSize + cellSize/2
            property real posZ: -gridSize/2 + gridZ * cellSize + cellSize/2
            property real depth: bathymetricPlaneRoot.getDepth(gridX, gridZ)

            position: Qt.vector3d(posX, depth / 2, posZ)
            scale: Qt.vector3d(cellSize * 0.95, Math.abs(depth), cellSize * 0.95)

            materials: PrincipledMaterial {
                baseColor: bathymetricPlaneRoot.getColorForDepth(depth)
                metalness: 0.2
                roughness: 0.7

                // Izgara çizgileri için
                opacity: 1.0
            }
        }
    }

    // Izgara çizgileri (wireframe efekti için)
    Repeater {
        model: gridResolution + 1

        Model {
            source: "#Cube"
            property real linePos: -gridSize/2 + index * cellSize
            position: Qt.vector3d(linePos, -maxDepth/2, 0)
            scale: Qt.vector3d(1, maxDepth * 0.8, gridSize)

            materials: PrincipledMaterial {
                baseColor: Qt.rgba(0.15, 0.15, 0.15, 0.8)
                metalness: 0.5
                roughness: 0.5
                alphaMode: PrincipledMaterial.Blend
            }
        }
    }

    Repeater {
        model: gridResolution + 1

        Model {
            source: "#Cube"
            property real linePos: -gridSize/2 + index * cellSize
            position: Qt.vector3d(0, -maxDepth/2, linePos)
            scale: Qt.vector3d(gridSize, maxDepth * 0.8, 1)

            materials: PrincipledMaterial {
                baseColor: Qt.rgba(0.15, 0.15, 0.15, 0.8)
                metalness: 0.5
                roughness: 0.5
                alphaMode: PrincipledMaterial.Blend
            }
        }
    }

    // Deniz seviyesi referans düzlemi
    Model {
        source: "#Rectangle"
        position: Qt.vector3d(0, 0, 0)
        eulerRotation.x: -90
        scale: Qt.vector3d(gridSize / 100, gridSize / 100, 1)

        materials: PrincipledMaterial {
            baseColor: Qt.rgba(0.2, 0.4, 0.6, 0.3)
            metalness: 0.8
            roughness: 0.1
            alphaMode: PrincipledMaterial.Blend
        }
    }
}
