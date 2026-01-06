import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * BathymetricLegend - ArcGIS tarzı profesyonel batimetri lejantı
 *
 * Özellikler:
 * - Gradyan renk skalası
 * - Derinlik etiketleri
 * - Başlık ve birim gösterimi
 */
Item {
    id: root

    property string title: "Derinlik (m)"
    property real minDepth: 0
    property real maxDepth: 30
    property int tickCount: 7
    property color textColor: "#2D3748"
    property color backgroundColor: "white"
    property real borderRadius: 8

    // Derinlik renk paleti (BathymetricMapCanvas ile aynı)
    property var depthColors: [
        { depth: 0, color: "#E8F4F8" },
        { depth: 0.1, color: "#C6E7F2" },
        { depth: 0.2, color: "#A8DAEB" },
        { depth: 0.5, color: "#7AC5DE" },
        { depth: 1, color: "#55B0D4" },
        { depth: 2, color: "#3A9CC8" },
        { depth: 3, color: "#2589BC" },
        { depth: 5, color: "#1A75A8" },
        { depth: 10, color: "#125E8C" },
        { depth: 15, color: "#0B4770" },
        { depth: 20, color: "#063554" },
        { depth: 30, color: "#022338" }
    ]

    implicitWidth: 80
    implicitHeight: 250

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        radius: borderRadius
        border.width: 1
        border.color: "#E2E8F0"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Başlık
            Text {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 11
                font.bold: true
                color: root.textColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            // Gradyan skala ve etiketler
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                // Gradyan çubuğu
                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.fillHeight: true
                    radius: 4
                    border.width: 1
                    border.color: "#CBD5E0"

                    // Gradyan arka plan
                    Canvas {
                        id: gradientCanvas
                        anchors.fill: parent
                        anchors.margins: 1

                        onPaint: {
                            var ctx = getContext("2d")
                            var h = height

                            // Gradient - üstten alta (sığdan derine)
                            for (var y = 0; y < h; y++) {
                                var depth = (y / h) * maxDepth
                                ctx.fillStyle = getDepthColor(depth)
                                ctx.fillRect(0, y, width, 1)
                            }
                        }

                        function getDepthColor(depth) {
                            if (depth <= 0) return depthColors[0].color

                            for (var i = depthColors.length - 1; i >= 0; i--) {
                                if (depth >= depthColors[i].depth) {
                                    if (i < depthColors.length - 1) {
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

                        Component.onCompleted: requestPaint()
                    }
                }

                // Etiketler
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Tick işaretleri ve değerler
                    Repeater {
                        model: tickCount

                        Item {
                            property real tickDepth: (index / (tickCount - 1)) * maxDepth
                            width: parent.width
                            height: 16
                            y: (index / (tickCount - 1)) * (parent.height - 16)

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                // Tick çizgisi
                                Rectangle {
                                    width: 6
                                    height: 1
                                    color: "#718096"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Değer
                                Text {
                                    text: tickDepth.toFixed(0)
                                    font.pixelSize: 10
                                    color: root.textColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }

            // Alt bilgi
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#E2E8F0"
            }

            // Min-Max bilgisi
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: depthColors[0].color
                    border.width: 1
                    border.color: "#CBD5E0"
                }

                Text {
                    text: "Sığ"
                    font.pixelSize: 9
                    color: "#718096"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 8; height: 1 }

                Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: depthColors[depthColors.length - 1].color
                    border.width: 1
                    border.color: "#CBD5E0"
                }

                Text {
                    text: "Derin"
                    font.pixelSize: 9
                    color: "#718096"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // MaxDepth değişince yeniden çiz
    onMaxDepthChanged: gradientCanvas.requestPaint()
}
