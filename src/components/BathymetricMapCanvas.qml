import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * BathymetricMapCanvas - ArcGIS tarzı batimetrik harita görselleştirmesi
 *
 * PERFORMANS OPTİMİZE - Rectangle tabanlı hızlı render
 */
Item {
    id: root

    // Veri özellikleri
    property int gridRows: 5
    property int gridCols: 5
    property var gridDepths: []
    property real minDepth: 0
    property real maxDepth: 30

    // Görsel ayarlar
    property bool showContours: true
    property bool showGrid: false
    property int contourInterval: 5

    // Hover durumu
    property real hoverX: -1
    property real hoverY: -1
    property real hoverDepth: -1
    property bool isHovering: false

    // Hücre derinlik değerini al
    function getCellDepth(row, col) {
        if (!gridDepths || gridDepths.length === 0) return 0
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
        if (depth < 1) return "#A8DAEB"
        if (depth < 3) return "#55B0D4"
        if (depth < 5) return "#3A9CC8"
        if (depth < 10) return "#1A75A8"
        if (depth < 15) return "#125E8C"
        if (depth < 20) return "#0B4770"
        if (depth < 25) return "#063554"
        return "#022338"
    }

    // Ana container
    Rectangle {
        anchors.fill: parent
        color: "#E0E0E0"

        // Boş veri mesajı
        Text {
            anchors.centerIn: parent
            text: qsTr("Batimetrik veri bekleniyor...")
            font.pixelSize: 14
            color: "#888888"
            visible: !gridDepths || gridDepths.length === 0
        }

        // Grid hücreleri - Rectangle tabanlı (çok hızlı)
        Grid {
            id: cellGrid
            anchors.fill: parent
            columns: gridCols
            rows: gridRows
            visible: gridDepths && gridDepths.length > 0

            Repeater {
                id: cellRepeater
                model: gridRows * gridCols

                Rectangle {
                    id: cell
                    property int row: Math.floor(index / gridCols)
                    property int col: index % gridCols
                    property real depth: getCellDepth(row, col)

                    width: cellGrid.width / gridCols
                    height: cellGrid.height / gridRows
                    color: getDepthColor(depth)

                    // Gradient efekti için iç Rectangle
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.lighter(cell.color, 1.1) }
                            GradientStop { position: 1.0; color: Qt.darker(cell.color, 1.1) }
                        }
                        opacity: 0.3
                    }

                    // Grid çizgisi
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: "#00000020"
                        visible: showGrid && col < gridCols - 1
                    }
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: "#00000020"
                        visible: showGrid && row < gridRows - 1
                    }
                }
            }
        }

        // Kontur çizgileri overlay (basitleştirilmiş)
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

                ctx.strokeStyle = "#1a1a1a"
                ctx.lineWidth = 1.5

                // Max derinlik bul
                var maxD = 0
                for (var i = 0; i < gridDepths.length; i++) {
                    if (gridDepths[i] > maxD) maxD = gridDepths[i]
                }

                // Her kontur seviyesi için basit çizim
                for (var level = contourInterval; level <= maxD; level += contourInterval) {
                    ctx.beginPath()

                    // Yatay tarama
                    for (var row = 0; row < gridRows - 1; row++) {
                        for (var col = 0; col < gridCols - 1; col++) {
                            var d00 = getCellDepth(row, col)
                            var d10 = getCellDepth(row, col + 1)
                            var d01 = getCellDepth(row + 1, col)
                            var d11 = getCellDepth(row + 1, col + 1)

                            var minD = Math.min(d00, d10, d01, d11)
                            var maxDCell = Math.max(d00, d10, d01, d11)

                            if (level >= minD && level <= maxDCell) {
                                var cx = (col + 0.5) * cellW
                                var cy = (row + 0.5) * cellH

                                // Basit kontur noktası
                                ctx.moveTo(cx - 3, cy)
                                ctx.lineTo(cx + 3, cy)
                            }
                        }
                    }

                    ctx.stroke()

                    // Kontur etiketi
                    var labelX = width * 0.1 + (level / maxD) * width * 0.3
                    var labelY = height * 0.5

                    ctx.fillStyle = "rgba(255, 255, 255, 0.9)"
                    ctx.fillRect(labelX - 15, labelY - 8, 30, 16)
                    ctx.fillStyle = "#1a1a1a"
                    ctx.font = "bold 10px sans-serif"
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText(level + "m", labelX, labelY)
                }
            }

            // Sadece gerektiğinde yeniden çiz
            Timer {
                id: contourUpdateTimer
                interval: 100
                onTriggered: contourCanvas.requestPaint()
            }
        }
    }

    // Hover overlay
    Rectangle {
        id: hoverOverlay
        visible: isHovering
        x: Math.floor(hoverX / (width / gridCols)) * (width / gridCols)
        y: Math.floor(hoverY / (height / gridRows)) * (height / gridRows)
        width: parent.width / gridCols
        height: parent.height / gridRows
        color: "transparent"
        border.width: 2
        border.color: "#FF5722"
        radius: 2
    }

    // Hover tooltip
    Rectangle {
        id: hoverTooltip
        visible: isHovering && hoverDepth >= 0
        width: tooltipContent.width + 16
        height: tooltipContent.height + 12
        radius: 6
        color: "#2D3748"
        border.width: 1
        border.color: "#4A5568"

        x: Math.min(hoverX + 15, root.width - width - 10)
        y: Math.max(hoverY - height - 10, 10)

        Column {
            id: tooltipContent
            anchors.centerIn: parent
            spacing: 2

            Text {
                text: "Derinlik: " + (hoverDepth >= 0 ? hoverDepth.toFixed(1) + " m" : "-")
                font.pixelSize: 12
                font.bold: true
                color: "white"
            }

            Text {
                property int cellRow: Math.floor(hoverY / (root.height / gridRows))
                property int cellCol: Math.floor(hoverX / (root.width / gridCols))
                text: "Hücre: " + String.fromCharCode(65 + cellCol) + (cellRow + 1)
                font.pixelSize: 10
                color: "#A0AEC0"
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

            var cellRow = Math.floor(mouse.y / (height / gridRows))
            var cellCol = Math.floor(mouse.x / (width / gridCols))
            cellRow = Math.max(0, Math.min(cellRow, gridRows - 1))
            cellCol = Math.max(0, Math.min(cellCol, gridCols - 1))

            hoverDepth = getCellDepth(cellRow, cellCol)
            isHovering = true
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
