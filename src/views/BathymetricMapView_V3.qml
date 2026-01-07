import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick.Controls
import ExcavatorUI_Qt3D
import BathymetryComponents 1.0

/**
 * Enhanced Bathymetric Map View with:
 * - Real heightmap mesh rendering
 * - Asynchronous tile loading
 * - Config-driven settings
 * - Performance optimizations
 */
Rectangle {
    id: bathymetricMapRoot
    color: "#2a2a2a"

    // Configuration (loaded from config file)
    property string vrtPath: ""
    property int tileSize: 256
    property int cacheSize: 100
    property double verticalExaggeration: 2.0
    property bool gridVisible: true
    property bool legendVisible: true

    // Runtime state
    property bool vrtLoaded: false
    property int currentLOD: 0
    property point centerCoordinate: Qt.point(41.0082, 28.9784) // Istanbul default
    property real zoomLevel: 5.0
    property int gridResolution: 32  // Vertices per tile edge

    // Tile management
    property int visibleTileGridSize: 4  // 4x4 visible tiles
    property var loadedTiles: ({})      // Dictionary: "x_y_lod" -> true
    property var tileMeshes: ({})       // Dictionary: "x_y_lod" -> Model component
    property int loadingTileCount: 0

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

        // Camera
        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 500, 800)
            eulerRotation.x: -30
            eulerRotation.y: 0
            clipNear: 1
            clipFar: 10000
            fieldOfView: 60

            // Kamera değiştiğinde yavaşça tile'ları güncelle (debounced)
            onPositionChanged: {
                updateTimer.restart()
            }
        }

        // Lighting
        DirectionalLight {
            eulerRotation.x: -45
            eulerRotation.y: -30
            brightness: 1.5
            castsShadow: true
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

        // Bathymetric tile container
        Node {
            id: bathymetricContainer
            // Tile meshes will be added here dynamically
        }

        // Grid referans çizgileri
        Node {
            id: gridLines
            visible: gridVisible

            Component.onCompleted: {
                if (gridVisible) {
                    createGridLines()
                }
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

    // Debounced tile update timer
    Timer {
        id: updateTimer
        interval: 500  // 500ms debounce
        running: false
        repeat: false
        onTriggered: {
            updateVisibleTiles()
        }
    }

    // Component for tile mesh
    Component {
        id: tileMeshComponent

        Model {
            property var tileData: null
            property var meshGenerator: null

            geometry: BathymetricMeshGenerator {
                id: meshGen
                gridResolution: bathymetricMapRoot.gridResolution
                verticalScale: bathymetricMapRoot.verticalExaggeration
                horizontalScale: 10.0  // 10 units per pixel
            }

            materials: PrincipledMaterial {
                baseColor: parent.tileData ?
                    configManager.getDepthColor(calculateAverageDepth(parent.tileData.depths)) :
                    "#3EADC4"
                roughness: 0.7
                metalness: 0.2
            }

            Component.onCompleted: {
                if (tileData) {
                    meshGen.generateFromTile(tileData)
                }
                meshGenerator = meshGen
            }
        }
    }

    // Başlatma ve config yükleme
    Component.onCompleted: {
        loadConfiguration()
        initializeBathymetry()
    }

    function loadConfiguration() {
        console.log("Loading configuration...")

        if (configManager && configManager.isLoaded) {
            vrtPath = configManager.vrtPath
            tileSize = configManager.tileSize
            cacheSize = configManager.cacheSize
            currentLOD = configManager.defaultLOD
            verticalExaggeration = configManager.verticalExaggeration
            gridVisible = configManager.gridVisible
            legendVisible = configManager.legendVisible

            console.log("✓ Configuration loaded:")
            console.log("  VRT:", vrtPath)
            console.log("  Tile Size:", tileSize)
            console.log("  Cache Size:", cacheSize)
            console.log("  Vertical Exaggeration:", verticalExaggeration)
        } else {
            console.warn("Config not loaded, using defaults")
            vrtPath = "/home/user/bathymetry/gebco_data/gebco_world_bathymetry.vrt"
        }
    }

    function initializeBathymetry() {
        console.log("Initializing bathymetric data loader...")

        if (!bathymetryLoader) {
            showErrorMessage("bathymetryLoader kullanılamıyor")
            return
        }

        // VRT'yi yükle
        bathymetryLoader.vrtPath = vrtPath

        if (bathymetryLoader.loadVRT()) {
            vrtLoaded = true
            console.log("✓ VRT loaded successfully")
            console.log("  Geographic bounds:", bathymetryLoader.geoBounds)
            console.log("  Overview count:", bathymetryLoader.overviewCount)
            console.log("  Tile size:", bathymetryLoader.tileSize)

            // İlk tile'ları yükle
            loadInitialTiles()
        } else {
            console.error("✗ Failed to load VRT:", vrtPath)
            showErrorMessage("Batimetrik veri yüklenemedi.\n\nLütfen:\n1. GDAL'ın kurulu olduğundan emin olun\n2. VRT dosya yolunu kontrol edin: " + vrtPath + "\n3. GeoTIFF dosyalarının mevcut olduğunu kontrol edin")
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
                    loadTileAsync(tileX, tileY, currentLOD)
                }
            }
        }
    }

    function loadTileAsync(tileX, tileY, lodLevel) {
        var tileKey = tileX + "_" + tileY + "_" + lodLevel

        // Zaten yüklü veya yükleniyor mu?
        if (loadedTiles[tileKey]) {
            return
        }

        loadedTiles[tileKey] = true  // Mark as loading
        loadingTileCount++

        console.log("⏳ Queueing tile load:", tileX, tileY, "LOD:", lodLevel)

        // Asenkron yükleme (setTimeout ile simüle ediliyor)
        // Gerçek implementasyonda TileLoadTask kullanılacak
        setTimeout(function() {
            var tile = bathymetryLoader.loadTile(tileX, tileY, lodLevel)

            if (tile && tile.isValid) {
                console.log("✓ Tile loaded:", tileX, tileY)
                createTileMesh(tile, tileX, tileY, lodLevel)
            } else {
                console.warn("✗ Failed to load tile:", tileX, tileY)
                loadedTiles[tileKey] = false  // Mark as failed
            }

            loadingTileCount--
        }, Math.random() * 100) // Random delay to simulate async
    }

    function createTileMesh(tile, tileX, tileY, lodLevel) {
        var tileKey = tileX + "_" + tileY + "_" + lodLevel

        // Tile'ın dünya pozisyonunu hesapla
        var worldScale = 10.0  // Her piksel -> 10 3D birim
        var worldX = tileX * tileSize * worldScale
        var worldZ = tileY * tileSize * worldScale

        // Heightmap mesh oluştur
        var meshModel = tileMeshComponent.createObject(bathymetricContainer, {
            "tileData": tile,
            "position": Qt.vector3d(worldX, 0, worldZ)
        })

        if (meshModel) {
            tileMeshes[tileKey] = meshModel
            console.log("  ✓ Mesh created for tile", tileX, tileY)
        }
    }

    function updateVisibleTiles() {
        // TODO: Implement frustum culling and dynamic tile loading
        console.log("Updating visible tiles (TODO: implement frustum culling)")
    }

    function calculateAverageDepth(depths) {
        if (!depths || depths.length === 0) {
            return 0
        }

        var sum = 0
        var count = 0

        for (var i = 0; i < depths.length; i++) {
            var depth = depths[i]
            if (depth > -32000) {  // Skip NO_DATA
                sum += depth
                count++
            }
        }

        return count > 0 ? sum / count : 0
    }

    function showErrorMessage(message) {
        errorText.text = message
        errorPanel.visible = true
    }

    function clearAllTiles() {
        // Destroy all tile meshes
        for (var key in tileMeshes) {
            if (tileMeshes[key]) {
                tileMeshes[key].destroy()
            }
        }

        tileMeshes = {}
        loadedTiles = {}
        loadingTileCount = 0
    }

    // Hata paneli
    Rectangle {
        id: errorPanel
        anchors.centerIn: parent
        width: 450
        height: 250
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
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                width: 410
                horizontalAlignment: Text.AlignLeft
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
        color: "#2d3748"
        opacity: 0.95
        radius: 10
        border.color: vrtLoaded ? "#00bcd4" : "#ff5555"
        border.width: 2
        z: 10

        Column {
            id: statusColumn
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "DURUM"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
            }

            Row {
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: vrtLoaded ? "#00ff00" : "#ff0000"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: vrtLoaded ? "VRT Yüklü" : "VRT Yüklenemedi"
                    font.pixelSize: 10
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: "LOD: " + currentLOD
                font.pixelSize: 10
                color: "#ffffff"
            }

            Text {
                text: "Tiles: " + Object.keys(tileMeshes).length
                font.pixelSize: 10
                color: "#ffffff"
            }

            Text {
                text: "Loading: " + loadingTileCount
                font.pixelSize: 10
                color: loadingTileCount > 0 ? "#ffaa00" : "#00ff00"
            }

            Text {
                text: "Grid Res: " + gridResolution
                font.pixelSize: 10
                color: "#ffffff"
            }

            Text {
                text: "Vert Scale: " + verticalExaggeration.toFixed(1) + "x"
                font.pixelSize: 10
                color: "#ffffff"
            }

            Text {
                text: bathymetryLoader ? bathymetryLoader.getCacheStats() : "N/A"
                font.pixelSize: 10
                color: "#ffffff"
            }
        }
    }

    // Derinlik lejantı (sağ alt köşe)
    Rectangle {
        visible: legendVisible
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
                text: "KONTROLLER"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // LOD Control
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "LOD -"
                    width: 55
                    height: 32
                    enabled: currentLOD > 0
                    onClicked: {
                        currentLOD--
                        clearAllTiles()
                        loadInitialTiles()
                    }
                }

                Text {
                    text: "LOD: " + currentLOD
                    color: "#ffffff"
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                    width: 60
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "LOD +"
                    width: 55
                    height: 32
                    enabled: bathymetryLoader && currentLOD < bathymetryLoader.overviewCount
                    onClicked: {
                        currentLOD++
                        clearAllTiles()
                        loadInitialTiles()
                    }
                }
            }

            // Vertical Exaggeration
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "-"
                    width: 30
                    height: 28
                    enabled: verticalExaggeration > 0.5
                    onClicked: {
                        verticalExaggeration = Math.max(0.5, verticalExaggeration - 0.5)
                        clearAllTiles()
                        loadInitialTiles()
                    }
                }

                Text {
                    text: "V.Scale: " + verticalExaggeration.toFixed(1) + "x"
                    color: "#ffffff"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "+"
                    width: 30
                    height: 28
                    enabled: verticalExaggeration < 10.0
                    onClicked: {
                        verticalExaggeration = Math.min(10.0, verticalExaggeration + 0.5)
                        clearAllTiles()
                        loadInitialTiles()
                    }
                }
            }

            // Grid Resolution
            Row {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "-"
                    width: 30
                    height: 28
                    enabled: gridResolution > 8
                    onClicked: {
                        gridResolution = Math.max(8, gridResolution / 2)
                        clearAllTiles()
                        loadInitialTiles()
                    }
                }

                Text {
                    text: "Mesh: " + gridResolution + "x" + gridResolution
                    color: "#ffffff"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                    width: 100
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "+"
                    width: 30
                    height: 28
                    enabled: gridResolution < 128
                    onClicked: {
                        gridResolution = Math.min(128, gridResolution * 2)
                        clearAllTiles()
                        loadInitialTiles()
                    }
                }
            }

            Button {
                text: "Yenile"
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    clearAllTiles()
                    loadInitialTiles()
                }
            }

            Button {
                text: "Grid: " + (gridVisible ? "ON" : "OFF")
                width: 150
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    gridVisible = !gridVisible
                    gridLines.visible = gridVisible
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
            if (distance < 100) {
                var scale = 100 / distance
                camera.position.x *= scale
                camera.position.y *= scale
                camera.position.z *= scale
            } else if (distance > 3000) {
                var scale = 3000 / distance
                camera.position.x *= scale
                camera.position.y *= scale
                camera.position.z *= scale
            }
        }
    }
}
