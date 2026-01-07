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
    property real maxDepth: 10.0          // Skala üst sınırı
    property real minDepth: -25.0         // Skala alt sınırı
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
    property real barHeight: height - 60  // Üst ve alt margin

    // Derinlik -> pixel pozisyonu
    function depthToPixel(depth) {
        return 30 + ((maxDepth - depth) / totalRange) * barHeight
    }

    // Sol skala
    Item {
        id: scaleArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 45

        // Skala değerleri
        Repeater {
            model: {
                var values = []
                var step = totalRange <= 20 ? 5 : 10
                for (var d = Math.ceil(minDepth / step) * step; d <= maxDepth; d += step) {
                    values.push(d)
                }
                return values
            }

            Item {
                width: scaleArea.width
                y: depthToPixel(modelData) - 8
                height: 16

                // Değer metni
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData + "m"
                    font.pixelSize: 10
                    font.bold: modelData === 0
                    color: modelData === 0 ? "#00BCD4" : "#A0A0A0"
                }

                // Çizgi
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: modelData === 0 ? 3 : 2
                    color: modelData === 0 ? "#00BCD4" : "#606060"
                }
            }
        }
    }

    // Ana bar
    Rectangle {
        id: mainBar
        anchors.left: scaleArea.right
        anchors.leftMargin: 2
        y: 30
        width: 35
        height: barHeight
        color: root.backgroundColor
        radius: 4
        border.width: 2
        border.color: root.borderColor
        clip: true

        // Su üstü (beyaz)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            y: 2
            height: Math.max(0, (maxDepth - waterLevel) / totalRange * parent.height - 4)
            color: root.aboveWaterColor
            radius: 2
        }

        // Su bölümü (cyan taralı)
        Rectangle {
            id: waterSection
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2
            y: Math.max(2, (maxDepth - waterLevel) / totalRange * parent.height)
            height: {
                var waterY = (maxDepth - waterLevel) / totalRange * parent.height
                var bucketY = (maxDepth - currentBucketDepth) / totalRange * parent.height
                return Math.max(0, Math.min(bucketY, parent.height - 2) - waterY)
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
                    ctx.strokeStyle = "#00000030"
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

        // Hedef altı (kırmızı taralı)
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
                    return Math.min(bucketY - targetY, parent.height - targetY - 2)
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
                    ctx.strokeStyle = "#00000050"
                    ctx.lineWidth = 3
                    for (var i = -height; i < width + height; i += 10) {
                        ctx.beginPath()
                        ctx.moveTo(i, 0)
                        ctx.lineTo(i + height, height)
                        ctx.stroke()
                    }
                }
            }
        }

        // Hedef çizgisi (sarı)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            y: (maxDepth - targetDepth) / totalRange * parent.height - 3
            height: 6
            color: root.targetLineColor
            visible: targetDepth >= minDepth && targetDepth <= maxDepth

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.4; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        // Su seviyesi çizgisi
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            y: (maxDepth - waterLevel) / totalRange * parent.height - 2
            height: 4
            color: "#00BCD4"
        }

        // Kepçe göstergesi (turuncu üçgen)
        Canvas {
            id: bucketIndicator
            x: parent.width - 5
            y: (maxDepth - currentBucketDepth) / totalRange * parent.height - 10
            width: 20
            height: 20

            Component.onCompleted: requestPaint()
            onYChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = "#FF5722"
                ctx.beginPath()
                ctx.moveTo(0, 10)
                ctx.lineTo(15, 0)
                ctx.lineTo(15, 20)
                ctx.closePath()
                ctx.fill()
                ctx.strokeStyle = "#FFFFFF"
                ctx.lineWidth = 2
                ctx.stroke()
            }
        }
    }

    // Mevcut derinlik kutusu
    Rectangle {
        anchors.horizontalCenter: mainBar.horizontalCenter
        anchors.top: mainBar.bottom
        anchors.topMargin: 8
        width: 65
        height: 24
        radius: 4
        color: currentBucketDepth < targetDepth ? root.overDigColor : root.backgroundColor
        border.width: 1
        border.color: currentBucketDepth < targetDepth ? Qt.darker(root.overDigColor, 1.2) : root.borderColor

        Text {
            anchors.centerIn: parent
            text: currentBucketDepth.toFixed(2) + "m"
            font.pixelSize: 11
            font.bold: true
            color: "#FFFFFF"
        }
    }

    // Hedef etiketi
    Text {
        x: mainBar.x + mainBar.width + 5
        y: depthToPixel(targetDepth) - 8
        text: "▶" + targetDepth.toFixed(0) + "m"
        font.pixelSize: 10
        font.bold: true
        color: root.targetLineColor
        visible: targetDepth >= minDepth && targetDepth <= maxDepth
    }

    Behavior on currentBucketDepth {
        NumberAnimation { duration: 150 }
    }
}
