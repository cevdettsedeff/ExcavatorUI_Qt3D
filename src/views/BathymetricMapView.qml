import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick.Controls
import ExcavatorUI_Qt3D

Rectangle {
    id: bathymetricMapRoot
    color: "#2a2a2a"

    View3D {
        id: view3D
        anchors.fill: parent
        anchors.topMargin: 90
        anchors.bottomMargin: 20
        anchors.margins: 20

        environment: SceneEnvironment {
            clearColor: "#2a2a2a"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        // Kamera
        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(400, 300, 400)
            eulerRotation.x: -30
            eulerRotation.y: 45
            clipNear: 1
            clipFar: 5000
            fieldOfView: 60
        }

        // Işıklandırma
        DirectionalLight {
            eulerRotation.x: -45
            eulerRotation.y: -30
            brightness: 1.5
            castsShadow: false
        }

        DirectionalLight {
            eulerRotation.x: -20
            eulerRotation.y: 120
            brightness: 1.0
        }

        PointLight {
            position: Qt.vector3d(0, 300, 0)
            brightness: 1.5
            ambientColor: Qt.rgba(0.3, 0.3, 0.3, 1.0)
        }

        // Ana batimetrik mesh container
        Node {
            id: bathymetricContainer

            // Batimetrik grid oluştur (dinamik)
            Component.onCompleted: {
                createBathymetricGrid()
            }

            function createBathymetricGrid() {
                var gridSize = 16 // 16x16 grid
                var cellSize = 50
                var centerOffset = (gridSize * cellSize) / 2

                // Her hücre için bir model oluştur
                for (var row = 0; row < gridSize; row++) {
                    for (var col = 0; col < gridSize; col++) {
                        // Pozisyon hesapla
                        var x = (col * cellSize) - centerOffset + cellSize/2
                        var z = (row * cellSize) - centerOffset + cellSize/2

                        // Liman benzeri batimetri oluştur
                        // Merkeze yakın sığ, kenarlar derin
                        var distFromCenter = Math.sqrt(
                            Math.pow((col - gridSize/2), 2) +
                            Math.pow((row - gridSize/2), 2)
                        )

                        // Liman kıyı etkisi için sol ve üst kenarlara yakınlaştır
                        var distFromLeftEdge = col
                        var distFromTopEdge = row
                        var shoreEffect = Math.min(distFromLeftEdge, distFromTopEdge) * 3

                        // Derinlik hesapla (sığdan derine)
                        var depth = -5 - (distFromCenter * 2) + shoreEffect
                        depth = Math.max(depth, -60) // Maksimum derinlik -60
                        depth = Math.min(depth, -2)  // Minimum derinlik -2

                        // Renk hesapla (derinliğe göre)
                        var normalizedDepth = (depth + 60) / 58.0 // 0-1 arası
                        var color = getDepthColor(normalizedDepth)

                        // Model oluştur
                        var component = Qt.createQmlObject(
                            'import QtQuick; import QtQuick3D; ' +
                            'Model { ' +
                            '    source: "#Cube"; ' +
                            '    position: Qt.vector3d(' + x + ', ' + depth + ', ' + z + '); ' +
                            '    scale: Qt.vector3d(' + (cellSize/100) + ', ' + (Math.abs(depth)/10) + ', ' + (cellSize/100) + '); ' +
                            '    materials: PrincipledMaterial { ' +
                            '        baseColor: "' + color + '"; ' +
                            '        roughness: 0.7; ' +
                            '        metalness: 0.3; ' +
                            '    } ' +
                            '}',
                            bathymetricContainer
                        )
                    }
                }

                // Ekskavatör işareti ekle
                var excavatorMarker = Qt.createQmlObject(
                    'import QtQuick; import QtQuick3D; ' +
                    'Model { ' +
                    '    source: "#Cylinder"; ' +
                    '    position: Qt.vector3d(150, 5, 100); ' +
                    '    scale: Qt.vector3d(1.2, 0.4, 1.2); ' +
                    '    materials: PrincipledMaterial { ' +
                    '        baseColor: "#FF5722"; ' +
                    '        roughness: 0.3; ' +
                    '        metalness: 0.6; ' +
                    '    } ' +
                    '}',
                    bathymetricContainer
                )
            }

            function getDepthColor(normalized) {
                // Renk gradyanı: sığ (açık yeşil) -> orta (turkuaz) -> derin (koyu mavi)
                if (normalized > 0.7) {
                    return "#90EE90" // Açık yeşil (sığ)
                } else if (normalized > 0.5) {
                    return "#4DB8A8" // Yeşil-turkuaz
                } else if (normalized > 0.35) {
                    return "#3EADC4" // Turkuaz
                } else if (normalized > 0.2) {
                    return "#2E8BC0" // Açık mavi
                } else {
                    return "#1F5F8B" // Koyu mavi (derin)
                }
            }
        }

        // Grid çizgileri için ince wireframe
        Node {
            id: gridLines

            Component.onCompleted: {
                var gridSize = 32  // Daha küçük ızgaralar için artırıldı
                var cellSize = 25  // Hücre boyutu küçültüldü
                var centerOffset = (gridSize * cellSize) / 2

                // Yatay çizgiler
                for (var i = 0; i <= gridSize; i++) {
                    var z = (i * cellSize) - centerOffset
                    Qt.createQmlObject(
                        'import QtQuick; import QtQuick3D; ' +
                        'Model { ' +
                        '    source: "#Cube"; ' +
                        '    position: Qt.vector3d(0, 1, ' + z + '); ' +
                        '    scale: Qt.vector3d(' + (gridSize * cellSize / 100) + ', 0.005, 0.005); ' +
                        '    materials: PrincipledMaterial { ' +
                        '        baseColor: "#404040"; ' +
                        '        roughness: 0.3; ' +
                        '        opacity: 0.4; ' +
                        '    } ' +
                        '}',
                        gridLines
                    )
                }

                // Dikey çizgiler
                for (var j = 0; j <= gridSize; j++) {
                    var x = (j * cellSize) - centerOffset
                    Qt.createQmlObject(
                        'import QtQuick; import QtQuick3D; ' +
                        'Model { ' +
                        '    source: "#Cube"; ' +
                        '    position: Qt.vector3d(' + x + ', 1, 0); ' +
                        '    scale: Qt.vector3d(0.005, 0.005, ' + (gridSize * cellSize / 100) + '); ' +
                        '    materials: PrincipledMaterial { ' +
                        '        baseColor: "#404040"; ' +
                        '        roughness: 0.3; ' +
                        '        opacity: 0.4; ' +
                        '    } ' +
                        '}',
                        gridLines
                    )
                }
            }
        }
    }

    // Derinlik lejantı (sağ alt köşe)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 30
        anchors.rightMargin: 30
        width: 200
        height: legendColumn.height + 30
        color: "#2d3748"
        opacity: 0.95
        radius: 10
        border.color: "#404040"
        border.width: 2
        z: 10

        Column {
            id: legendColumn
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "DERİNLİK LEJANTİ"
                font.pixelSize: 12
                font.bold: true
                color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: 160
                height: 1
                color: "#404040"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 10
                Rectangle { width: 20; height: 20; color: "#90EE90"; radius: 3 }
                Text { text: "0-5m (Sığ)"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 10
                Rectangle { width: 20; height: 20; color: "#4DB8A8"; radius: 3 }
                Text { text: "5-15m"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 10
                Rectangle { width: 20; height: 20; color: "#3EADC4"; radius: 3 }
                Text { text: "15-30m"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 10
                Rectangle { width: 20; height: 20; color: "#2E8BC0"; radius: 3 }
                Text { text: "30-45m"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                spacing: 10
                Rectangle { width: 20; height: 20; color: "#1F5F8B"; radius: 3 }
                Text { text: "45-60m (Derin)"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
            }

            Rectangle {
                width: 160
                height: 1
                color: "#404040"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 10
                Rectangle { width: 20; height: 20; color: "#FF5722"; radius: 3 }
                Text { text: "Ekskavatör"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }

    // Kontrol paneli (sol alt köşe)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 30
        anchors.leftMargin: 30
        width: controlColumn.width + 30
        height: controlColumn.height + 30
        color: "#2d3748"
        opacity: 0.95
        radius: 10
        border.color: "#404040"
        border.width: 2
        z: 10

        Column {
            id: controlColumn
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "KAMERA KONTROL"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "◄"
                    width: 40
                    height: 40
                    font.pixelSize: 16
                    onClicked: {
                        camera.eulerRotation.y -= 15
                    }
                }

                Button {
                    text: "►"
                    width: 40
                    height: 40
                    font.pixelSize: 16
                    onClicked: {
                        camera.eulerRotation.y += 15
                    }
                }
            }

            Button {
                text: "Varsayılan Görünüm"
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    camera.position = Qt.vector3d(400, 300, 400)
                    camera.eulerRotation.x = -30
                    camera.eulerRotation.y = 45
                }
            }
        }
    }

    // Mouse ile kamera kontrolü
    MouseArea {
        anchors.fill: view3D
        property real lastX: 0
        property real lastY: 0

        onPressed: (mouse) => {
            lastX = mouse.x
            lastY = mouse.y
        }

        onPositionChanged: (mouse) => {
            if (pressed) {
                var deltaX = mouse.x - lastX
                var deltaY = mouse.y - lastY

                camera.eulerRotation.y += deltaX * 0.3
                camera.eulerRotation.x += deltaY * 0.3
                camera.eulerRotation.x = Math.max(-80, Math.min(-5, camera.eulerRotation.x))

                lastX = mouse.x
                lastY = mouse.y
            }
        }

        onWheel: (wheel) => {
            var delta = wheel.angleDelta.y / 120
            var zoomFactor = 1.0 - (delta * 0.1)

            camera.position.x *= zoomFactor
            camera.position.y *= zoomFactor
            camera.position.z *= zoomFactor

            // Minimum ve maksimum zoom limitleri
            var distance = Math.sqrt(
                camera.position.x * camera.position.x +
                camera.position.y * camera.position.y +
                camera.position.z * camera.position.z
            )

            if (distance < 200) {
                var scale = 200 / distance
                camera.position.x *= scale
                camera.position.y *= scale
                camera.position.z *= scale
            } else if (distance > 1000) {
                var scale = 1000 / distance
                camera.position.x *= scale
                camera.position.y *= scale
                camera.position.z *= scale
            }
        }
    }

    // Üstten Görünüm Paneli (sağ üst köşe)
    Rectangle {
        id: topViewPanel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 90
        anchors.rightMargin: 20
        width: 350
        height: 260
        color: "#2d3748"
        radius: 10
        border.color: "#00bcd4"
        border.width: 2
        opacity: 0.95
        z: 15

        // Başlık
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: "#0d0d0d"
            radius: 10

            Text {
                anchors.centerIn: parent
                text: "Üstten Görünüm"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
            }
        }

        // 3D Görünüm - Üstten (Batimetrik Harita)
        View3D {
            id: topView3D
            anchors.fill: parent
            anchors.topMargin: 30
            anchors.bottomMargin: 35
            anchors.margins: 5

            environment: SceneEnvironment {
                clearColor: "#2a2a2a"
                backgroundMode: SceneEnvironment.Color
                antialiasingMode: SceneEnvironment.MSAA
                antialiasingQuality: SceneEnvironment.Medium
            }

            // Üstten kamera
            PerspectiveCamera {
                id: topViewCamera
                position: Qt.vector3d(0, topViewZoomSlider.value, 0)
                eulerRotation.x: -90
                clipNear: 1
                clipFar: 2000
            }

            DirectionalLight {
                eulerRotation.x: -90
                brightness: 2.0
            }

            // Batimetrik mesh container (mini)
            Node {
                id: bathymetricContainerMini

                Component.onCompleted: {
                    var gridSize = 16
                    var cellSize = 50
                    var centerOffset = (gridSize * cellSize) / 2

                    for (var row = 0; row < gridSize; row++) {
                        for (var col = 0; col < gridSize; col++) {
                            var x = (col * cellSize) - centerOffset + cellSize/2
                            var z = (row * cellSize) - centerOffset + cellSize/2

                            var distFromCenter = Math.sqrt(
                                Math.pow((col - gridSize/2), 2) +
                                Math.pow((row - gridSize/2), 2)
                            )

                            var distFromLeftEdge = col
                            var distFromTopEdge = row
                            var shoreEffect = Math.min(distFromLeftEdge, distFromTopEdge) * 3

                            var depth = -5 - (distFromCenter * 2) + shoreEffect
                            depth = Math.max(depth, -60)
                            depth = Math.min(depth, -2)

                            var normalizedDepth = (depth + 60) / 58.0
                            var color = getDepthColorMini(normalizedDepth)

                            var component = Qt.createQmlObject(
                                'import QtQuick; import QtQuick3D; ' +
                                'Model { ' +
                                '    source: "#Cube"; ' +
                                '    position: Qt.vector3d(' + x + ', ' + depth + ', ' + z + '); ' +
                                '    scale: Qt.vector3d(' + (cellSize/100) + ', ' + (Math.abs(depth)/10) + ', ' + (cellSize/100) + '); ' +
                                '    materials: PrincipledMaterial { ' +
                                '        baseColor: "' + color + '"; ' +
                                '        roughness: 0.7; ' +
                                '        metalness: 0.3; ' +
                                '    } ' +
                                '}',
                                bathymetricContainerMini
                            )
                        }
                    }

                    // Ekskavatör işareti
                    var excavatorMarker = Qt.createQmlObject(
                        'import QtQuick; import QtQuick3D; ' +
                        'Model { ' +
                        '    source: "#Cylinder"; ' +
                        '    position: Qt.vector3d(150, 5, 100); ' +
                        '    scale: Qt.vector3d(1.2, 0.4, 1.2); ' +
                        '    materials: PrincipledMaterial { ' +
                        '        baseColor: "#FF5722"; ' +
                        '        roughness: 0.3; ' +
                        '        metalness: 0.6; ' +
                        '    } ' +
                        '}',
                        bathymetricContainerMini
                    )
                }

                function getDepthColorMini(normalized) {
                    if (normalized > 0.7) {
                        return "#90EE90"
                    } else if (normalized > 0.5) {
                        return "#4DB8A8"
                    } else if (normalized > 0.35) {
                        return "#3EADC4"
                    } else if (normalized > 0.2) {
                        return "#2E8BC0"
                    } else {
                        return "#1F5F8B"
                    }
                }
            }
        }

        // Zoom kontrolü - Üstten görünüm
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            height: 30
            color: "#0d0d0d"
            radius: 5
            opacity: 0.9

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "−"
                    font.pixelSize: 16
                    color: "#00bcd4"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: topViewZoomSlider
                    from: 600
                    to: 300
                    value: 450
                    width: 240
                    anchors.verticalCenter: parent.verticalCenter

                    background: Rectangle {
                        x: topViewZoomSlider.leftPadding
                        y: topViewZoomSlider.topPadding + topViewZoomSlider.availableHeight / 2 - height / 2
                        implicitWidth: 240
                        implicitHeight: 4
                        width: topViewZoomSlider.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#404040"

                        Rectangle {
                            width: topViewZoomSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#00bcd4"
                            radius: 2
                        }
                    }

                    handle: Rectangle {
                        x: topViewZoomSlider.leftPadding + topViewZoomSlider.visualPosition * (topViewZoomSlider.availableWidth - width)
                        y: topViewZoomSlider.topPadding + topViewZoomSlider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: topViewZoomSlider.pressed ? "#00e5ff" : "#00bcd4"
                        border.color: "#ffffff"
                        border.width: 2
                    }
                }

                Text {
                    text: "+"
                    font.pixelSize: 16
                    color: "#00bcd4"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
