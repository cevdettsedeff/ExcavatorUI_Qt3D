import QtQuick
import QtQuick.Controls

/**
 * ScreenSaver - Windows tarzı bekleme ekranı
 *
 * Saat, tarih ve ekskavatör silüeti gösterir.
 * Herhangi bir dokunma/fare hareketi ile kapanır.
 */
Rectangle {
    id: screenSaver

    signal dismissed()

    color: "#000000"

    // Saat ve tarih için timer
    Timer {
        id: clockTimer
        interval: 1000
        running: screenSaver.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            timeText.text = Qt.formatTime(now, "HH:mm")
            secondsText.text = Qt.formatTime(now, ":ss")
            dateText.text = Qt.formatDate(now, "dddd, d MMMM yyyy")
        }
    }

    // Yavaş hareket animasyonu için pozisyon
    property real contentX: (parent.width - contentColumn.width) / 2
    property real contentY: (parent.height - contentColumn.height) / 2

    // Yavaş drift animasyonu (Windows screensaver gibi)
    SequentialAnimation {
        id: driftAnimation
        running: screenSaver.visible
        loops: Animation.Infinite

        ParallelAnimation {
            NumberAnimation {
                target: screenSaver
                property: "contentX"
                from: screenSaver.width * 0.2
                to: screenSaver.width * 0.5
                duration: 15000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: screenSaver
                property: "contentY"
                from: screenSaver.height * 0.3
                to: screenSaver.height * 0.5
                duration: 12000
                easing.type: Easing.InOutSine
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: screenSaver
                property: "contentX"
                from: screenSaver.width * 0.5
                to: screenSaver.width * 0.3
                duration: 13000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: screenSaver
                property: "contentY"
                from: screenSaver.height * 0.5
                to: screenSaver.height * 0.2
                duration: 14000
                easing.type: Easing.InOutSine
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: screenSaver
                property: "contentX"
                from: screenSaver.width * 0.3
                to: screenSaver.width * 0.2
                duration: 11000
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: screenSaver
                property: "contentY"
                from: screenSaver.height * 0.2
                to: screenSaver.height * 0.3
                duration: 16000
                easing.type: Easing.InOutSine
            }
        }
    }

    // Ana içerik
    Column {
        id: contentColumn
        x: screenSaver.contentX
        y: screenSaver.contentY
        spacing: 20

        // Ekskavatör silüeti (Canvas ile çizim)
        Canvas {
            id: excavatorCanvas
            width: 280
            height: 160
            anchors.horizontalCenter: parent.horizontalCenter

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var scale = 2.0
                var offsetX = 20
                var offsetY = 30

                // Silüet rengi (sarı-turuncu tonları)
                ctx.fillStyle = "#F5A623"
                ctx.strokeStyle = "#F5A623"
                ctx.lineWidth = 2

                // Alt şasi (paletler)
                ctx.fillRect(offsetX + 10 * scale, offsetY + 50 * scale, 90 * scale, 15 * scale)

                // Paletler detay
                ctx.fillStyle = "#2C2C2C"
                for (var i = 0; i < 8; i++) {
                    ctx.fillRect(offsetX + (15 + i * 11) * scale, offsetY + 52 * scale, 8 * scale, 11 * scale)
                }

                // Üst yapı (döner platform)
                ctx.fillStyle = "#F5A623"
                ctx.beginPath()
                ctx.moveTo(offsetX + 25 * scale, offsetY + 50 * scale)
                ctx.lineTo(offsetX + 30 * scale, offsetY + 25 * scale)
                ctx.lineTo(offsetX + 85 * scale, offsetY + 25 * scale)
                ctx.lineTo(offsetX + 90 * scale, offsetY + 50 * scale)
                ctx.closePath()
                ctx.fill()

                // Kabin
                ctx.fillStyle = "#1a1a1a"
                ctx.fillRect(offsetX + 32 * scale, offsetY + 28 * scale, 20 * scale, 20 * scale)
                ctx.fillStyle = "#87CEEB"
                ctx.fillRect(offsetX + 34 * scale, offsetY + 30 * scale, 16 * scale, 12 * scale)

                // Boom (ana kol)
                ctx.fillStyle = "#F5A623"
                ctx.save()
                ctx.translate(offsetX + 55 * scale, offsetY + 35 * scale)
                ctx.rotate(-0.6)
                ctx.fillRect(0, -4 * scale, 45 * scale, 8 * scale)
                ctx.restore()

                // Arm (ikinci kol)
                ctx.save()
                ctx.translate(offsetX + 92 * scale, offsetY + 12 * scale)
                ctx.rotate(0.8)
                ctx.fillRect(0, -3 * scale, 35 * scale, 6 * scale)
                ctx.restore()

                // Kepçe
                ctx.fillStyle = "#888888"
                ctx.beginPath()
                ctx.moveTo(offsetX + 115 * scale, offsetY + 35 * scale)
                ctx.lineTo(offsetX + 130 * scale, offsetY + 35 * scale)
                ctx.lineTo(offsetX + 135 * scale, offsetY + 50 * scale)
                ctx.lineTo(offsetX + 120 * scale, offsetY + 55 * scale)
                ctx.lineTo(offsetX + 110 * scale, offsetY + 45 * scale)
                ctx.closePath()
                ctx.fill()

                // Kepçe dişleri
                ctx.fillStyle = "#555555"
                for (var j = 0; j < 4; j++) {
                    ctx.beginPath()
                    ctx.moveTo(offsetX + (122 + j * 4) * scale, offsetY + 55 * scale)
                    ctx.lineTo(offsetX + (124 + j * 4) * scale, offsetY + 60 * scale)
                    ctx.lineTo(offsetX + (126 + j * 4) * scale, offsetY + 55 * scale)
                    ctx.closePath()
                    ctx.fill()
                }

                // Karşı ağırlık
                ctx.fillStyle = "#F5A623"
                ctx.beginPath()
                ctx.moveTo(offsetX + 15 * scale, offsetY + 50 * scale)
                ctx.lineTo(offsetX + 10 * scale, offsetY + 35 * scale)
                ctx.lineTo(offsetX + 25 * scale, offsetY + 30 * scale)
                ctx.lineTo(offsetX + 25 * scale, offsetY + 50 * scale)
                ctx.closePath()
                ctx.fill()
            }
        }

        // Saat
        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: timeText
                text: "00:00"
                font.pixelSize: 96
                font.weight: Font.Light
                font.family: "Segoe UI"
                color: "#ffffff"
            }

            Text {
                id: secondsText
                text: ":00"
                font.pixelSize: 48
                font.weight: Font.Light
                font.family: "Segoe UI"
                color: "#888888"
                anchors.baseline: timeText.baseline
            }
        }

        // Tarih
        Text {
            id: dateText
            text: "Pazartesi, 1 Ocak 2024"
            font.pixelSize: 24
            font.weight: Font.Normal
            font.family: "Segoe UI"
            color: "#aaaaaa"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Alt yazı
        Text {
            text: qsTr("Devam etmek için dokunun")
            font.pixelSize: 14
            color: "#666666"
            anchors.horizontalCenter: parent.horizontalCenter

            SequentialAnimation on opacity {
                running: screenSaver.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.3; to: 1.0; duration: 1500 }
                NumberAnimation { from: 1.0; to: 0.3; duration: 1500 }
            }
        }
    }

    // Tüm ekranı kaplayan dokunma alanı
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: screenSaver.dismissed()
        onPressed: screenSaver.dismissed()
        onPositionChanged: {
            // Fare hareket ettiğinde de kapat
            if (pressed || containsMouse) {
                screenSaver.dismissed()
            }
        }
    }

    // Klavye tuşlarını yakala
    Keys.onPressed: function(event) {
        screenSaver.dismissed()
        event.accepted = true
    }

    // Görünür olduğunda focus al
    onVisibleChanged: {
        if (visible) {
            forceActiveFocus()
        }
    }

    // Fade in/out animasyonları
    opacity: 0

    Behavior on opacity {
        NumberAnimation { duration: 500 }
    }

    // Görünürlük kontrolü için states
    states: [
        State {
            name: "visible"
            when: screenSaver.visible
            PropertyChanges { target: screenSaver; opacity: 1 }
        }
    ]
}
