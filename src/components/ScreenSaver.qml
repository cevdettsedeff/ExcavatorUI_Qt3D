import QtQuick
import QtQuick.Controls

/**
 * ScreenSaver - Windows tarzı bekleme ekranı
 *
 * Saat, tarih ve ekskavatör resmi gösterir.
 * Herhangi bir dokunma/fare hareketi ile kapanır.
 */
Rectangle {
    id: screenSaver

    signal dismissed()

    // Arka plan tema rengiyle uyumlu (biraz daha koyu)
    color: themeManager ? Qt.darker(themeManager.backgroundColor, 1.3) : "#1a202c"

    // Türkçe gün ve ay isimleri
    property var turkishDays: ["Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi"]
    property var turkishMonths: ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]

    // Türkçe tarih formatı
    function formatTurkishDate(date) {
        var dayName = turkishDays[date.getDay()]
        var day = date.getDate()
        var monthName = turkishMonths[date.getMonth()]
        var year = date.getFullYear()
        return dayName + ", " + day + " " + monthName + " " + year
    }

    // Dil kontrolü
    property bool isTurkish: translationService && translationService.currentLanguage === "tr_TR"

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
            // Türkçe ise Türkçe format, değilse İngilizce
            if (screenSaver.isTurkish) {
                dateText.text = screenSaver.formatTurkishDate(now)
            } else {
                dateText.text = Qt.formatDate(now, "dddd, d MMMM yyyy")
            }
        }
    }

    // Yavaş hareket animasyonu için pozisyon
    property real contentX: (width - contentColumn.width) / 2
    property real contentY: (height - contentColumn.height) / 2

    // Çok yavaş drift animasyonu (Windows screensaver gibi)
    SequentialAnimation {
        id: driftAnimation
        running: screenSaver.visible
        loops: Animation.Infinite

        ParallelAnimation {
            NumberAnimation {
                target: screenSaver
                property: "contentX"
                from: screenSaver.width * 0.25
                to: screenSaver.width * 0.45
                duration: 45000  // 45 saniye - çok yavaş
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: screenSaver
                property: "contentY"
                from: screenSaver.height * 0.3
                to: screenSaver.height * 0.45
                duration: 40000  // 40 saniye
                easing.type: Easing.InOutSine
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: screenSaver
                property: "contentX"
                from: screenSaver.width * 0.45
                to: screenSaver.width * 0.35
                duration: 50000  // 50 saniye
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: screenSaver
                property: "contentY"
                from: screenSaver.height * 0.45
                to: screenSaver.height * 0.25
                duration: 42000  // 42 saniye
                easing.type: Easing.InOutSine
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: screenSaver
                property: "contentX"
                from: screenSaver.width * 0.35
                to: screenSaver.width * 0.25
                duration: 38000  // 38 saniye
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                target: screenSaver
                property: "contentY"
                from: screenSaver.height * 0.25
                to: screenSaver.height * 0.3
                duration: 48000  // 48 saniye
                easing.type: Easing.InOutSine
            }
        }
    }

    // Ana içerik
    Column {
        id: contentColumn
        x: screenSaver.contentX
        y: screenSaver.contentY
        spacing: 25

        // Ekskavatör resmi (PNG) - Büyütülmüş boyut
        Image {
            id: excavatorImage
            source: "qrc:/ExcavatorUI_Qt3D/resources/screensaver/excavator_screensaver.png"
            width: 550
            height: 330
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            smooth: true
            antialiasing: true

            // Resim yüklenemezse Canvas ile fallback çiz
            visible: status === Image.Ready

            // Hafif parıldama efekti
            SequentialAnimation on opacity {
                running: excavatorImage.visible && screenSaver.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.85; to: 1.0; duration: 3000 }
                NumberAnimation { from: 1.0; to: 0.85; duration: 3000 }
            }
        }

        // Fallback: Resim yoksa Canvas ile çiz - Büyütülmüş boyut
        Canvas {
            id: excavatorCanvas
            width: 550
            height: 330
            anchors.horizontalCenter: parent.horizontalCenter
            visible: excavatorImage.status !== Image.Ready

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var scale = 4.0  // Büyütülmüş ölçek
                var offsetX = 25
                var offsetY = 45

                // Silüet rengi (sarı-turuncu tonları)
                var mainColor = "#F5A623"
                ctx.fillStyle = mainColor
                ctx.strokeStyle = mainColor
                ctx.lineWidth = 2

                // Alt şasi (paletler)
                ctx.fillRect(offsetX + 10 * scale, offsetY + 50 * scale, 90 * scale, 15 * scale)

                // Paletler detay
                ctx.fillStyle = "#2C2C2C"
                for (var i = 0; i < 8; i++) {
                    ctx.fillRect(offsetX + (15 + i * 11) * scale, offsetY + 52 * scale, 8 * scale, 11 * scale)
                }

                // Üst yapı (döner platform)
                ctx.fillStyle = mainColor
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
                ctx.fillStyle = mainColor
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
                ctx.fillStyle = mainColor
                ctx.beginPath()
                ctx.moveTo(offsetX + 15 * scale, offsetY + 50 * scale)
                ctx.lineTo(offsetX + 10 * scale, offsetY + 35 * scale)
                ctx.lineTo(offsetX + 25 * scale, offsetY + 30 * scale)
                ctx.lineTo(offsetX + 25 * scale, offsetY + 50 * scale)
                ctx.closePath()
                ctx.fill()
            }

            // Hafif parıldama efekti
            SequentialAnimation on opacity {
                running: excavatorCanvas.visible && screenSaver.visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.85; to: 1.0; duration: 3000 }
                NumberAnimation { from: 1.0; to: 0.85; duration: 3000 }
            }
        }

        // Saat - Büyütülmüş boyut
        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: timeText
                text: "00:00"
                font.pixelSize: 140
                font.weight: Font.Light
                font.family: "Segoe UI"
                color: "#ffffff"
            }

            Text {
                id: secondsText
                text: ":00"
                font.pixelSize: 70
                font.weight: Font.Light
                font.family: "Segoe UI"
                color: "#888888"
                anchors.baseline: timeText.baseline
            }
        }

        // Tarih - Büyütülmüş boyut
        Text {
            id: dateText
            text: "Pazartesi, 1 Ocak 2024"
            font.pixelSize: 36
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
                NumberAnimation { from: 0.3; to: 1.0; duration: 2000 }
                NumberAnimation { from: 1.0; to: 0.3; duration: 2000 }
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

    // Opacity AppRoot tarafından kontrol edilir (binding loop önlemek için)
}
