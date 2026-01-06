import QtQuick
import QtQuick.Controls

/**
 * BucketDepthIndicator - Kepçe Derinlik Göstergesi
 *
 * Kepçenin mevcut derinliğini ve hedef derinliği görsel olarak gösterir.
 * Hedef derinliğin altına inildiğinde taralı (hatched) gösterim yapar.
 */
Rectangle {
    id: root
    width: 80
    height: 400
    color: "transparent"

    // Derinlik değerleri (metre cinsinden, pozitif = yukarı, negatif = aşağı)
    property real maxDepth: 20.0          // Skala üst sınırı (su seviyesi üstü)
    property real minDepth: -20.0         // Skala alt sınırı (maksimum derinlik)
    property real waterLevel: 0.0         // Su seviyesi (referans noktası)
    property real targetDepth: -10.0      // Hedef kazı derinliği
    property real currentBucketDepth: -5.0 // Kepçenin mevcut derinliği

    // Görsel ayarlar
    property real barWidth: 25
    property real labelWidth: 50
    property color aboveWaterColor: "#E8E8E8"      // Su seviyesi üstü (beyaz/gri)
    property color waterColor: "#4DD0E1"           // Su (cyan)
    property color normalDigColor: "#2196F3"       // Normal kazı (mavi)
    property color overDigColor: "#F44336"         // Hedef altı kazı (kırmızı)
    property color targetLineColor: "#FFEB3B"      // Hedef çizgisi (sarı)
    property color textColor: "#FFFFFF"

    // Hesaplamalar
    property real totalRange: maxDepth - minDepth
    property real pixelsPerMeter: (barContainer.height) / totalRange

    // Derinlik -> Y pozisyonu dönüşümü
    function depthToY(depth) {
        return (maxDepth - depth) * pixelsPerMeter
    }

    // Bar container
    Rectangle {
        id: barContainer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 5
        anchors.topMargin: 25
        anchors.bottomMargin: 25
        width: root.barWidth
        color: "#1a1a1a"
        radius: 3
        border.width: 1
        border.color: "#404040"
        clip: true

        // Su seviyesi üstü (beyaz/gri alan)
        Rectangle {
            id: aboveWaterSection
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: Math.max(0, depthToY(waterLevel))
            color: root.aboveWaterColor
            radius: 2

            // Alt köşeleri düzleştir
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.radius
                color: parent.color
            }
        }

        // Su bölümü (cyan, taralı)
        Item {
            id: waterSection
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(waterLevel)
            height: Math.max(0, depthToY(Math.max(currentBucketDepth, targetDepth)) - y)
            clip: true

            Rectangle {
                anchors.fill: parent
                color: root.waterColor
            }

            // Taralı desen (su için)
            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = "#00000030"
                    ctx.lineWidth = 1

                    // Diagonal lines
                    for (var i = -height; i < width + height; i += 6) {
                        ctx.beginPath()
                        ctx.moveTo(i, 0)
                        ctx.lineTo(i + height, height)
                        ctx.stroke()
                    }
                }
            }
        }

        // Normal kazı bölümü (mavi) - su ile hedef arası
        Rectangle {
            id: normalDigSection
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(waterLevel)
            height: {
                var digStart = depthToY(waterLevel)
                var digEnd = depthToY(Math.min(currentBucketDepth, targetDepth))
                return Math.max(0, digEnd - digStart)
            }
            color: root.normalDigColor
            visible: currentBucketDepth < waterLevel
        }

        // Hedef altı kazı bölümü (kırmızı, taralı) - hedefin altında kalan kısım
        Item {
            id: overDigSection
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(targetDepth)
            height: {
                if (currentBucketDepth < targetDepth) {
                    return depthToY(currentBucketDepth) - depthToY(targetDepth)
                }
                return 0
            }
            clip: true
            visible: currentBucketDepth < targetDepth

            Rectangle {
                anchors.fill: parent
                color: root.overDigColor
            }

            // Taralı desen (hedef altı için)
            Canvas {
                id: overDigCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = "#00000050"
                    ctx.lineWidth = 2

                    // Diagonal lines (daha belirgin)
                    for (var i = -height; i < width + height; i += 8) {
                        ctx.beginPath()
                        ctx.moveTo(i, 0)
                        ctx.lineTo(i + height, height)
                        ctx.stroke()
                    }
                }
            }
        }

        // Hedef derinlik çizgisi
        Rectangle {
            id: targetLine
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(targetDepth) - 2
            height: 4
            color: root.targetLineColor
            visible: targetDepth >= minDepth && targetDepth <= maxDepth

            // Yanıp sönen efekt
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        // Kepçe konumu göstergesi (üçgen)
        Item {
            id: bucketIndicator
            anchors.right: parent.right
            anchors.rightMargin: -8
            y: depthToY(currentBucketDepth) - 8
            width: 16
            height: 16

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    // Üçgen çiz
                    ctx.fillStyle = "#FF5722"
                    ctx.beginPath()
                    ctx.moveTo(0, 8)
                    ctx.lineTo(16, 0)
                    ctx.lineTo(16, 16)
                    ctx.closePath()
                    ctx.fill()

                    // Kenarlık
                    ctx.strokeStyle = "#FFFFFF"
                    ctx.lineWidth = 1
                    ctx.stroke()
                }
            }
        }

        // Su seviyesi çizgisi
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(waterLevel) - 1
            height: 2
            color: "#00BCD4"
        }
    }

    // Üst etiket (max depth)
    Text {
        anchors.top: parent.top
        anchors.left: barContainer.right
        anchors.leftMargin: 5
        text: maxDepth.toFixed(1) + "m"
        font.pixelSize: 11
        font.bold: true
        color: root.textColor
    }

    // Alt etiket (min depth / current bucket)
    Text {
        anchors.bottom: parent.bottom
        anchors.left: barContainer.right
        anchors.leftMargin: 5
        text: currentBucketDepth.toFixed(2) + "m"
        font.pixelSize: 11
        font.bold: true
        color: currentBucketDepth < targetDepth ? root.overDigColor : root.textColor
    }

    // Hedef derinlik etiketi
    Text {
        anchors.left: barContainer.right
        anchors.leftMargin: 5
        y: barContainer.y + depthToY(targetDepth) - 6
        text: "▶ " + targetDepth.toFixed(1) + "m"
        font.pixelSize: 10
        font.bold: true
        color: root.targetLineColor
        visible: targetDepth >= minDepth && targetDepth <= maxDepth
    }

    // Su seviyesi etiketi
    Text {
        anchors.left: barContainer.right
        anchors.leftMargin: 5
        y: barContainer.y + depthToY(waterLevel) - 6
        text: "~~ 0m"
        font.pixelSize: 10
        color: "#00BCD4"
        visible: waterLevel >= minDepth && waterLevel <= maxDepth
    }

    // Skala çizgileri
    Column {
        anchors.left: barContainer.left
        anchors.top: barContainer.top
        anchors.bottom: barContainer.bottom
        width: barContainer.width

        Repeater {
            model: Math.floor(totalRange / 5) + 1

            Item {
                width: parent.width
                height: barContainer.height / (totalRange / 5)
                y: index * height

                // Ana çizgi
                Rectangle {
                    anchors.left: parent.left
                    width: 8
                    height: 2
                    color: "#FFFFFF60"
                }

                // Ara çizgiler
                Repeater {
                    model: 4

                    Rectangle {
                        anchors.left: parent.left
                        y: (index + 1) * parent.height / 5
                        width: 4
                        height: 1
                        color: "#FFFFFF30"
                    }
                }
            }
        }
    }

    // Değişiklik animasyonları
    Behavior on currentBucketDepth {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    // Canvas'ları yeniden çiz
    onCurrentBucketDepthChanged: {
        overDigCanvas.requestPaint()
    }
}
