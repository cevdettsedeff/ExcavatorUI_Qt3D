import QtQuick
import QtQuick.Controls

/**
 * Simple OpenStreetMap View - Top-down view
 * No dependencies required, works out of the box
 */
Rectangle {
    id: simpleMapRoot
    color: "#E5E3DF"

    // Map state
    property real centerLat: 40.8078  // Tuzla Limanı (Port)
    property real centerLon: 29.2936
    property int zoomLevel: 15
    property real tileSize: 256

    // Tile loading
    property var loadedTiles: ({})
    property int maxCachedTiles: 50

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

    // Map canvas
    Flickable {
        id: mapFlickable
        anchors.fill: parent

        contentWidth: mapContainer.width
        contentHeight: mapContainer.height
        clip: true

        // Load more tiles when user pans the map
        onContentXChanged: loadVisibleTiles()
        onContentYChanged: loadVisibleTiles()

        // Center on initial position
        Component.onCompleted: {
            // Delay initial load to ensure width/height are properly set
            initTimer.start()
        }

        Timer {
            id: initTimer
            interval: 100
            repeat: false
            onTriggered: {
                centerOnPosition()
                loadVisibleTiles()
            }
        }

        function centerOnPosition() {
            var tile = latLonToTile(centerLat, centerLon, zoomLevel)
            var tilePx = tileSize * tile.x
            var tilePy = tileSize * tile.y

            contentX = tilePx - width / 2
            contentY = tilePy - height / 2
        }

        // Load tiles visible in current viewport
        function loadVisibleTiles() {
            if (width === 0 || height === 0) {
                return  // Not initialized yet
            }

            var tileBuffer = 3  // Load 3 extra tiles in each direction

            // Calculate visible tile range based on viewport position
            var startX = Math.floor(contentX / tileSize) - tileBuffer
            var endX = Math.ceil((contentX + width) / tileSize) + tileBuffer
            var startY = Math.floor(contentY / tileSize) - tileBuffer
            var endY = Math.ceil((contentY + height) / tileSize) + tileBuffer

            var maxTiles = Math.pow(2, zoomLevel)

            console.log("Loading tiles:", "X:", startX, "-", endX, "Y:", startY, "-", endY, "ViewportW:", width, "ViewportH:", height)

            // Load all visible tiles
            for (var ty = startY; ty <= endY; ty++) {
                for (var tx = startX; tx <= endX; tx++) {
                    if (tx >= 0 && ty >= 0 && tx < maxTiles && ty < maxTiles) {
                        tileGrid.createTile(tx, ty, zoomLevel)
                    }
                }
            }
        }

        Rectangle {
            id: mapContainer
            width: tileSize * Math.pow(2, zoomLevel)
            height: tileSize * Math.pow(2, zoomLevel)
            color: "#E5E3DF"

            // Tile grid container
            Item {
                id: tileGrid
                anchors.fill: parent

                function createTile(x, y, z) {
                    var tileKey = x + "_" + y + "_" + z

                    if (loadedTiles[tileKey]) {
                        return  // Already loaded
                    }

                    // Use image provider with proper HTTP headers (complies with OSM policy)
                    var tileUrl = "image://osmtiles/" + z + "/" + x + "/" + y

                    var component = Qt.createQmlObject(
                        'import QtQuick; ' +
                        'Image { ' +
                        '    x: ' + (x * tileSize) + '; ' +
                        '    y: ' + (y * tileSize) + '; ' +
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

                    loadedTiles[tileKey] = component
                }
            }

        }

        // Scroll indicator
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
    }

    // Center marker (excavator position) - positioned at viewport center
    Rectangle {
        id: centerMarker
        width: 30
        height: 30
        radius: 15
        color: "#FF6B35"
        border.color: "#ffffff"
        border.width: 3

        // Always at the center of the visible viewport
        anchors.centerIn: mapFlickable
        z: 20  // Above map tiles

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

    function updateMapTiles() {
        // Clear old tiles
        for (var key in loadedTiles) {
            if (loadedTiles[key]) {
                loadedTiles[key].destroy()
            }
        }
        loadedTiles = {}

        // Reload visible tiles
        mapFlickable.loadVisibleTiles()
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
                    enabled: zoomLevel < 18

                    onClicked: {
                        if (zoomLevel < 18) {
                            zoomLevel++
                            updateMapTiles()
                            mapFlickable.centerOnPosition()
                        }
                    }
                }

                Button {
                    text: "−"
                    width: 50
                    height: 40
                    font.pixelSize: 24
                    font.bold: true
                    enabled: zoomLevel > 3

                    onClicked: {
                        if (zoomLevel > 3) {
                            zoomLevel--
                            updateMapTiles()
                            mapFlickable.centerOnPosition()
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

                onClicked: {
                    mapFlickable.centerOnPosition()
                }
            }

            // Location presets
            Column {
                spacing: 5

                Button {
                    text: "Tuzla Limanı"
                    width: 100
                    height: 40
                    onClicked: {
                        centerLat = 40.8078
                        centerLon = 29.2936
                        zoomLevel = 15
                        updateMapTiles()
                        mapFlickable.centerOnPosition()
                    }
                }

                Button {
                    text: "İstanbul"
                    width: 100
                    height: 40
                    onClicked: {
                        centerLat = 41.0082
                        centerLon = 28.9784
                        zoomLevel = 13
                        updateMapTiles()
                        mapFlickable.centerOnPosition()
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
