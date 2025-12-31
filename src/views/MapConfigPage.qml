import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * MapConfigPage - Harita Ayarları Sayfası
 *
 * Kullanıcı kazı yapılacak alanı haritadan seçer:
 * - OpenStreetMap görünümü
 * - Önizleme karesi ile alan seçimi
 * - Koordinat ve boyut ayarları
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#e8eaf6"

    signal back()
    signal configSaved()

    // Translation support
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Theme colors with fallbacks (light theme defaults)
    property color primaryColor: themeManager ? themeManager.primaryColor : "#0097a7"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color backgroundColor: themeManager ? themeManager.backgroundColor : "#e8eaf6"
    property color textColor: themeManager ? themeManager.textColor : "#1a237e"
    property color textSecondaryColor: themeManager ? themeManager.textSecondaryColor : "#5c6bc0"
    property color borderColor: themeManager ? themeManager.borderColor : "#c5cae9"

    // Map state
    property real mapCenterLat: configManager ? configManager.mapCenterLatitude : 40.65
    property real mapCenterLon: configManager ? configManager.mapCenterLongitude : 29.275
    property int mapZoom: configManager ? configManager.mapZoomLevel : 14

    // Selection rectangle state (in pixels, relative to map)
    property real selectionX: 0.3
    property real selectionY: 0.3
    property real selectionWidth: 0.4
    property real selectionHeight: 0.4

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
                anchors.margins: 8

                // OpenStreetMap Tile Display
                Rectangle {
                    id: mapView
                    anchors.fill: parent
                    color: "#0a3050"
                    clip: true

                    // Map tiles grid simulation
                    Grid {
                        id: tilesGrid
                        anchors.centerIn: parent
                        columns: 3
                        rows: 3
                        spacing: 0

                        property int tileSize: Math.min(mapView.width, mapView.height) / 3

                        Repeater {
                            model: 9

                            Image {
                                width: tilesGrid.tileSize
                                height: tilesGrid.tileSize
                                source: getTileUrl(index)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true

                                // Fallback for when tiles don't load
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#1a4060"
                                    visible: parent.status !== Image.Ready

                                    // Grid lines
                                    Canvas {
                                        anchors.fill: parent
                                        onPaint: {
                                            var ctx = getContext("2d")
                                            ctx.strokeStyle = "#ffffff20"
                                            ctx.lineWidth = 1

                                            var spacing = 40
                                            for (var x = 0; x < width; x += spacing) {
                                                ctx.beginPath()
                                                ctx.moveTo(x, 0)
                                                ctx.lineTo(x, height)
                                                ctx.stroke()
                                            }
                                            for (var y = 0; y < height; y += spacing) {
                                                ctx.beginPath()
                                                ctx.moveTo(0, y)
                                                ctx.lineTo(width, y)
                                                ctx.stroke()
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🗺"
                                        font.pixelSize: 30
                                        opacity: 0.3
                                    }
                                }

                                function getTileUrl(idx) {
                                    var row = Math.floor(idx / 3) - 1
                                    var col = (idx % 3) - 1

                                    var lat = mapCenterLat + (row * -0.01 / Math.pow(2, mapZoom - 10))
                                    var lon = mapCenterLon + (col * 0.01 / Math.pow(2, mapZoom - 10))

                                    // Calculate OSM tile coordinates
                                    var n = Math.pow(2, mapZoom)
                                    var xtile = Math.floor((lon + 180) / 360 * n)
                                    var ytile = Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * n)

                                    return "https://tile.openstreetmap.org/" + mapZoom + "/" + xtile + "/" + ytile + ".png"
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

                                            if (index === 0) { // Top-left
                                                selectionX = Math.max(0, Math.min(startSelX + startSelW - 0.1, startSelX + deltaX))
                                                selectionY = Math.max(0, Math.min(startSelY + startSelH - 0.1, startSelY + deltaY))
                                                selectionWidth = startSelW - (selectionX - startSelX)
                                                selectionHeight = startSelH - (selectionY - startSelY)
                                            } else if (index === 1) { // Top-right
                                                selectionY = Math.max(0, Math.min(startSelY + startSelH - 0.1, startSelY + deltaY))
                                                selectionWidth = Math.max(0.1, Math.min(1 - startSelX, startSelW + deltaX))
                                                selectionHeight = startSelH - (selectionY - startSelY)
                                            } else if (index === 2) { // Bottom-left
                                                selectionX = Math.max(0, Math.min(startSelX + startSelW - 0.1, startSelX + deltaX))
                                                selectionWidth = startSelW - (selectionX - startSelX)
                                                selectionHeight = Math.max(0.1, Math.min(1 - startSelY, startSelH + deltaY))
                                            } else { // Bottom-right
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

                    // Map Controls
                    Column {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 8

                        // Zoom In
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: zoomInMa.pressed ? Qt.darker(root.surfaceColor, 1.2) : root.surfaceColor

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 24
                                color: root.textColor
                            }

                            MouseArea {
                                id: zoomInMa
                                anchors.fill: parent
                                onClicked: {
                                    if (mapZoom < 19) mapZoom++
                                }
                            }
                        }

                        // Zoom level indicator
                        Rectangle {
                            width: 40
                            height: 24
                            radius: 4
                            color: Qt.rgba(0, 0, 0, 0.5)

                            Text {
                                anchors.centerIn: parent
                                text: mapZoom.toString()
                                font.pixelSize: 12
                                color: "white"
                            }
                        }

                        // Zoom Out
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 8
                            color: zoomOutMa.pressed ? Qt.darker(root.surfaceColor, 1.2) : root.surfaceColor

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 24
                                color: root.textColor
                            }

                            MouseArea {
                                id: zoomOutMa
                                anchors.fill: parent
                                onClicked: {
                                    if (mapZoom > 1) mapZoom--
                                }
                            }
                        }
                    }

                    // Pan controls
                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        property real lastX: 0
                        property real lastY: 0

                        onPressed: (mouse) => {
                            lastX = mouse.x
                            lastY = mouse.y
                        }

                        onPositionChanged: (mouse) => {
                            if (pressed) {
                                var deltaLat = (mouse.y - lastY) * 0.0001 * Math.pow(2, 15 - mapZoom)
                                var deltaLon = -(mouse.x - lastX) * 0.0001 * Math.pow(2, 15 - mapZoom)
                                mapCenterLat = Math.max(-85, Math.min(85, mapCenterLat + deltaLat))
                                mapCenterLon = mapCenterLon + deltaLon
                                lastX = mouse.x
                                lastY = mouse.y
                            }
                        }

                        onWheel: (wheel) => {
                            var delta = wheel.angleDelta.y / 120
                            mapZoom = Math.max(1, Math.min(19, mapZoom + delta))
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
                    radius: 4
                    color: Qt.rgba(0, 0, 0, 0.7)

                    Text {
                        id: coordText
                        anchors.centerIn: parent
                        text: mapCenterLat.toFixed(4) + "°, " + mapCenterLon.toFixed(4) + "°"
                        font.pixelSize: 11
                        color: "white"
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
                                    mapCenterLat = Math.max(-85, Math.min(85, val))
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
                                    mapCenterLon = val
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

                        onClicked: {
                            mapCenterLat = 40.6500
                            mapCenterLon = 29.2750
                            mapZoom = 14
                        }
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

                        onClicked: {
                            mapCenterLat = 41.0082
                            mapCenterLon = 28.9784
                            mapZoom = 12
                        }
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

                        onClicked: {
                            mapCenterLat = 40.7000
                            mapCenterLon = 29.5100
                            mapZoom = 15
                        }
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
