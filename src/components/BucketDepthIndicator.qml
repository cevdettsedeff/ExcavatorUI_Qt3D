import QtQuick
import QtQuick.Controls

/**
 * BucketDepthIndicator - Kepçe Derinlik Göstergesi
 */
Rectangle {
    id: root
    width: 120
    height: 400
    color: "transparent"

    // Derinlik değerleri
    property real maxDepth: 10.0          // Skala üst sınırı (pozitif = su üstü)
    property real minDepth: -25.0         // Skala alt sınırı (negatif = su altı)
    property real waterLevel: 0.0         // Su seviyesi
    property real targetDepth: -15.0      // Hedef kazı derinliği
    property real currentBucketDepth: -5.0

    // Tema renkleri
    property color backgroundColor: themeManager ? themeManager.backgroundColor : "#2d3748"
    property color borderColor: themeManager ? themeManager.borderColor : "#4a5568"

    // Görsel renkler
    property color aboveWaterColor: "#FFFFFF"
    property color waterColor: "#4DD0E1"
    property color overDigColor: "#F44336"
    property color targetLineColor: "#FFEB3B"

    // Hesaplamalar
    property real totalRange: maxDepth - minDepth
    property real barTop: 30
    property real barBottom: height - 30
    property real barHeight: barBottom - barTop

    // Derinlik -> Y pozisyonu (bar içinde)
    function depthToY(depth) {
        var ratio = (maxDepth - depth) / totalRange
        return barTop + ratio * barHeight
    }

    // Sol Skala
    Column {
        id: scaleColumn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: barTop
        width: 40

        Repeater {
            id: scaleRepeater
            model: {
                var values = []
                var range = Math.abs(totalRange)
                var step = range <= 15 ? 2 : (range <= 30 ? 5 : 10)
                var start = Math.ceil(minDepth / step) * step
                var end = Math.floor(maxDepth / step) * step
                for (var d = end; d >= start; d -= step) {
                    values.push(d)
                }
                return values
            }

            Item {
                width: scaleColumn.width
                height: {
                    var idx = index
                    var nextIdx = idx + 1
                    if (nextIdx < scaleRepeater.count) {
                        var thisDepth = scaleRepeater.model[idx]
                        var nextDepth = scaleRepeater.model[nextIdx]
                        return (thisDepth - nextDepth) / totalRange * barHeight
                    }
                    return 30
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.top: parent.top
                    text: modelData + "m"
                    font.pixelSize: 11
                    font.bold: modelData === 0
                    color: modelData === 0 ? "#00BCD4" : "#CCCCCC"
                }

                // Tick çizgisi
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    width: 8
                    height: modelData === 0 ? 3 : 2
                    color: modelData === 0 ? "#00BCD4" : "#888888"
                }
            }
        }
    }

    // Ana Bar
    Rectangle {
        id: mainBar
        x: 48
        y: barTop
        width: 40
        height: barHeight
        color: root.backgroundColor
        radius: 4
        border.width: 2
        border.color: root.borderColor
        clip: true

        // Su üstü bölümü (beyaz)
        Rectangle {
            id: aboveWaterSection
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            y: 2
            height: {
                var waterY = (maxDepth - waterLevel) / totalRange * parent.height
                return Math.max(0, waterY - 2)
            }
            color: root.aboveWaterColor
            radius: 2
        }

        // Su seviyesi çizgisi
        Rectangle {
            id: waterLevelLine
            anchors.left: parent.left
            anchors.right: parent.right
            y: (maxDepth - waterLevel) / totalRange * parent.height - 2
            height: 4
            color: "#00BCD4"
            z: 10
        }

        // Su içi bölümü (cyan)
        Rectangle {
            id: waterSection
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            y: (maxDepth - waterLevel) / totalRange * parent.height
            height: {
                var waterY = (maxDepth - waterLevel) / totalRange * parent.height
                var limitY = currentBucketDepth < targetDepth ?
                    (maxDepth - targetDepth) / totalRange * parent.height :
                    (maxDepth - currentBucketDepth) / totalRange * parent.height
                return Math.max(0, Math.min(limitY, parent.height) - waterY)
            }
            color: root.waterColor

            // Taralı desen
            Canvas {
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (width > 0 && height > 0) {
                        ctx.strokeStyle = "#00000030"
                        ctx.lineWidth = 1
                        for (var i = -height; i < width + height; i += 6) {
                            ctx.beginPath()
                            ctx.moveTo(i, 0)
                            ctx.lineTo(i + height, height)
                            ctx.stroke()
                        }
                    }
                }
            }
        }

        // Hedef altı bölümü (kırmızı - sadece kepçe hedefin altındaysa)
        Rectangle {
            id: overDigSection
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            y: (maxDepth - targetDepth) / totalRange * parent.height
            height: {
                if (currentBucketDepth < targetDepth) {
                    var targetY = (maxDepth - targetDepth) / totalRange * parent.height
                    var bucketY = (maxDepth - currentBucketDepth) / totalRange * parent.height
                    return Math.max(0, Math.min(bucketY, parent.height - 2) - targetY)
                }
                return 0
            }
            color: root.overDigColor
            visible: currentBucketDepth < targetDepth

            Canvas {
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    if (width > 0 && height > 0) {
                        ctx.strokeStyle = "#00000060"
                        ctx.lineWidth = 2
                        for (var i = -height; i < width + height; i += 8) {
                            ctx.beginPath()
                            ctx.moveTo(i, 0)
                            ctx.lineTo(i + height, height)
                            ctx.stroke()
                        }
                    }
                }
            }
        }

        // Hedef çizgisi (sarı, yanıp sönen)
        Rectangle {
            id: targetLine
            anchors.left: parent.left
            anchors.right: parent.right
            y: (maxDepth - targetDepth) / totalRange * parent.height - 3
            height: 6
            color: root.targetLineColor
            visible: targetDepth >= minDepth && targetDepth <= maxDepth
            z: 20

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: targetLine.visible
                NumberAnimation { to: 0.4; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        // Kepçe göstergesi (turuncu üçgen - sağ tarafta)
        Canvas {
            id: bucketIndicator
            x: parent.width - 15
            y: (maxDepth - currentBucketDepth) / totalRange * parent.height - 12
            width: 24
            height: 24
            z: 30

            Component.onCompleted: requestPaint()
            onYChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                // Turuncu üçgen
                ctx.fillStyle = "#FF5722"
                ctx.beginPath()
                ctx.moveTo(0, 12)
                ctx.lineTo(18, 0)
                ctx.lineTo(18, 24)
                ctx.closePath()
                ctx.fill()

                // Beyaz kenar
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 2
                ctx.stroke()
            }
        }
    }

    // Hedef derinlik etiketi (bar sağında)
    Rectangle {
        x: mainBar.x + mainBar.width + 4
        y: depthToY(targetDepth) - 10
        width: 28
        height: 20
        color: root.targetLineColor
        radius: 3
        visible: targetDepth >= minDepth && targetDepth <= maxDepth

        Text {
            anchors.centerIn: parent
            text: Math.abs(targetDepth).toFixed(0)
            font.pixelSize: 10
            font.bold: true
            color: "#000000"
        }
    }

    // Mevcut derinlik göstergesi (alt kısımda)
    Rectangle {
        anchors.horizontalCenter: mainBar.horizontalCenter
        anchors.top: mainBar.bottom
        anchors.topMargin: 6
        width: 60
        height: 22
        radius: 4
        color: currentBucketDepth < targetDepth ? root.overDigColor : root.backgroundColor
        border.width: 1
        border.color: currentBucketDepth < targetDepth ? Qt.darker(root.overDigColor, 1.3) : root.borderColor

        Text {
            anchors.centerIn: parent
            text: currentBucketDepth.toFixed(1) + "m"
            font.pixelSize: 11
            font.bold: true
            color: "#FFFFFF"
        }
    }

    // Animasyonlu geçiş
    Behavior on currentBucketDepth {
        NumberAnimation { duration: 100 }
    }
}
