import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - Detaylı sensör durumları
Rectangle {
    id: statusBar
    height: 50
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // Proje adı property'si
    property string projectName: "AŞ-KAZI-042"
    property bool rtkConnected: true
    property string rtkStatus: "FIX"  // FIX, FLOAT, SINGLE, NONE
    property bool imuOk: true
    property int alarmCount: 1
    property bool gpsConnected: true
    property int satellites: 12

    signal userIconClicked()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        // RTK Durumu - Detaylı
        Rectangle {
            Layout.preferredWidth: 85
            Layout.preferredHeight: 36
            radius: 5
            color: "#2a2a2a"
            border.color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 5

                // Sinyal ikonu - Row ile yatay dizilim
                Row {
                    spacing: 1
                    anchors.verticalCenter: parent.verticalCenter
                    height: 16

                    Repeater {
                        model: 4

                        Rectangle {
                            width: 3
                            height: 4 + index * 3
                            radius: 1
                            anchors.bottom: parent.bottom
                            color: {
                                var strength = statusBar.rtkConnected ? (statusBar.rtkStatus === "FIX" ? 4 : (statusBar.rtkStatus === "FLOAT" ? 3 : 2)) : 0
                                return index < strength ? "#4CAF50" : "#555555"
                            }
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: "RTK"
                        font.pixelSize: 11
                        font.bold: true
                        color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                    }

                    Text {
                        text: statusBar.rtkStatus
                        font.pixelSize: 9
                        color: "#888888"
                    }
                }
            }
        }

        // IMU Durumu - Detaylı
        Rectangle {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 36
            radius: 5
            color: "#2a2a2a"
            border.color: statusBar.imuOk ? "#4CAF50" : "#f44336"
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 5

                // Durum ikonu
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: statusBar.imuOk ? "✓" : "!"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        text: "IMU"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        text: statusBar.imuOk ? "OK" : "ERR"
                        font.pixelSize: 9
                        color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                    }
                }
            }
        }

        // Alarm Badge
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 5
            color: statusBar.alarmCount > 0 ? "#f44336" : "#2a2a2a"
            visible: true
            border.color: statusBar.alarmCount > 0 ? "#ff6b6b" : "#444444"
            border.width: 1

            Column {
                anchors.centerIn: parent
                spacing: 0

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "▲"
                    font.pixelSize: 10
                    color: statusBar.alarmCount > 0 ? "#ffffff" : "#666666"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: statusBar.alarmCount.toString()
                    font.pixelSize: 12
                    font.bold: true
                    color: statusBar.alarmCount > 0 ? "#ffffff" : "#666666"
                }
            }
        }

        // Boşluk
        Item {
            Layout.fillWidth: true
        }

        // Proje Adı
        Rectangle {
            Layout.preferredHeight: 36
            Layout.preferredWidth: projeText.width + 20
            radius: 5
            color: "#2a2a2a"
            border.color: "#444444"
            border.width: 1

            Text {
                id: projeText
                anchors.centerIn: parent
                text: "Proje: " + statusBar.projectName
                font.pixelSize: 12
                font.bold: true
                color: "#ffffff"
            }
        }

        // Kullanıcı İkonu
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 18
            color: "#2a2a2a"
            border.color: "#505050"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "☰"
                font.pixelSize: 18
                color: "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: statusBar.userIconClicked()
            }
        }
    }

    // Alt çizgi
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#333333"
    }
}
