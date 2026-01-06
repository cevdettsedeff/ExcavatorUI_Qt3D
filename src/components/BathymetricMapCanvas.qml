import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * BathymetricMapCanvas - ArcGIS tarzı batimetrik harita görselleştirmesi
 *
 * Özellikler:
 * - Bilinear interpolasyon ile yumuşak renk geçişleri
 * - Kontur çizgileri (eş derinlik eğrileri)
 * - Profesyonel renk skalası
 * - Hover bilgi gösterimi
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
    property int contourInterval: 5  // metre
    property real contourLineWidth: 1.5
    property color contourColor: "#1a1a1a"
    property bool showLabels: true
    property real interpolationResolution: 4  // Her hücre kaç piksel

    // Hover durumu
    property real hoverX: -1
    property real hoverY: -1
    property real hoverDepth: -1
    property bool isHovering: false

    // Derinlik renk paleti (ArcGIS Batimetri stili - açık mavi'den koyu maviye)
    property var depthColors: [
        { depth: 0, color: "#E8F4F8" },      // Çok sığ - neredeyse beyaz
        { depth: 0.1, color: "#C6E7F2" },    // Çok sığ
        { depth: 0.2, color: "#A8DAEB" },    // Sığ
        { depth: 0.5, color: "#7AC5DE" },    // Sığ-orta
        { depth: 1, color: "#55B0D4" },      // Orta sığ
        { depth: 2, color: "#3A9CC8" },      // Orta
        { depth: 3, color: "#2589BC" },      // Orta-derin
        { depth: 5, color: "#1A75A8" },      // Derin
        { depth: 10, color: "#125E8C" },     // Çok derin
        { depth: 15, color: "#0B4770" },     // Aşırı derin
        { depth: 20, color: "#063554" },     // Ultra derin
        { depth: 30, color: "#022338" }      // Maksimum derin
    ]

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

    // Bilinear interpolasyon
    function bilinearInterpolate(x, y) {
        // Grid koordinatlarına dönüştür
        var cellWidth = mapCanvas.width / gridCols
        var cellHeight = mapCanvas.height / gridRows

        var gx = x / cellWidth
        var gy = y / cellHeight

        var x0 = Math.floor(gx)
        var y0 = Math.floor(gy)
        var x1 = Math.min(x0 + 1, gridCols - 1)
        var y1 = Math.min(y0 + 1, gridRows - 1)

        x0 = Math.max(0, Math.min(x0, gridCols - 1))
        y0 = Math.max(0, Math.min(y0, gridRows - 1))

        var fx = gx - Math.floor(gx)
        var fy = gy - Math.floor(gy)

        // 4 köşe değeri
        var d00 = getCellDepth(y0, x0)
        var d10 = getCellDepth(y0, x1)
        var d01 = getCellDepth(y1, x0)
        var d11 = getCellDepth(y1, x1)

        // Bilinear interpolasyon
        var d0 = d00 * (1 - fx) + d10 * fx
        var d1 = d01 * (1 - fx) + d11 * fx
        var depth = d0 * (1 - fy) + d1 * fy

        return depth
    }

    // Derinliğe göre renk hesapla
    function getDepthColor(depth) {
        if (depth <= 0 || isNaN(depth)) {
            return "#E8F4F8"  // Kara/sığ
        }

        // Renk paletinde arama
        for (var i = depthColors.length - 1; i >= 0; i--) {
            if (depth >= depthColors[i].depth) {
                if (i < depthColors.length - 1) {
                    // İki renk arası interpolasyon
                    var c1 = depthColors[i]
                    var c2 = depthColors[i + 1]
                    var t = (depth - c1.depth) / (c2.depth - c1.depth)
                    t = Math.min(1, Math.max(0, t))
                    return lerpColor(c1.color, c2.color, t)
                }
                return depthColors[i].color
            }
        }
        return depthColors[0].color
    }

    // Renk interpolasyonu
    function lerpColor(color1, color2, t) {
        var r1 = parseInt(color1.substr(1, 2), 16)
        var g1 = parseInt(color1.substr(3, 2), 16)
        var b1 = parseInt(color1.substr(5, 2), 16)

        var r2 = parseInt(color2.substr(1, 2), 16)
        var g2 = parseInt(color2.substr(3, 2), 16)
        var b2 = parseInt(color2.substr(5, 2), 16)

        var r = Math.round(r1 + (r2 - r1) * t)
        var g = Math.round(g1 + (g2 - g1) * t)
        var b = Math.round(b1 + (b2 - b1) * t)

        return "#" + r.toString(16).padStart(2, '0') +
                     g.toString(16).padStart(2, '0') +
                     b.toString(16).padStart(2, '0')
    }

    // Harita canvas'ı
    Canvas {
        id: mapCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            if (!gridDepths || gridDepths.length === 0) {
                // Boş veri - gri arka plan
                ctx.fillStyle = "#E0E0E0"
                ctx.fillRect(0, 0, width, height)

                ctx.fillStyle = "#888888"
                ctx.font = "14px sans-serif"
                ctx.textAlign = "center"
                ctx.fillText("Batimetrik veri bekleniyor...", width / 2, height / 2)
                return
            }

            // Interpolasyonlu harita çizimi
            var cellWidth = width / gridCols
            var cellHeight = height / gridRows
            var step = Math.max(1, Math.floor(interpolationResolution))

            // Her piksel için renk hesapla
            for (var py = 0; py < height; py += step) {
                for (var px = 0; px < width; px += step) {
                    var depth = bilinearInterpolate(px, py)
                    ctx.fillStyle = getDepthColor(depth)
                    ctx.fillRect(px, py, step, step)
                }
            }

            // Kontur çizgileri
            if (showContours && contourInterval > 0) {
                drawContours(ctx)
            }

            // Grid çizgileri (opsiyonel)
            if (showGrid) {
                ctx.strokeStyle = "rgba(0, 0, 0, 0.2)"
                ctx.lineWidth = 0.5

                for (var i = 0; i <= gridCols; i++) {
                    var x = i * cellWidth
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }

                for (var j = 0; j <= gridRows; j++) {
                    var y = j * cellHeight
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }

        function drawContours(ctx) {
            ctx.strokeStyle = contourColor
            ctx.lineWidth = contourLineWidth

            var cellWidth = width / gridCols
            var cellHeight = height / gridRows
            var step = 2  // Kontur hassasiyeti

            // Kontur seviyeleri
            var maxD = 0
            for (var i = 0; i < gridDepths.length; i++) {
                if (gridDepths[i] > maxD) maxD = gridDepths[i]
            }

            // Her kontur seviyesi için
            for (var level = contourInterval; level <= maxD + contourInterval; level += contourInterval) {
                ctx.beginPath()
                var started = false

                // Marching squares basitleştirilmiş versiyonu
                for (var py = 0; py < height - step; py += step) {
                    for (var px = 0; px < width - step; px += step) {
                        var d00 = bilinearInterpolate(px, py)
                        var d10 = bilinearInterpolate(px + step, py)
                        var d01 = bilinearInterpolate(px, py + step)
                        var d11 = bilinearInterpolate(px + step, py + step)

                        // Kontur bu hücreden geçiyor mu?
                        var min = Math.min(d00, d10, d01, d11)
                        var max = Math.max(d00, d10, d01, d11)

                        if (level >= min && level <= max) {
                            // Basit kontur çizimi - kenarları bul
                            var points = []

                            // Sol kenar
                            if ((d00 < level && d01 >= level) || (d00 >= level && d01 < level)) {
                                var t = (level - d00) / (d01 - d00)
                                points.push({x: px, y: py + t * step})
                            }
                            // Üst kenar
                            if ((d00 < level && d10 >= level) || (d00 >= level && d10 < level)) {
                                var t = (level - d00) / (d10 - d00)
                                points.push({x: px + t * step, y: py})
                            }
                            // Sağ kenar
                            if ((d10 < level && d11 >= level) || (d10 >= level && d11 < level)) {
                                var t = (level - d10) / (d11 - d10)
                                points.push({x: px + step, y: py + t * step})
                            }
                            // Alt kenar
                            if ((d01 < level && d11 >= level) || (d01 >= level && d11 < level)) {
                                var t = (level - d01) / (d11 - d01)
                                points.push({x: px + t * step, y: py + step})
                            }

                            // Çizgi çiz
                            if (points.length >= 2) {
                                ctx.moveTo(points[0].x, points[0].y)
                                ctx.lineTo(points[1].x, points[1].y)
                            }
                        }
                    }
                }

                ctx.stroke()

                // Kontur etiketi (opsiyonel)
                if (showLabels) {
                    // Her seviye için bir etiket
                    var labelPlaced = false
                    for (var ly = height * 0.3; ly < height * 0.7 && !labelPlaced; ly += 50) {
                        for (var lx = width * 0.3; lx < width * 0.7 && !labelPlaced; lx += 50) {
                            var d = bilinearInterpolate(lx, ly)
                            if (Math.abs(d - level) < contourInterval * 0.3) {
                                ctx.fillStyle = "#000000"
                                ctx.font = "bold 10px sans-serif"
                                ctx.textAlign = "center"
                                ctx.textBaseline = "middle"

                                // Arka plan
                                var text = level + "m"
                                var textWidth = ctx.measureText(text).width
                                ctx.fillStyle = "rgba(255, 255, 255, 0.8)"
                                ctx.fillRect(lx - textWidth/2 - 2, ly - 6, textWidth + 4, 12)

                                ctx.fillStyle = contourColor
                                ctx.fillText(text, lx, ly)
                                labelPlaced = true
                            }
                        }
                    }
                }
            }
        }

        // Veri değişince yeniden çiz
        Connections {
            target: root
            function onGridDepthsChanged() { mapCanvas.requestPaint() }
            function onGridRowsChanged() { mapCanvas.requestPaint() }
            function onGridColsChanged() { mapCanvas.requestPaint() }
            function onShowContoursChanged() { mapCanvas.requestPaint() }
            function onContourIntervalChanged() { mapCanvas.requestPaint() }
            function onShowGridChanged() { mapCanvas.requestPaint() }
        }

        Component.onCompleted: requestPaint()
    }

    // Hover işaretçisi
    Rectangle {
        id: hoverMarker
        visible: isHovering && hoverDepth >= 0
        width: 8
        height: 8
        radius: 4
        color: "#FF5722"
        border.width: 2
        border.color: "white"
        x: hoverX - 4
        y: hoverY - 4
    }

    // Hover bilgi baloncuğu
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
                text: "Derinlik: " + (hoverDepth >= 0 ? hoverDepth.toFixed(2) + " m" : "-")
                font.pixelSize: 12
                font.bold: true
                color: "white"
            }

            Text {
                text: "Konum: " + Math.floor(hoverX) + ", " + Math.floor(hoverY)
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
            hoverDepth = bilinearInterpolate(mouse.x, mouse.y)
            isHovering = true
        }

        onExited: {
            isHovering = false
        }
    }

    // Yeniden çizim fonksiyonu (dışarıdan çağrılabilir)
    function refresh() {
        mapCanvas.requestPaint()
    }
}
