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

    // Ana container - dikey layout
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Üst menü bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#0d0d0d"
            z: 100

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20

                // Sol taraf - Başlık ve kullanıcı bilgisi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Text {
                        text: "🚜"
                        font.pixelSize: 24
                    }

                    Text {
                        text: "Excavator Dashboard"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                    }

                    Rectangle {
                        width: 2
                        height: 30
                        color: "#404040"
                    }

                    Text {
                        text: authService && authService.currentUser ? "Hoşgeldin, " + authService.currentUser : ""
                        font.pixelSize: 14
                        color: "#888888"
                    }
                }

                // Sağ taraf - Logout butonu
                Button {
                    id: logoutButton
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 35
                    text: "Çıkış"

                    background: Rectangle {
                        color: logoutButton.pressed ? "#c0392b" : (logoutButton.hovered ? "#e74c3c" : "#34495e")
                        radius: 5

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    contentItem: Text {
                        text: logoutButton.text
                        font.pixelSize: 13
                        font.bold: true
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        console.log("Logout butonu tıklandı")
                        if (authService) {
                            authService.logout()
                        }
                    }
                }
            }
        }

        // Alt çizgi
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#404040"
        }

        // Ana içerik - yan yana iki panel
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                    text: "3D Ekskavatör Modeli"
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
}
