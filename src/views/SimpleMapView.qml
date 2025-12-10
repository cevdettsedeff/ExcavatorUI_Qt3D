import QtQuick
import QtQuick.Controls

/**
 * Simple OpenStreetMap View - Top-down view
 * Uses virtual scrolling to handle large zoom levels efficiently
 */
Rectangle {
    id: simpleMapRoot
    color: "#E5E3DF"

    // Map state
    property real centerLat: 40.8078  // Tuzla Limanı (Port)
    property real centerLon: 29.2936
    property int zoomLevel: 15
    property real tileSize: 256

    // Virtual scrolling - track the actual world position
    property real virtualCenterX: 0  // Center tile X coordinate (fractional)
    property real virtualCenterY: 0  // Center tile Y coordinate (fractional)

    // Tile loading
    property var loadedTiles: ({})
    property int maxCachedTiles: 100

    // OpenStreetMap tile URL template
    function getTileUrl(x, y, z) {
        // OSM tile servers (use responsibly, consider setting up your own tile server for production)
        var servers = ['a', 'b', 'c']
        var server = servers[Math.floor(Math.random() * servers.length)]
        return "https://" + server + ".tile.openstreetmap.org/" + z + "/" + x + "/" + y + ".png"
    }

    // Convert lat/lon to tile coordinates
    function latLonToTile(lat, lon, zoom) {
        var n = Math.pow(2, zoom)
        var x = Math.floor((lon + 180) / 360 * n)
        var y = Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * n)
        return {x: x, y: y}
    }

    // Convert tile coordinates to lat/lon
    function tileToLatLon(x, y, zoom) {
        var n = Math.pow(2, zoom)
        var lon = x / n * 360 - 180
        var lat = Math.atan(Math.sinh(Math.PI * (1 - 2 * y / n))) * 180 / Math.PI
        return {lat: lat, lon: lon}
    }

    // Map container with virtual scrolling
    Item {
        id: mapViewport
        anchors.fill: parent
        clip: true

        property bool initialized: false
        property bool updating: false

        // Drag handling
        property real dragStartX: 0
        property real dragStartY: 0
        property real dragStartVirtualX: 0
        property real dragStartVirtualY: 0

        // Initialize map when size becomes available
        Component.onCompleted: {
            initTimer.start()
        }

        Timer {
            id: initTimer
            interval: 100
            repeat: false
            onTriggered: {
                if (mapViewport.width > 0 && mapViewport.height > 0 && !mapViewport.initialized) {
                    mapViewport.initialized = true
                    console.log("Initializing map - Viewport:", mapViewport.width, "x", mapViewport.height)

                    // Calculate initial center position
                    var tile = latLonToTile(centerLat, centerLon, zoomLevel)
                    virtualCenterX = tile.x + 0.5  // Center of the tile
                    virtualCenterY = tile.y + 0.5

                    console.log("Initial virtual center:", virtualCenterX, virtualCenterY, "at zoom", zoomLevel)
                    loadVisibleTiles()
                }
            }
        }

        // Load tiles visible in current viewport
        function loadVisibleTiles() {
            if (width === 0 || height === 0) {
                console.log("loadVisibleTiles: Skipping - viewport not initialized")
                return
            }

            if (updating) {
                console.log("loadVisibleTiles: Skipping - update in progress")
                return
            }

            var tileBuffer = 2  // Load 2 extra tiles in each direction

            // Calculate visible tile range based on virtual center
            var tilesWide = Math.ceil(width / tileSize) + tileBuffer * 2
            var tilesHigh = Math.ceil(height / tileSize) + tileBuffer * 2

            var startX = Math.floor(virtualCenterX - tilesWide / 2)
            var endX = Math.ceil(virtualCenterX + tilesWide / 2)
            var startY = Math.floor(virtualCenterY - tilesHigh / 2)
            var endY = Math.ceil(virtualCenterY + tilesHigh / 2)

            var maxTiles = Math.pow(2, zoomLevel)

            console.log("Loading tiles: X:", startX, "-", endX, "Y:", startY, "-", endY,
                        "VirtualCenter:", virtualCenterX.toFixed(2), virtualCenterY.toFixed(2),
                        "Zoom:", zoomLevel)

            // Load all visible tiles
            var loadedCount = 0
            for (var ty = startY; ty <= endY; ty++) {
                for (var tx = startX; tx <= endX; tx++) {
                    if (tx >= 0 && ty >= 0 && tx < maxTiles && ty < maxTiles) {
                        tileGrid.createTile(tx, ty, zoomLevel)
                        loadedCount++
                    }
                }
            }
            console.log("Loaded", loadedCount, "tiles at zoom", zoomLevel)
        }

        // Tile container - positioned relative to viewport center
        Item {
            id: mapContainer
            // Size covers the visible area plus buffer
            width: parent.width + tileSize * 6
            height: parent.height + tileSize * 6
            x: -tileSize * 3
            y: -tileSize * 3

            // Tile grid container
            Item {
                id: tileGrid
                anchors.fill: parent

                function createTile(tileX, tileY, z) {
                    var tileKey = tileX + "_" + tileY + "_" + z

                    if (loadedTiles[tileKey]) {
                        // Update position of existing tile
                        updateTilePosition(loadedTiles[tileKey], tileX, tileY)
                        return
                    }

                    try {
                        var tileUrl = "image://osmtiles/" + z + "/" + tileX + "/" + tileY

                        var component = Qt.createQmlObject(
                            'import QtQuick; ' +
                            'Image { ' +
                            '    property int tileX: ' + tileX + '; ' +
                            '    property int tileY: ' + tileY + '; ' +
                            '    width: ' + tileSize + '; ' +
                            '    height: ' + tileSize + '; ' +
                            '    source: "' + tileUrl + '"; ' +
                            '    asynchronous: true; ' +
                            '    cache: true; ' +
                            '    fillMode: Image.PreserveAspectFit; ' +
                            '    onStatusChanged: { ' +
                            '        if (status === Image.Error) { ' +
                            '            console.warn("Failed to load tile: ' + tileKey + '"); ' +
                            '        } ' +
                            '    } ' +
                            '}',
                            tileGrid
                        )

                        // Position tile relative to virtual center
                        updateTilePosition(component, tileX, tileY)
                        loadedTiles[tileKey] = component
                    } catch (e) {
                        console.error("Failed to create tile", tileKey, ":", e)
                    }
                }

                function updateTilePosition(tile, tileX, tileY) {
                    // Calculate position relative to viewport center
                    var viewportCenterX = mapViewport.width / 2
                    var viewportCenterY = mapViewport.height / 2

                    // Offset from virtual center (in pixels)
                    var offsetX = (tileX - virtualCenterX) * tileSize
                    var offsetY = (tileY - virtualCenterY) * tileSize

                    // Position in mapContainer coordinates (which is offset by -tileSize*3)
                    tile.x = viewportCenterX + tileSize * 3 + offsetX
                    tile.y = viewportCenterY + tileSize * 3 + offsetY
                }

                function updateAllTilePositions() {
                    for (var key in loadedTiles) {
                        if (loadedTiles[key]) {
                            var tile = loadedTiles[key]
                            updateTilePosition(tile, tile.tileX, tile.tileY)
                        }
                    }
                }
            }
        }

        // Mouse handling for pan
        MouseArea {
            id: mapMouseArea
            anchors.fill: parent

            onPressed: (mouse) => {
                mapViewport.dragStartX = mouse.x
                mapViewport.dragStartY = mouse.y
                mapViewport.dragStartVirtualX = virtualCenterX
                mapViewport.dragStartVirtualY = virtualCenterY
            }

            onPositionChanged: (mouse) => {
                if (pressed && !mapViewport.updating) {
                    var deltaX = mouse.x - mapViewport.dragStartX
                    var deltaY = mouse.y - mapViewport.dragStartY

                    // Convert pixel delta to tile delta (negative because dragging right should move map left)
                    virtualCenterX = mapViewport.dragStartVirtualX - deltaX / tileSize
                    virtualCenterY = mapViewport.dragStartVirtualY - deltaY / tileSize

                    // Clamp to valid tile range
                    var maxTiles = Math.pow(2, zoomLevel)
                    virtualCenterX = Math.max(0, Math.min(maxTiles, virtualCenterX))
                    virtualCenterY = Math.max(0, Math.min(maxTiles, virtualCenterY))

                    // Update tile positions
                    tileGrid.updateAllTilePositions()
                }
            }

            onReleased: {
                // Load any new tiles that became visible
                Qt.callLater(mapViewport.loadVisibleTiles)
            }

            onWheel: (wheel) => {
                // Zoom with mouse wheel is handled by buttons for stability
            }
        }
    }

    // Center marker (excavator position) - positioned at fixed map coordinates
    Rectangle {
        id: centerMarker
        width: 30
        height: 30
        radius: 15
        color: "#FF6B35"
        border.color: "#ffffff"
        border.width: 3
        z: 20  // Above map tiles
        visible: mapViewport.initialized && !mapViewport.updating

        // Calculate position based on fixed map coordinates (centerLat, centerLon)
        x: {
            if (!mapViewport.initialized || mapViewport.updating) return mapViewport.width / 2 - width / 2
            var tile = latLonToTile(centerLat, centerLon, zoomLevel)
            var offsetX = (tile.x + 0.5 - virtualCenterX) * tileSize
            return mapViewport.width / 2 + offsetX - width / 2
        }

        y: {
            if (!mapViewport.initialized || mapViewport.updating) return mapViewport.height / 2 - height / 2
            var tile = latLonToTile(centerLat, centerLon, zoomLevel)
            var offsetY = (tile.y + 0.5 - virtualCenterY) * tileSize
            return mapViewport.height / 2 + offsetY - height / 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 5
            color: "#ffffff"
        }

        // Pulse animation
        SequentialAnimation on scale {
            running: true
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.2; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.2; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
        }
    }

    // Timer for safe zoom level changes
    Timer {
        id: zoomChangeTimer
        interval: 50
        repeat: false
        property int targetZoom: 15

        onTriggered: {
            console.log("Applying zoom change to:", targetZoom)
            applyZoomChange(targetZoom)
        }
    }

    // Timer for delayed tile loading after zoom
    Timer {
        id: tileLoadTimer
        interval: 100
        repeat: false

        onTriggered: {
            console.log("Loading new tiles after zoom...")
            mapViewport.updating = false
            mapViewport.loadVisibleTiles()
            console.log("Zoom update complete")
        }
    }

    // Safely change zoom level
    function changeZoomLevel(newZoom) {
        if (mapViewport.updating) {
            console.log("Update already in progress, skipping zoom change...")
            return
        }

        console.log("Requesting zoom change from", zoomLevel, "to", newZoom)
        mapViewport.updating = true
        zoomChangeTimer.targetZoom = newZoom
        zoomChangeTimer.start()
    }

    // Apply the zoom change
    function applyZoomChange(newZoom) {
        console.log("applyZoomChange: from", zoomLevel, "to", newZoom)

        // Get current center in lat/lon before zoom change
        var currentCenterLatLon = tileToLatLon(virtualCenterX, virtualCenterY, zoomLevel)
        console.log("Current center lat/lon:", currentCenterLatLon.lat.toFixed(6), currentCenterLatLon.lon.toFixed(6))

        // Clear old tiles first
        var clearedCount = 0
        for (var key in loadedTiles) {
            if (loadedTiles[key]) {
                try {
                    loadedTiles[key].destroy()
                    clearedCount++
                } catch (e) {
                    console.warn("Error destroying tile:", key, e)
                }
            }
        }
        loadedTiles = {}
        console.log("Cleared", clearedCount, "old tiles")

        // Update zoom level
        zoomLevel = newZoom

        // Recalculate virtual center for new zoom level
        var newTile = latLonToTile(currentCenterLatLon.lat, currentCenterLatLon.lon, newZoom)
        virtualCenterX = newTile.x + 0.5
        virtualCenterY = newTile.y + 0.5
        console.log("New virtual center:", virtualCenterX.toFixed(2), virtualCenterY.toFixed(2), "at zoom", newZoom)

        // Load new tiles with delay
        tileLoadTimer.start()
    }

    function updateMapTiles() {
        if (mapViewport.updating) {
            console.log("Update already in progress, skipping...")
            return
        }

        mapViewport.updating = true
        updateMapTilesInternal()
    }

    function updateMapTilesInternal() {
        console.log("updateMapTilesInternal: Centering on", centerLat, centerLon, "at zoom", zoomLevel)

        // Clear old tiles
        var clearedCount = 0
        for (var key in loadedTiles) {
            if (loadedTiles[key]) {
                try {
                    loadedTiles[key].destroy()
                    clearedCount++
                } catch (e) {
                    console.warn("Error destroying tile:", key, e)
                }
            }
        }
        loadedTiles = {}
        console.log("Cleared", clearedCount, "old tiles")

        // Recalculate virtual center
        var tile = latLonToTile(centerLat, centerLon, zoomLevel)
        virtualCenterX = tile.x + 0.5
        virtualCenterY = tile.y + 0.5
        console.log("Virtual center set to:", virtualCenterX.toFixed(2), virtualCenterY.toFixed(2))

        // Load new tiles with delay
        tileLoadTimer.start()
    }

    // Info panel (top-left)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 90  // Below the "Harita Görünümü" header (80px + 10px spacing)
        anchors.leftMargin: 20
        width: infoColumn.width + 30
        height: infoColumn.height + 30
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: "#00bcd4"
        border.width: 2
        z: 10

        Column {
            id: infoColumn
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "KONUM BİLGİSİ"
                font.pixelSize: 12
                font.bold: true
                color: "#00bcd4"
            }

            Row {
                spacing: 5
                Text { text: "Lat:"; font.pixelSize: 11; color: "#ffffff"; width: 40 }
                Text { text: centerLat.toFixed(6); font.pixelSize: 11; color: "#00ff00" }
            }

            Row {
                spacing: 5
                Text { text: "Lon:"; font.pixelSize: 11; color: "#ffffff"; width: 40 }
                Text { text: centerLon.toFixed(6); font.pixelSize: 11; color: "#00ff00" }
            }

            Row {
                spacing: 5
                Text { text: "Zoom:"; font.pixelSize: 11; color: "#ffffff"; width: 40 }
                Text { text: zoomLevel; font.pixelSize: 11; color: "#00ff00" }
            }

            Text {
                text: "📍 Tuzla Limanı, İstanbul"
                font.pixelSize: 10
                color: "#aaaaaa"
            }
        }
    }

    // Control panel (bottom)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: controlRow.width + 40
        height: controlRow.height + 30
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: "#404040"
        border.width: 2
        z: 10

        Row {
            id: controlRow
            anchors.centerIn: parent
            spacing: 15

            // Zoom controls
            Column {
                spacing: 5

                Button {
                    text: "+"
                    width: 50
                    height: 40
                    font.pixelSize: 20
                    font.bold: true
                    enabled: zoomLevel < 18 && !mapViewport.updating

                    onClicked: {
                        if (zoomLevel < 18 && !mapViewport.updating) {
                            changeZoomLevel(zoomLevel + 1)
                        }
                    }
                }

                Button {
                    text: "−"
                    width: 50
                    height: 40
                    font.pixelSize: 24
                    font.bold: true
                    enabled: zoomLevel > 3 && !mapViewport.updating

                    onClicked: {
                        if (zoomLevel > 3 && !mapViewport.updating) {
                            changeZoomLevel(zoomLevel - 1)
                        }
                    }
                }
            }

            // Reset button
            Button {
                text: "Merkeze Dön"
                width: 120
                height: 85
                anchors.verticalCenter: parent.verticalCenter
                enabled: !mapViewport.updating

                onClicked: {
                    if (!mapViewport.updating) {
                        updateMapTiles()
                    }
                }
            }

            // Location presets
            Column {
                spacing: 5

                Button {
                    text: "Tuzla Limanı"
                    width: 100
                    height: 40
                    enabled: !mapViewport.updating
                    onClicked: {
                        if (!mapViewport.updating) {
                            mapViewport.updating = true
                            centerLat = 40.8078
                            centerLon = 29.2936
                            zoomLevel = 15
                            updateMapTilesInternal()
                        }
                    }
                }

                Button {
                    text: "İstanbul"
                    width: 100
                    height: 40
                    enabled: !mapViewport.updating
                    onClicked: {
                        if (!mapViewport.updating) {
                            mapViewport.updating = true
                            centerLat = 41.0082
                            centerLon = 28.9784
                            zoomLevel = 13
                            updateMapTilesInternal()
                        }
                    }
                }
            }
        }
    }

    // Attribution (required by OSM)
    Text {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 5
        text: "© OpenStreetMap contributors"
        font.pixelSize: 8
        color: "#666666"
        z: 15
    }

    // Help text (top-right)
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 90  // Below the "Harita Görünümü" header (80px + 10px spacing)
        anchors.rightMargin: 20
        width: helpText.width + 20
        height: helpText.height + 20
        color: "#1a1a1a"
        opacity: 0.9
        radius: 5
        border.color: "#404040"
        border.width: 1
        z: 10

        Text {
            id: helpText
            anchors.centerIn: parent
            text: "🖱️ Sürükle: Kaydır\n🔍 Butonlar: Zoom"
            color: "#ffffff"
            font.pixelSize: 10
            lineHeight: 1.4
        }
    }
}
