import QtQuick
import QtQuick3D

Node {
    id: bathymetricPlaneRoot

    property real gridSize: 1000
    property int gridResolution: 15  // 15x15 grid (daha az obje)
    property real cellSize: gridSize / gridResolution
    property real minDepth: 20
    property real maxDepth: 60

    // Derinlik hesaplama
    function getDepth(x, z) {
        var wave1 = Math.sin(x * 0.5) * Math.cos(z * 0.4) * 15
        var wave2 = Math.sin(x * 0.3 + z * 0.3) * 10
        var noise = (Math.sin(x * 10 + z * 10) * 1000) % 5
        var totalDepth = minDepth + Math.abs(wave1 + wave2) + noise
        return Math.min(totalDepth, maxDepth)
    }

    // Renk hesaplama
    function getColorForDepth(depth) {
        var normalizedDepth = (depth - minDepth) / (maxDepth - minDepth)
        var gray = 0.7 - (normalizedDepth * 0.4)
        return Qt.rgba(gray, gray, gray + 0.05, 1.0)
    }

    // Ana deniz tabanı düzlemi
    Model {
        source: "#Rectangle"
        position: Qt.vector3d(0, -maxDepth - 5, 0)
        eulerRotation.x: -90
        scale: Qt.vector3d(gridSize / 100, gridSize / 100, 1)

        materials: PrincipledMaterial {
            baseColor: "#1a1a1a"
            roughness: 0.9
            metalness: 0.1
        }
    }

    // Grid hücreleri - JavaScript ile oluştur
    Component.onCompleted: {
        createGridCells()
    }

    function createGridCells() {
        for (var i = 0; i < gridResolution; i++) {
            for (var j = 0; j < gridResolution; j++) {
                var posX = -gridSize/2 + i * cellSize + cellSize/2
                var posZ = -gridSize/2 + j * cellSize + cellSize/2
                var depth = getDepth(i, j)
                var color = getColorForDepth(depth)

                // Küp oluştur
                var cubeComponent = Qt.createQmlObject(`
                    import QtQuick
                    import QtQuick3D
                    Model {
                        source: "#Cube"
                        position: Qt.vector3d(${posX}, ${-depth/2}, ${posZ})
                        scale: Qt.vector3d(${cellSize}, ${depth}, ${cellSize})
                        materials: PrincipledMaterial {
                            baseColor: "${color}"
                            roughness: 0.8
                            metalness: 0.1
                        }
                    }
                `, bathymetricPlaneRoot, "gridCell_" + i + "_" + j)
            }
        }

        // Grid çizgileri - X yönü
        for (var x = 0; x <= gridResolution; x++) {
            var lineX = -gridSize/2 + x * cellSize
            Qt.createQmlObject(`
                import QtQuick
                import QtQuick3D
                Model {
                    source: "#Cube"
                    position: Qt.vector3d(${lineX}, ${-maxDepth/2}, 0)
                    scale: Qt.vector3d(1, ${maxDepth}, ${gridSize})
                    materials: PrincipledMaterial {
                        baseColor: "#0a0a0a"
                        roughness: 0.8
                    }
                }
            `, bathymetricPlaneRoot, "lineX_" + x)
        }

        // Grid çizgileri - Z yönü
        for (var z = 0; z <= gridResolution; z++) {
            var lineZ = -gridSize/2 + z * cellSize
            Qt.createQmlObject(`
                import QtQuick
                import QtQuick3D
                Model {
                    source: "#Cube"
                    position: Qt.vector3d(0, ${-maxDepth/2}, ${lineZ})
                    scale: Qt.vector3d(${gridSize}, ${maxDepth}, 1)
                    materials: PrincipledMaterial {
                        baseColor: "#0a0a0a"
                        roughness: 0.8
                    }
                }
            `, bathymetricPlaneRoot, "lineZ_" + z)
        }
    }

    // Deniz seviyesi referans çerçevesi
    Model {
        source: "#Cube"
        position: Qt.vector3d(-gridSize/2, 0, 0)
        scale: Qt.vector3d(gridSize, 3, 3)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }

    Model {
        source: "#Cube"
        position: Qt.vector3d(gridSize/2, 0, 0)
        scale: Qt.vector3d(gridSize, 3, 3)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }

    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 0, -gridSize/2)
        scale: Qt.vector3d(3, 3, gridSize)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }

    Model {
        source: "#Cube"
        position: Qt.vector3d(0, 0, gridSize/2)
        scale: Qt.vector3d(3, 3, gridSize)
        materials: PrincipledMaterial {
            baseColor: "#00bcd4"
            roughness: 0.2
            metalness: 0.8
        }
    }
}
