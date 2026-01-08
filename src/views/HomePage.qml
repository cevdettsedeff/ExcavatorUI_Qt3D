import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import ExcavatorUI_Qt3D

// Ana Sayfa - 3D Ekskavatör Görünümü (Mockup'a göre)
Rectangle {
    id: homePage
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

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
                height: 40
                color: themeManager ? themeManager.backgroundColorDark : "#1a2a3a"
                z: 10

                Text {
                    anchors.centerIn: parent
                    text: tr("3D Excavator View")
                    font.pixelSize: 16
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

            // Kepçe Derinlik Göstergesi (Sol taraf)
            BucketDepthIndicator {
                id: bucketDepthIndicator
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 8
                width: 120

                maxDepth: homePage.bucketMaxDepth
                minDepth: homePage.bucketMinDepth
                waterLevel: homePage.bucketWaterLevel
                targetDepth: homePage.bucketTargetDepth
                currentBucketDepth: homePage.bucketCurrentDepth
            }

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

            // Sürüklenebilir Kontroller (Sağ taraf) - Responsive
            Column {
                id: manualControls
                anchors.right: parent.right
                anchors.top: view3DHeader.bottom
                anchors.bottom: parent.bottom
                anchors.margins: Math.max(5, parent.width * 0.01)
                width: Math.max(100, Math.min(150, parent.width * 0.15))
                spacing: Math.max(5, parent.height * 0.01)

                // Başlık
                Rectangle {
                    width: parent.width
                    height: Math.max(30, Math.min(40, parent.width * 0.3))
                    color: themeManager ? themeManager.backgroundColorDark : "#1a2a3a"
                    radius: 6

                    Text {
                        anchors.centerIn: parent
                        text: tr("Manual Control")
                        font.pixelSize: Math.max(9, Math.min(12, parent.width * 0.09))
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Rastgele Hareket Butonu
                Button {
                    width: parent.width
                    height: Math.max(35, Math.min(45, parent.width * 0.35))

                    background: Rectangle {
                        color: imuService && imuService.isRandomMode ? "#e91e63" : "#9c27b0"
                        radius: 6
                        border.color: imuService && imuService.isRandomMode ? "#f06292" : "#ba68c8"
                        border.width: 2

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    contentItem: Text {
                        anchors.centerIn: parent
                        text: imuService && imuService.isRandomMode ? tr("Stop") : tr("Test")
                        font.pixelSize: Math.max(9, Math.min(12, parent.width * 0.1))
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
                    spacing: Math.max(3, parent.width * 0.03)

                    Text {
                        text: "Boom"
                        font.pixelSize: Math.max(8, Math.min(11, parent.width * 0.08))
                        font.bold: true
                        color: "#ffc107"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: Math.max(90, Math.min(120, parent.width * 0.9))
                        color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                        radius: 6
                        border.color: "#ffc107"
                        border.width: 2

                        Slider {
                            id: boomSlider
                            anchors.centerIn: parent
                            width: parent.height - 20
                            height: parent.width - 20
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
                                x: boomSlider.leftPadding + (boomSlider.horizontal ? 0 : boomSlider.availableWidth / 2 - width / 2)
                                y: boomSlider.topPadding + (boomSlider.horizontal ? boomSlider.availableHeight / 2 - height / 2 : 0)
                                implicitWidth: boomSlider.horizontal ? 200 : 4
                                implicitHeight: boomSlider.horizontal ? 4 : 200
                                width: boomSlider.horizontal ? boomSlider.availableWidth : implicitWidth
                                height: boomSlider.horizontal ? implicitHeight : boomSlider.availableHeight
                                radius: 2
                                color: "#444444"
                            }

                            handle: Rectangle {
                                x: boomSlider.leftPadding + (boomSlider.horizontal ? boomSlider.visualPosition * (boomSlider.availableWidth - width) : boomSlider.availableWidth / 2 - width / 2)
                                y: boomSlider.topPadding + (boomSlider.horizontal ? boomSlider.availableHeight / 2 - height / 2 : boomSlider.visualPosition * (boomSlider.availableHeight - height))
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 13
                                color: boomSlider.pressed ? "#f0a000" : "#ffc107"
                                border.color: "#ffffff"
                                border.width: 2
                            }
                        }
                    }

                    Text {
                        text: (imuService ? imuService.boomAngle.toFixed(1) : "0.0") + "°"
                        font.pixelSize: Math.max(8, Math.min(11, parent.width * 0.08))
                        color: "#ffc107"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Arm Kontrolü
                Column {
                    width: parent.width
                    spacing: Math.max(3, parent.width * 0.03)

                    Text {
                        text: "Arm"
                        font.pixelSize: Math.max(8, Math.min(11, parent.width * 0.08))
                        font.bold: true
                        color: "#4CAF50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: Math.max(90, Math.min(120, parent.width * 0.9))
                        color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                        radius: 6
                        border.color: "#4CAF50"
                        border.width: 2

                        Slider {
                            id: armSlider
                            anchors.centerIn: parent
                            width: parent.height - 20
                            height: parent.width - 20
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
                                x: armSlider.leftPadding + (armSlider.horizontal ? 0 : armSlider.availableWidth / 2 - width / 2)
                                y: armSlider.topPadding + (armSlider.horizontal ? armSlider.availableHeight / 2 - height / 2 : 0)
                                implicitWidth: armSlider.horizontal ? 200 : 4
                                implicitHeight: armSlider.horizontal ? 4 : 200
                                width: armSlider.horizontal ? armSlider.availableWidth : implicitWidth
                                height: armSlider.horizontal ? implicitHeight : armSlider.availableHeight
                                radius: 2
                                color: "#444444"
                            }

                            handle: Rectangle {
                                x: armSlider.leftPadding + (armSlider.horizontal ? armSlider.visualPosition * (armSlider.availableWidth - width) : armSlider.availableWidth / 2 - width / 2)
                                y: armSlider.topPadding + (armSlider.horizontal ? armSlider.availableHeight / 2 - height / 2 : armSlider.visualPosition * (armSlider.availableHeight - height))
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 13
                                color: armSlider.pressed ? "#2e7d32" : "#4CAF50"
                                border.color: "#ffffff"
                                border.width: 2
                            }
                        }
                    }

                    Text {
                        text: (imuService ? imuService.armAngle.toFixed(1) : "0.0") + "°"
                        font.pixelSize: Math.max(8, Math.min(11, parent.width * 0.08))
                        color: "#4CAF50"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Bucket Kontrolü
                Column {
                    width: parent.width
                    spacing: Math.max(3, parent.width * 0.03)

                    Text {
                        text: "Bucket"
                        font.pixelSize: Math.max(8, Math.min(11, parent.width * 0.08))
                        font.bold: true
                        color: "#2196F3"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        width: parent.width
                        height: Math.max(90, Math.min(120, parent.width * 0.9))
                        color: themeManager ? themeManager.backgroundColor : "#2a2a2a"
                        radius: 6
                        border.color: "#2196F3"
                        border.width: 2

                        Slider {
                            id: bucketSlider
                            anchors.centerIn: parent
                            width: parent.height - 20
                            height: parent.width - 20
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
                                x: bucketSlider.leftPadding + (bucketSlider.horizontal ? 0 : bucketSlider.availableWidth / 2 - width / 2)
                                y: bucketSlider.topPadding + (bucketSlider.horizontal ? bucketSlider.availableHeight / 2 - height / 2 : 0)
                                implicitWidth: bucketSlider.horizontal ? 200 : 4
                                implicitHeight: bucketSlider.horizontal ? 4 : 200
                                width: bucketSlider.horizontal ? bucketSlider.availableWidth : implicitWidth
                                height: bucketSlider.horizontal ? implicitHeight : bucketSlider.availableHeight
                                radius: 2
                                color: "#444444"
                            }

                            handle: Rectangle {
                                x: bucketSlider.leftPadding + (bucketSlider.horizontal ? bucketSlider.visualPosition * (bucketSlider.availableWidth - width) : bucketSlider.availableWidth / 2 - width / 2)
                                y: bucketSlider.topPadding + (bucketSlider.horizontal ? bucketSlider.availableHeight / 2 - height / 2 : bucketSlider.visualPosition * (bucketSlider.availableHeight - height))
                                implicitWidth: 26
                                implicitHeight: 26
                                radius: 13
                                color: bucketSlider.pressed ? "#1565c0" : "#2196F3"
                                border.color: "#ffffff"
                                border.width: 2
                            }
                        }
                    }

                    Text {
                        text: (imuService ? imuService.bucketAngle.toFixed(1) : "0.0") + "°"
                        font.pixelSize: Math.max(8, Math.min(11, parent.width * 0.08))
                        color: "#2196F3"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // ALT: Mini Görünümler (yan yana) - Daha büyük
        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: 350
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
                    height: 35
                    color: "#1a2a3a"

                    Text {
                        anchors.centerIn: parent
                        text: tr("Top-Down View")
                        font.pixelSize: 14
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
                    height: 35
                    color: "#1a2a3a"

                    Row {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: tr("Side View")
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }

                        Rectangle {
                            width: 60
                            height: 20
                            radius: 3
                            color: "#4CAF5040"

                            Text {
                                anchors.centerIn: parent
                                text: tr("Target")
                                font.pixelSize: 10
                                color: "#4CAF50"
                            }
                        }
                    }
                }

                // 3D Görünüm - Yandan
                View3D {
                    anchors.top: sideViewHeader.bottom
                    anchors.left: parent.left
                    anchors.right: depthLabels.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 2

                    environment: SceneEnvironment {
                        clearColor: "#0a1628"
                        backgroundMode: SceneEnvironment.Color
                        antialiasingMode: SceneEnvironment.MSAA
                        antialiasingQuality: SceneEnvironment.Medium
                    }

                    PerspectiveCamera {
                        position: Qt.vector3d(-50, 20, 0)
                        eulerRotation.y: -90
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

                // Derinlik göstergesi (sağ taraf) - Termometre tarzı
                Rectangle {
                    id: depthLabels
                    anchors.right: parent.right
                    anchors.top: sideViewHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 5
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    width: 50
                    color: "#2a2a2a"
                    radius: 4
                    border.color: "#444444"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 5

                        // Başlık
                        Text {
                            text: "Derinlik"
                            font.pixelSize: 8
                            font.bold: true
                            color: "#00bcd4"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Termometre stili bar
                        Item {
                            width: parent.width
                            height: parent.height - 20

                            // Ana dikey çubuk (gri background)
                            Rectangle {
                                id: thermometerBar
                                anchors.centerIn: parent
                                width: 8
                                height: parent.height - 20
                                radius: 4
                                color: "#1a1a1a"
                                border.color: "#555555"
                                border.width: 1

                                // Renkli gradyan dolgu (aşağıdan yukarı)
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 2
                                    height: parent.height * 0.75
                                    radius: 3
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#9C27B0" }
                                        GradientStop { position: 0.33; color: "#FF5722" }
                                        GradientStop { position: 0.66; color: "#FFC107" }
                                        GradientStop { position: 1.0; color: "#4CAF50" }
                                    }
                                }
                            }

                            // Scala işaretleri ve metinler
                            Column {
                                anchors.fill: parent
                                spacing: 0

                                Repeater {
                                    model: [
                                        {depth: "-1.0", color: "#4CAF50", position: 0.0},
                                        {depth: "-1.5", color: "#FFC107", position: 0.33},
                                        {depth: "-2.0", color: "#FF5722", position: 0.66},
                                        {depth: "-2.5", color: "#9C27B0", position: 1.0}
                                    ]

                                    Item {
                                        width: parent.width
                                        height: parent.height / 4

                                        // Yatay çizgi (skala)
                                        Rectangle {
                                            anchors.left: thermometerBar.right
                                            anchors.leftMargin: -4
                                            anchors.verticalCenter: parent.top
                                            width: 8
                                            height: 2
                                            color: modelData.color
                                        }

                                        // Derinlik metni
                                        Text {
                                            anchors.left: thermometerBar.right
                                            anchors.leftMargin: 6
                                            anchors.verticalCenter: parent.top
                                            text: modelData.depth + "m"
                                            font.pixelSize: 7
                                            font.bold: true
                                            color: modelData.color
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Koordinat Çubuğu (En alt)
        Rectangle {
            id: coordinateBar
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            color: themeManager ? themeManager.backgroundColor : "#2d3748"
            border.color: "#333333"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                // X koordinatı
                Row {
                    spacing: 5

                    Text {
                        text: "X:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.posX.toFixed(2)
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Y koordinatı
                Row {
                    spacing: 5

                    Text {
                        text: "Y:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.posY.toFixed(2)
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Z koordinatı
                Row {
                    spacing: 5

                    Text {
                        text: "Z:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.posZ.toFixed(2) + "m"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#00bcd4"
                    }
                }

                Item { Layout.fillWidth: true }

                // Pitch
                Row {
                    spacing: 5

                    Text {
                        text: "Pitch:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.pitch.toFixed(1) + "°"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Roll
                Row {
                    spacing: 5

                    Text {
                        text: "Roll:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#888888"
                    }

                    Text {
                        text: homePage.roll.toFixed(1) + "°"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ffffff"
                    }
                }
            }
        }
    }
}
