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
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    property bool contentLoaded: false

    // İLK FRAME'DEN İTİBAREN GÖRÜNMESİ GEREKEN ARKAPLAN
    Rectangle {
        anchors.fill: parent
        color: themeManager ? themeManager.backgroundColor : "#1a1a1a"
        z: -1

        Behavior on color {
            ColorAnimation { duration: 300 }
        }
    }

    // Ana container - dikey layout
    ColumnLayout {
        id: mainContent
        anchors.fill: parent
        spacing: 0
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        Component.onCompleted: {
            // İçerik yüklendi, loading ekranını kapat
            loadingCompleteTimer.start()
        }

        // Üst menü bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: themeManager ? themeManager.backgroundColorDark : "#0d0d0d"
            z: 100

            Behavior on color {
                ColorAnimation { duration: 300 }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20

                // Sol taraf - Tema butonu + Başlık ve kullanıcı bilgisi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    // Tema değiştirme butonu (Sol üst köşe)
                    Rectangle {
                        width: 40
                        height: 35
                        radius: 5
                        color: themeBtnArea.containsMouse ? (themeManager ? themeManager.hoverColor : "#333333") : "transparent"
                        border.color: themeManager ? themeManager.borderColor : "#404040"
                        border.width: 1

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: themeManager && themeManager.isDarkTheme ? "☀️" : "🌙"
                            font.pixelSize: 20
                        }

                        MouseArea {
                            id: themeBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (themeManager) {
                                    themeManager.toggleTheme()
                                }
                            }
                        }

                        // Tooltip
                        Rectangle {
                            visible: themeBtnArea.containsMouse
                            anchors.top: parent.bottom
                            anchors.topMargin: 5
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: tooltipText.width + 16
                            height: 25
                            color: themeManager ? themeManager.backgroundColorDark : "#2a2a2a"
                            radius: 3
                            opacity: 0.95
                            z: 200

                            Text {
                                id: tooltipText
                                anchors.centerIn: parent
                                text: themeManager && themeManager.isDarkTheme ? qsTr("Light") : qsTr("Dark")
                                font.pixelSize: 11
                                color: themeManager ? themeManager.textColor : "#ffffff"
                            }
                        }
                    }

                    Rectangle {
                        width: 2
                        height: 30
                        color: themeManager ? themeManager.borderColor : "#404040"
                    }

                    Text {
                        text: "🚜"
                        font.pixelSize: 24
                    }

                    Text {
                        text: qsTr("Excavator Dashboard")
                        font.pixelSize: 18
                        font.bold: true
                        color: themeManager ? themeManager.textColor : "#ffffff"
                    }

                    Rectangle {
                        width: 2
                        height: 30
                        color: themeManager ? themeManager.borderColor : "#404040"
                    }

                    Text {
                        text: authService && authService.currentUser ?
                              qsTr("Welcome") + ", " + authService.currentUser + (authService.isAdmin ? " (" + qsTr("Admin") + ")" : "") : ""
                        font.pixelSize: 14
                        color: authService && authService.isAdmin ? "#ba68c8" : (themeManager ? themeManager.textColorSecondary : "#888888")
                    }

                    Rectangle {
                        width: 2
                        height: 30
                        color: themeManager ? themeManager.borderColor : "#404040"
                    }

                    // Navbar Menü Butonları
                    Row {
                        spacing: 10

                        Button {
                            id: excavatorViewButton
                            text: qsTr("Excavator")
                            width: 110
                            height: 35

                            background: Rectangle {
                                color: contentStack.currentIndex === 0 ? (themeManager ? themeManager.primaryColor : "#00bcd4") : (themeManager ? themeManager.secondaryColor : "#34495e")
                                radius: 5
                                border.color: contentStack.currentIndex === 0 ? (themeManager ? themeManager.accentColor : "#00e5ff") : (themeManager ? themeManager.borderColor : "#505050")
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: excavatorViewButton.text
                                font.pixelSize: 13
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                contentStack.currentIndex = 0
                            }
                        }

                        Button {
                            id: mapViewButton
                            text: qsTr("Map")
                            width: 110
                            height: 35

                            background: Rectangle {
                                color: contentStack.currentIndex === 1 ? (themeManager ? themeManager.primaryColor : "#00bcd4") : (themeManager ? themeManager.secondaryColor : "#34495e")
                                radius: 5
                                border.color: contentStack.currentIndex === 1 ? (themeManager ? themeManager.accentColor : "#00e5ff") : (themeManager ? themeManager.borderColor : "#505050")
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: mapViewButton.text
                                font.pixelSize: 13
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                contentStack.currentIndex = 1
                            }
                        }

                        // Admin butonu (sadece admin görebilir)
                        Button {
                            id: adminViewButton
                            text: qsTr("User Management")
                            width: 160
                            height: 35
                            visible: authService && authService.isAdmin

                            background: Rectangle {
                                color: contentStack.currentIndex === 2 ? "#9c27b0" : (themeManager ? themeManager.secondaryColor : "#34495e")
                                radius: 5
                                border.color: contentStack.currentIndex === 2 ? "#ba68c8" : (themeManager ? themeManager.borderColor : "#505050")
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: adminViewButton.text
                                font.pixelSize: 13
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                contentStack.currentIndex = 2
                            }
                        }

                        // Profilim butonu (sadece admin değilse görebilir)
                        Button {
                            id: profileViewButton
                            text: qsTr("Profile")
                            width: 100
                            height: 35
                            visible: authService && !authService.isAdmin

                            background: Rectangle {
                                color: contentStack.currentIndex === 3 ? "#3498db" : (themeManager ? themeManager.secondaryColor : "#34495e")
                                radius: 5
                                border.color: contentStack.currentIndex === 3 ? "#5dade2" : (themeManager ? themeManager.borderColor : "#505050")
                                border.width: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            contentItem: Text {
                                text: profileViewButton.text
                                font.pixelSize: 13
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                contentStack.currentIndex = 3
                            }
                        }
                    }
                }

                // Sağ taraf - Dil seçici + Logout butonu
                Row {
                    spacing: 10

                    // Dil seçici butonu
                    Rectangle {
                        width: 80
                        height: 35
                        radius: 5
                        color: langBtnArea.containsMouse ? (themeManager ? themeManager.hoverColor : "#333333") : (themeManager ? themeManager.secondaryColor : "#34495e")
                        border.color: themeManager ? themeManager.borderColor : "#505050"
                        border.width: 1

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: "🌐"
                                font.pixelSize: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: translationService ? (translationService.currentLanguage === "tr_TR" ? "TR" : "EN") : "TR"
                                font.pixelSize: 12
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: langBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                langMenu.open()
                            }
                        }

                        // Language menu
                        Menu {
                            id: langMenu
                            y: parent.height

                            MenuItem {
                                text: "🇹🇷 Türkçe"
                                onTriggered: {
                                    if (translationService) {
                                        translationService.switchLanguage("tr_TR")
                                    }
                                }
                            }

                            MenuItem {
                                text: "🇬🇧 English"
                                onTriggered: {
                                    if (translationService) {
                                        translationService.switchLanguage("en_US")
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    id: logoutButton
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 35
                    text: qsTr("Logout")

                    background: Rectangle {
                        color: logoutButton.pressed ? "#c0392b" : (logoutButton.hovered ? "#e74c3c" : "#d32f2f")
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
            color: themeManager ? themeManager.borderColor : "#404040"
        }

        // Ana içerik - StackLayout ile görünüm değişimi
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: themeManager ? themeManager.backgroundColor : "#2a2a2a"

            Behavior on color {
                ColorAnimation { duration: 300 }
            }

            StackLayout {
                id: contentStack
                anchors.fill: parent
                currentIndex: 0

                // Ekskavatör Görünümü
                Rectangle {
                    color: themeManager ? themeManager.backgroundColor : "#2a2a2a"

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }

                    ExcavatorView {
                        id: mainExcavatorView
                        anchors.fill: parent
                    }

                    // Panel başlığı
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 80
                        color: "transparent"

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: themeManager ? themeManager.backgroundColorDark : "#2d2d2d" }
                                GradientStop { position: 1.0; color: themeManager ? themeManager.backgroundColor : "#1a1a1a" }
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 15

                            Text {
                                text: "🚜"
                                font.pixelSize: 32
                            }

                            Text {
                                text: qsTr("3D Excavator View")
                                font.pixelSize: 28
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.5; color: "#00bcd4" }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }
                    }

                    // Sensör Durumu Paneli (Aşağı Açılan Menü) - Sadece Ekskavatör Görünümünde
                    Rectangle {
                        id: sensorStatusPanel
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: 90
                        anchors.leftMargin: 20
                        width: 200
                        height: sensorExpanded ? 380 : 50
                        color: themeManager ? themeManager.backgroundColor : "#1a1a1a"
                        radius: 10
                        border.color: "#4CAF50"
                        border.width: 2
                        opacity: 0.95
                        z: 10

                        property bool sensorExpanded: false

                        Behavior on height {
                            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }

                        // Başlık/Toggle Butonu
                        Rectangle {
                            id: sensorHeader
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 5
                            height: 40
                            color: themeManager ? themeManager.backgroundColorDark : "#0d0d0d"
                            radius: 5

                            Behavior on color {
                                ColorAnimation { duration: 300 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    sensorStatusPanel.sensorExpanded = !sensorStatusPanel.sensorExpanded
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 10

                                Text {
                                    text: qsTr("SENSOR STATUS")
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#4CAF50"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: sensorStatusPanel.sensorExpanded ? "▲" : "▼"
                                    font.pixelSize: 12
                                    color: "#4CAF50"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Sensör İçerik Alanı (Açık Durumda Görünür - Dikey)
                        Column {
                            id: sensorColumn
                            anchors.top: sensorHeader.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 10
                            spacing: 8
                            visible: sensorStatusPanel.sensorExpanded
                            opacity: sensorStatusPanel.sensorExpanded ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }

                            // RTK Sensör
                            Rectangle {
                                width: parent.width
                                height: 55
                                color: themeManager ? themeManager.backgroundColorDark : "#252525"
                                radius: 5
                                border.color: themeManager ? themeManager.borderColor : "#404040"
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 300 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

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
                                        spacing: 3
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: qsTr("RTK SENSOR")
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: themeManager ? themeManager.textColor : "#ffffff"
                                        }
                                        Text {
                                            text: qsTr("Connection: Active")
                                            font.pixelSize: 10
                                            color: "#4CAF50"
                                        }
                                    }
                                }
                            }

                            // IMU 1
                            Rectangle {
                                width: parent.width
                                height: 55
                                color: themeManager ? themeManager.backgroundColorDark : "#252525"
                                radius: 5
                                border.color: themeManager ? themeManager.borderColor : "#404040"
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 300 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

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
                                        spacing: 3
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "IMU 1"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: themeManager ? themeManager.textColor : "#ffffff"
                                        }
                                        Text {
                                            text: qsTr("Connection: Active")
                                            font.pixelSize: 10
                                            color: "#4CAF50"
                                        }
                                    }
                                }
                            }

                            // IMU 2
                            Rectangle {
                                width: parent.width
                                height: 55
                                color: themeManager ? themeManager.backgroundColorDark : "#252525"
                                radius: 5
                                border.color: themeManager ? themeManager.borderColor : "#404040"
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 300 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

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
                                        spacing: 3
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "IMU 2"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: themeManager ? themeManager.textColor : "#ffffff"
                                        }
                                        Text {
                                            text: qsTr("Connection: Active")
                                            font.pixelSize: 10
                                            color: "#4CAF50"
                                        }
                                    }
                                }
                            }

                            // IMU 3
                            Rectangle {
                                width: parent.width
                                height: 55
                                color: themeManager ? themeManager.backgroundColorDark : "#252525"
                                radius: 5
                                border.color: themeManager ? themeManager.borderColor : "#404040"
                                border.width: 1

                                Behavior on color {
                                    ColorAnimation { duration: 300 }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 12

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
                                        spacing: 3
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: "IMU 3"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: themeManager ? themeManager.textColor : "#ffffff"
                                        }
                                        Text {
                                            text: qsTr("Connection: Active")
                                            font.pixelSize: 10
                                            color: "#4CAF50"
                                        }
                                    }
                                }
                            }

                            // Ayırıcı
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#404040"
                            }

                            // Kazı Simülasyonu Kontrolü
                            Button {
                                width: parent.width
                                height: 55

                                background: Rectangle {
                                    color: imuService && imuService.isDigging ? "#f44336" : "#4CAF50"
                                    radius: 5
                                    border.color: imuService && imuService.isDigging ? "#e53935" : "#66BB6A"
                                    border.width: 2

                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }

                                contentItem: Row {
                                    anchors.centerIn: parent
                                    spacing: 10

                                    Text {
                                        text: imuService && imuService.isDigging ? "⏸" : "▶"
                                        font.pixelSize: 18
                                        color: "#ffffff"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: imuService && imuService.isDigging ? qsTr("STOP") : qsTr("START DIGGING")
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#ffffff"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                onClicked: {
                                    if (imuService) {
                                        if (imuService.isDigging) {
                                            imuService.stopDigging()
                                        } else {
                                            imuService.startDigging()
                                        }
                                    }
                                }
                            }

                        }
                    }

                    // Mini kamera görünümü (sağ üst köşe - üstten)
                    Rectangle {
                        id: miniCameraView
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 90
                        anchors.rightMargin: 20
                        width: 350
                        height: 260
                        color: themeManager ? themeManager.backgroundColor : "#1a1a1a"
                        radius: 10
                        border.color: themeManager ? themeManager.primaryColor : "#00bcd4"
                        border.width: 2
                        opacity: 0.95

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }

                        // Başlık
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            color: themeManager ? themeManager.backgroundColorDark : "#0d0d0d"
                            radius: 10

                            Behavior on color {
                                ColorAnimation { duration: 300 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Top View")
                                font.pixelSize: 12
                                font.bold: true
                                color: themeManager ? themeManager.primaryColor : "#00bcd4"
                            }
                        }

                        // 3D Görünüm - Üstten
                        View3D {
                            anchors.fill: parent
                            anchors.topMargin: 30
                            anchors.bottomMargin: 35
                            anchors.margins: 5

                            environment: SceneEnvironment {
                                clearColor: "#2a2a2a"
                                backgroundMode: SceneEnvironment.Color
                                antialiasingMode: SceneEnvironment.MSAA
                                antialiasingQuality: SceneEnvironment.Medium
                            }

                            // Üstten kamera
                            PerspectiveCamera {
                                id: topCamera
                                position: Qt.vector3d(0, topZoomSlider.value, 0)
                                eulerRotation.x: -90
                                clipNear: 1
                                clipFar: 1000
                            }

                            DirectionalLight {
                                eulerRotation.x: -45
                                brightness: 1.5
                            }

                            Node {
                                scale: Qt.vector3d(4.0, 4.0, 4.0)
                                eulerRotation.y: mainExcavatorView.excavatorRotation

                                Excavator {
                                    id: excavatorTopView
                                    // IMU servisinden açı verilerini al
                                    boomAngle: imuService ? imuService.boomAngle : 0.0
                                    armAngle: imuService ? imuService.armAngle : 0.0
                                    bucketAngle: imuService ? imuService.bucketAngle : 0.0
                                }
                            }
                        }

                        // Zoom kontrolü - Üstten görünüm
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 5
                            height: 30
                            color: themeManager ? themeManager.backgroundColorDark : "#0d0d0d"
                            radius: 5
                            opacity: 0.9

                            Behavior on color {
                                ColorAnimation { duration: 300 }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "−"
                                    font.pixelSize: 16
                                    color: "#00bcd4"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Slider {
                                    id: topZoomSlider
                                    from: 150
                                    to: 50
                                    value: 80
                                    width: 180
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        x: topZoomSlider.leftPadding
                                        y: topZoomSlider.topPadding + topZoomSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 180
                                        implicitHeight: 4
                                        width: topZoomSlider.availableWidth
                                        height: implicitHeight
                                        radius: 2
                                        color: themeManager ? themeManager.borderColor : "#404040"

                                        Rectangle {
                                            width: topZoomSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: "#00bcd4"
                                            radius: 2
                                        }
                                    }

                                    handle: Rectangle {
                                        x: topZoomSlider.leftPadding + topZoomSlider.visualPosition * (topZoomSlider.availableWidth - width)
                                        y: topZoomSlider.topPadding + topZoomSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 16
                                        implicitHeight: 16
                                        radius: 8
                                        color: topZoomSlider.pressed ? "#00e5ff" : "#00bcd4"
                                        border.color: "#ffffff"
                                        border.width: 2
                                    }
                                }

                                Text {
                                    text: "+"
                                    font.pixelSize: 16
                                    color: "#00bcd4"
                                    anchors.verticalCenter: parent.verticalCenter
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
                        width: 350
                        height: 260
                        color: themeManager ? themeManager.backgroundColor : "#1a1a1a"
                        radius: 10
                        border.color: "#ffc107"
                        border.width: 2
                        opacity: 0.95

                        Behavior on color {
                            ColorAnimation { duration: 300 }
                        }

                        // Başlık
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            color: themeManager ? themeManager.backgroundColorDark : "#0d0d0d"
                            radius: 10

                            Behavior on color {
                                ColorAnimation { duration: 300 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Side View")
                                font.pixelSize: 12
                                font.bold: true
                                color: "#ffc107"
                            }
                        }

                        // 3D Görünüm - Yandan
                        View3D {
                            anchors.fill: parent
                            anchors.topMargin: 30
                            anchors.bottomMargin: 35
                            anchors.margins: 5

                            environment: SceneEnvironment {
                                clearColor: "#2a2a2a"
                                backgroundMode: SceneEnvironment.Color
                                antialiasingMode: SceneEnvironment.MSAA
                                antialiasingQuality: SceneEnvironment.Medium
                            }

                            // Yandan kamera (yakın plan)
                            PerspectiveCamera {
                                id: sideCamera
                                position: Qt.vector3d(sideZoomSlider.value, 25, 0)
                                eulerRotation.y: 90
                                eulerRotation.x: 0
                                clipNear: 1
                                clipFar: 1000
                                fieldOfView: 45
                            }

                            DirectionalLight {
                                eulerRotation.x: -45
                                eulerRotation.y: 90
                                brightness: 2.5
                            }

                            DirectionalLight {
                                eulerRotation.x: 45
                                eulerRotation.y: -90
                                brightness: 2.0
                            }

                            PointLight {
                                position: Qt.vector3d(0, 50, 0)
                                brightness: 3.0
                            }

                            Node {
                                scale: Qt.vector3d(4.0, 4.0, 4.0)

                                Excavator {
                                    id: excavatorSideView
                                    // IMU servisinden açı verilerini al
                                    boomAngle: imuService ? imuService.boomAngle : 0.0
                                    armAngle: imuService ? imuService.armAngle : 0.0
                                    bucketAngle: imuService ? imuService.bucketAngle : 0.0
                                }
                            }
                        }

                        // Zoom kontrolü - Yandan görünüm
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 5
                            height: 30
                            color: "#0d0d0d"
                            radius: 5
                            opacity: 0.9

                            Row {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "−"
                                    font.pixelSize: 16
                                    color: "#ffc107"
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Slider {
                                    id: sideZoomSlider
                                    from: 120
                                    to: 50
                                    value: 80
                                    width: 180
                                    anchors.verticalCenter: parent.verticalCenter

                                    background: Rectangle {
                                        x: sideZoomSlider.leftPadding
                                        y: sideZoomSlider.topPadding + sideZoomSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 180
                                        implicitHeight: 4
                                        width: sideZoomSlider.availableWidth
                                        height: implicitHeight
                                        radius: 2
                                        color: "#404040"

                                        Rectangle {
                                            width: sideZoomSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: "#ffc107"
                                            radius: 2
                                        }
                                    }

                                    handle: Rectangle {
                                        x: sideZoomSlider.leftPadding + sideZoomSlider.visualPosition * (sideZoomSlider.availableWidth - width)
                                        y: sideZoomSlider.topPadding + sideZoomSlider.availableHeight / 2 - height / 2
                                        implicitWidth: 16
                                        implicitHeight: 16
                                        radius: 8
                                        color: sideZoomSlider.pressed ? "#ffeb3b" : "#ffc107"
                                        border.color: "#ffffff"
                                        border.width: 2
                                    }
                                }

                                Text {
                                    text: "+"
                                    font.pixelSize: 16
                                    color: "#ffc107"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }

                // Harita Görünümü (Online/Offline sekmeli)
                Rectangle {
                    color: themeManager ? themeManager.backgroundColor : "#2a2a2a"

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }

                    // Panel başlığı ve alt sekmeler
                    Rectangle {
                        id: mapHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 80
                        color: "transparent"
                        z: 10

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: themeManager ? themeManager.backgroundColorDark : "#2d2d2d" }
                                GradientStop { position: 1.0; color: themeManager ? themeManager.backgroundColor : "#1a1a1a" }
                            }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 15

                            Text {
                                text: "🗺️"
                                font.pixelSize: 32
                            }

                            Text {
                                text: qsTr("Map View")
                                font.pixelSize: 28
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#ffffff"
                            }

                            // Alt sekme butonları
                            Rectangle {
                                width: 2
                                height: 40
                                color: themeManager ? themeManager.borderColor : "#404040"
                                Layout.leftMargin: 20
                            }

                            Row {
                                spacing: 8
                                Layout.leftMargin: 10

                                // Online Harita butonu
                                Rectangle {
                                    width: 110
                                    height: 36
                                    radius: 18
                                    color: mapSubStack.currentIndex === 0 ? "#4CAF50" : (themeManager ? themeManager.backgroundColorDark : "#252525")
                                    border.color: "#4CAF50"
                                    border.width: 2

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Text {
                                            text: "●"
                                            font.pixelSize: 10
                                            color: mapSubStack.currentIndex === 0 ? (themeManager ? themeManager.textColor : "#ffffff") : "#4CAF50"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "Online"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: mapSubStack.currentIndex === 0 ? (themeManager ? themeManager.textColor : "#ffffff") : "#4CAF50"
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mapSubStack.currentIndex = 0
                                    }
                                }

                                // Offline Harita butonu
                                Rectangle {
                                    width: 110
                                    height: 36
                                    radius: 18
                                    color: mapSubStack.currentIndex === 1 ? "#ff9800" : (themeManager ? themeManager.backgroundColorDark : "#252525")
                                    border.color: "#ff9800"
                                    border.width: 2

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 6

                                        Text {
                                            text: "◉"
                                            font.pixelSize: 10
                                            color: mapSubStack.currentIndex === 1 ? (themeManager ? themeManager.textColor : "#ffffff") : "#ff9800"
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "Offline"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: mapSubStack.currentIndex === 1 ? (themeManager ? themeManager.textColor : "#ffffff") : "#ff9800"
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mapSubStack.currentIndex = 1
                                    }

                                    // Cache boyutu badge
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.topMargin: -5
                                        anchors.rightMargin: -5
                                        width: cacheBadgeText.width + 8
                                        height: 16
                                        radius: 8
                                        color: "#f44336"
                                        visible: offlineTileManager && offlineTileManager.cacheSize > 0

                                        Text {
                                            id: cacheBadgeText
                                            anchors.centerIn: parent
                                            text: offlineTileManager ? offlineTileManager.formatCacheSize() : ""
                                            font.pixelSize: 8
                                            font.bold: true
                                            color: "#ffffff"
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 2
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.5; color: mapSubStack.currentIndex === 0 ? "#4CAF50" : "#ff9800" }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }
                    }

                    // Alt sekme içerikleri
                    StackLayout {
                        id: mapSubStack
                        anchors.top: mapHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        currentIndex: 1  // Varsayılan olarak Offline harita göster

                        // Online Harita
                        SimpleMapView {
                            id: simpleMapView
                        }

                        // Offline Harita
                        OfflineMapView {
                            id: offlineMapView
                        }
                    }
                }

                // Kullanıcı Yönetimi Görünümü (Sadece Admin)
                Rectangle {
                    color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                    visible: authService && authService.isAdmin

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }

                    UserManagementView {
                        anchors.fill: parent
                    }
                }

                // Profil Görünümü (Sadece Admin Değilse)
                Rectangle {
                    color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                    visible: authService && !authService.isAdmin

                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }

                    ProfileView {
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    // Timer - Ana içerik yüklendiğinde tetiklenir
    Timer {
        id: loadingCompleteTimer
        interval: 200
        onTriggered: {
            root.contentLoaded = true
        }
    }

    property real loadingStartTime: 0

    Component.onCompleted: {
        loadingStartTime = Date.now()
    }

    // Sürekli kontrol eden timer
    Timer {
        id: checkReadyTimer
        interval: 100
        repeat: true
        running: true

        onTriggered: {
            var elapsedTime = Date.now() - root.loadingStartTime
            var minTimeElapsed = elapsedTime >= 2000
            var progressComplete = loadingScreen.progress >= 0.99

            if (root.contentLoaded && minTimeElapsed && progressComplete) {
                stop()
                mainContent.opacity = 1.0
                fadeOutAnimation.start()
            }
        }
    }

    // Loading Screen overlay - İLK GÖRÜNEN EKRAN
    LoadingScreen {
        id: loadingScreen
        anchors.fill: parent
        z: 1000
        visible: true
        opacity: 1.0

        // Progress otomatik olarak artacak
        property real loadProgress: 0.0
        property real targetProgress: 0.0

        Timer {
            interval: 30
            repeat: true
            running: true

            onTriggered: {
                // İçerik yüklendiyse hedef %100
                if (root.contentLoaded) {
                    loadingScreen.targetProgress = 1.0
                } else {
                    // Yüklenmiyorsa yavaşça %90'a kadar
                    if (loadingScreen.targetProgress < 0.9) {
                        loadingScreen.targetProgress += 0.01
                    }
                }

                // Smooth progress artışı
                if (loadingScreen.loadProgress < loadingScreen.targetProgress) {
                    var diff = loadingScreen.targetProgress - loadingScreen.loadProgress
                    loadingScreen.loadProgress += diff * 0.15
                }

                loadingScreen.progress = loadingScreen.loadProgress
            }
        }

        OpacityAnimator {
            id: fadeOutAnimation
            target: loadingScreen
            from: 1.0
            to: 0.0
            duration: 500
            easing.type: Easing.InOutQuad

            onFinished: {
                loadingScreen.visible = false
            }
        }
    }
}
