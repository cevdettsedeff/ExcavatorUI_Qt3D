import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Harita Sayfası - ConfigManager'dan gelen koordinatları gösterir
Rectangle {
    id: mapPage
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // ConfigManager'dan gelen veriler
    property real mapCenterLat: configManager ? configManager.mapCenterLatitude : 40.65
    property real mapCenterLon: configManager ? configManager.mapCenterLongitude : 29.275
    property int mapZoom: configManager ? configManager.mapZoomLevel : 14
    property real areaWidth: configManager ? configManager.mapAreaWidth : 100
    property real areaHeight: configManager ? configManager.mapAreaHeight : 100

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

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#38b2ac"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#333333"

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

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

    // Ana içerik
    Row {
        anchors.fill: parent
        spacing: 0

        // Sol Araç Çubuğu
        Rectangle {
            id: leftToolbar
            width: 70
            height: parent.height
            color: mapPage.surfaceColor
            border.color: mapPage.borderColor
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.topMargin: 10
                spacing: 5

                // Hedef butonu
                ToolbarButton {
                    iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/icon_target.png"
                    fallbackIcon: "◎"
                    label: tr("Target")
                    onClicked: goToLocation(mapCenterLat, mapCenterLon, mapZoom)
                }

                // Katmanlar butonu
                ToolbarButton {
                    iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/icon_layers.png"
                    fallbackIcon: "☰"
                    label: tr("Layers")
                    onClicked: console.log("Katmanlar clicked")
                }

                // Ayırıcı
                Rectangle {
                    width: 50
                    height: 1
                    color: mapPage.borderColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Zoom In
                ToolbarButton {
                    fallbackIcon: "+"
                    label: ""
                    onClicked: changeZoom(1)
                }

                // Zoom indicator
                Rectangle {
                    width: 50
                    height: 28
                    color: Qt.rgba(0, 0, 0, 0.3)
                    radius: 4
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: mapZoom.toString()
                        font.pixelSize: 14
                        font.bold: true
                        color: mapPage.primaryColor
                    }
                }

                // Zoom Out
                ToolbarButton {
                    fallbackIcon: "−"
                    label: ""
                    onClicked: changeZoom(-1)
                }

                // Ayırıcı
                Rectangle {
                    width: 50
                    height: 1
                    color: mapPage.borderColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Home (configured area)
                ToolbarButton {
                    iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/icon_home.png"
                    fallbackIcon: "⌂"
                    label: tr("Home")
                    onClicked: {
                        if (configManager) {
                            goToLocation(configManager.mapCenterLatitude, configManager.mapCenterLongitude, configManager.mapZoomLevel)
                        }
                    }
                }

                // Reset
                ToolbarButton {
                    fallbackIcon: "⟲"
                    label: ""
                    onClicked: {
                        offsetX = 0
                        offsetY = 0
                    }
                }
            }
        }

        // Harita Alanı
        Rectangle {
            width: parent.width - leftToolbar.width
            height: parent.height
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
                        }
                    }
                }
            }

            // Çalışma alanı göstergesi (Dashboard'da seçilen alan)
            Rectangle {
                id: workAreaIndicator
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.6, 300)
                height: Math.min(parent.height * 0.6, 300)
                color: Qt.rgba(mapPage.primaryColor.r, mapPage.primaryColor.g, mapPage.primaryColor.b, 0.15)
                border.color: mapPage.primaryColor
                border.width: 3
                radius: 8

                // Köşe işaretleri
                Repeater {
                    model: 4

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: mapPage.primaryColor
                        border.width: 2
                        border.color: "white"

                        x: (index % 2 === 0) ? -8 : workAreaIndicator.width - 8
                        y: (index < 2) ? -8 : workAreaIndicator.height - 8
                    }
                }

                // Alan bilgisi etiketi
                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: areaInfoText.width + 24
                    height: 32
                    radius: 16
                    color: mapPage.primaryColor

                    Text {
                        id: areaInfoText
                        anchors.centerIn: parent
                        text: tr("Work Area") + ": " + areaWidth.toFixed(0) + "m x " + areaHeight.toFixed(0) + "m"
                        font.pixelSize: 12
                        font.bold: true
                        color: "white"
                    }
                }
            }

            // Ekskavatör ikonu (merkez)
            Rectangle {
                id: excavatorIcon
                anchors.centerIn: parent
                width: 50
                height: 35
                color: "#FF6B35"
                radius: 5
                rotation: -15
                z: 10

                Rectangle {
                    anchors.left: parent.right
                    anchors.leftMargin: -5
                    anchors.verticalCenter: parent.verticalCenter
                    width: 35
                    height: 6
                    color: "#FF6B35"
                    rotation: -20
                    transformOrigin: Item.Left
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.9
                    height: 6
                    color: "#333333"
                    radius: 2
                }

                // Pulse animation
                SequentialAnimation on scale {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 1.1; duration: 800 }
                    NumberAnimation { from: 1.1; to: 1.0; duration: 800 }
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

                        var maxTile = Math.pow(2, mapZoom) - 1
                        centerTileX = Math.max(0, Math.min(maxTile, centerTileX))
                        centerTileY = Math.max(0, Math.min(maxTile, centerTileY))

                        offsetX = offsetX - shiftX * tileSize
                        offsetY = offsetY - shiftY * tileSize

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

            // Derinlik skalası (sağ)
            Rectangle {
                id: depthLegend
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 15
                width: 80
                height: 200
                color: Qt.rgba(0, 0, 0, 0.7)
                radius: 8
                z: 20

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text {
                        text: tr("Depth")
                        font.pixelSize: 11
                        font.bold: true
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#ffffff30"
                    }

                    Repeater {
                        model: [
                            { depth: "-0.5m", color: "#4CAF50" },
                            { depth: "-1.0m", color: "#8BC34A" },
                            { depth: "-1.5m", color: "#CDDC39" },
                            { depth: "-2.0m", color: "#FFEB3B" },
                            { depth: "-2.5m", color: "#FFC107" },
                            { depth: "-3.0m", color: "#FF9800" },
                            { depth: "-3.5m", color: "#f44336" }
                        ]

                        Row {
                            spacing: 6

                            Rectangle {
                                width: 18
                                height: 18
                                color: modelData.color
                                radius: 3
                            }

                            Text {
                                text: modelData.depth
                                font.pixelSize: 11
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }

            // Koordinat çubuğu (alt)
            Rectangle {
                id: coordinateBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 45
                color: mapPage.surfaceColor
                z: 20

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: mapPage.borderColor
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 20

                    Row {
                        spacing: 6

                        Text {
                            text: "LAT:"
                            font.pixelSize: 12
                            color: mapPage.textSecondaryColor
                        }

                        Text {
                            text: mapCenterLat.toFixed(6) + "°"
                            font.pixelSize: 12
                            font.bold: true
                            color: mapPage.textColor
                        }
                    }

                    Row {
                        spacing: 6

                        Text {
                            text: "LON:"
                            font.pixelSize: 12
                            color: mapPage.textSecondaryColor
                        }

                        Text {
                            text: mapCenterLon.toFixed(6) + "°"
                            font.pixelSize: 12
                            font.bold: true
                            color: mapPage.textColor
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Row {
                        spacing: 6

                        Text {
                            text: "ZOOM:"
                            font.pixelSize: 12
                            color: mapPage.textSecondaryColor
                        }

                        Text {
                            text: mapZoom.toString()
                            font.pixelSize: 12
                            font.bold: true
                            color: mapPage.primaryColor
                        }
                    }

                    // Attribution
                    Text {
                        text: "© CARTO © OSM"
                        font.pixelSize: 9
                        color: mapPage.textSecondaryColor
                    }
                }
            }
        }
    }

    // Araç çubuğu buton komponenti
    component ToolbarButton: Rectangle {
        property string iconPath: ""
        property string fallbackIcon: ""
        property string label: ""
        signal clicked()

        width: 60
        height: label !== "" ? 55 : 40
        color: mouseArea.containsMouse ? Qt.rgba(mapPage.primaryColor.r, mapPage.primaryColor.g, mapPage.primaryColor.b, 0.1) : "transparent"
        radius: 5
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            anchors.centerIn: parent
            spacing: 3

            Item {
                width: 24
                height: 24
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: btnIcon
                    anchors.fill: parent
                    source: iconPath
                    fillMode: Image.PreserveAspectFit
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: fallbackIcon
                    font.pixelSize: label !== "" ? 20 : 24
                    color: mapPage.textColor
                    visible: btnIcon.status !== Image.Ready
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                font.pixelSize: 9
                color: mapPage.textSecondaryColor
                visible: label !== ""
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}
