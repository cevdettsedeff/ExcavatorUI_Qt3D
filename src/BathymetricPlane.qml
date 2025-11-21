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

    Component.onCompleted: {
        createBathymetricGrid()
    }

    function createBathymetricGrid() {
        // Grid hücreleri oluştur
        var cellComponent = Qt.createComponent("qrc:/qt/qml/ExcavatorUI_Qt3D/BathymetricCell.qml")

        if (cellComponent.status === Component.Error) {
            console.log("Error loading component:", cellComponent.errorString())
            return
        }

        for (var i = 0; i < gridResolution; i++) {
            for (var j = 0; j < gridResolution; j++) {
                var posX = -gridSize/2 + i * cellSize + cellSize/2
                var posZ = -gridSize/2 + j * cellSize + cellSize/2
                var depth = getDepth(i, j)
                var color = getColorForDepth(depth)

                var cellObj = cellComponent.createObject(bathymetricPlaneRoot, {
                    "position": Qt.vector3d(posX, -depth/2, posZ),
                    "scale": Qt.vector3d(cellSize, depth, cellSize),
                    "cellColor": color
                })

                if (cellObj === null) {
                    console.log("Error creating object")
                }
            }
        }

        // Grid çizgileri X ekseni
        var lineComponent = Qt.createComponent("qrc:/qt/qml/ExcavatorUI_Qt3D/GridLine.qml")

        for (var k = 0; k <= gridResolution; k++) {
            var linePos = -gridSize/2 + k * cellSize

            // X ekseni çizgisi
            lineComponent.createObject(bathymetricPlaneRoot, {
                "position": Qt.vector3d(linePos, -(minDepth + maxDepth) / 4, 0),
                "scale": Qt.vector3d(1.5, (minDepth + maxDepth) / 2, gridSize + 2)
            })

            // Z ekseni çizgisi
            lineComponent.createObject(bathymetricPlaneRoot, {
                "position": Qt.vector3d(0, -(minDepth + maxDepth) / 4, linePos),
                "scale": Qt.vector3d(gridSize + 2, (minDepth + maxDepth) / 2, 1.5)
            })
        }

        // Deniz seviyesi çerçevesi
        var frameComponent = Qt.createComponent("qrc:/qt/qml/ExcavatorUI_Qt3D/SeaLevelFrame.qml")

        for (var m = 0; m < 4; m++) {
            var angle = m * 90 * Math.PI / 180
            var offset = gridSize / 2

            frameComponent.createObject(bathymetricPlaneRoot, {
                "position": Qt.vector3d(Math.cos(angle) * offset, 0, Math.sin(angle) * offset),
                "eulerRotation": Qt.vector3d(0, m * 90, 0),
                "scale": Qt.vector3d(gridSize, 2, 2)
            })
        }
    }
}
