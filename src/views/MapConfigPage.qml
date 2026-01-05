import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * MapConfigPage - Harita Ayarları Sayfası
 *
 * Kullanıcı kazı yapılacak alanı haritadan seçer:
 * - Carto basemap görünümü
 * - Akıcı pan ve zoom
 * - Koordinat ve boyut ayarları
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#f7fafc"

    signal back()
    signal configSaved()

    // Translation support
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Theme colors with fallbacks (softer light theme defaults)
    property color primaryColor: themeManager ? themeManager.primaryColor : "#319795"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color backgroundColor: themeManager ? themeManager.backgroundColor : "#f7fafc"
    property color textColor: themeManager ? themeManager.textColor : "#2d3748"
    property color textSecondaryColor: themeManager ? themeManager.textSecondaryColor : "#718096"
    property color borderColor: themeManager ? themeManager.borderColor : "#e2e8f0"

    // Map state
    property real mapCenterLat: configManager ? configManager.mapCenterLatitude : 40.65
    property real mapCenterLon: configManager ? configManager.mapCenterLongitude : 29.275
    property int mapZoom: configManager ? configManager.mapZoomLevel : 14

    // Tile management
    property real tileSize: 256
    property int centerTileX: 0
    property int centerTileY: 0
    property real offsetX: 0
    property real offsetY: 0
    property int gridWidth: 5
    property int gridHeight: 5
    property bool isUpdating: false
    property bool isInitialized: false

    // Selection rectangle state (in pixels, relative to map)
    property real selectionX: 0.3
    property real selectionY: 0.3
    property real selectionWidth: 0.4
    property real selectionHeight: 0.4

    Component.onCompleted: {
        initializeMap()
    }

    function initializeMap() {
        if (isInitialized) return
        isInitialized = true

        var tile = latLonToTile(mapCenterLat, mapCenterLon, mapZoom)
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
        var maxTile = Math.pow(2, mapZoom) - 1
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
                        tileZ: mapZoom,
                        gridX: dx,
                        gridY: dy
                    })
                }
            }
        }
    }

    function changeZoom(delta) {
        if (isUpdating) return

        var newZoom = mapZoom + delta
        if (newZoom < 3 || newZoom > 18) return

        isUpdating = true

        var currentCenter = tileToLatLon(
            centerTileX + offsetX / tileSize,
            centerTileY + offsetY / tileSize,
            mapZoom
        )

        mapZoom = newZoom
        mapCenterLat = currentCenter.lat
        mapCenterLon = currentCenter.lon

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
        mapCenterLat = lat
        mapCenterLon = lon
        mapZoom = zoom

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
        interval: 100
        repeat: false
        onTriggered: {
            populateTileModel()
            isUpdating = false
        }
    }

    ListModel {
        id: tileModel
    }

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                flat: true

                contentItem: Text {
                    text: "←"
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 20
                    color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                }

                onClicked: root.back()
            }

            Text {
                Layout.fillWidth: true
                text: qsTr("Harita Ayarları")
                font.pixelSize: 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: 40 }
        }
    }

    // Content
    ColumnLayout {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        spacing: 0

        // Map View
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16
            color: root.surfaceColor
            radius: 12
            clip: true

            // Map Container
            Item {
                id: mapContainer
                anchors.fill: parent
                anchors.margins: 4

                // Map Viewport
                Rectangle {
                    id: mapView
                    anchors.fill: parent
                    color: "#e8f4f8"
                    clip: true

                    // Grid background pattern
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.strokeStyle = "#d0e0e8"
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

                        Behavior on x { NumberAnimation { duration: 50 } }
                        Behavior on y { NumberAnimation { duration: 50 } }

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

                                Image {
                                    anchors.fill: parent
                                    source: "https://basemaps.cartocdn.com/rastertiles/voyager/" + parent.tileZ + "/" + parent.tileX + "/" + parent.tileY + ".png"
                                    asynchronous: true
                                    cache: true
                                    fillMode: Image.PreserveAspectFit

                                    // Loading indicator
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#e0f0f5"
                                        visible: parent.status === Image.Loading

                                        Text {
                                            anchors.centerIn: parent
                                            text: "⏳"
                                            font.pixelSize: 20
                                            opacity: 0.5
                                        }
                                    }

                                    // Error placeholder
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "#f0f4f8"
                                        visible: parent.status === Image.Error
                                        border.color: "#d0d8e0"
                                        border.width: 1

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: "🗺"
                                                font.pixelSize: 24
                                                opacity: 0.4
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Selection Rectangle
                    Rectangle {
                        id: selectionRect
                        x: mapView.width * selectionX
                        y: mapView.height * selectionY
                        width: mapView.width * selectionWidth
                        height: mapView.height * selectionHeight
                        color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.2)
                        border.width: 3
                        border.color: root.primaryColor
                        radius: 4
                        z: 10

                        // Corner handles
                        Repeater {
                            model: 4

                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: root.primaryColor
                                border.width: 2
                                border.color: "white"

                                x: (index % 2 === 0) ? -10 : selectionRect.width - 10
                                y: (index < 2) ? -10 : selectionRect.height - 10

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.SizeFDiagCursor

                                    property real startMouseX: 0
                                    property real startMouseY: 0
                                    property real startSelX: 0
                                    property real startSelY: 0
                                    property real startSelW: 0
                                    property real startSelH: 0

                                    onPressed: (mouse) => {
                                        startMouseX = mouse.x + parent.x + selectionRect.x
                                        startMouseY = mouse.y + parent.y + selectionRect.y
                                        startSelX = selectionX
                                        startSelY = selectionY
                                        startSelW = selectionWidth
                                        startSelH = selectionHeight
                                    }

                                    onPositionChanged: (mouse) => {
                                        if (pressed) {
                                            var currentX = mouse.x + parent.x + selectionRect.x
                                            var currentY = mouse.y + parent.y + selectionRect.y
                                            var deltaX = (currentX - startMouseX) / mapView.width
                                            var deltaY = (currentY - startMouseY) / mapView.height

                                            if (index === 0) {
                                                selectionX = Math.max(0, Math.min(startSelX + startSelW - 0.1, startSelX + deltaX))
                                                selectionY = Math.max(0, Math.min(startSelY + startSelH - 0.1, startSelY + deltaY))
                                                selectionWidth = startSelW - (selectionX - startSelX)
                                                selectionHeight = startSelH - (selectionY - startSelY)
                                            } else if (index === 1) {
                                                selectionY = Math.max(0, Math.min(startSelY + startSelH - 0.1, startSelY + deltaY))
                                                selectionWidth = Math.max(0.1, Math.min(1 - startSelX, startSelW + deltaX))
                                                selectionHeight = startSelH - (selectionY - startSelY)
                                            } else if (index === 2) {
                                                selectionX = Math.max(0, Math.min(startSelX + startSelW - 0.1, startSelX + deltaX))
                                                selectionWidth = startSelW - (selectionX - startSelX)
                                                selectionHeight = Math.max(0.1, Math.min(1 - startSelY, startSelH + deltaY))
                                            } else {
                                                selectionWidth = Math.max(0.1, Math.min(1 - startSelX, startSelW + deltaX))
                                                selectionHeight = Math.max(0.1, Math.min(1 - startSelY, startSelH + deltaY))
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Center drag handle
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.OpenHandCursor

                            property real startMouseX: 0
                            property real startMouseY: 0
                            property real startSelX: 0
                            property real startSelY: 0

                            onPressed: (mouse) => {
                                startMouseX = mouse.x
                                startMouseY = mouse.y
                                startSelX = selectionX
                                startSelY = selectionY
                                cursorShape = Qt.ClosedHandCursor
                            }

                            onReleased: {
                                cursorShape = Qt.OpenHandCursor
                            }

                            onPositionChanged: (mouse) => {
                                if (pressed) {
                                    var deltaX = (mouse.x - startMouseX) / mapView.width
                                    var deltaY = (mouse.y - startMouseY) / mapView.height
                                    selectionX = Math.max(0, Math.min(1 - selectionWidth, startSelX + deltaX))
                                    selectionY = Math.max(0, Math.min(1 - selectionHeight, startSelY + deltaY))
                                }
                            }
                        }

                        // Selection info overlay
                        Rectangle {
                            anchors.top: parent.bottom
                            anchors.topMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: selectionInfoText.width + 16
                            height: 24
                            radius: 12
                            color: root.primaryColor

                            Text {
                                id: selectionInfoText
                                anchors.centerIn: parent
                                text: qsTr("Seçili Alan")
                                font.pixelSize: 11
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                    // Pan handling
                    MouseArea {
                        id: panArea
                        anchors.fill: parent
                        z: -1
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

                                var maxTile = Math.pow(2, mapZoom) - 1
                                centerTileX = Math.max(0, Math.min(maxTile, centerTileX))
                                centerTileY = Math.max(0, Math.min(maxTile, centerTileY))

                                offsetX = offsetX - shiftX * tileSize
                                offsetY = offsetY - shiftY * tileSize

                                // Update center coordinates
                                var newCenter = tileToLatLon(centerTileX, centerTileY, mapZoom)
                                mapCenterLat = newCenter.lat
                                mapCenterLon = newCenter.lon

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

                    // Map Controls
                    Column {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 8
                        z: 20

                        // Zoom In
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: zoomInMa.pressed ? Qt.darker(root.surfaceColor, 1.1) : root.surfaceColor
                            border.color: root.primaryColor
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 24
                                font.bold: true
                                color: root.primaryColor
                            }

                            MouseArea {
                                id: zoomInMa
                                anchors.fill: parent
                                enabled: mapZoom < 18 && !isUpdating
                                onClicked: changeZoom(1)
                            }
                        }

                        // Zoom level indicator
                        Rectangle {
                            width: 44
                            height: 28
                            radius: 6
                            color: Qt.rgba(0, 0, 0, 0.6)

                            Column {
                                anchors.centerIn: parent
                                spacing: 0

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "ZOOM"
                                    font.pixelSize: 7
                                    color: "#aaaaaa"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: mapZoom.toString()
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                }
                            }
                        }

                        // Zoom Out
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: zoomOutMa.pressed ? Qt.darker(root.surfaceColor, 1.1) : root.surfaceColor
                            border.color: root.primaryColor
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 24
                                font.bold: true
                                color: root.primaryColor
                            }

                            MouseArea {
                                id: zoomOutMa
                                anchors.fill: parent
                                enabled: mapZoom > 3 && !isUpdating
                                onClicked: changeZoom(-1)
                            }
                        }
                    }

                    // Coordinate overlay
                    Rectangle {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 8
                        width: coordText.width + 16
                        height: 28
                        radius: 6
                        color: Qt.rgba(0, 0, 0, 0.7)
                        z: 20

                        Text {
                            id: coordText
                            anchors.centerIn: parent
                            text: mapCenterLat.toFixed(4) + "°, " + mapCenterLon.toFixed(4) + "°"
                            font.pixelSize: 11
                            color: "white"
                        }
                    }

                    // Attribution
                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 8
                        text: "© CARTO © OpenStreetMap"
                        font.pixelSize: 9
                        color: "#666666"
                        z: 20
                    }
                }
            }
        }

        // Coordinate Input Section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: coordInputContent.height + 32
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 8
            color: root.surfaceColor
            radius: 12

            ColumnLayout {
                id: coordInputContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                spacing: 12

                Text {
                    text: qsTr("Koordinat Ayarları")
                    font.pixelSize: 14
                    font.bold: true
                    color: root.textColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    // Latitude
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: qsTr("Enlem (Latitude)")
                            font.pixelSize: 11
                            color: root.textSecondaryColor
                        }

                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            text: mapCenterLat.toFixed(6)
                            font.pixelSize: 14
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            validator: DoubleValidator { bottom: -90; top: 90; decimals: 6 }

                            background: Rectangle {
                                color: root.backgroundColor
                                radius: 6
                                border.width: parent.activeFocus ? 2 : 1
                                border.color: parent.activeFocus ? root.primaryColor : root.borderColor
                            }

                            onEditingFinished: {
                                var val = parseFloat(text)
                                if (!isNaN(val)) {
                                    goToLocation(Math.max(-85, Math.min(85, val)), mapCenterLon, mapZoom)
                                }
                            }
                        }
                    }

                    // Longitude
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: qsTr("Boylam (Longitude)")
                            font.pixelSize: 11
                            color: root.textSecondaryColor
                        }

                        TextField {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            text: mapCenterLon.toFixed(6)
                            font.pixelSize: 14
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            validator: DoubleValidator { bottom: -180; top: 180; decimals: 6 }

                            background: Rectangle {
                                color: root.backgroundColor
                                radius: 6
                                border.width: parent.activeFocus ? 2 : 1
                                border.color: parent.activeFocus ? root.primaryColor : root.borderColor
                            }

                            onEditingFinished: {
                                var val = parseFloat(text)
                                if (!isNaN(val)) {
                                    goToLocation(mapCenterLat, val, mapZoom)
                                }
                            }
                        }
                    }
                }

                // Quick location buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: qsTr("Hızlı Konum:")
                        font.pixelSize: 11
                        color: root.textSecondaryColor
                    }

                    Button {
                        Layout.preferredHeight: 28
                        text: "Yalova"
                        font.pixelSize: 11

                        background: Rectangle {
                            radius: 4
                            color: parent.pressed ? Qt.darker(root.backgroundColor, 1.1) : root.backgroundColor
                            border.width: 1
                            border.color: root.borderColor
                        }

                        onClicked: goToLocation(40.6500, 29.2750, 14)
                    }

                    Button {
                        Layout.preferredHeight: 28
                        text: "İstanbul"
                        font.pixelSize: 11

                        background: Rectangle {
                            radius: 4
                            color: parent.pressed ? Qt.darker(root.backgroundColor, 1.1) : root.backgroundColor
                            border.width: 1
                            border.color: root.borderColor
                        }

                        onClicked: goToLocation(41.0082, 28.9784, 12)
                    }

                    Button {
                        Layout.preferredHeight: 28
                        text: "Altınova"
                        font.pixelSize: 11

                        background: Rectangle {
                            radius: 4
                            color: parent.pressed ? Qt.darker(root.backgroundColor, 1.1) : root.backgroundColor
                            border.width: 1
                            border.color: root.borderColor
                        }

                        onClicked: goToLocation(40.7000, 29.5100, 15)
                    }

                    Item { Layout.fillWidth: true }
                }
            }
        }
    }

    // Footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.borderColor
        }

        Button {
            anchors.centerIn: parent
            width: parent.width - 40
            height: 50
            text: qsTr("Kaydet ve Devam Et")

            background: Rectangle {
                radius: 12
                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                // Save map settings
                if (configManager) {
                    configManager.mapCenterLatitude = mapCenterLat
                    configManager.mapCenterLongitude = mapCenterLon
                    configManager.mapZoomLevel = mapZoom
                }
                root.configSaved()
            }
        }
    }
}
