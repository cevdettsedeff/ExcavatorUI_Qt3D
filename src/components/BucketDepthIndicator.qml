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
    width: 100
    height: 400
    color: "transparent"

    // Derinlik değerleri (metre cinsinden, pozitif = yukarı, negatif = aşağı)
    property real maxDepth: 20.0          // Skala üst sınırı (su seviyesi üstü)
    property real minDepth: -20.0         // Skala alt sınırı (maksimum derinlik)
    property real waterLevel: 0.0         // Su seviyesi (referans noktası)
    property real targetDepth: -10.0      // Hedef kazı derinliği
    property real currentBucketDepth: -5.0 // Kepçenin mevcut derinliği

    // Tema renkleri
    property color backgroundColor: themeManager ? themeManager.backgroundColor : "#2d3748"
    property color borderColor: themeManager ? themeManager.borderColor : "#4a5568"

    // Görsel ayarlar
    property real barWidth: 35            // Daha kalın bar
    property real labelWidth: 55
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

    // Bar container - Tema rengi ile
    Rectangle {
        id: barContainer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 5
        anchors.topMargin: 25
        anchors.bottomMargin: 25
        width: root.barWidth
        color: root.backgroundColor      // Tema arka plan rengi
        radius: 4
        border.width: 2                  // Daha kalın kenarlık
        border.color: root.borderColor
        clip: true

        // İç gölge efekti
        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            color: "transparent"
            radius: parent.radius - 2
            border.width: 1
            border.color: "#00000040"
        }

        // Su seviyesi üstü (beyaz/gri alan)
        Rectangle {
            id: aboveWaterSection
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 2
            height: Math.max(0, depthToY(waterLevel) - 2)
            color: root.aboveWaterColor
            radius: 3

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
            anchors.leftMargin: 2
            anchors.rightMargin: 2
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
                    ctx.strokeStyle = "#00000040"
                    ctx.lineWidth = 2        // Daha kalın çizgiler

                    // Diagonal lines
                    for (var i = -height; i < width + height; i += 8) {
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
            anchors.leftMargin: 2
            anchors.rightMargin: 2
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
            anchors.leftMargin: 2
            anchors.rightMargin: 2
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
                    ctx.strokeStyle = "#00000060"
                    ctx.lineWidth = 3        // Daha kalın çizgiler

                    // Diagonal lines (daha belirgin)
                    for (var i = -height; i < width + height; i += 10) {
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
            y: depthToY(targetDepth) - 3
            height: 6                    // Daha kalın çizgi
            color: root.targetLineColor
            visible: targetDepth >= minDepth && targetDepth <= maxDepth

            // Yanıp sönen efekt
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.5; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        // Kepçe konumu göstergesi (üçgen) - Daha büyük
        Item {
            id: bucketIndicator
            anchors.right: parent.right
            anchors.rightMargin: -12
            y: depthToY(currentBucketDepth) - 10
            width: 20
            height: 20

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    // Üçgen çiz
                    ctx.fillStyle = "#FF5722"
                    ctx.beginPath()
                    ctx.moveTo(0, 10)
                    ctx.lineTo(20, 0)
                    ctx.lineTo(20, 20)
                    ctx.closePath()
                    ctx.fill()

                    // Kenarlık
                    ctx.strokeStyle = "#FFFFFF"
                    ctx.lineWidth = 2
                    ctx.stroke()
                }
            }
        }

        // Su seviyesi çizgisi
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(waterLevel) - 2
            height: 4                    // Daha kalın çizgi
            color: "#00BCD4"
        }

        // Skala çizgileri - Bar içinde
        Repeater {
            model: Math.floor(totalRange / 5) + 1

            Rectangle {
                x: 0
                y: barContainer.height * index / (totalRange / 5)
                width: 12                // Daha uzun çizgiler
                height: 3                // Daha kalın çizgiler
                color: "#FFFFFFA0"
                visible: index > 0 && index < Math.floor(totalRange / 5)
            }
        }

        // Ara skala çizgileri
        Repeater {
            model: Math.floor(totalRange) + 1

            Rectangle {
                x: 0
                y: barContainer.height * index / totalRange
                width: index % 5 === 0 ? 0 : 6    // 5'in katları için ana çizgi var
                height: 2
                color: "#FFFFFF50"
                visible: index > 0 && index < Math.floor(totalRange) && index % 5 !== 0
            }
        }
    }

    // Üst etiket (max depth)
    Text {
        anchors.top: parent.top
        anchors.left: barContainer.right
        anchors.leftMargin: 8
        text: maxDepth.toFixed(1) + "m"
        font.pixelSize: 12
        font.bold: true
        color: root.textColor
    }

    // Alt etiket (current bucket depth)
    Text {
        anchors.bottom: parent.bottom
        anchors.left: barContainer.right
        anchors.leftMargin: 8
        text: currentBucketDepth.toFixed(2) + "m"
        font.pixelSize: 12
        font.bold: true
        color: currentBucketDepth < targetDepth ? root.overDigColor : root.textColor
    }

    // Hedef derinlik etiketi
    Text {
        anchors.left: barContainer.right
        anchors.leftMargin: 8
        y: barContainer.y + depthToY(targetDepth) - 8
        text: "▶ " + targetDepth.toFixed(1) + "m"
        font.pixelSize: 11
        font.bold: true
        color: root.targetLineColor
        visible: targetDepth >= minDepth && targetDepth <= maxDepth
    }

    // Su seviyesi etiketi
    Text {
        anchors.left: barContainer.right
        anchors.leftMargin: 8
        y: barContainer.y + depthToY(waterLevel) - 8
        text: "~~ 0m"
        font.pixelSize: 11
        font.bold: true
        color: "#00BCD4"
        visible: waterLevel >= minDepth && waterLevel <= maxDepth
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
