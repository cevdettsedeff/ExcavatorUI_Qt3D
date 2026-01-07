import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * BathymetricLegend - ArcGIS tarzı profesyonel batimetri lejantı
 *
 * PERFORMANS OPTİMİZE - Rectangle Gradient tabanlı
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

                // Gradyan çubuğu - QML Gradient (çok hızlı)
                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.fillHeight: true
                    radius: 4
                    border.width: 1
                    border.color: "#CBD5E0"

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#E8F4F8" }
                        GradientStop { position: 0.05; color: "#A8DAEB" }
                        GradientStop { position: 0.1; color: "#55B0D4" }
                        GradientStop { position: 0.2; color: "#3A9CC8" }
                        GradientStop { position: 0.35; color: "#1A75A8" }
                        GradientStop { position: 0.5; color: "#125E8C" }
                        GradientStop { position: 0.7; color: "#0B4770" }
                        GradientStop { position: 1.0; color: "#022338" }
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
                    color: "#E8F4F8"
                    border.width: 1
                    border.color: "#CBD5E0"
                }

                Text {
                    text: qsTr("Sığ")
                    font.pixelSize: 9
                    color: "#718096"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item { width: 8; height: 1 }

                Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: "#022338"
                    border.width: 1
                    border.color: "#CBD5E0"
                }

                Text {
                    text: qsTr("Derin")
                    font.pixelSize: 9
                    color: "#718096"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
