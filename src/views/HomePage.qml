import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import ExcavatorUI_Qt3D

// Ana Sayfa - 3D Ekskavatör Görünümü (Yeni Layout)
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
    property real bucketMaxDepth: 10.0
    property real bucketMinDepth: configManager ? -Math.max(configManager.calculatedMaxDepth + 5, 20) : -25.0
    property real bucketWaterLevel: 0.0
    property real bucketTargetDepth: configManager ? -configManager.targetDepth : -15.0
    property real bucketCurrentDepth: imuService ? imuService.bucketDepth : -5.0

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Ana Layout - Yatay (Sol: Derinlik Kartı, Sağ: İçerik)
    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // SOL: Derinlik Göstergesi Kartı - Üstten alta uzanır
        Rectangle {
            id: depthCard
            Layout.preferredWidth: 90
            Layout.fillHeight: true
            color: "#0a1628"
            radius: 8
            border.color: "#2a4a6a"
            border.width: 2

            // Kart Başlığı
            Rectangle {
                id: depthCardHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 28
                color: "#1a2a3a"
                radius: 8

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 8
                    color: parent.color
                }

                Text {
                    anchors.centerIn: parent
                    text: tr("Depth")
                    font.pixelSize: 10
                    font.bold: true
                    color: "#ffffff"
                }
            }

            // Derinlik Göstergesi
            BucketDepthIndicator {
                id: bucketDepthIndicator
                anchors.top: depthCardHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 4

                maxDepth: homePage.bucketMaxDepth
                minDepth: homePage.bucketMinDepth
                waterLevel: homePage.bucketWaterLevel
                targetDepth: homePage.bucketTargetDepth
                currentBucketDepth: homePage.bucketCurrentDepth
            }
        }

        // SAĞ: Ana İçerik
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            // ÜST: 3D Ekskavatör Görünümü (Manuel kontroller içinde)
            Rectangle {
                id: main3DView
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#0a1628"
                radius: 6
                border.color: "#2a4a6a"
                border.width: 1

                // Başlık
                Rectangle {
                    id: view3DHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 28
                    color: "#1a2a3a"
                    radius: 6

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 6
                        color: parent.color
                    }

                    Text {
                        anchors.centerIn: parent
                        text: tr("3D Excavator View")
                        font.pixelSize: 11
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // 3D Görünüm
                View3D {
                    id: view3D
                    anchors.top: view3DHeader.bottom
                    anchors.left: parent.left
                    anchors.right: manualControlsPanel.left
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

                    // Grid çizgileri
                    Node {
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

                // Mouse kontrolü
                MouseArea {
                    anchors.top: view3DHeader.bottom
                    anchors.left: parent.left
                    anchors.right: manualControlsPanel.left
                    anchors.bottom: parent.bottom
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

                // Manuel Kontroller Paneli (Sağ tarafta, 3D görünüm içinde)
                Rectangle {
                    id: manualControlsPanel
                    anchors.top: view3DHeader.bottom
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 4
                    width: 80
                    color: "#1a2a3a"
                    radius: 6
                    border.color: "#2a4a6a"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4

                        // Başlık
                        Text {
                            text: tr("Manual")
                            font.pixelSize: 9
                            font.bold: true
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // Test Butonu
                        Rectangle {
                            width: parent.width
                            height: 32
                            color: imuService && imuService.isRandomMode ? "#e91e63" : "#9c27b0"
                            radius: 4
                            border.color: imuService && imuService.isRandomMode ? "#f06292" : "#ba68c8"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 1

                                Text {
                                    text: "🎲"
                                    font.pixelSize: 12
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Text {
                                    text: imuService && imuService.isRandomMode ? tr("Stop") : tr("Test")
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: "#ffffff"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: imuService && !imuService.isDigging
                                cursorShape: Qt.PointingHandCursor
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
                        }

                        // Boom Kontrolü
                        Rectangle {
                            width: parent.width
                            height: (parent.height - 70) / 3
                            color: "#2a2a2a"
                            radius: 4
                            border.color: "#ffc107"
                            border.width: 2

                            Column {
                                anchors.fill: parent
                                anchors.margins: 2
                                spacing: 1

                                Text {
                                    text: "Boom"
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: "#ffc107"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Slider {
                                    id: boomSlider
                                    width: parent.width - 4
                                    height: parent.height - 28
                                    anchors.horizontalCenter: parent.horizontalCenter
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
                                        width: 4
                                        height: boomSlider.availableHeight
                                        radius: 2
                                        color: "#444444"
                                    }

                                    handle: Rectangle {
                                        x: boomSlider.leftPadding + boomSlider.availableWidth / 2 - width / 2
                                        y: boomSlider.topPadding + boomSlider.visualPosition * (boomSlider.availableHeight - height)
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: boomSlider.pressed ? "#f0a000" : "#ffc107"
                                        border.color: "#ffffff"
                                        border.width: 1
                                    }
                                }

                                Text {
                                    text: (imuService ? imuService.boomAngle.toFixed(0) : "0") + "°"
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: "#ffc107"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // Arm Kontrolü
                        Rectangle {
                            width: parent.width
                            height: (parent.height - 70) / 3
                            color: "#2a2a2a"
                            radius: 4
                            border.color: "#4CAF50"
                            border.width: 2

                            Column {
                                anchors.fill: parent
                                anchors.margins: 2
                                spacing: 1

                                Text {
                                    text: "Arm"
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: "#4CAF50"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Slider {
                                    id: armSlider
                                    width: parent.width - 4
                                    height: parent.height - 28
                                    anchors.horizontalCenter: parent.horizontalCenter
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
                                        width: 4
                                        height: armSlider.availableHeight
                                        radius: 2
                                        color: "#444444"
                                    }

                                    handle: Rectangle {
                                        x: armSlider.leftPadding + armSlider.availableWidth / 2 - width / 2
                                        y: armSlider.topPadding + armSlider.visualPosition * (armSlider.availableHeight - height)
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: armSlider.pressed ? "#2e7d32" : "#4CAF50"
                                        border.color: "#ffffff"
                                        border.width: 1
                                    }
                                }

                                Text {
                                    text: (imuService ? imuService.armAngle.toFixed(0) : "0") + "°"
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: "#4CAF50"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        // Bucket Kontrolü
                        Rectangle {
                            width: parent.width
                            height: (parent.height - 70) / 3
                            color: "#2a2a2a"
                            radius: 4
                            border.color: "#2196F3"
                            border.width: 2

                            Column {
                                anchors.fill: parent
                                anchors.margins: 2
                                spacing: 1

                                Text {
                                    text: "Bucket"
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: "#2196F3"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Slider {
                                    id: bucketSlider
                                    width: parent.width - 4
                                    height: parent.height - 28
                                    anchors.horizontalCenter: parent.horizontalCenter
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
                                        width: 4
                                        height: bucketSlider.availableHeight
                                        radius: 2
                                        color: "#444444"
                                    }

                                    handle: Rectangle {
                                        x: bucketSlider.leftPadding + bucketSlider.availableWidth / 2 - width / 2
                                        y: bucketSlider.topPadding + bucketSlider.visualPosition * (bucketSlider.availableHeight - height)
                                        width: 16
                                        height: 16
                                        radius: 8
                                        color: bucketSlider.pressed ? "#1565c0" : "#2196F3"
                                        border.color: "#ffffff"
                                        border.width: 1
                                    }
                                }

                                Text {
                                    text: (imuService ? imuService.bucketAngle.toFixed(0) : "0") + "°"
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: "#2196F3"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
            }

            // ALT: Mini Görünümler (yan yana)
            Row {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                spacing: 4

                // Üstten Görünüm
                Rectangle {
                    width: (parent.width - 4) / 2
                    height: parent.height
                    color: "#0a1628"
                    radius: 6
                    border.color: "#2a4a6a"
                    border.width: 1

                    Rectangle {
                        id: topViewHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 24
                        color: "#1a2a3a"
                        radius: 6

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 6
                            color: parent.color
                        }

                        Text {
                            anchors.centerIn: parent
                            text: tr("Top View")
                            font.pixelSize: 10
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

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

                // Yandan Görünüm
                Rectangle {
                    width: (parent.width - 4) / 2
                    height: parent.height
                    color: "#0a1628"
                    radius: 6
                    border.color: "#2a4a6a"
                    border.width: 1

                    Rectangle {
                        id: sideViewHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 24
                        color: "#1a2a3a"
                        radius: 6

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 6
                            color: parent.color
                        }

                        Text {
                            anchors.centerIn: parent
                            text: tr("Side View")
                            font.pixelSize: 10
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

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
                Layout.preferredHeight: 28
                color: themeManager ? themeManager.backgroundColor : "#2d3748"
                radius: 4
                border.color: "#333333"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 15

                    Row {
                        spacing: 3
                        Text { text: "X:"; font.pixelSize: 10; font.bold: true; color: "#888888" }
                        Text { text: homePage.posX.toFixed(2); font.pixelSize: 10; font.bold: true; color: "#ffffff" }
                    }

                    Row {
                        spacing: 3
                        Text { text: "Y:"; font.pixelSize: 10; font.bold: true; color: "#888888" }
                        Text { text: homePage.posY.toFixed(2); font.pixelSize: 10; font.bold: true; color: "#ffffff" }
                    }

                    Row {
                        spacing: 3
                        Text { text: "Z:"; font.pixelSize: 10; font.bold: true; color: "#888888" }
                        Text { text: homePage.posZ.toFixed(2) + "m"; font.pixelSize: 10; font.bold: true; color: "#00bcd4" }
                    }

                    Item { Layout.fillWidth: true }

                    Row {
                        spacing: 3
                        Text { text: "Pitch:"; font.pixelSize: 10; font.bold: true; color: "#888888" }
                        Text { text: homePage.pitch.toFixed(1) + "°"; font.pixelSize: 10; font.bold: true; color: "#ffffff" }
                    }

                    Row {
                        spacing: 3
                        Text { text: "Roll:"; font.pixelSize: 10; font.bold: true; color: "#888888" }
                        Text { text: homePage.roll.toFixed(1) + "°"; font.pixelSize: 10; font.bold: true; color: "#ffffff" }
                    }
                }
            }
        }
    }
}
