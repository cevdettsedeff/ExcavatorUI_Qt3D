import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - Mockup'a göre tasarlanmış
Rectangle {
    id: statusBar
    height: 50
    color: "#1a1a1a"

    // Proje adı property'si
    property string projectName: "AŞ-KAZI-042"
    property bool rtkConnected: true
    property bool imuOk: true
    property int alarmCount: 1

    signal userIconClicked()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 12

        // RTK Durumu
        Row {
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            // WiFi benzeri RTK ikonu
            Image {
                source: "qrc:/ExcavatorUI_Qt3D/resources/icons/wifi.svg"
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                visible: false // SVG yoksa text kullan
            }

            Text {
                text: "📶"
                font.pixelSize: 18
                color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "RTK"
                font.pixelSize: 14
                font.bold: true
                color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // IMU Durumu
        Row {
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                width: 22
                height: 22
                radius: 3
                color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: statusBar.imuOk ? "✓" : "✗"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                }
            }

            Text {
                text: "IMU"
                font.pixelSize: 14
                font.bold: true
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: statusBar.imuOk ? "OK" : "ERR"
                font.pixelSize: 14
                font.bold: true
                color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Alarm Sayısı (Kırmızı Badge)
        Rectangle {
            width: 28
            height: 28
            radius: 14
            color: "#f44336"
            visible: statusBar.alarmCount > 0
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: statusBar.alarmCount.toString()
                font.pixelSize: 14
                font.bold: true
                color: "#ffffff"
            }
        }

        // Boşluk
        Item {
            Layout.fillWidth: true
        }

        // Proje Adı
        Text {
            text: "Proje: " + statusBar.projectName
            font.pixelSize: 14
            font.bold: true
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }

        // Kullanıcı İkonu
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: "#2a2a2a"
            border.color: "#505050"
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "👤"
                font.pixelSize: 20
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
