import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick.Controls
import ExcavatorUI_Qt3D

Rectangle {
    id: bathymetricMapRoot
    color: "#2a2a2a"

    // VRT yükleme durumu
    property bool vrtLoaded: false
    property string vrtPath: ""
    property int currentLOD: 0
    property point centerCoordinate: Qt.point(41.0082, 28.9784) // Istanbul default
    property real zoomLevel: 5.0

    // Tile management
    property int visibleTileGridSize: 4  // 4x4 visible tiles
    property var loadedTiles: ({})  // Dictionary of loaded tiles

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
            position: Qt.vector3d(0, 500, 800)
            eulerRotation.x: -30
            eulerRotation.y: 0
            clipNear: 1
            clipFar: 10000
            fieldOfView: 60

            // Kamera değiştiğinde tile'ları güncelle
            onPositionChanged: {
                updateVisibleTiles()
            }
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
            position: Qt.vector3d(0, 500, 0)
            brightness: 1.5
            ambientColor: Qt.rgba(0.3, 0.3, 0.3, 1.0)
        }

        // Batimetrik mesh container
        Node {
            id: bathymetricContainer

            // Tile'lar dinamik olarak bu container'a eklenecek
        }

        // Grid referans çizgileri
        Node {
            id: gridLines
            visible: true

            Component.onCompleted: {
                createGridLines()
            }

            function createGridLines() {
                var gridSize = 20
                var cellSize = 100
                var centerOffset = (gridSize * cellSize) / 2

                // Yatay çizgiler
                for (var i = 0; i <= gridSize; i++) {
                    var z = (i * cellSize) - centerOffset
                    Qt.createQmlObject(
                        'import QtQuick; import QtQuick3D; ' +
                        'Model { ' +
                        '    source: "#Cube"; ' +
                        '    position: Qt.vector3d(0, 0, ' + z + '); ' +
                        '    scale: Qt.vector3d(' + (gridSize * cellSize / 100) + ', 0.01, 0.01); ' +
                        '    materials: PrincipledMaterial { ' +
                        '        baseColor: "#404040"; ' +
                        '        roughness: 0.3; ' +
                        '        opacity: 0.3; ' +
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
                        '    position: Qt.vector3d(' + x + ', 0, 0); ' +
                        '    scale: Qt.vector3d(0.01, 0.01, ' + (gridSize * cellSize / 100) + '); ' +
                        '    materials: PrincipledMaterial { ' +
                        '        baseColor: "#404040"; ' +
                        '        roughness: 0.3; ' +
                        '        opacity: 0.3; ' +
                        '    } ' +
                        '}',
                        gridLines
                    )
                }
            }
        }
    }

    // Başlatma ve VRT yükleme
    Component.onCompleted: {
        initializeBathymetry()
    }

    function initializeBathymetry() {
        console.log("Initializing bathymetric data loader...")

        // Config dosyasından VRT path'i oku (şimdilik hardcoded)
        // Production'da: JSON config file okuyacak
        vrtPath = "/home/user/bathymetry/gebco_data/gebco_world_bathymetry.vrt"

        // VRT'yi yükle
        if (bathymetryLoader) {
            bathymetryLoader.vrtPath = vrtPath

            if (bathymetryLoader.loadVRT()) {
                vrtLoaded = true
                console.log("✓ VRT loaded successfully")
                console.log("  Geographic bounds:", bathymetryLoader.geoBounds)
                console.log("  Overview count:", bathymetryLoader.overviewCount)

                // İlk tile'ları yükle
                loadInitialTiles()
            } else {
                console.error("✗ Failed to load VRT:", vrtPath)
                showErrorMessage("Batimetrik veri yüklenemedi. Lütfen VRT dosya yolunu kontrol edin.")
            }
        } else {
            console.error("✗ bathymetryLoader not available")
            showErrorMessage("Batimetrik veri yükleyici kullanılamıyor.")
        }
    }

    function loadInitialTiles() {
        console.log("Loading initial tiles...")

        // Merkez koordinat etrafında tile'ları yükle
        var centerPixel = bathymetryLoader.geoToPixel(centerCoordinate.x, centerCoordinate.y, currentLOD)
        var tileSize = bathymetryLoader.tileSize

        var centerTileX = Math.floor(centerPixel.x / tileSize)
        var centerTileY = Math.floor(centerPixel.y / tileSize)

        var halfGrid = Math.floor(visibleTileGridSize / 2)

        for (var dy = -halfGrid; dy <= halfGrid; dy++) {
            for (var dx = -halfGrid; dx <= halfGrid; dx++) {
                var tileX = centerTileX + dx
                var tileY = centerTileY + dy

                if (tileX >= 0 && tileY >= 0) {
                    loadTile(tileX, tileY, currentLOD)
                }
            }
        }
    }

    function loadTile(tileX, tileY, lodLevel) {
        var tileKey = tileX + "_" + tileY + "_" + lodLevel

        // Zaten yüklü mü?
        if (loadedTiles[tileKey]) {
            return
        }

        console.log("Loading tile:", tileX, tileY, "LOD:", lodLevel)

        // Tile verisini yükle
        var tile = bathymetryLoader.loadTile(tileX, tileY, lodLevel)

        if (tile && tile.isValid) {
            // Tile mesh'i oluştur
            createTileMesh(tile)
            loadedTiles[tileKey] = tile
        } else {
            console.warn("Failed to load tile:", tileX, tileY)
        }
    }

    function createTileMesh(tile) {
        // Tile için basit bir görselleştirme oluştur
        // Gerçek implementasyonda: Custom geometry veya heightmap texture kullanılacak

        var tileSize = bathymetryLoader.tileSize
        var worldScale = 10.0  // Her piksel -> 10 3D birim

        // Tile'ın dünya pozisyonunu hesapla
        var worldX = tile.tileX * tileSize * worldScale
        var worldZ = tile.tileY * tileSize * worldScale

        // Ortalama derinliği hesapla (basit görselleştirme için)
        var avgDepth = 0
        var validCount = 0
        for (var i = 0; i < tile.depths.length; i++) {
            var depth = tile.depths[i]
            if (depth > -32768) {  // NO_DATA_VALUE değil
                avgDepth += depth
                validCount++
            }
        }

        if (validCount > 0) {
            avgDepth /= validCount
        }

        // Renk hesapla
        var color = getDepthColor(avgDepth)

        // Basit bir küp mesh oluştur (placeholder)
        // TODO: Gerçek heightmap mesh oluşturulacak
        var meshComponent = Qt.createQmlObject(
            'import QtQuick; import QtQuick3D; ' +
            'Model { ' +
            '    source: "#Cube"; ' +
            '    position: Qt.vector3d(' + worldX + ', ' + avgDepth + ', ' + worldZ + '); ' +
            '    scale: Qt.vector3d(' + (tileSize * worldScale / 100) + ', ' + (Math.abs(avgDepth) / 50) + ', ' + (tileSize * worldScale / 100) + '); ' +
            '    materials: PrincipledMaterial { ' +
            '        baseColor: "' + color + '"; ' +
            '        roughness: 0.7; ' +
            '        metalness: 0.2; ' +
            '    } ' +
            '}',
            bathymetricContainer
        )
    }

    function updateVisibleTiles() {
        // Kamera pozisyonuna göre görünür tile'ları güncelle
        // TODO: Viewport frustum culling
        // Şimdilik basit mesafe bazlı yükleme
    }

    function getDepthColor(depth) {
        // Derinliğe göre renk (GEBCO standartları)
        var absDepth = Math.abs(depth)

        if (absDepth < 5) {
            return "#90EE90"  // Shallow (açık yeşil)
        } else if (absDepth < 15) {
            return "#4DB8A8"  // Shallow-mid (yeşil-turkuaz)
        } else if (absDepth < 30) {
            return "#3EADC4"  // Mid (turkuaz)
        } else if (absDepth < 45) {
            return "#2E8BC0"  // Mid-deep (açık mavi)
        } else {
            return "#1F5F8B"  // Deep (koyu mavi)
        }
    }

    function showErrorMessage(message) {
        errorText.text = message
        errorPanel.visible = true
    }

    // Hata paneli
    Rectangle {
        id: errorPanel
        anchors.centerIn: parent
        width: 400
        height: 200
        color: "#ff5555"
        radius: 10
        visible: false
        z: 100

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                id: errorText
                color: "#ffffff"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                width: 360
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                text: "Tamam"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: errorPanel.visible = false
            }
        }
    }

    // Durum paneli (sol üst köşe)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 90
        anchors.leftMargin: 20
        width: statusColumn.width + 30
        height: statusColumn.height + 30
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: vrtLoaded ? "#00bcd4" : "#ff5555"
        border.width: 2
        z: 10

        Column {
            id: statusColumn
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "DURUM"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
            }

            Row {
                spacing: 10
                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: vrtLoaded ? "#00ff00" : "#ff0000"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: vrtLoaded ? "VRT Yüklü" : "VRT Yüklenemedi"
                    font.pixelSize: 11
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: "LOD: " + currentLOD
                font.pixelSize: 11
                color: "#ffffff"
            }

            Text {
                text: "Tiles: " + Object.keys(loadedTiles).length
                font.pixelSize: 11
                color: "#ffffff"
            }

            Text {
                text: bathymetryLoader ? bathymetryLoader.getCacheStats() : "N/A"
                font.pixelSize: 11
                color: "#ffffff"
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
                Text { text: "45m+ (Derin)"; font.pixelSize: 11; color: "#ffffff"; anchors.verticalCenter: parent.verticalCenter }
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
                text: "KONTROLLER"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "LOD -"
                    width: 60
                    height: 35
                    enabled: currentLOD > 0
                    onClicked: {
                        currentLOD--
                        loadedTiles = {}  // Clear tiles
                        clearContainer()
                        loadInitialTiles()
                    }
                }

                Text {
                    text: "LOD: " + currentLOD
                    color: "#ffffff"
                    font.pixelSize: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: 60
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "LOD +"
                    width: 60
                    height: 35
                    enabled: bathymetryLoader && currentLOD < bathymetryLoader.overviewCount
                    onClicked: {
                        currentLOD++
                        loadedTiles = {}
                        clearContainer()
                        loadInitialTiles()
                    }
                }
            }

            Button {
                text: "Yenile"
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    loadedTiles = {}
                    clearContainer()
                    loadInitialTiles()
                }
            }

            Button {
                text: "Cache Temizle"
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (bathymetryLoader) {
                        bathymetryLoader.clearCache()
                        console.log("Cache cleared")
                    }
                }
            }
        }
    }

    function clearContainer() {
        // Container'daki tüm child'ları temizle
        while (bathymetricContainer.children.length > 0) {
            bathymetricContainer.children[0].destroy()
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

            // Zoom level'ı güncelle
            var distance = Math.sqrt(
                camera.position.x * camera.position.x +
                camera.position.y * camera.position.y +
                camera.position.z * camera.position.z
            )

            zoomLevel = distance / 200.0

            // Limit
            if (distance < 200) {
                var scale = 200 / distance
                camera.position.x *= scale
                camera.position.y *= scale
                camera.position.z *= scale
            } else if (distance > 2000) {
                var scale = 2000 / distance
                camera.position.x *= scale
                camera.position.y *= scale
                camera.position.z *= scale
            }
        }
    }
}
