import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import ExcavatorUI_Qt3D

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

                    Rectangle {
                        width: 2
                        height: 30
                        color: "#404040"
                    }

                    // Navbar Menü Butonları
                    Row {
                        spacing: 10

                        Button {
                            id: excavatorViewButton
                            text: "Ekskavatör"
                            width: 110
                            height: 35

                            background: Rectangle {
                                color: contentStack.currentIndex === 0 ? "#00bcd4" : "#34495e"
                                radius: 5
                                border.color: contentStack.currentIndex === 0 ? "#00e5ff" : "#505050"
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: excavatorViewButton.text
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                contentStack.currentIndex = 0
                            }
                        }

                        Button {
                            id: mapViewButton
                            text: "Harita"
                            width: 110
                            height: 35

                            background: Rectangle {
                                color: contentStack.currentIndex === 1 ? "#00bcd4" : "#34495e"
                                radius: 5
                                border.color: contentStack.currentIndex === 1 ? "#00e5ff" : "#505050"
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: mapViewButton.text
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                contentStack.currentIndex = 1
                            }
                        }
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

        // Ana içerik - StackLayout ile görünüm değişimi
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#2a2a2a"

            StackLayout {
                id: contentStack
                anchors.fill: parent
                currentIndex: 0

                // Ekskavatör Görünümü
                Rectangle {
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
                            text: "3D Ekskavatör Görünümü"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    // Mini kamera görünümü (sağ üst köşe - üstten)
                    Rectangle {
                        id: miniCameraView
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 60
                        anchors.rightMargin: 20
                        width: 280
                        height: 200
                        color: "#1a1a1a"
                        radius: 10
                        border.color: "#00bcd4"
                        border.width: 2
                        opacity: 0.95

                        // Başlık
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            color: "#0d0d0d"
                            radius: 10

                            Text {
                                anchors.centerIn: parent
                                text: "Üstten Görünüm"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#00bcd4"
                            }
                        }

                        // 3D Görünüm - Üstten
                        View3D {
                            anchors.fill: parent
                            anchors.topMargin: 30
                            anchors.margins: 5

                            environment: SceneEnvironment {
                                clearColor: "#2a2a2a"
                                backgroundMode: SceneEnvironment.Color
                                antialiasingMode: SceneEnvironment.MSAA
                                antialiasingQuality: SceneEnvironment.Medium
                            }

                            // Üstten kamera
                            PerspectiveCamera {
                                position: Qt.vector3d(0, 150, 0)
                                eulerRotation.x: -90
                                clipNear: 1
                                clipFar: 1000
                            }

                            DirectionalLight {
                                eulerRotation.x: -45
                                brightness: 1.5
                            }

                            Node {
                                scale: Qt.vector3d(1.5, 1.5, 1.5)

                                Excavator {
                                    id: excavatorTopView
                                }
                            }
                        }
                    }

                    // Yandan görünüm (sağ ortada)
                    Rectangle {
                        id: sideView
                        anchors.top: miniCameraView.bottom
                        anchors.right: parent.right
                        anchors.topMargin: 10
                        anchors.rightMargin: 20
                        width: 280
                        height: 200
                        color: "#1a1a1a"
                        radius: 10
                        border.color: "#ffc107"
                        border.width: 2
                        opacity: 0.95

                        // Başlık
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            color: "#0d0d0d"
                            radius: 10

                            Text {
                                anchors.centerIn: parent
                                text: "Yandan Görünüm"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#ffc107"
                            }
                        }

                        // 3D Görünüm - Yandan
                        View3D {
                            anchors.fill: parent
                            anchors.topMargin: 30
                            anchors.margins: 5

                            environment: SceneEnvironment {
                                clearColor: "#2a2a2a"
                                backgroundMode: SceneEnvironment.Color
                                antialiasingMode: SceneEnvironment.MSAA
                                antialiasingQuality: SceneEnvironment.Medium
                            }

                            // Yandan kamera
                            PerspectiveCamera {
                                position: Qt.vector3d(150, 40, 0)
                                eulerRotation.y: -90
                                eulerRotation.x: -10
                                clipNear: 1
                                clipFar: 1000
                            }

                            DirectionalLight {
                                eulerRotation.x: -30
                                eulerRotation.y: -70
                                brightness: 1.5
                            }

                            DirectionalLight {
                                eulerRotation.x: 30
                                eulerRotation.y: 110
                                brightness: 1.0
                            }

                            Node {
                                scale: Qt.vector3d(1.5, 1.5, 1.5)

                                Excavator {
                                    id: excavatorSideView
                                }
                            }
                        }
                    }
                }

                // Batimetrik Harita Görünümü
                Rectangle {
                    color: "#2a2a2a"

                    BathymetricMapView {
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
                            text: "Batimetrik Harita - Liman Bölgesi"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }
            }

            // Sensör Durumu Paneli (Sol Üst Köşe)
            Rectangle {
                id: sensorStatusPanel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 60
                anchors.leftMargin: 20
                width: 280
                height: sensorColumn.height + 30
                color: "#1a1a1a"
                radius: 10
                border.color: "#4CAF50"
                border.width: 2
                opacity: 0.95
                z: 10

                Column {
                    id: sensorColumn
                    anchors.centerIn: parent
                    spacing: 12
                    width: parent.width - 20

                    // Başlık
                    Rectangle {
                        width: parent.width
                        height: 35
                        color: "#0d0d0d"
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: "SENSÖR DURUM"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#4CAF50"
                        }
                    }

                    // RTK Sensör
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: "#4CAF50"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                                }
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "RTK SENSÖR"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Bağlantı: Aktif"
                                    font.pixelSize: 10
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // IMU 1
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: "#4CAF50"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                                }
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "IMU 1"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Bağlantı: Aktif"
                                    font.pixelSize: 10
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // IMU 2
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: "#4CAF50"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                                }
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "IMU 2"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Bağlantı: Aktif"
                                    font.pixelSize: 10
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // IMU 3
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: "#4CAF50"
                                anchors.verticalCenter: parent.verticalCenter

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
                                }
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "IMU 3"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Bağlantı: Aktif"
                                    font.pixelSize: 10
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
