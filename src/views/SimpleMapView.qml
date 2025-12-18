import QtQuick
import QtQuick.Controls

/**
 * Simple OpenStreetMap View - Optimized version
 * Uses Repeater with limited tile count to prevent crashes
 */
Rectangle {
    id: simpleMapRoot
    color: themeManager && themeManager.isDarkTheme ? "#1a2332" : "#87CEEB"  // Koyu mavi (dark) veya açık mavi (light)

    Behavior on color {
        ColorAnimation { duration: 300 }
    }

    // Excavator fixed position (never changes)
    property real excavatorLat: 40.8078  // Tuzla Limanı
    property real excavatorLon: 29.2936

    // Map view state (can change with pan/zoom)
    property real centerLat: excavatorLat
    property real centerLon: excavatorLon
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

    // Download preview visibility
    property bool showDownloadPreview: false

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

        // Pan and zoom handling
        MouseArea {
            id: panArea
            anchors.fill: parent
            enabled: !isUpdating
            acceptedButtons: Qt.LeftButton | Qt.RightButton

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

            // Mouse wheel zoom
            onWheel: (wheel) => {
                if (isUpdating) return

                // Zoom in with scroll up, zoom out with scroll down
                if (wheel.angleDelta.y > 0) {
                    changeZoom(1)  // Zoom in
                } else if (wheel.angleDelta.y < 0) {
                    changeZoom(-1)  // Zoom out
                }
            }
        }
    }

    // Excavator marker (fixed GPS position - never moves relative to map)
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

        // Position at the excavator's FIXED GPS location
        x: {
            // Get excavator's tile coordinates
            var excavatorTile = latLonToTile(excavatorLat, excavatorLon, zoomLevel)
            // Calculate difference from current map center tile
            var tileDiffX = excavatorTile.x - centerTileX
            // Position relative to viewport center + tile difference + pan offset
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

    // Download area preview rectangle (draggable)
    Rectangle {
        id: downloadPreview
        visible: showDownloadPreview && offlinePanel.offlinePanelExpanded
        z: 15
        color: downloadPreviewDrag.drag.active ? "#22ff9800" : "transparent"
        border.color: downloadPreviewDrag.drag.active ? "#ffcc00" : "#ff9800"
        border.width: 3
        opacity: 0.8

        // Custom center position (can be dragged)
        property real customCenterX: excavatorMarker.x + excavatorMarker.width / 2
        property real customCenterY: excavatorMarker.y + excavatorMarker.height / 2
        property bool isDragged: false

        // Calculate size based on radius selection
        property real radiusKm: radiusCombo.selectedRadius
        // At equator, 1 degree ≈ 111 km. Adjust for latitude
        property real kmPerPixel: {
            // meters per pixel at current zoom
            var metersPerPixel = 156543.03 * Math.cos(excavatorLat * Math.PI / 180) / Math.pow(2, zoomLevel)
            return metersPerPixel / 1000  // convert to km
        }
        property real radiusPixels: radiusKm / kmPerPixel

        // Calculate the lat/lon of the download center
        property real downloadCenterLat: {
            if (!isDragged) return excavatorLat
            // Convert pixel offset to lat/lon
            var centerPixelY = y + height / 2
            var excavatorPixelY = excavatorMarker.y + excavatorMarker.height / 2
            var pixelDiffY = centerPixelY - excavatorPixelY
            var tileDiffY = pixelDiffY / tileSize
            var newTileY = latLonToTile(excavatorLat, excavatorLon, zoomLevel).y + tileDiffY
            return tileToLatLon(0, newTileY, zoomLevel).lat
        }
        property real downloadCenterLon: {
            if (!isDragged) return excavatorLon
            var centerPixelX = x + width / 2
            var excavatorPixelX = excavatorMarker.x + excavatorMarker.width / 2
            var pixelDiffX = centerPixelX - excavatorPixelX
            var tileDiffX = pixelDiffX / tileSize
            var newTileX = latLonToTile(excavatorLat, excavatorLon, zoomLevel).x + tileDiffX
            return tileToLatLon(newTileX, 0, zoomLevel).lon
        }

        width: radiusPixels * 2
        height: radiusPixels * 2
        radius: 10

        // Position: follow excavator if not dragged, otherwise use custom position
        x: isDragged ? x : (excavatorMarker.x + excavatorMarker.width / 2 - width / 2)
        y: isDragged ? y : (excavatorMarker.y + excavatorMarker.height / 2 - height / 2)

        // Reset position when preview is hidden
        onVisibleChanged: {
            if (!visible) {
                isDragged = false
            }
        }

        // Drag handle
        MouseArea {
            id: downloadPreviewDrag
            anchors.fill: parent
            cursorShape: Qt.SizeAllCursor
            drag.target: downloadPreview
            drag.axis: Drag.XAndYAxis

            onPressed: {
                downloadPreview.isDragged = true
            }

            onDoubleClicked: {
                // Reset to excavator position on double-click
                downloadPreview.isDragged = false
                downloadPreview.x = excavatorMarker.x + excavatorMarker.width / 2 - downloadPreview.width / 2
                downloadPreview.y = excavatorMarker.y + excavatorMarker.height / 2 - downloadPreview.height / 2
            }
        }

        // Dashed border effect with inner rectangle
        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            color: "transparent"
            border.color: "#ff9800"
            border.width: 1
            opacity: 0.5
            radius: 7
        }

        // Drag indicator icon
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 5
            width: 24
            height: 24
            radius: 12
            color: "#ff9800"
            opacity: 0.9

            Text {
                anchors.centerIn: parent
                text: "✥"
                font.pixelSize: 14
                color: "#ffffff"
            }
        }

        // Label showing the area size and position
        Rectangle {
            anchors.top: parent.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: areaLabelColumn.width + 16
            height: areaLabelColumn.height + 8
            color: "#ff9800"
            radius: 4

            Column {
                id: areaLabelColumn
                anchors.centerIn: parent
                spacing: 2

                Text {
                    id: areaLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: radiusCombo.selectedRadius + " km"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#ffffff"
                }

                Text {
                    visible: downloadPreview.isDragged
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: downloadPreview.downloadCenterLat.toFixed(4) + ", " + downloadPreview.downloadCenterLon.toFixed(4)
                    font.pixelSize: 8
                    color: "#ffffffcc"
                }
            }
        }

        // Reset button (visible when dragged)
        Rectangle {
            visible: downloadPreview.isDragged
            anchors.bottom: parent.top
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: resetLabel.width + 12
            height: 20
            color: "#555555"
            radius: 3

            Text {
                id: resetLabel
                anchors.centerIn: parent
                text: qsTr("Reset (2x click)")
                font.pixelSize: 8
                color: "#ffffff"
            }
        }
    }

    // Loading indicator
    Rectangle {
        anchors.centerIn: parent
        width: 100
        height: 40
        radius: 5
        color: themeManager ? themeManager.backgroundColorDark : "#1a1a1a"
        opacity: 0.9
        visible: isUpdating
        z: 100

        Behavior on color {
            ColorAnimation { duration: 300 }
        }

        Text {
            anchors.centerIn: parent
            text: qsTr("Loading...")
            color: themeManager ? themeManager.primaryColor : "#00bcd4"
            font.pixelSize: 12

            Behavior on color {
                ColorAnimation { duration: 300 }
            }
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
        color: themeManager ? themeManager.backgroundColor : "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: themeManager ? themeManager.primaryColor : "#00bcd4"
        border.width: 2
        z: 10

        Behavior on color {
            ColorAnimation { duration: 300 }
        }

        Column {
            id: infoColumn
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: qsTr("EXCAVATOR LOCATION")
                font.pixelSize: 12
                font.bold: true
                color: themeManager ? themeManager.primaryColor : "#00bcd4"

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }

            Row {
                spacing: 5
                Text {
                    text: "Lat:";
                    font.pixelSize: 11;
                    color: themeManager ? themeManager.textColor : "#ffffff";
                    width: 40

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                Text { text: excavatorLat.toFixed(6); font.pixelSize: 11; color: "#00ff00" }
            }

            Row {
                spacing: 5
                Text {
                    text: "Lon:";
                    font.pixelSize: 11;
                    color: themeManager ? themeManager.textColor : "#ffffff";
                    width: 40

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                Text { text: excavatorLon.toFixed(6); font.pixelSize: 11; color: "#00ff00" }
            }

            Row {
                spacing: 5
                Text {
                    text: "Zoom:";
                    font.pixelSize: 11;
                    color: themeManager ? themeManager.textColor : "#ffffff";
                    width: 40

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                Text { text: zoomLevel; font.pixelSize: 11; color: "#00ff00" }
            }

            Text {
                text: qsTr("Tuzla Port, Istanbul")
                font.pixelSize: 10
                color: themeManager ? themeManager.textColorSecondary : "#aaaaaa"

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
    }

    // Control panel (bottom) - Modern design
    Rectangle {
        id: controlPanel
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

        // Subtle shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            z: -1
            radius: 27
            color: "#00000044"
        }

        Row {
            id: controlRow
            anchors.centerIn: parent
            spacing: 8

            // Zoom out button
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: zoomOutArea.pressed ? "#333333" : (zoomLevel > 3 && !isUpdating ? "#252525" : "#1a1a1a")
                border.color: zoomLevel > 3 && !isUpdating ? "#00bcd4" : "#333333"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "−"
                    font.pixelSize: 24
                    font.bold: true
                    color: zoomLevel > 3 && !isUpdating ? "#00bcd4" : "#555555"
                }

                MouseArea {
                    id: zoomOutArea
                    anchors.fill: parent
                    enabled: zoomLevel > 3 && !isUpdating
                    onClicked: changeZoom(-1)
                }
            }

            // Zoom level indicator
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
                        color: "#00bcd4"
                    }
                }
            }

            // Zoom in button
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: zoomInArea.pressed ? "#333333" : (zoomLevel < 18 && !isUpdating ? "#252525" : "#1a1a1a")
                border.color: zoomLevel < 18 && !isUpdating ? "#00bcd4" : "#333333"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    font.pixelSize: 22
                    font.bold: true
                    color: zoomLevel < 18 && !isUpdating ? "#00bcd4" : "#555555"
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

            // Home/excavator button
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
                    onClicked: goToLocation(excavatorLat, excavatorLon, 15)
                }

                // Tooltip
                Rectangle {
                    visible: homeArea.containsMouse
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: tooltipText1.width + 16
                    height: 24
                    radius: 4
                    color: "#333333"
                    border.color: "#555555"
                    border.width: 1

                    Text {
                        id: tooltipText1
                        anchors.centerIn: parent
                        text: qsTr("Excavator")
                        font.pixelSize: 10
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: goToLocation(excavatorLat, excavatorLon, 15)
                    enabled: !isUpdating
                    property bool containsMouse: false
                    onEntered: containsMouse = true
                    onExited: containsMouse = false
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 30
                color: "#404040"
                anchors.verticalCenter: parent.verticalCenter
            }

            // Location presets
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                // Tuzla button
                Rectangle {
                    width: 70
                    height: 36
                    radius: 18
                    color: tuzlaArea.pressed ? "#00bcd4" : "#252525"
                    border.color: "#00bcd4"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Tuzla")
                        font.pixelSize: 11
                        font.bold: true
                        color: tuzlaArea.pressed ? "#ffffff" : "#00bcd4"
                    }

                    MouseArea {
                        id: tuzlaArea
                        anchors.fill: parent
                        enabled: !isUpdating
                        onClicked: goToLocation(excavatorLat, excavatorLon, 15)
                    }
                }

                // Istanbul button
                Rectangle {
                    width: 70
                    height: 36
                    radius: 18
                    color: istanbulArea.pressed ? "#4CAF50" : "#252525"
                    border.color: "#4CAF50"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Istanbul")
                        font.pixelSize: 11
                        font.bold: true
                        color: istanbulArea.pressed ? "#ffffff" : "#4CAF50"
                    }

                    MouseArea {
                        id: istanbulArea
                        anchors.fill: parent
                        enabled: !isUpdating
                        onClicked: goToLocation(41.0082, 28.9784, 13)
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
                        text: qsTr("OFFLINE MAP DOWNLOAD")
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
                            text: qsTr("Cache") + ": " + (offlineTileManager ? offlineTileManager.formatCacheSize() : "0 MB")
                            font.pixelSize: 10
                            color: "#aaaaaa"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // Tile provider selection
                Row {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: qsTr("Map") + ":"
                        font.pixelSize: 10
                        color: "#ffffff"
                        width: 35
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: tileProviderCombo
                        width: parent.width - 40
                        height: 30
                        model: ["OpenStreetMap", "CartoDB Positron"]
                        currentIndex: 1  // Default to CartoDB

                        property var providerValues: ["osm", "cartodb"]
                        property string selectedProvider: providerValues[currentIndex]

                        onCurrentIndexChanged: {
                            if (offlineTileManager) {
                                offlineTileManager.tileProvider = selectedProvider
                                console.log("Tile provider changed to:", selectedProvider)
                            }
                        }
                    }
                }

                // Radius selection
                Row {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: qsTr("Area") + ":"
                        font.pixelSize: 10
                        color: "#ffffff"
                        width: 35
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ComboBox {
                        id: radiusCombo
                        width: parent.width - 40
                        height: 30
                        model: ["1 km", "2 km", "5 km", "10 km", qsTr("All Turkey")]
                        currentIndex: 1

                        property var radiusValues: [1, 2, 5, 10, 0]  // 0 means use Turkey bounds
                        property real selectedRadius: radiusValues[currentIndex]
                        property bool isTurkeyMode: currentIndex === 4
                    }
                }

                // Turkey download info (visible when Turkey mode selected)
                Rectangle {
                    width: parent.width
                    height: turkeyInfoColumn.height + 10
                    color: "#2a4858"
                    radius: 5
                    visible: radiusCombo.isTurkeyMode

                    Column {
                        id: turkeyInfoColumn
                        anchors.centerIn: parent
                        spacing: 2
                        width: parent.width - 10

                        Text {
                            text: "⚠ " + qsTr("All Turkey")
                            font.pixelSize: 10
                            font.bold: true
                            color: "#ffa726"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: qsTr("Area") + ": 36°-42° " + qsTr("North") + ", 26°-45° " + qsTr("East")
                            font.pixelSize: 8
                            color: "#cccccc"
                            anchors.horizontalCenter: parent.horizontalCenter
                            wrapMode: Text.WordWrap
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: {
                                if (offlineTileManager && radiusCombo.isTurkeyMode) {
                                    // Calculate for Turkey bounds
                                    var minLat = 36.0, maxLat = 42.1
                                    var minLon = 26.0, maxLon = 45.0
                                    var centerLat = (minLat + maxLat) / 2
                                    var centerLon = (minLon + maxLon) / 2

                                    // Estimate radius in km (approximate)
                                    var latDiff = maxLat - minLat
                                    var lonDiff = maxLon - minLon
                                    var radiusKm = Math.sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111 / 2

                                    var count = offlineTileManager.estimateTileCount(
                                        centerLat, centerLon, radiusKm,
                                        zoomRangeCombo.selectedMinZoom,
                                        zoomRangeCombo.selectedMaxZoom
                                    )
                                    var sizeMB = Math.round(count * 30 / 1024)
                                    return "~" + count + " tile (~" + sizeMB + " MB)"
                                }
                                return ""
                            }
                            font.pixelSize: 8
                            color: "#ffb74d"
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
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
                        model: ["13-15 (Hızlı)", "13-16 (Normal)", "13-17 (Detaylı)", "13-18 (Maksimum)"]
                        currentIndex: 1

                        property var minZooms: [13, 13, 13, 13]
                        property var maxZooms: [15, 16, 17, 18]
                        property int selectedMinZoom: minZooms[currentIndex]
                        property int selectedMaxZoom: maxZooms[currentIndex]
                    }
                }

                // Preview toggle
                Row {
                    width: parent.width
                    spacing: 8

                    CheckBox {
                        id: previewCheck
                        checked: showDownloadPreview
                        onCheckedChanged: showDownloadPreview = checked

                        indicator: Rectangle {
                            width: 18
                            height: 18
                            radius: 3
                            color: previewCheck.checked ? "#ff9800" : "#333333"
                            border.color: "#ff9800"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: previewCheck.checked ? "✓" : ""
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        text: "Alanı Önizle"
                        font.pixelSize: 10
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Estimated tile count
                Text {
                    width: parent.width
                    text: {
                        if (offlineTileManager) {
                            var count = offlineTileManager.estimateTileCount(
                                excavatorLat, excavatorLon,
                                radiusCombo.selectedRadius,
                                zoomRangeCombo.selectedMinZoom,
                                zoomRangeCombo.selectedMaxZoom
                            )
                            return "Tahmini: ~" + count + " tile (~" + Math.round(count * 30 / 1024) + " MB)"
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
                    text: offlineTileManager && offlineTileManager.isDownloading ? "İptal Et" : "Bölgeyi İndir"
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
                                if (radiusCombo.isTurkeyMode) {
                                    // Download entire Turkey using bounds
                                    console.log("Downloading entire Turkey...")
                                    offlineTileManager.downloadArea(
                                        36.0, 42.1,  // minLat, maxLat
                                        26.0, 45.0,  // minLon, maxLon
                                        zoomRangeCombo.selectedMinZoom,
                                        zoomRangeCombo.selectedMaxZoom
                                    )
                                } else {
                                    // Download around preview center (draggable) or excavator position
                                    var downloadLat = downloadPreview.isDragged ? downloadPreview.downloadCenterLat : excavatorLat
                                    var downloadLon = downloadPreview.isDragged ? downloadPreview.downloadCenterLon : excavatorLon
                                    console.log("Downloading region at:", downloadLat, downloadLon)
                                    offlineTileManager.downloadRegion(
                                        downloadLat, downloadLon,
                                        radiusCombo.selectedRadius,
                                        zoomRangeCombo.selectedMinZoom,
                                        zoomRangeCombo.selectedMaxZoom
                                    )
                                }
                            }
                        }
                    }
                }

                // Clear cache button
                Button {
                    width: parent.width
                    height: 30
                    text: "Önbelleği Temizle"
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
                    text: "İndirilen haritalar\noffline kullanılabilir"
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
                text: "İndirme Tamamlandı!"
                font.pixelSize: 14
                font.bold: true
                color: "#4CAF50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Harita offline kullanılabilir"
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
