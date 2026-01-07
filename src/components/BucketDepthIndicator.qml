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
    width: 120
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
    property real barWidth: 35
    property real scaleWidth: 45          // Sol taraftaki skala genişliği
    property color aboveWaterColor: "#FFFFFF"      // Su seviyesi üstü (beyaz)
    property color waterColor: "#4DD0E1"           // Su (cyan)
    property color normalDigColor: "#2196F3"       // Normal kazı (mavi)
    property color overDigColor: "#F44336"         // Hedef altı kazı (kırmızı)
    property color targetLineColor: "#FFEB3B"      // Hedef çizgisi (sarı)
    property color textColor: "#FFFFFF"
    property color scaleTextColor: "#B0B0B0"       // Skala yazı rengi

    // Hesaplamalar
    property real totalRange: maxDepth - minDepth
    property real pixelsPerMeter: (barContainer.height) / totalRange
    property int scaleInterval: calculateScaleInterval()

    // Skala aralığını hesapla (toplam aralığa göre uygun adım)
    function calculateScaleInterval() {
        if (totalRange <= 10) return 1
        if (totalRange <= 20) return 2
        if (totalRange <= 50) return 5
        if (totalRange <= 100) return 10
        return 20
    }

    // Derinlik -> Y pozisyonu dönüşümü
    function depthToY(depth) {
        return (maxDepth - depth) * pixelsPerMeter
    }

    // Sol taraf skala
    Item {
        id: scaleArea
        anchors.left: parent.left
        anchors.top: barContainer.top
        anchors.bottom: barContainer.bottom
        width: root.scaleWidth

        // Skala çizgileri ve değerleri
        Repeater {
            model: Math.floor(totalRange / scaleInterval) + 1

            Item {
                width: parent.width
                height: 20
                y: (index * scaleInterval) * pixelsPerMeter - 10

                property real depthValue: maxDepth - (index * scaleInterval)

                // Yatay çizgi
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 10
                    height: depthValue === 0 ? 3 : 2  // Su seviyesi daha kalın
                    color: depthValue === 0 ? "#00BCD4" : "#808080"
                }

                // Derinlik değeri
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: depthValue.toFixed(0) + "m"
                    font.pixelSize: 10
                    font.bold: depthValue === 0
                    color: depthValue === 0 ? "#00BCD4" : root.scaleTextColor
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // Ara çizgiler (her metre için küçük çizgi)
        Repeater {
            model: Math.floor(totalRange) + 1

            Rectangle {
                x: parent.width - 5
                y: index * pixelsPerMeter
                width: 5
                height: 1
                color: "#505050"
                visible: index % scaleInterval !== 0  // Ana çizgilerde görünmesin
            }
        }
    }

    // Bar container - Tema rengi ile
    Rectangle {
        id: barContainer
        anchors.left: scaleArea.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 5
        anchors.topMargin: 15
        anchors.bottomMargin: 15
        anchors.leftMargin: 2
        width: root.barWidth
        color: root.backgroundColor
        radius: 4
        border.width: 2
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

        // Su seviyesi üstü (beyaz alan)
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

        // Hedef altı kazı bölümü (kırmızı, taralı)
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

            Canvas {
                id: overDigCanvas
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = "#00000060"
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

        // Hedef derinlik çizgisi
        Rectangle {
            id: targetLine
            anchors.left: parent.left
            anchors.right: parent.right
            y: depthToY(targetDepth) - 3
            height: 6
            color: root.targetLineColor
            visible: targetDepth >= minDepth && targetDepth <= maxDepth

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
            anchors.rightMargin: -12
            y: depthToY(currentBucketDepth) - 10
            width: 20
            height: 20

            Canvas {
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.fillStyle = "#FF5722"
                    ctx.beginPath()
                    ctx.moveTo(0, 10)
                    ctx.lineTo(20, 0)
                    ctx.lineTo(20, 20)
                    ctx.closePath()
                    ctx.fill()

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
            height: 4
            color: "#00BCD4"
        }
    }

    // Sağ taraf etiketler
    Column {
        anchors.left: barContainer.right
        anchors.top: barContainer.top
        anchors.bottom: barContainer.bottom
        anchors.leftMargin: 8
        width: 55

        // Hedef derinlik etiketi
        Item {
            width: parent.width
            height: 20
            y: depthToY(targetDepth) - 10
            visible: targetDepth >= minDepth && targetDepth <= maxDepth

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "▶ " + targetDepth.toFixed(1) + "m"
                font.pixelSize: 10
                font.bold: true
                color: root.targetLineColor
            }
        }
    }

    // Mevcut derinlik etiketi (bar altında)
    Rectangle {
        anchors.top: barContainer.bottom
        anchors.horizontalCenter: barContainer.horizontalCenter
        anchors.topMargin: 5
        width: 70
        height: 22
        radius: 4
        color: currentBucketDepth < targetDepth ? root.overDigColor : root.backgroundColor
        border.width: 1
        border.color: currentBucketDepth < targetDepth ? Qt.darker(root.overDigColor, 1.2) : root.borderColor

        Text {
            anchors.centerIn: parent
            text: currentBucketDepth.toFixed(2) + "m"
            font.pixelSize: 11
            font.bold: true
            color: root.textColor
        }
    }

    // Değişiklik animasyonları
    Behavior on currentBucketDepth {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    onCurrentBucketDepthChanged: {
        overDigCanvas.requestPaint()
    }
}
