import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * Offline Map View - Shows only cached/downloaded tiles
 * Displays map tiles that have been previously downloaded for offline use
 */
Rectangle {
    id: offlineMapRoot
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    Behavior on color {
        ColorAnimation { duration: 300 }
    }

    // Excavator fixed position
    property real excavatorLat: 40.8078
    property real excavatorLon: 29.2936

    // Map view state
    property real centerLat: excavatorLat
    property real centerLon: excavatorLon
    property int zoomLevel: 12  // Kullanıcının mevcut tile zoom seviyesi
    property real tileSize: 256

    // Current center tile coordinates
    property int centerTileX: 0
    property int centerTileY: 0

    // Offset within the center tile
    property real offsetX: 0
    property real offsetY: 0

    // Grid dimensions
    property int gridWidth: 7
    property int gridHeight: 5

    // State management
    property bool isUpdating: false
    property bool isInitialized: false

    Component.onCompleted: {
        console.log("OfflineMapView loading...")
        initializeMap()
    }

    onWidthChanged: {
        if (width > 0 && height > 0 && !isInitialized) {
            initializeMap()
        }
    }

    function initializeMap() {
        if (width <= 0 || height <= 0) return

        console.log("Initializing offline map at", width, "x", height)
        isInitialized = true

        var tile = latLonToTile(centerLat, centerLon, zoomLevel)
        centerTileX = tile.x
        centerTileY = tile.y
        offsetX = 0
        offsetY = 0

        tileModel.clear()
        populateTileModel()
    }

    function latLonToTile(lat, lon, zoom) {
        var n = Math.pow(2, zoom)
        var x = Math.floor((lon + 180) / 360 * n)
        var latRad = lat * Math.PI / 180
        var y = Math.floor((1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI) / 2 * n)
        return { x: x, y: y }
    }

    function tileToLatLon(x, y, zoom) {
        var n = Math.pow(2, zoom)
        var lon = x / n * 360 - 180
        var lat = Math.atan(Math.sinh(Math.PI * (1 - 2 * y / n))) * 180 / Math.PI
        return { lat: lat, lon: lon }
    }

    function populateTileModel() {
        var maxTile = Math.pow(2, zoomLevel) - 1
        var halfW = Math.floor(gridWidth / 2)
        var halfH = Math.floor(gridHeight / 2)

        for (var dy = -halfH; dy <= halfH; dy++) {
            for (var dx = -halfW; dx <= halfW; dx++) {
                var tx = centerTileX + dx
                var ty = centerTileY + dy

                if (tx >= 0 && tx <= maxTile && ty >= 0 && ty <= maxTile) {
                    tileModel.append({
                        tileX: tx,
                        tileY: ty,
                        tileZ: zoomLevel,
                        gridX: dx,
                        gridY: dy
                    })
                }
            }
        }
    }

    function changeZoom(delta) {
        if (isUpdating) return

        var newZoom = zoomLevel + delta
        if (newZoom < 3 || newZoom > 18) return

        isUpdating = true

        var currentCenter = tileToLatLon(
            centerTileX + offsetX / tileSize,
            centerTileY + offsetY / tileSize,
            zoomLevel
        )

        zoomLevel = newZoom

        var newTile = latLonToTile(currentCenter.lat, currentCenter.lon, newZoom)
        centerTileX = newTile.x
        centerTileY = newTile.y
        offsetX = 0
        offsetY = 0

        tileModel.clear()
        rebuildTimer.start()
    }

    function goToLocation(lat, lon, zoom) {
        if (isUpdating) return

        isUpdating = true
        centerLat = lat
        centerLon = lon
        zoomLevel = zoom

        var tile = latLonToTile(lat, lon, zoom)
        centerTileX = tile.x
        centerTileY = tile.y
        offsetX = 0
        offsetY = 0

        tileModel.clear()
        rebuildTimer.start()
    }

    Timer {
        id: rebuildTimer
        interval: 150
        repeat: false
        onTriggered: {
            populateTileModel()
            isUpdating = false
        }
    }

    ListModel {
        id: tileModel
    }

    // Offline mode indicator background
    Rectangle {
        anchors.fill: parent
        color: "#0d0d0d"
    }

    // Map viewport
    Item {
        id: mapViewport
        anchors.fill: parent
        clip: true

        // Grid pattern background (shows where tiles are missing)
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = "#252525"
                ctx.lineWidth = 1

                var gridSize = 50
                for (var x = 0; x < width; x += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                for (var y = 0; y < height; y += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }

        // Tile container
        Item {
            id: tileContainer
            width: gridWidth * tileSize
            height: gridHeight * tileSize
            x: (parent.width - width) / 2 + offsetX
            y: (parent.height - height) / 2 + offsetY

            Repeater {
                model: tileModel

                Item {
                    required property int tileX
                    required property int tileY
                    required property int tileZ
                    required property int gridX
                    required property int gridY

                    x: (gridX + Math.floor(gridWidth / 2)) * tileSize
                    y: (gridY + Math.floor(gridHeight / 2)) * tileSize
                    width: tileSize
                    height: tileSize

                    // Check if tile is cached
                    property bool isCached: offlineTileManager ? offlineTileManager.isTileCached(tileZ, tileX, tileY) : false

                    // Cached tile image
                    Image {
                        anchors.fill: parent
                        source: parent.isCached ? "image://osmtiles/" + parent.tileZ + "/" + parent.tileX + "/" + parent.tileY : ""
                        visible: parent.isCached
                        asynchronous: true
                        cache: true
                        fillMode: Image.PreserveAspectFit
                    }

                    // Missing tile placeholder
                    Rectangle {
                        anchors.fill: parent
                        visible: !parent.isCached
                        color: "#1a1a1a"
                        border.color: "#333333"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "?"
                                font.pixelSize: 24
                                color: "#555555"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: qsTr("Not Downloaded")
                                font.pixelSize: 10
                                color: "#444444"
                            }
                        }
                    }
                }
            }
        }

        // Pan handling
        MouseArea {
            id: panArea
            anchors.fill: parent
            enabled: !isUpdating

            property real lastX: 0
            property real lastY: 0

            onPressed: (mouse) => {
                lastX = mouse.x
                lastY = mouse.y
            }

            onPositionChanged: (mouse) => {
                if (!pressed) return

                var dx = mouse.x - lastX
                var dy = mouse.y - lastY

                offsetX += dx
                offsetY += dy

                lastX = mouse.x
                lastY = mouse.y
            }

            onReleased: {
                var shiftX = Math.round(offsetX / tileSize)
                var shiftY = Math.round(offsetY / tileSize)

                if (Math.abs(shiftX) >= 1 || Math.abs(shiftY) >= 1) {
                    centerTileX -= shiftX
                    centerTileY -= shiftY

                    var maxTile = Math.pow(2, zoomLevel) - 1
                    centerTileX = Math.max(0, Math.min(maxTile, centerTileX))
                    centerTileY = Math.max(0, Math.min(maxTile, centerTileY))

                    offsetX = offsetX - shiftX * tileSize
                    offsetY = offsetY - shiftY * tileSize

                    tileModel.clear()
                    populateTileModel()
                }
            }

            onWheel: (wheel) => {
                if (isUpdating) return
                if (wheel.angleDelta.y > 0) {
                    changeZoom(1)
                } else if (wheel.angleDelta.y < 0) {
                    changeZoom(-1)
                }
            }
        }
    }

    // Excavator marker
    Rectangle {
        id: excavatorMarker
        width: 30
        height: 30
        radius: 15
        color: "#FF6B35"
        border.color: "#ffffff"
        border.width: 3
        z: 20
        visible: isInitialized

        x: {
            var excavatorTile = latLonToTile(excavatorLat, excavatorLon, zoomLevel)
            var tileDiffX = excavatorTile.x - centerTileX
            return mapViewport.width / 2 + tileDiffX * tileSize + offsetX - width / 2
        }
        y: {
            var excavatorTile = latLonToTile(excavatorLat, excavatorLon, zoomLevel)
            var tileDiffY = excavatorTile.y - centerTileY
            return mapViewport.height / 2 + tileDiffY * tileSize + offsetY - height / 2
        }

        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 5
            color: "#ffffff"
        }

        SequentialAnimation on scale {
            running: true
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.2; duration: 800 }
            NumberAnimation { from: 1.2; to: 1.0; duration: 800 }
        }
    }

    // Offline mode banner
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 35
        color: "#ff9800"
        z: 25

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "◉"
                font.pixelSize: 14
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: qsTr("OFFLINE MODE - Showing only downloaded maps")
                font.pixelSize: 12
                font.bold: true
                color: "#ffffff"
            }
        }
    }

    // Cache info panel (top-left)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 50
        anchors.leftMargin: 20
        width: cacheColumn.width + 30
        height: cacheColumn.height + 30
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: "#ff9800"
        border.width: 2
        z: 10

        Column {
            id: cacheColumn
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: qsTr("CACHE STATUS")
                font.pixelSize: 12
                font.bold: true
                color: "#ff9800"
            }

            Rectangle {
                width: 180
                height: 1
                color: "#404040"
            }

            Row {
                spacing: 5
                Text { text: qsTr("Size") + ":"; font.pixelSize: 11; color: "#ffffff"; width: 60 }
                Text {
                    text: offlineTileManager ? offlineTileManager.formatCacheSize() : "0 MB"
                    font.pixelSize: 11
                    color: "#00ff00"
                }
            }

            Row {
                spacing: 5
                Text { text: qsTr("Tiles") + ":"; font.pixelSize: 11; color: "#ffffff"; width: 60 }
                Text {
                    text: offlineTileManager ? offlineTileManager.cachedTileCount + " " + qsTr("pcs") : "0 " + qsTr("pcs")
                    font.pixelSize: 11
                    color: "#00ff00"
                }
            }

            Row {
                spacing: 5
                Text { text: "Zoom:"; font.pixelSize: 11; color: "#ffffff"; width: 60 }
                Text { text: zoomLevel; font.pixelSize: 11; color: "#00ff00" }
            }

            Rectangle {
                width: 180
                height: 1
                color: "#404040"
            }

            // Clear cache button
            Rectangle {
                width: 180
                height: 35
                radius: 5
                color: clearCacheArea.pressed ? "#c0392b" : (clearCacheArea.containsMouse ? "#e74c3c" : "#d32f2f")

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Clear Cache")
                    font.pixelSize: 11
                    font.bold: true
                    color: "#ffffff"
                }

                MouseArea {
                    id: clearCacheArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (offlineTileManager) {
                            offlineTileManager.clearCache()
                            tileModel.clear()
                            populateTileModel()
                        }
                    }
                }
            }
        }
    }

    // Control panel (bottom)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 15
        width: controlRow.width + 30
        height: controlRow.height + 20
        color: "#1a1a1a"
        opacity: 0.95
        radius: 25
        border.color: "#333333"
        border.width: 1
        z: 10

        Row {
            id: controlRow
            anchors.centerIn: parent
            spacing: 8

            // Zoom out
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: zoomOutArea.pressed ? "#333333" : "#252525"
                border.color: "#ff9800"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "-"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#ff9800"
                }

                MouseArea {
                    id: zoomOutArea
                    anchors.fill: parent
                    enabled: zoomLevel > 3 && !isUpdating
                    onClicked: changeZoom(-1)
                }
            }

            // Zoom indicator
            Rectangle {
                width: 50
                height: 44
                radius: 8
                color: "#252525"

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "ZOOM"
                        font.pixelSize: 8
                        color: "#666666"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: zoomLevel
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ff9800"
                    }
                }
            }

            // Zoom in
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: zoomInArea.pressed ? "#333333" : "#252525"
                border.color: "#ff9800"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#ff9800"
                }

                MouseArea {
                    id: zoomInArea
                    anchors.fill: parent
                    enabled: zoomLevel < 18 && !isUpdating
                    onClicked: changeZoom(1)
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 30
                color: "#404040"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Home button
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: homeArea.pressed ? "#FF6B35" : "#252525"
                border.color: "#FF6B35"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "⌂"
                    font.pixelSize: 20
                    color: "#FF6B35"
                }

                MouseArea {
                    id: homeArea
                    anchors.fill: parent
                    enabled: !isUpdating
                    onClicked: goToLocation(excavatorLat, excavatorLon, 12)
                }
            }
        }
    }

    // Help text
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 15
        width: helpText.width + 20
        height: helpText.height + 10
        radius: 5
        color: "#1a1a1a"
        opacity: 0.9
        z: 10

        Text {
            id: helpText
            anchors.centerIn: parent
            text: qsTr("Download regions from Online tab")
            font.pixelSize: 10
            color: "#888888"
        }
    }

    // Attribution
    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 5
        text: "© OpenStreetMap contributors"
        font.pixelSize: 8
        color: "#666666"
        z: 15
    }
}
