import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1400
    height: 800
    visible: true
    title: qsTr("Excavator Dashboard - 3D Model & Map")
    color: "#1a1a1a"

    // Ana layout - yan yana iki panel
    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // Sol panel - 3D Excavator Modeli (2/3 genişlik)
        Rectangle {
            Layout.preferredWidth: root.width * 2 / 3
            Layout.fillHeight: true
            color: "#2a2a2a"
            
            ExcavatorView {
                anchors.fill: parent
            }

            // Panel başlığı
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "#1a1a1a"
                
                Text {
                    anchors.centerIn: parent
                    text: "3D Araba Modeli"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#ffffff"
                }
            }
        }

        // Ayırıcı çizgi
        Rectangle {
            Layout.fillHeight: true
            width: 2
            color: "#404040"
        }

        // Sağ panel - Harita (1/3 genişlik)
        Rectangle {
            Layout.preferredWidth: root.width * 1 / 3
            Layout.fillHeight: true
            color: "#2a2a2a"
            
            MapView {
                anchors.fill: parent
            }

            // Panel başlığı
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50
                color: "#1a1a1a"
                
                Text {
                    anchors.centerIn: parent
                    text: "Harita"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#ffffff"
                }
            }
        }
    }
}
