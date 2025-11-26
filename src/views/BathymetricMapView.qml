import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick.Controls
import QtQuick.Dialogs
import ExcavatorUI_Qt3D

Rectangle {
    id: bathymetricMapRoot
    color: "#2a2a2a"

    // GeoTIFF Loader instance
    GeoTIFFLoader {
        id: geoTiffLoader

        onLoadingProgress: function(percentage) {
            loadingProgressBar.value = percentage / 100.0
        }

        onLoadingFinished: function(success) {
            if (success) {
                console.log("GeoTIFF loaded successfully!")
                bathymetricContainer.refreshBathymetricData()
            } else {
                console.error("Failed to load GeoTIFF:", geoTiffLoader.errorMessage)
            }
        }
    }

    // Map Tile Manager instance
    MapTileManager {
        id: mapTileManager
    }

    // Excavator Tracker instance
    ExcavatorTracker {
        id: excavatorTracker
        gridSize: 16
        cellSize: 50

        onGridCellEntered: function(row, col) {
            console.log("Grid cell entered:", row, col)
            bathymetricContainer.highlightCell(row, col, true)
        }

        onGridCellExited: function(row, col) {
            console.log("Grid cell exited:", row, col)
            bathymetricContainer.highlightCell(row, col, false)
        }
    }

    // File Dialog for GeoTIFF selection
    FileDialog {
        id: fileDialog
        title: "GeoTIFF Dosyası Seç"
        nameFilters: ["GeoTIFF files (*.tif *.tiff)", "All files (*)"]
        onAccepted: {
            var filePath = fileDialog.selectedFile.toString()
            // file:// prefix'ini kaldır
            if (filePath.startsWith("file://")) {
                filePath = filePath.substring(7)
            }
            console.log("Selected GeoTIFF file:", filePath)
            geoTiffLoader.loadFile(filePath)
        }
    }

    View3D {
        id: view3D
        anchors.fill: parent
        anchors.topMargin: 60
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

        // Base layer (harita altlığı) - En altta
        Model {
            id: baseLayerPlane
            source: "#Rectangle"
            position: Qt.vector3d(0, -65, 0)  // Batimetrik verilerin altında
            eulerRotation.x: -90
            scale: Qt.vector3d(10, 10, 1)

            materials: PrincipledMaterial {
                baseColorMap: Texture {
                    source: mapTileManager.baseLayerTexture
                }
                roughness: 0.8
                metalness: 0.1
            }
        }

        // Ana batimetrik mesh container
        Node {
            id: bathymetricContainer

            property var gridModels: []  // Grid modellerini sakla

            // Batimetrik grid oluştur (dinamik)
            Component.onCompleted: {
                createBathymetricGrid()
            }

            // GeoTIFF yüklendiğinde verileri yenile
            function refreshBathymetricData() {
                console.log("Refreshing bathymetric data from GeoTIFF")
                clearGrid()
                createBathymetricGrid()
            }

            // Mevcut grid'i temizle
            function clearGrid() {
                for (var i = 0; i < gridModels.length; i++) {
                    gridModels[i].destroy()
                }
                gridModels = []
            }

            // Belirli bir hücreyi vurgula/vurgulamayı kaldır
            function highlightCell(row, col, highlight) {
                // Grid modellerinde ilgili hücreyi bul
                for (var i = 0; i < gridModels.length; i++) {
                    var model = gridModels[i]
                    if (model.gridRow === row && model.gridCol === col) {
                        model.isExcavating = highlight
                        console.log("Cell [" + row + "," + col + "] highlighted:", highlight)
                        break
                    }
                }
            }

            function createBathymetricGrid() {
                var gridSize = 16 // 16x16 grid
                var cellSize = 50
                var centerOffset = (gridSize * cellSize) / 2

                // GeoTIFF yüklü mü kontrol et
                var useGeoTIFF = geoTiffLoader.isLoaded

                console.log("Creating bathymetric grid, using GeoTIFF:", useGeoTIFF)

                // Her hücre için bir model oluştur
                for (var row = 0; row < gridSize; row++) {
                    for (var col = 0; col < gridSize; col++) {
                        // Pozisyon hesapla
                        var x = (col * cellSize) - centerOffset + cellSize/2
                        var z = (row * cellSize) - centerOffset + cellSize/2

                        var depth = 0
                        var normalizedDepth = 0

                        if (useGeoTIFF) {
                            // GeoTIFF'ten derinlik al
                            depth = geoTiffLoader.getDepthAt(col, row)
                            normalizedDepth = geoTiffLoader.normalizeDepth(depth)
                        } else {
                            // Varsayılan liman benzeri batimetri oluştur
                            var distFromCenter = Math.sqrt(
                                Math.pow((col - gridSize/2), 2) +
                                Math.pow((row - gridSize/2), 2)
                            )

                            var distFromLeftEdge = col
                            var distFromTopEdge = row
                            var shoreEffect = Math.min(distFromLeftEdge, distFromTopEdge) * 3

                            depth = -5 - (distFromCenter * 2) + shoreEffect
                            depth = Math.max(depth, -60)
                            depth = Math.min(depth, -2)

                            normalizedDepth = (depth + 60) / 58.0
                        }

                        // Renk hesapla (derinliğe göre)
                        var color = useGeoTIFF ? geoTiffLoader.getDepthColor(normalizedDepth) : getDepthColor(normalizedDepth)

                        // Model oluştur ve sakla (blinking animation ile)
                        var component = Qt.createQmlObject(
                            'import QtQuick; import QtQuick3D; ' +
                            'Model { ' +
                            '    property int gridRow: ' + row + '; ' +
                            '    property int gridCol: ' + col + '; ' +
                            '    property bool isExcavating: false; ' +
                            '    property color originalColor: "' + color + '"; ' +
                            '    property color highlightColor: "#FF5722"; ' +
                            '    source: "#Cube"; ' +
                            '    position: Qt.vector3d(' + x + ', ' + depth + ', ' + z + '); ' +
                            '    scale: Qt.vector3d(' + (cellSize/100) + ', ' + (Math.abs(depth)/10) + ', ' + (cellSize/100) + '); ' +
                            '    materials: PrincipledMaterial { ' +
                            '        id: cellMaterial; ' +
                            '        baseColor: originalColor; ' +
                            '        roughness: 0.7; ' +
                            '        metalness: 0.3; ' +
                            '    } ' +
                            '    SequentialAnimation on materials { ' +
                            '        running: isExcavating; ' +
                            '        loops: Animation.Infinite; ' +
                            '        PropertyAnimation { ' +
                            '            target: cellMaterial; ' +
                            '            property: "baseColor"; ' +
                            '            to: highlightColor; ' +
                            '            duration: 500; ' +
                            '        } ' +
                            '        PropertyAnimation { ' +
                            '            target: cellMaterial; ' +
                            '            property: "baseColor"; ' +
                            '            to: originalColor; ' +
                            '            duration: 500; ' +
                            '        } ' +
                            '    } ' +
                            '    onIsExcavatingChanged: { ' +
                            '        if (!isExcavating) { ' +
                            '            cellMaterial.baseColor = originalColor; ' +
                            '        } ' +
                            '    } ' +
                            '}',
                            bathymetricContainer
                        )

                        gridModels.push(component)
                    }
                }

                // Ekskavatör işareti ekle (dinamik pozisyon)
                var excavatorMarker = Qt.createQmlObject(
                    'import QtQuick; import QtQuick3D; ' +
                    'Model { ' +
                    '    id: excavatorMarkerModel; ' +
                    '    source: "#Cylinder"; ' +
                    '    position: excavatorTracker.bucketPosition; ' +
                    '    scale: Qt.vector3d(1.2, 0.4, 1.2); ' +
                    '    materials: PrincipledMaterial { ' +
                    '        baseColor: excavatorTracker.isExcavating ? "#FF5722" : "#FFA726"; ' +
                    '        roughness: 0.3; ' +
                    '        metalness: 0.6; ' +
                    '    } ' +
                    '    SequentialAnimation on scale { ' +
                    '        running: excavatorTracker.isExcavating; ' +
                    '        loops: Animation.Infinite; ' +
                    '        Vector3dAnimation { ' +
                    '            from: Qt.vector3d(1.2, 0.4, 1.2); ' +
                    '            to: Qt.vector3d(1.5, 0.5, 1.5); ' +
                    '            duration: 500; ' +
                    '        } ' +
                    '        Vector3dAnimation { ' +
                    '            from: Qt.vector3d(1.5, 0.5, 1.5); ' +
                    '            to: Qt.vector3d(1.2, 0.4, 1.2); ' +
                    '            duration: 500; ' +
                    '        } ' +
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
        color: "#1a1a1a"
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
        color: "#1a1a1a"
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

            Rectangle {
                width: 150
                height: 1
                color: "#404040"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "BATİMETRİK VERİ"
                font.pixelSize: 11
                font.bold: true
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: "GeoTIFF Yükle"
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    fileDialog.open()
                }
            }

            Text {
                text: geoTiffLoader.isLoaded ? "✓ Veri Yüklü" : "Varsayılan Veri"
                font.pixelSize: 10
                color: geoTiffLoader.isLoaded ? "#4CAF50" : "#FFA726"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: 150
                height: 1
                color: "#404040"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "KAZI TAKİBİ"
                font.pixelSize: 11
                font.bold: true
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Button {
                text: excavatorTracker.simulationMode ? "Simülasyonu Durdur" : "Simülasyon Başlat"
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (excavatorTracker.simulationMode) {
                        excavatorTracker.stopSimulation()
                    } else {
                        excavatorTracker.startSimulation()
                    }
                }
            }

            Text {
                text: "Grid: [" + excavatorTracker.currentGridRow + "," + excavatorTracker.currentGridCol + "]"
                font.pixelSize: 9
                color: "#ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: excavatorTracker.isExcavating ? "🔴 Kazı Yapılıyor" : "⚪ Bekleme"
                font.pixelSize: 10
                color: excavatorTracker.isExcavating ? "#FF5722" : "#9E9E9E"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Loading Progress Bar (üstte)
    Rectangle {
        id: loadingProgressContainer
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 70
        width: 300
        height: 60
        color: "#1a1a1a"
        radius: 10
        border.color: "#00bcd4"
        border.width: 2
        opacity: loadingProgressBar.value > 0 && loadingProgressBar.value < 1.0 ? 0.95 : 0
        visible: opacity > 0
        z: 20

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "GeoTIFF Yükleniyor..."
                font.pixelSize: 12
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ProgressBar {
                id: loadingProgressBar
                from: 0.0
                to: 1.0
                value: 0.0
                width: 250
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
        anchors.topMargin: 60
        anchors.rightMargin: 20
        width: 350
        height: 260
        color: "#1a1a1a"
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
