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

        // Center on initial position
        Component.onCompleted: {
            updateMapTiles()
            centerOnPosition()
        }

        function centerOnPosition() {
            var tile = latLonToTile(centerLat, centerLon, zoomLevel)
            var tilePx = tileSize * tile.x
            var tilePy = tileSize * tile.y

            contentX = tilePx - width / 2
            contentY = tilePy - height / 2
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

                Component.onCompleted: {
                    createVisibleTiles()
                }

                function createVisibleTiles() {
                    // Calculate visible tile range
                    var centerTile = latLonToTile(centerLat, centerLon, zoomLevel)
                    var tilesX = 3  // Show 3x3 grid of tiles
                    var tilesY = 3

                    for (var dy = -1; dy <= 1; dy++) {
                        for (var dx = -1; dx <= 1; dx++) {
                            var tx = centerTile.x + dx
                            var ty = centerTile.y + dy

                            if (tx >= 0 && ty >= 0 && tx < Math.pow(2, zoomLevel) && ty < Math.pow(2, zoomLevel)) {
                                createTile(tx, ty, zoomLevel)
                            }
                        }
                    }
                }

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

        // Recreate tiles
        tileGrid.createVisibleTiles()
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
