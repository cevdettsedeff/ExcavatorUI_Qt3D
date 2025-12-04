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

    property bool contentLoaded: false

    // İLK FRAME'DEN İTİBAREN GÖRÜNMESİ GEREKEN ARKAPLAN
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
        z: -1
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
                        id: mainExcavatorView
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
                        width: 350
                        height: 260
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
                            color: "#0d0d0d"
                            radius: 5
                            opacity: 0.9

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
                                        color: "#404040"

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

            // Sensör Durumu Paneli (Açılır Menü)
            Rectangle {
                id: sensorStatusPanel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 60
                anchors.leftMargin: 20
                width: sensorExpanded ? 680 : 180
                height: sensorExpanded ? 90 : 50
                color: "#1a1a1a"
                radius: 10
                border.color: "#4CAF50"
                border.width: 2
                opacity: 0.95
                z: 10

                property bool sensorExpanded: false

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                Behavior on height {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                // Başlık/Toggle Butonu
                Rectangle {
                    id: sensorHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 5
                    width: 170
                    height: 40
                    color: "#0d0d0d"
                    radius: 5

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
                            text: "SENSÖR DURUM"
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

                // Sensör İçerik Alanı (Açık Durumda Görünür)
                Row {
                    id: sensorRow
                    anchors.top: parent.top
                    anchors.left: sensorHeader.right
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 5
                    spacing: 10
                    visible: sensorStatusPanel.sensorExpanded
                    opacity: sensorStatusPanel.sensorExpanded ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    // RTK Sensör
                    Rectangle {
                        width: 110
                        height: parent.height
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
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
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Aktif"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // IMU 1
                    Rectangle {
                        width: 85
                        height: parent.height
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
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
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Aktif"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // IMU 2
                    Rectangle {
                        width: 85
                        height: parent.height
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
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
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Aktif"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // IMU 3
                    Rectangle {
                        width: 85
                        height: parent.height
                        color: "#252525"
                        radius: 5
                        border.color: "#404040"
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
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
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#ffffff"
                                }
                                Text {
                                    text: "Aktif"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // Ayırıcı
                    Rectangle {
                        width: 2
                        height: parent.height - 10
                        color: "#404040"
                    }

                    // Kazı Simülasyonu Kontrolü
                    Button {
                        width: 150
                        height: parent.height - 10

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
                            spacing: 8

                            Text {
                                text: imuService && imuService.isDigging ? "⏸" : "▶"
                                font.pixelSize: 16
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: imuService && imuService.isDigging ? "KAZI DURDUR" : "KAZI BAŞLAT"
                                font.pixelSize: 11
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
