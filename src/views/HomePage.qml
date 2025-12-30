import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import ExcavatorUI_Qt3D

// Ana Sayfa - 3D Ekskavatör Görünümü (Mockup'a göre)
Rectangle {
    id: homePage
    color: "#1a1a1a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // Konum verileri
    property real posX: 124.32
    property real posY: 842.11
    property real posZ: -2.45
    property real pitch: 2.1
    property real roll: 0.8

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
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

            // 3D Görünüm
            View3D {
                id: view3D
                anchors.fill: parent
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

            // Derinlik Skalası - Gridli (Sol taraf)
            Rectangle {
                id: depthScale
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10
                width: 55
                color: "transparent"

                // Gradient bar with grid lines
                Item {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 18
                    height: parent.height * 0.7

                    // Ana gradient bar
                    Rectangle {
                        anchors.fill: parent
                        radius: 3

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#4CAF50" }
                            GradientStop { position: 0.3; color: "#FFEB3B" }
                            GradientStop { position: 0.6; color: "#FF9800" }
                            GradientStop { position: 1.0; color: "#f44336" }
                        }
                    }

                    // Grid çizgileri
                    Column {
                        anchors.fill: parent
                        spacing: 0

                        Repeater {
                            model: 5

                            Item {
                                width: parent.width
                                height: parent.height / 5

                                // Yatay çizgi
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: "#00000060"
                                    visible: index < 4
                                }

                                // Küçük işaret çizgileri
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 5
                                    height: 2
                                    color: "#ffffff80"
                                }
                            }
                        }
                    }
                }

                // Derinlik etiketleri
                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.15
                    spacing: (parent.height * 0.7) / 4 - 18

                    Repeater {
                        model: ["0M", "-5M", "-10M", "-15M", "-20M"]

                        Text {
                            text: modelData
                            font.pixelSize: 12
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }
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
                        text: "Top-Down View"
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
                        position: Qt.vector3d(0, 120, 0)
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
                                text: "Hedef"
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
                        position: Qt.vector3d(100, 20, 0)
                        eulerRotation.y: 90
                        clipNear: 1
                        clipFar: 500
                        fieldOfView: 45
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

                // Derinlik etiketleri (sağ taraf)
                Column {
                    id: depthLabels
                    anchors.right: parent.right
                    anchors.top: sideViewHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 8
                    anchors.topMargin: 20
                    width: 60
                    spacing: 35

                    Repeater {
                        model: ["-1.0m", "-1.5m", "-2.0m", "-2.5m"]

                        Row {
                            spacing: 5
                            layoutDirection: Qt.RightToLeft

                            Text {
                                text: modelData
                                font.pixelSize: 11
                                color: "#888888"
                            }

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: index === 2 ? "#f44336" : "#888888"
                                anchors.verticalCenter: parent.verticalCenter
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
            color: "#1a1a1a"
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
