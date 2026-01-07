import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * MapDecorations - Harita dekorasyon elementleri
 *
 * İçerir:
 * - Kuzey oku (North arrow)
 * - Ölçek çubuğu (Scale bar)
 */
Item {
    id: root

    property real scale: 1.0  // metre/piksel
    property color textColor: "#2D3748"
    property color accentColor: "#1A75A8"

    implicitWidth: 120
    implicitHeight: 100

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Kuzey Oku
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 40
            Layout.preferredHeight: 50

            Canvas {
                id: northArrowCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    var cx = width / 2
                    var cy = height / 2 + 5

                    // Ok gövdesi
                    ctx.beginPath()
                    ctx.moveTo(cx, 5)           // Tepe
                    ctx.lineTo(cx + 12, cy)     // Sağ alt
                    ctx.lineTo(cx + 4, cy - 5)  // Sağ iç
                    ctx.lineTo(cx + 4, height - 5)  // Sağ alt gövde
                    ctx.lineTo(cx - 4, height - 5)  // Sol alt gövde
                    ctx.lineTo(cx - 4, cy - 5)  // Sol iç
                    ctx.lineTo(cx - 12, cy)     // Sol alt
                    ctx.closePath()

                    // Gradyan dolgu
                    var gradient = ctx.createLinearGradient(cx - 12, 0, cx + 12, 0)
                    gradient.addColorStop(0, "#1A75A8")
                    gradient.addColorStop(0.5, "#2589BC")
                    gradient.addColorStop(1, "#0B4770")
                    ctx.fillStyle = gradient
                    ctx.fill()

                    // Çerçeve
                    ctx.strokeStyle = "#063554"
                    ctx.lineWidth = 1
                    ctx.stroke()
                }

                Component.onCompleted: requestPaint()
            }

            // N harfi
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.top
                anchors.bottomMargin: -2
                text: "N"
                font.pixelSize: 14
                font.bold: true
                color: root.accentColor
            }
        }

        // Ölçek Çubuğu
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 35

            Column {
                anchors.centerIn: parent
                spacing: 4

                // Çubuk
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0

                    Repeater {
                        model: 4

                        Rectangle {
                            width: 20
                            height: 8
                            color: index % 2 === 0 ? root.accentColor : "white"
                            border.width: 1
                            border.color: "#063554"
                        }
                    }
                }

                // Etiketler
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 80

                    Text {
                        width: 20
                        text: "0"
                        font.pixelSize: 9
                        color: root.textColor
                        horizontalAlignment: Text.AlignLeft
                    }

                    Item { width: 40; height: 1 }

                    Text {
                        width: 20
                        text: Math.round(scale * 80) + "m"
                        font.pixelSize: 9
                        color: root.textColor
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
