import QtQuick
import QtQuick.Controls

/**
 * Simple OpenStreetMap View - Optimized version
 * Uses Repeater with limited tile count to prevent crashes
 */
Rectangle {
    id: simpleMapRoot
    color: "#87CEEB"  // Sky blue as fallback

    // Map state
    property real centerLat: 40.8078  // Tuzla Limanı
    property real centerLon: 29.2936
    property int zoomLevel: 15
    property real tileSize: 256

    // Current center tile coordinates
    property int centerTileX: 0
    property int centerTileY: 0

    // Offset within the center tile (for smooth panning)
    property real offsetX: 0
    property real offsetY: 0

    // Grid dimensions (odd numbers to have center tile)
    property int gridWidth: 7   // tiles horizontally
    property int gridHeight: 5  // tiles vertically

    // State management
    property bool isUpdating: false
    property bool isInitialized: false

    // Initialize on load
    Component.onCompleted: {
        console.log("SimpleMapView loading...")
        initializeMap()
    }

    // Also initialize when size changes (tab switching)
    onWidthChanged: {
        if (width > 0 && height > 0 && !isInitialized) {
            initializeMap()
        }
    }

    function initializeMap() {
        if (width <= 0 || height <= 0) {
            console.log("Waiting for valid size...")
            return
        }

        console.log("Initializing map at", width, "x", height)
        isInitialized = true

        // Calculate center tile from lat/lon
        var tile = latLonToTile(centerLat, centerLon, zoomLevel)
        centerTileX = tile.x
        centerTileY = tile.y
        offsetX = 0
        offsetY = 0

        console.log("Center tile:", centerTileX, centerTileY, "at zoom", zoomLevel)

        // Force model refresh
        tileModel.clear()
        populateTileModel()
    }

    // Convert lat/lon to tile coordinates
    function latLonToTile(lat, lon, zoom) {
        var n = Math.pow(2, zoom)
        var x = Math.floor((lon + 180) / 360 * n)
        var latRad = lat * Math.PI / 180
        var y = Math.floor((1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI) / 2 * n)
        return { x: x, y: y }
    }

    // Convert tile to lat/lon
    function tileToLatLon(x, y, zoom) {
        var n = Math.pow(2, zoom)
        var lon = x / n * 360 - 180
        var lat = Math.atan(Math.sinh(Math.PI * (1 - 2 * y / n))) * 180 / Math.PI
        return { lat: lat, lon: lon }
    }

    // Populate tile model with current visible tiles
    function populateTileModel() {
        var maxTile = Math.pow(2, zoomLevel) - 1
        var halfW = Math.floor(gridWidth / 2)
        var halfH = Math.floor(gridHeight / 2)

        console.log("Populating tiles around", centerTileX, centerTileY)

        for (var dy = -halfH; dy <= halfH; dy++) {
            for (var dx = -halfW; dx <= halfW; dx++) {
                var tx = centerTileX + dx
                var ty = centerTileY + dy

                // Clamp to valid range
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

        console.log("Added", tileModel.count, "tiles to model")
    }

    // Change zoom level safely
    function changeZoom(delta) {
        if (isUpdating) {
            console.log("Update in progress, skipping zoom")
            return
        }

        var newZoom = zoomLevel + delta
        if (newZoom < 3 || newZoom > 18) {
            console.log("Zoom out of range:", newZoom)
            return
        }

        console.log("Changing zoom from", zoomLevel, "to", newZoom)
        isUpdating = true

        // Get current center in lat/lon
        var currentCenter = tileToLatLon(
            centerTileX + offsetX / tileSize,
            centerTileY + offsetY / tileSize,
            zoomLevel
        )

        // Update zoom level
        zoomLevel = newZoom

        // Recalculate center tile for new zoom
        var newTile = latLonToTile(currentCenter.lat, currentCenter.lon, newZoom)
        centerTileX = newTile.x
        centerTileY = newTile.y
        offsetX = 0
        offsetY = 0

        // Rebuild tile model
        tileModel.clear()
        rebuildTimer.start()
    }

    // Go to specific location
    function goToLocation(lat, lon, zoom) {
        if (isUpdating) return

        console.log("Going to", lat, lon, "at zoom", zoom)
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

    // Timer for delayed tile rebuild (prevents rapid updates)
    Timer {
        id: rebuildTimer
        interval: 150
        repeat: false
        onTriggered: {
            populateTileModel()
            isUpdating = false
            console.log("Tile rebuild complete")
        }
    }

    // Tile data model
    ListModel {
        id: tileModel
    }

    // Map viewport
    Item {
        id: mapViewport
        anchors.fill: parent
        clip: true

        // Tile container - moves with panning
        Item {
            id: tileContainer
            width: gridWidth * tileSize
            height: gridHeight * tileSize

            // Center the container and apply offset
            x: (parent.width - width) / 2 + offsetX
            y: (parent.height - height) / 2 + offsetY

            // Tile repeater
            Repeater {
                model: tileModel

                Image {
                    required property int tileX
                    required property int tileY
                    required property int tileZ
                    required property int gridX
                    required property int gridY

                    x: (gridX + Math.floor(gridWidth / 2)) * tileSize
                    y: (gridY + Math.floor(gridHeight / 2)) * tileSize
                    width: tileSize
                    height: tileSize

                    source: "image://osmtiles/" + tileZ + "/" + tileX + "/" + tileY
                    asynchronous: true
                    cache: true
                    fillMode: Image.PreserveAspectFit

                    // Loading placeholder
                    Rectangle {
                        anchors.fill: parent
                        color: "#E5E3DF"
                        visible: parent.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "..."
                            color: "#999"
                            font.pixelSize: 14
                        }
                    }

                    onStatusChanged: {
                        if (status === Image.Error) {
                            console.warn("Tile load error:", tileX, tileY, tileZ)
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
                // Check if we need to shift tiles
                var shiftX = Math.round(offsetX / tileSize)
                var shiftY = Math.round(offsetY / tileSize)

                if (Math.abs(shiftX) >= 1 || Math.abs(shiftY) >= 1) {
                    // Update center tile
                    centerTileX -= shiftX
                    centerTileY -= shiftY

                    // Clamp to valid range
                    var maxTile = Math.pow(2, zoomLevel) - 1
                    centerTileX = Math.max(0, Math.min(maxTile, centerTileX))
                    centerTileY = Math.max(0, Math.min(maxTile, centerTileY))

                    // Keep remainder offset
                    offsetX = offsetX - shiftX * tileSize
                    offsetY = offsetY - shiftY * tileSize

                    // Rebuild tiles
                    tileModel.clear()
                    populateTileModel()
                }
            }
        }
    }

    // Center marker (excavator position)
    Rectangle {
        id: centerMarker
        width: 30
        height: 30
        radius: 15
        color: "#FF6B35"
        border.color: "#ffffff"
        border.width: 3
        z: 20
        visible: isInitialized

        // Position at the excavator's fixed location
        x: {
            var tile = latLonToTile(centerLat, centerLon, zoomLevel)
            var tileDiffX = tile.x - centerTileX
            return mapViewport.width / 2 + tileDiffX * tileSize + offsetX - width / 2
        }
        y: {
            var tile = latLonToTile(centerLat, centerLon, zoomLevel)
            var tileDiffY = tile.y - centerTileY
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

    // Loading indicator
    Rectangle {
        anchors.centerIn: parent
        width: 100
        height: 40
        radius: 5
        color: "#1a1a1a"
        opacity: 0.9
        visible: isUpdating
        z: 100

        Text {
            anchors.centerIn: parent
            text: "Yükleniyor..."
            color: "#00bcd4"
            font.pixelSize: 12
        }
    }

    // Info panel (top-left)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 90
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
                text: "Tuzla Limani, Istanbul"
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
                    enabled: zoomLevel < 18 && !isUpdating

                    onClicked: changeZoom(1)
                }

                Button {
                    text: "-"
                    width: 50
                    height: 40
                    font.pixelSize: 24
                    font.bold: true
                    enabled: zoomLevel > 3 && !isUpdating

                    onClicked: changeZoom(-1)
                }
            }

            // Reset button
            Button {
                text: "Merkeze Don"
                width: 120
                height: 85
                anchors.verticalCenter: parent.verticalCenter
                enabled: !isUpdating

                onClicked: goToLocation(40.8078, 29.2936, 15)
            }

            // Location presets
            Column {
                spacing: 5

                Button {
                    text: "Tuzla Limani"
                    width: 100
                    height: 40
                    enabled: !isUpdating
                    onClicked: goToLocation(40.8078, 29.2936, 15)
                }

                Button {
                    text: "Istanbul"
                    width: 100
                    height: 40
                    enabled: !isUpdating
                    onClicked: goToLocation(41.0082, 28.9784, 13)
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

    // Offline download panel (top-right)
    Rectangle {
        id: offlinePanel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 90
        anchors.rightMargin: 20
        width: 220
        height: offlinePanelExpanded ? offlineColumn.height + 30 : 45
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: "#ff9800"
        border.width: 2
        z: 10
        clip: true

        property bool offlinePanelExpanded: false

        Behavior on height {
            NumberAnimation { duration: 200 }
        }

        Column {
            id: offlineColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 8

            // Header (clickable to expand/collapse)
            Rectangle {
                width: parent.width
                height: 25
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: offlinePanel.offlinePanelExpanded = !offlinePanel.offlinePanelExpanded
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "OFFLINE HARITA"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ff9800"
                    }

                    Text {
                        text: offlinePanel.offlinePanelExpanded ? "▲" : "▼"
                        font.pixelSize: 10
                        color: "#ff9800"
                    }
                }
            }

            // Expanded content
            Column {
                width: parent.width
                spacing: 8
                visible: offlinePanel.offlinePanelExpanded
                opacity: offlinePanel.offlinePanelExpanded ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                // Cache info
                Rectangle {
                    width: parent.width
                    height: 35
                    color: "#252525"
                    radius: 5

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "Onbellek: " + (offlineTileManager ? offlineTileManager.formatCacheSize() : "0 MB")
                            font.pixelSize: 10
                            color: "#aaaaaa"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Radius selection
                Row {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Alan:"
                        font.pixelSize: 10
                        color: "#ffffff"
                        width: 35
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: radiusCombo
                        width: parent.width - 40
                        height: 30
                        model: ["1 km", "2 km", "5 km", "10 km"]
                        currentIndex: 1

                        property var radiusValues: [1, 2, 5, 10]
                        property real selectedRadius: radiusValues[currentIndex]
                    }
                }

                // Zoom range selection
                Row {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Zoom:"
                        font.pixelSize: 10
                        color: "#ffffff"
                        width: 35
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: zoomRangeCombo
                        width: parent.width - 40
                        height: 30
                        model: ["13-15 (Hizli)", "13-16 (Normal)", "13-17 (Detayli)", "13-18 (Maksimum)"]
                        currentIndex: 1

                        property var minZooms: [13, 13, 13, 13]
                        property var maxZooms: [15, 16, 17, 18]
                        property int selectedMinZoom: minZooms[currentIndex]
                        property int selectedMaxZoom: maxZooms[currentIndex]
                    }
                }

                // Estimated tile count
                Text {
                    width: parent.width
                    text: {
                        if (offlineTileManager) {
                            var count = offlineTileManager.estimateTileCount(
                                centerLat, centerLon,
                                radiusCombo.selectedRadius,
                                zoomRangeCombo.selectedMinZoom,
                                zoomRangeCombo.selectedMaxZoom
                            )
                            return "Tahmini: ~" + count + " tile"
                        }
                        return ""
                    }
                    font.pixelSize: 9
                    color: "#888888"
                    horizontalAlignment: Text.AlignCenter
                }

                // Progress bar (visible during download)
                Rectangle {
                    width: parent.width
                    height: 20
                    color: "#333333"
                    radius: 3
                    visible: offlineTileManager && offlineTileManager.isDownloading

                    Rectangle {
                        width: parent.width * (offlineTileManager ? offlineTileManager.progress : 0)
                        height: parent.height
                        color: "#4CAF50"
                        radius: 3
                    }

                    Text {
                        anchors.centerIn: parent
                        text: offlineTileManager ?
                              offlineTileManager.downloadedTiles + " / " + offlineTileManager.totalTiles :
                              ""
                        font.pixelSize: 9
                        color: "#ffffff"
                    }
                }

                // Download button
                Button {
                    width: parent.width
                    height: 35
                    text: offlineTileManager && offlineTileManager.isDownloading ? "Iptal Et" : "Bolgeyi Indir"
                    enabled: offlineTileManager !== null

                    background: Rectangle {
                        color: offlineTileManager && offlineTileManager.isDownloading ?
                               "#f44336" : "#ff9800"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (offlineTileManager) {
                            if (offlineTileManager.isDownloading) {
                                offlineTileManager.cancelDownload()
                            } else {
                                offlineTileManager.downloadRegion(
                                    centerLat, centerLon,
                                    radiusCombo.selectedRadius,
                                    zoomRangeCombo.selectedMinZoom,
                                    zoomRangeCombo.selectedMaxZoom
                                )
                            }
                        }
                    }
                }

                // Clear cache button
                Button {
                    width: parent.width
                    height: 30
                    text: "Onbellegi Temizle"
                    enabled: offlineTileManager && !offlineTileManager.isDownloading

                    background: Rectangle {
                        color: "#555555"
                        radius: 5
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 10
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (offlineTileManager) {
                            offlineTileManager.clearCache()
                        }
                    }
                }

                // Help text
                Text {
                    width: parent.width
                    text: "Indirilen haritalar\noffline kullanilabilir"
                    font.pixelSize: 8
                    color: "#666666"
                    horizontalAlignment: Text.AlignCenter
                    lineHeight: 1.3
                }
            }
        }
    }

    // Download complete notification
    Connections {
        target: offlineTileManager

        function onDownloadComplete() {
            console.log("Offline download complete!")
            downloadCompletePopup.open()
        }

        function onDownloadError(error) {
            console.log("Download error:", error)
        }
    }

    // Download complete popup
    Popup {
        id: downloadCompletePopup
        anchors.centerIn: parent
        width: 250
        height: 80
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "#1a1a1a"
            radius: 10
            border.color: "#4CAF50"
            border.width: 2
        }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "Indirme Tamamlandi!"
                font.pixelSize: 14
                font.bold: true
                color: "#4CAF50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Harita offline kullanilabilir"
                font.pixelSize: 11
                color: "#aaaaaa"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Timer {
            running: downloadCompletePopup.visible
            interval: 3000
            onTriggered: downloadCompletePopup.close()
        }
    }
}
