import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import ExcavatorUI_Qt3D

// Ana Sayfa - 3D Ekskavatör Görünümü (Mockup'a göre)
Rectangle {
    id: homePage
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // Konum verileri
    property real posX: 124.32
    property real posY: 842.11
    property real posZ: -2.45
    property real pitch: 2.1
    property real roll: 0.8

    // Kepçe derinlik verileri (IMU servisinden veya simülasyon)
    property real bucketMaxDepth: 10.0      // Su üstü yükseklik (sabit)
    property real bucketMinDepth: configManager ? -Math.max(configManager.calculatedMaxDepth + 5, 20) : -25.0  // Batimetrik max + 5m
    property real bucketWaterLevel: 0.0     // Su seviyesi
    property real bucketTargetDepth: configManager ? -configManager.targetDepth : -15.0  // Hedef derinlik
    property real bucketCurrentDepth: imuService ? imuService.bucketDepth : -5.0      // Mevcut kepçe derinliği

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Kepçe Derinlik Göstergesi (Sol taraf) - Üstten alta kadar uzanır
    BucketDepthIndicator {
        id: bucketDepthIndicator
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: coordinateBar.top
        anchors.leftMargin: app.smallPadding
        anchors.topMargin: app.smallPadding
        anchors.bottomMargin: app.smallPadding
        width: app.largeIconSize * 3.3
        z: 100  // Diğer elemanların üstünde

        maxDepth: homePage.bucketMaxDepth
        minDepth: homePage.bucketMinDepth
        waterLevel: homePage.bucketWaterLevel
        targetDepth: homePage.bucketTargetDepth
        currentBucketDepth: homePage.bucketCurrentDepth
    }

    // Ana içerik - Dikey düzen
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ÜST: Ana 3D Görünüm (büyük alan)
        Rectangle {
            id: main3DView
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0a1628"
            border.color: "#2a4a6a"
            border.width: 1

            // Başlık
            Rectangle {
                id: view3DHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: app.buttonHeight * 0.9
                color: themeManager ? themeManager.backgroundColorDark : "#1a2a3a"
                z: 10

                Text {
                    anchors.centerIn: parent
                    text: tr("3D Excavator View")
                    font.pixelSize: app.mediumFontSize
                    font.bold: true
                    color: "#ffffff"
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#444444"
                }
            }

            // 3D Görünüm
            View3D {
                id: view3D
                anchors.top: view3DHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 2

                environment: SceneEnvironment {
                    clearColor: "#0a1628"
                    backgroundMode: SceneEnvironment.Color
                    antialiasingMode: SceneEnvironment.MSAA
                    antialiasingQuality: SceneEnvironment.High
                }

                PerspectiveCamera {
                    id: mainCamera
                    position: Qt.vector3d(-80, 60, 150)
                    eulerRotation.x: -15
                    eulerRotation.y: -20
                    clipNear: 1
                    clipFar: 5000
                    fieldOfView: 50
                }

                DirectionalLight {
                    eulerRotation.x: -30
                    eulerRotation.y: -70
                    brightness: 2.0
                    castsShadow: true
                }

                DirectionalLight {
                    eulerRotation.x: 30
                    eulerRotation.y: 110
                    brightness: 1.5
                }

                PointLight {
                    position: Qt.vector3d(0, 200, 200)
                    brightness: 2.0
                }

                // Zemin/Su
                Model {
                    source: "#Rectangle"
                    position: Qt.vector3d(0, -10, 0)
                    eulerRotation.x: -90
                    scale: Qt.vector3d(30, 30, 1)

                    materials: PrincipledMaterial {
                        baseColor: "#1a4a7a"
                        roughness: 0.9
                        metalness: 0.1
                    }
                }

                // Ekskavatör
                Node {
                    id: excavatorNode
                    scale: Qt.vector3d(5.0, 5.0, 5.0)
                    eulerRotation.y: -30

                    Excavator {
                        id: excavatorMain
                        boomAngle: imuService ? imuService.boomAngle : 0.0
                        armAngle: imuService ? imuService.armAngle : 0.0
                        bucketAngle: imuService ? imuService.bucketAngle : 0.0
                    }
                }

                // Grid çizgileri (derinlik referansı)
                Node {
                    id: gridNode

                    Repeater3D {
                        model: 5

                        Model {
                            source: "#Rectangle"
                            position: Qt.vector3d(0, -index * 20 - 10, 0)
                            eulerRotation.x: -90
                            scale: Qt.vector3d(25, 25, 1)
                            opacity: 0.2

                            materials: PrincipledMaterial {
                                baseColor: "#40ffa0"
                                roughness: 1.0
                            }
                        }
                    }
                }
            }

            // Kepçe Derinlik Göstergesi - Ana sayfada gösterilmiyor, aşağı taşındı
            // (Sol bar artık homePage seviyesinde)

            // Mouse kontrolü
            MouseArea {
                anchors.fill: parent
                property real lastX: 0
                property real lastY: 0

                onPressed: (mouse) => {
                    lastX = mouse.x
                    lastY = mouse.y
                }

                onPositionChanged: (mouse) => {
                    if (pressed) {
                        var deltaX = mouse.x - lastX
                        var deltaY = mouse.y - lastY

                        excavatorNode.eulerRotation.y += deltaX * 0.5
                        mainCamera.eulerRotation.x += deltaY * 0.2
                        mainCamera.eulerRotation.x = Math.max(-45, Math.min(15, mainCamera.eulerRotation.x))

                        lastX = mouse.x
                        lastY = mouse.y
                    }
                }
            }

            // Sürüklenebilir Kontroller (Sağ taraf) - 10.1 inç için optimize
            Column {
                id: manualControls
                anchors.right: parent.right
                anchors.top: view3DHeader.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 4
                width: Math.max(70, Math.min(90, parent.width * 0.12))
                spacing: 2

                // Başlık
                Rectangle {
                    width: parent.width
                    height: 22
                    color: themeManager ? themeManager.backgroundColorDark : "#1a2a3a"
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: tr("Manual Control")
                        font.pixelSize: 8
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Rastgele Hareket Butonu
                Button {
                    width: parent.width
                    height: 28

                    background: Rectangle {
                        color: imuService && imuService.isRandomMode ? "#e91e63" : "#9c27b0"
                        radius: 4
                        border.color: imuService && imuService.isRandomMode ? "#f06292" : "#ba68c8"
                        border.width: 1

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    contentItem: Text {
                        anchors.centerIn: parent
                        text: imuService && imuService.isRandomMode ? tr("Stop") : tr("Test")
                        font.pixelSize: 9
                        font.bold: true
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    enabled: imuService && !imuService.isDigging

                    onClicked: {
                        if (imuService) {
                            if (imuService.isRandomMode) {
                                imuService.stopRandomMovement()
                            } else {
                                imuService.startRandomMovement()
                            }
                        }
                    }
                }

                // Boom Kontrolü
                Column {
                    width: parent.width
                    spacing: 1

                    Text {
                        text: "Boom"
                        font.pixelSize: 8
                        font.bold: true
                        color: "#ffc107"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: (manualControls.height - 90) / 3  // Dinamik yükseklik
                        color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                        radius: 4
                        border.color: "#ffc107"
                        border.width: 1

                        Slider {
                            id: boomSlider
                            anchors.centerIn: parent
                            width: parent.height - 10
                            height: parent.width - 10
                            orientation: Qt.Vertical
                            from: -25
                            to: 45
                            value: imuService ? imuService.boomAngle : 0
                            enabled: imuService && !imuService.isDigging && !imuService.isRandomMode

                            onValueChanged: {
                                if (imuService && !imuService.isDigging) {
                                    imuService.setBoomAngle(value)
                                }
                            }

                            background: Rectangle {
                                x: boomSlider.leftPadding + boomSlider.availableWidth / 2 - width / 2
                                y: boomSlider.topPadding
                                implicitWidth: 3
                                implicitHeight: 200
                                width: implicitWidth
                                height: boomSlider.availableHeight
                                radius: 2
                                color: "#444444"
                            }

                            handle: Rectangle {
                                x: boomSlider.leftPadding + boomSlider.availableWidth / 2 - width / 2
                                y: boomSlider.topPadding + boomSlider.visualPosition * (boomSlider.availableHeight - height)
                                implicitWidth: 18
                                implicitHeight: 18
                                radius: 9
                                color: boomSlider.pressed ? "#f0a000" : "#ffc107"
                                border.color: "#ffffff"
                                border.width: 1
                            }
                        }
                    }

                    Text {
                        text: (imuService ? imuService.boomAngle.toFixed(0) : "0") + "°"
                        font.pixelSize: 8
                        color: "#ffc107"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Arm Kontrolü
                Column {
                    width: parent.width
                    spacing: 1

                    Text {
                        text: "Arm"
                        font.pixelSize: 8
                        font.bold: true
                        color: "#4CAF50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: (manualControls.height - 90) / 3
                        color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                        radius: 4
                        border.color: "#4CAF50"
                        border.width: 1

                        Slider {
                            id: armSlider
                            anchors.centerIn: parent
                            width: parent.height - 10
                            height: parent.width - 10
                            orientation: Qt.Vertical
                            from: -60
                            to: 35
                            value: imuService ? imuService.armAngle : 0
                            enabled: imuService && !imuService.isDigging && !imuService.isRandomMode

                            onValueChanged: {
                                if (imuService && !imuService.isDigging) {
                                    imuService.setArmAngle(value)
                                }
                            }

                            background: Rectangle {
                                x: armSlider.leftPadding + armSlider.availableWidth / 2 - width / 2
                                y: armSlider.topPadding
                                implicitWidth: 3
                                implicitHeight: 200
                                width: implicitWidth
                                height: armSlider.availableHeight
                                radius: 2
                                color: "#444444"
                            }

                            handle: Rectangle {
                                x: armSlider.leftPadding + armSlider.availableWidth / 2 - width / 2
                                y: armSlider.topPadding + armSlider.visualPosition * (armSlider.availableHeight - height)
                                implicitWidth: 18
                                implicitHeight: 18
                                radius: 9
                                color: armSlider.pressed ? "#2e7d32" : "#4CAF50"
                                border.color: "#ffffff"
                                border.width: 1
                            }
                        }
                    }

                    Text {
                        text: (imuService ? imuService.armAngle.toFixed(0) : "0") + "°"
                        font.pixelSize: 8
                        color: "#4CAF50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Bucket Kontrolü
                Column {
                    width: parent.width
                    spacing: 1

                    Text {
                        text: "Bucket"
                        font.pixelSize: 8
                        font.bold: true
                        color: "#2196F3"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: (manualControls.height - 90) / 3
                        color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                        radius: 4
                        border.color: "#2196F3"
                        border.width: 1

                        Slider {
                            id: bucketSlider
                            anchors.centerIn: parent
                            width: parent.height - 10
                            height: parent.width - 10
                            orientation: Qt.Vertical
                            from: -75
                            to: 50
                            value: imuService ? imuService.bucketAngle : 0
                            enabled: imuService && !imuService.isDigging && !imuService.isRandomMode

                            onValueChanged: {
                                if (imuService && !imuService.isDigging) {
                                    imuService.setBucketAngle(value)
                                }
                            }

                            background: Rectangle {
                                x: bucketSlider.leftPadding + bucketSlider.availableWidth / 2 - width / 2
                                y: bucketSlider.topPadding
                                implicitWidth: 3
                                implicitHeight: 200
                                width: implicitWidth
                                height: bucketSlider.availableHeight
                                radius: 2
                                color: "#444444"
                            }

                            handle: Rectangle {
                                x: bucketSlider.leftPadding + bucketSlider.availableWidth / 2 - width / 2
                                y: bucketSlider.topPadding + bucketSlider.visualPosition * (bucketSlider.availableHeight - height)
                                implicitWidth: 18
                                implicitHeight: 18
                                radius: 9
                                color: bucketSlider.pressed ? "#1565c0" : "#2196F3"
                                border.color: "#ffffff"
                                border.width: 1
                            }
                        }
                    }

                    Text {
                        text: (imuService ? imuService.bucketAngle.toFixed(0) : "0") + "°"
                        font.pixelSize: 8
                        color: "#2196F3"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // ALT: Mini Görünümler (yan yana) - Daha büyük
        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: app.largeIconSize * 9.7
            spacing: 0

            // Top-Down View (Kuşbakışı) - Sol
            Rectangle {
                width: parent.width / 2
                height: parent.height
                color: "#0a1628"
                border.color: "#2a4a6a"
                border.width: 1

                // Başlık
                Rectangle {
                    id: topViewHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: app.buttonHeight * 0.78
                    color: "#1a2a3a"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Top View")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // 3D Görünüm - Üstten
                View3D {
                    anchors.top: topViewHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 2

                    environment: SceneEnvironment {
                        clearColor: "#0a1628"
                        backgroundMode: SceneEnvironment.Color
                        antialiasingMode: SceneEnvironment.MSAA
                        antialiasingQuality: SceneEnvironment.Medium
                    }

                    PerspectiveCamera {
                        position: Qt.vector3d(0, 70, 0)
                        eulerRotation.x: -90
                        clipNear: 1
                        clipFar: 500
                    }

                    DirectionalLight {
                        eulerRotation.x: -90
                        brightness: 2.0
                    }

                    // Çalışma alanı sınırı
                    Model {
                        source: "#Rectangle"
                        position: Qt.vector3d(0, -5, 0)
                        eulerRotation.x: -90
                        scale: Qt.vector3d(8, 8, 1)

                        materials: PrincipledMaterial {
                            baseColor: "#ff444460"
                            roughness: 1.0
                        }
                    }

                    Node {
                        scale: Qt.vector3d(3.0, 3.0, 3.0)
                        eulerRotation.y: excavatorNode.eulerRotation.y

                        Excavator {
                            boomAngle: imuService ? imuService.boomAngle : 0.0
                            armAngle: imuService ? imuService.armAngle : 0.0
                            bucketAngle: imuService ? imuService.bucketAngle : 0.0
                        }
                    }
                }
            }

            // Yandan Görünüm - Sağ
            Rectangle {
                width: parent.width / 2
                height: parent.height
                color: "#0a1628"
                border.color: "#2a4a6a"
                border.width: 1

                // Başlık
                Rectangle {
                    id: sideViewHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: app.buttonHeight * 0.78
                    color: "#1a2a3a"

                    Row {
                        anchors.centerIn: parent
                        spacing: app.normalSpacing * 0.8

                        Text {
                            text: tr("Side View")
                            font.pixelSize: app.baseFontSize
                            font.bold: true
                            color: "#ffffff"
                        }

                        Rectangle {
                            width: app.largeIconSize * 1.7
                            height: app.smallIconSize
                            radius: app.smallRadius * 0.7
                            color: "#4CAF5040"

                            Text {
                                anchors.centerIn: parent
                                text: tr("Target")
                                font.pixelSize: app.smallFontSize * 0.8
                                color: "#4CAF50"
                            }
                        }
                    }
                }

                // 3D Görünüm - Yandan
                View3D {
                    anchors.top: sideViewHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 2

                    environment: SceneEnvironment {
                        clearColor: "#0a1628"
                        backgroundMode: SceneEnvironment.Color
                        antialiasingMode: SceneEnvironment.MSAA
                        antialiasingQuality: SceneEnvironment.Medium
                    }

                    PerspectiveCamera {
                        position: Qt.vector3d(45, 20, 0)
                        eulerRotation.y: 90
                        clipNear: 1
                        clipFar: 500
                        fieldOfView: 50
                    }

                    DirectionalLight {
                        eulerRotation.x: -30
                        eulerRotation.y: 90
                        brightness: 2.5
                    }

                    PointLight {
                        position: Qt.vector3d(50, 50, 0)
                        brightness: 2.0
                    }

                    // Zemin profili
                    Model {
                        source: "#Rectangle"
                        position: Qt.vector3d(0, -20, 0)
                        eulerRotation.x: -90
                        scale: Qt.vector3d(15, 8, 1)

                        materials: PrincipledMaterial {
                            baseColor: "#8B7355"
                            roughness: 0.9
                        }
                    }

                    // Su
                    Model {
                        source: "#Rectangle"
                        position: Qt.vector3d(0, 0, 0)
                        eulerRotation.x: -90
                        scale: Qt.vector3d(15, 8, 1)
                        opacity: 0.5

                        materials: PrincipledMaterial {
                            baseColor: "#1a6a9a"
                            roughness: 0.3
                        }
                    }

                    Node {
                        scale: Qt.vector3d(3.0, 3.0, 3.0)

                        Excavator {
                            boomAngle: imuService ? imuService.boomAngle : 0.0
                            armAngle: imuService ? imuService.armAngle : 0.0
                            bucketAngle: imuService ? imuService.bucketAngle : 0.0
                        }
                    }
                }
            }
        }

        // Koordinat Çubuğu (En alt)
        Rectangle {
            id: coordinateBar
            Layout.fillWidth: true
            Layout.preferredHeight: app.buttonHeight
            color: themeManager ? themeManager.backgroundColor : "#2d3748"
            border.color: "#333333"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: app.normalSpacing * 0.8
                spacing: app.normalSpacing

                // X koordinatı
                Row {
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "X:"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.posX.toFixed(2)
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Y koordinatı
                Row {
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "Y:"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.posY.toFixed(2)
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Z koordinatı
                Row {
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "Z:"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.posZ.toFixed(2) + "m"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#00bcd4"
                    }
                }

                Item { Layout.fillWidth: true }

                // Pitch
                Row {
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "Pitch:"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.pitch.toFixed(1) + "°"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Roll
                Row {
                    spacing: app.smallSpacing * 0.5

                    Text {
                        text: "Roll:"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.roll.toFixed(1) + "°"
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "#ffffff"
                    }
                }
            }
        }
    }
}
