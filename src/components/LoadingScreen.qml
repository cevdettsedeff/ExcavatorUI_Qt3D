import QtQuick
import QtQuick.Controls

Rectangle {
    id: loadingScreen
    anchors.fill: parent
    color: "#1a1a1a"

    property real progress: 0.0

    signal loadingComplete()

    Column {
        anchors.centerIn: parent
        spacing: 30

        // Logo veya başlık
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ExcavatorUI"
            font.pixelSize: 48
            font.bold: true
            color: "#4CAF50"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Yükleniyor..."
            font.pixelSize: 20
            color: "#888888"
        }

        // Progress bar container
        Rectangle {
            width: 400
            height: 8
            radius: 4
            color: "#333333"
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: progressBar
                width: parent.width * loadingScreen.progress
                height: parent.height
                radius: parent.radius
                color: "#4CAF50"

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }

        // Yüzde göstergesi
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(loadingScreen.progress * 100) + "%"
            font.pixelSize: 16
            color: "#4CAF50"
        }
    }

    // Loading timer - simulates loading process
    Timer {
        id: loadingTimer
        interval: 50
        repeat: true
        running: true

        onTriggered: {
            loadingScreen.progress += 0.02
            if (loadingScreen.progress >= 1.0) {
                loadingScreen.progress = 1.0
                stop()
                // Kısa bir gecikme sonrası loading complete signal gönder
                completeTimer.start()
            }
        }
    }

    Timer {
        id: completeTimer
        interval: 300
        onTriggered: {
            loadingScreen.loadingComplete()
        }
    }
}
