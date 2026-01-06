import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

/**
 * BathymetricMapCanvas - ArcGIS tarzı batimetrik harita görselleştirmesi
 *
 * PERFORMANS OPTİMİZE + YUMUŞAK GEÇİŞLER
 * - Rectangle tabanlı hızlı render
 * - Gradient köşe yumuşatma
 * - MultiEffect blur (opsiyonel)
 */
Item {
    id: root

    // Veri özellikleri
    property int gridRows: 5
    property int gridCols: 5
    property var gridDepths: []
    property real minDepth: 0
    property real maxDepth: 30

    // Koordinat özellikleri
    property real startLatitude: 40.71
    property real startLongitude: 29.00
    property real endLatitude: 40.72
    property real endLongitude: 29.01

    // Görsel ayarlar
    property bool showContours: true
    property bool showGrid: false
    property bool showCoordinates: true
    property int contourInterval: 5
    property bool smoothTransitions: true

    // Tema renkleri
    property color containerColor: "#E8EFF5"
    property color labelColor: "#4A5568"

    // Hover durumu
    property real hoverX: -1
    property real hoverY: -1
    property real hoverDepth: -1
    property bool isHovering: false
    property int hoverRow: -1
    property int hoverCol: -1

    // Hücre derinlik değerini al
    function getCellDepth(row, col) {
        if (!gridDepths || gridDepths.length === 0) return 0
        row = Math.max(0, Math.min(row, gridRows - 1))
        col = Math.max(0, Math.min(col, gridCols - 1))
        var index = row * gridCols + col
        if (index >= 0 && index < gridDepths.length) {
            var val = gridDepths[index]
            return (val !== null && val !== undefined && !isNaN(val)) ? val : 0
        }
        return 0
    }

    // Derinliğe göre renk hesapla (optimize edilmiş)
    function getDepthColor(depth) {
        if (depth <= 0 || isNaN(depth)) return "#E8F4F8"
        if (depth < 1) return "#B8E0EE"
        if (depth < 2) return "#8ED0E5"
        if (depth < 4) return "#64C0DC"
        if (depth < 6) return "#45A8C8"
        if (depth < 8) return "#3090B4"
        if (depth < 12) return "#2278A0"
        if (depth < 16) return "#18608C"
        if (depth < 20) return "#104878"
        if (depth < 25) return "#0A3464"
        return "#052850"
    }

    // Koordinat formatla
    function formatCoord(value, isLat) {
        var deg = Math.floor(Math.abs(value))
        var min = ((Math.abs(value) - deg) * 60).toFixed(3)
        var dir = isLat ? (value >= 0 ? "N" : "S") : (value >= 0 ? "E" : "W")
        return deg + "°" + min + "'" + dir
    }

    // Ana container
    Rectangle {
        id: mapContainer
        anchors.fill: parent
        color: root.containerColor
        clip: true

        // Boş veri mesajı
        Text {
            anchors.centerIn: parent
            text: qsTr("Batimetrik veri bekleniyor...")
            font.pixelSize: 14
            color: "#888888"
            visible: !gridDepths || gridDepths.length === 0
        }

        // Harita içeriği
        Item {
            id: mapContent
            anchors.fill: parent
            anchors.margins: showCoordinates ? 25 : 0
            visible: gridDepths && gridDepths.length > 0

            // Grid hücreleri - Yumuşak geçişli
            Grid {
                id: cellGrid
                anchors.fill: parent
                columns: gridCols
                rows: gridRows

                Repeater {
                    id: cellRepeater
                    model: gridRows * gridCols

                    Rectangle {
                        id: cell
                        property int row: Math.floor(index / gridCols)
                        property int col: index % gridCols
                        property real depth: getCellDepth(row, col)

                        // Komşu derinlikler (yumuşak geçiş için)
                        property real depthTop: getCellDepth(row - 1, col)
                        property real depthBottom: getCellDepth(row + 1, col)
                        property real depthLeft: getCellDepth(row, col - 1)
                        property real depthRight: getCellDepth(row, col + 1)

                        // Köşe derinlikleri (diyagonal komşular)
                        property real depthTL: getCellDepth(row - 1, col - 1)
                        property real depthTR: getCellDepth(row - 1, col + 1)
                        property real depthBL: getCellDepth(row + 1, col - 1)
                        property real depthBR: getCellDepth(row + 1, col + 1)

                        // Ortalama köşe derinlikleri
                        property real avgTopLeft: (depth + depthTop + depthLeft + depthTL) / 4
                        property real avgTopRight: (depth + depthTop + depthRight + depthTR) / 4
                        property real avgBottomLeft: (depth + depthBottom + depthLeft + depthBL) / 4
                        property real avgBottomRight: (depth + depthBottom + depthRight + depthBR) / 4

                        width: cellGrid.width / gridCols
                        height: cellGrid.height / gridRows
                        color: getDepthColor(depth)

                        // 4 köşe gradient overlay (yumuşak geçiş için)
                        Item {
                            anchors.fill: parent
                            visible: smoothTransitions

                            // Sol üst köşe
                            Rectangle {
                                width: parent.width / 2
                                height: parent.height / 2
                                anchors.left: parent.left
                                anchors.top: parent.top
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: getDepthColor(cell.avgTopLeft) }
                                    GradientStop { position: 1.0; color: cell.color }
                                }
                                opacity: 0.5
                            }

                            // Sağ üst köşe
                            Rectangle {
                                width: parent.width / 2
                                height: parent.height / 2
                                anchors.right: parent.right
                                anchors.top: parent.top
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: getDepthColor(cell.avgTopRight) }
                                    GradientStop { position: 1.0; color: cell.color }
                                }
                                opacity: 0.5
                            }

                            // Sol alt köşe
                            Rectangle {
                                width: parent.width / 2
                                height: parent.height / 2
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: cell.color }
                                    GradientStop { position: 1.0; color: getDepthColor(cell.avgBottomLeft) }
                                }
                                opacity: 0.5
                            }

                            // Sağ alt köşe
                            Rectangle {
                                width: parent.width / 2
                                height: parent.height / 2
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop { position: 0.0; color: cell.color }
                                    GradientStop { position: 1.0; color: getDepthColor(cell.avgBottomRight) }
                                }
                                opacity: 0.5
                            }
                        }

                        // Derinlik etiketi (hücre içinde)
                        Text {
                            anchors.centerIn: parent
                            text: cell.depth > 0 ? cell.depth.toFixed(1) : ""
                            font.pixelSize: Math.min(parent.width, parent.height) * 0.25
                            font.bold: true
                            color: cell.depth > 8 ? "#FFFFFF" : "#1a1a1a"
                            opacity: 0.8
                            visible: parent.width > 40 && parent.height > 30
                        }
                    }
                }
            }

            // Kontur çizgileri overlay
            Canvas {
                id: contourCanvas
                anchors.fill: parent
                visible: showContours && gridDepths && gridDepths.length > 0
                renderStrategy: Canvas.Cooperative

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    if (!gridDepths || gridDepths.length === 0) return

                    var cellW = width / gridCols
                    var cellH = height / gridRows

                    // Max derinlik bul
                    var maxD = 0
                    for (var i = 0; i < gridDepths.length; i++) {
                        if (gridDepths[i] > maxD) maxD = gridDepths[i]
                    }

                    // Her kontur seviyesi için
                    for (var level = contourInterval; level <= maxD; level += contourInterval) {
                        ctx.strokeStyle = "rgba(0, 0, 0, 0.4)"
                        ctx.lineWidth = 1
                        ctx.beginPath()

                        // Hücre kenarlarında kontur ara
                        for (var row = 0; row < gridRows; row++) {
                            for (var col = 0; col < gridCols; col++) {
                                var d = getCellDepth(row, col)
                                var cx = (col + 0.5) * cellW
                                var cy = (row + 0.5) * cellH

                                // Sağ komşu ile karşılaştır
                                if (col < gridCols - 1) {
                                    var dRight = getCellDepth(row, col + 1)
                                    if ((d < level && dRight >= level) || (d >= level && dRight < level)) {
                                        var t = (level - d) / (dRight - d)
                                        var x = (col + 0.5 + t) * cellW
                                        ctx.moveTo(x, cy - cellH * 0.4)
                                        ctx.lineTo(x, cy + cellH * 0.4)
                                    }
                                }

                                // Alt komşu ile karşılaştır
                                if (row < gridRows - 1) {
                                    var dBottom = getCellDepth(row + 1, col)
                                    if ((d < level && dBottom >= level) || (d >= level && dBottom < level)) {
                                        var t2 = (level - d) / (dBottom - d)
                                        var y = (row + 0.5 + t2) * cellH
                                        ctx.moveTo(cx - cellW * 0.4, y)
                                        ctx.lineTo(cx + cellW * 0.4, y)
                                    }
                                }
                            }
                        }

                        ctx.stroke()
                    }
                }

                Timer {
                    id: contourUpdateTimer
                    interval: 150
                    onTriggered: contourCanvas.requestPaint()
                }
            }

            // Grid çizgileri
            Item {
                anchors.fill: parent
                visible: showGrid

                Repeater {
                    model: gridCols + 1
                    Rectangle {
                        x: index * (parent.width / gridCols)
                        y: 0
                        width: 1
                        height: parent.height
                        color: "#00000030"
                    }
                }

                Repeater {
                    model: gridRows + 1
                    Rectangle {
                        x: 0
                        y: index * (parent.height / gridRows)
                        width: parent.width
                        height: 1
                        color: "#00000030"
                    }
                }
            }
        }

        // Koordinat etiketleri - Sol (Latitude)
        Column {
            anchors.left: parent.left
            anchors.top: mapContent.top
            anchors.bottom: mapContent.bottom
            width: 25
            visible: showCoordinates && gridDepths && gridDepths.length > 0

            Repeater {
                model: gridRows

                Item {
                    width: 25
                    height: mapContent.height / gridRows

                    Text {
                        anchors.centerIn: parent
                        rotation: -90
                        text: {
                            var lat = startLatitude + (index + 0.5) * (endLatitude - startLatitude) / gridRows
                            return lat.toFixed(4) + "°"
                        }
                        font.pixelSize: 8
                        color: root.labelColor
                    }
                }
            }
        }

        // Koordinat etiketleri - Alt (Longitude)
        Row {
            anchors.bottom: parent.bottom
            anchors.left: mapContent.left
            anchors.right: mapContent.right
            height: 25
            visible: showCoordinates && gridDepths && gridDepths.length > 0

            Repeater {
                model: gridCols

                Item {
                    width: mapContent.width / gridCols
                    height: 25

                    Text {
                        anchors.centerIn: parent
                        text: {
                            var lon = startLongitude + (index + 0.5) * (endLongitude - startLongitude) / gridCols
                            return lon.toFixed(4) + "°"
                        }
                        font.pixelSize: 8
                        color: root.labelColor
                    }
                }
            }
        }
    }

    // Hover overlay
    Rectangle {
        id: hoverOverlay
        visible: isHovering && hoverRow >= 0 && hoverCol >= 0
        x: (showCoordinates ? 25 : 0) + hoverCol * ((root.width - (showCoordinates ? 50 : 0)) / gridCols)
        y: (showCoordinates ? 25 : 0) + hoverRow * ((root.height - (showCoordinates ? 50 : 0)) / gridRows)
        width: (root.width - (showCoordinates ? 50 : 0)) / gridCols
        height: (root.height - (showCoordinates ? 50 : 0)) / gridRows
        color: "transparent"
        border.width: 3
        border.color: "#FF5722"
        radius: 2
    }

    // Hover tooltip
    Rectangle {
        id: hoverTooltip
        visible: isHovering && hoverDepth >= 0
        width: tooltipContent.width + 20
        height: tooltipContent.height + 16
        radius: 8
        color: "#2D3748"
        border.width: 1
        border.color: "#4A5568"

        x: Math.min(hoverX + 15, root.width - width - 10)
        y: Math.max(hoverY - height - 10, 10)

        Column {
            id: tooltipContent
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: "Derinlik: " + (hoverDepth >= 0 ? hoverDepth.toFixed(2) + " m" : "-")
                font.pixelSize: 13
                font.bold: true
                color: "white"
            }

            Text {
                text: "Hücre: " + String.fromCharCode(65 + hoverCol) + (hoverRow + 1)
                font.pixelSize: 11
                color: "#A0AEC0"
            }

            Rectangle {
                width: parent.width
                height: 1
                color: "#4A5568"
            }

            Text {
                text: {
                    if (hoverRow < 0 || hoverCol < 0) return ""
                    var lat = startLatitude + (hoverRow + 0.5) * (endLatitude - startLatitude) / gridRows
                    var lon = startLongitude + (hoverCol + 0.5) * (endLongitude - startLongitude) / gridCols
                    return "Lat: " + lat.toFixed(5) + "°\nLon: " + lon.toFixed(5) + "°"
                }
                font.pixelSize: 10
                color: "#A0AEC0"
                lineHeight: 1.3
            }
        }
    }

    // Mouse etkileşimi
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPositionChanged: function(mouse) {
            hoverX = mouse.x
            hoverY = mouse.y

            var offsetX = showCoordinates ? 25 : 0
            var offsetY = showCoordinates ? 25 : 0
            var mapWidth = width - (showCoordinates ? 50 : 0)
            var mapHeight = height - (showCoordinates ? 50 : 0)

            var relX = mouse.x - offsetX
            var relY = mouse.y - offsetY

            if (relX >= 0 && relX < mapWidth && relY >= 0 && relY < mapHeight) {
                hoverCol = Math.floor(relX / (mapWidth / gridCols))
                hoverRow = Math.floor(relY / (mapHeight / gridRows))
                hoverCol = Math.max(0, Math.min(hoverCol, gridCols - 1))
                hoverRow = Math.max(0, Math.min(hoverRow, gridRows - 1))
                hoverDepth = getCellDepth(hoverRow, hoverCol)
                isHovering = true
            } else {
                isHovering = false
            }
        }

        onExited: {
            isHovering = false
        }
    }

    // Veri değişikliklerini izle
    onGridDepthsChanged: contourUpdateTimer.restart()
    onShowContoursChanged: contourUpdateTimer.restart()
    onContourIntervalChanged: contourUpdateTimer.restart()

    function refresh() {
        contourUpdateTimer.restart()
    }
}
