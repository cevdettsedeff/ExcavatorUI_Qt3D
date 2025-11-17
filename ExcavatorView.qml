import QtQuick
import QtQuick.Controls
import QtQuick3D
import QtQuick3D.Helpers

Rectangle {
    id: excavatorViewRoot
    color: "#2a2a2a"

    View3D {
        id: view3D
        anchors.fill: parent
        anchors.topMargin: 60
        anchors.bottomMargin: 150
        anchors.margins: 20

        environment: SceneEnvironment {
            clearColor: "#2a2a2a"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        // Kamera
        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 50, 200)
            eulerRotation.x: -10
            clipNear: 1
            clipFar: 20000
            fieldOfView: 60
        }

        // Işıklandırma
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
            ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
        }

        PointLight {
            position: Qt.vector3d(200, 100, 0)
            brightness: 1.0
            color: Qt.rgba(1.0, 1.0, 0.9, 1.0)
        }

        // Excavator Container Node - Bu node döndürülecek
        Node {
            id: excavatorContainer
            position: Qt.vector3d(0, -35, 0)  // Yere oturmuş pozisyon

            // Scale ve rotation bu node'a uygulanacak
            property real currentScale: 1.5
            scale: Qt.vector3d(currentScale, currentScale, currentScale)

            Excavator {
                id: excavatorModel
            }
        }

        // Zemin - Ön taraf (Deniz)
        Model {
            source: "#Rectangle"
            position: Qt.vector3d(0, -50, 100)
            eulerRotation.x: -90
            scale: Qt.vector3d(20, 20, 1)
            materials: PrincipledMaterial {
                baseColor: "#1e88e5"  // Deniz mavisi
                roughness: 0.3
                metalness: 0.6
            }
        }

        // Zemin - Arka taraf (Toprak)
        Model {
            source: "#Rectangle"
            position: Qt.vector3d(0, -50, -100)
            eulerRotation.x: -90
            scale: Qt.vector3d(20, 20, 1)
            materials: PrincipledMaterial {
                baseColor: "#8B4513"  // Toprak kahverengisi
                roughness: 0.9
                metalness: 0.1
            }
        }

        // Zemin - Merkez (Geçiş bölgesi)
        Model {
            source: "#Rectangle"
            position: Qt.vector3d(0, -49, 0)
            eulerRotation.x: -90
            scale: Qt.vector3d(20, 5, 1)
            materials: PrincipledMaterial {
                baseColor: "#D2691E"  // Kumsal rengi
                roughness: 0.7
                metalness: 0.2
            }
        }
    }

    // Rotation Animation - Container'a bağlı
    SequentialAnimation {
        id: rotationAnimation
        running: autoRotateCheckbox.checked
        loops: Animation.Infinite

        NumberAnimation {
            target: excavatorContainer
            property: "eulerRotation.y"
            from: 0
            to: 360
            duration: 20000  // Yavaş dönme (20 saniye)
            easing.type: Easing.Linear
        }
    }

    // Kontroller - Alt Menü (Yatay Layout)
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        height: 130
        color: "#1e1e1e"
        opacity: 0.98
        radius: 12
        border.color: "#505050"
        border.width: 2

        // Gradient arka plan için
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#252525" }
            GradientStop { position: 1.0; color: "#1a1a1a" }
        }

        CheckBox {
            id: autoRotateCheckbox
            checked: false
            visible: false

            onCheckedChanged: {
                if (checked) {
                    rotationAnimation.restart()
                } else {
                    rotationAnimation.stop()
                }
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 30

            // Otomatik Dönme Bölümü
            Column {
                spacing: 10

                Rectangle {
                    width: 180
                    height: 35
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#2d2d2d"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "⚙ OTOMATIK DÖNME"
                        color: "#00bcd4"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Button {
                    id: autoRotateButton
                    text: autoRotateCheckbox.checked ? "⏸ Durdur" : "▶ Başlat"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 180
                    height: 55

                    background: Rectangle {
                        color: autoRotateCheckbox.checked ? "#4CAF50" : "#424242"
                        radius: 8
                        border.color: autoRotateCheckbox.checked ? "#66BB6A" : "#616161"
                        border.width: 2

                        // Hover efekti için gradient
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: autoRotateCheckbox.checked ? "#66BB6A" : "#505050" }
                            GradientStop { position: 1.0; color: autoRotateCheckbox.checked ? "#4CAF50" : "#383838" }
                        }
                    }

                    contentItem: Text {
                        text: autoRotateButton.text
                        color: "#ffffff"
                        font.pixelSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        autoRotateCheckbox.checked = !autoRotateCheckbox.checked
                    }
                }
            }

            // Ayırıcı
            Rectangle {
                width: 2
                height: 110
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: "#505050" }
                    GradientStop { position: 0.8; color: "#505050" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Açı Bölümü
            Column {
                spacing: 10

                Rectangle {
                    width: 250
                    height: 35
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#2d2d2d"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🔄 AÇI KONTROLÜ"
                        color: "#ffc107"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "◄"
                        width: 50
                        height: 50
                        enabled: !autoRotateCheckbox.checked
                        font.pixelSize: 20
                        onClicked: {
                            excavatorContainer.eulerRotation.y -= 15
                            rotationSlider.value = excavatorContainer.eulerRotation.y % 360
                        }
                    }

                    Slider {
                        id: rotationSlider
                        from: 0
                        to: 360
                        value: 0
                        width: 120
                        enabled: !autoRotateCheckbox.checked
                        anchors.verticalCenter: parent.verticalCenter

                        onValueChanged: {
                            if (!autoRotateCheckbox.checked) {
                                excavatorContainer.eulerRotation.y = value
                            }
                        }
                    }

                    Button {
                        text: "►"
                        width: 50
                        height: 50
                        enabled: !autoRotateCheckbox.checked
                        font.pixelSize: 20
                        onClicked: {
                            excavatorContainer.eulerRotation.y += 15
                            rotationSlider.value = excavatorContainer.eulerRotation.y % 360
                        }
                    }

                    Text {
                        text: Math.round(rotationSlider.value) + "°"
                        color: "#ffffff"
                        width: 45
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 14
                    }
                }
            }

            // Ayırıcı
            Rectangle {
                width: 2
                height: 110
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: "#505050" }
                    GradientStop { position: 0.8; color: "#505050" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Zoom Bölümü
            Column {
                spacing: 10

                Rectangle {
                    width: 250
                    height: 35
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#2d2d2d"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🔍 ZOOM"
                        color: "#9c27b0"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "−"
                        width: 50
                        height: 50
                        font.pixelSize: 24
                        onClicked: {
                            zoomSlider.value = Math.min(500, zoomSlider.value + 20)
                        }
                    }

                    Slider {
                        id: zoomSlider
                        from: 100
                        to: 500
                        value: 200
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter

                        onValueChanged: {
                            camera.position.z = value
                        }
                    }

                    Button {
                        text: "+"
                        width: 50
                        height: 50
                        font.pixelSize: 24
                        onClicked: {
                            zoomSlider.value = Math.max(100, zoomSlider.value - 20)
                        }
                    }

                    Text {
                        text: Math.round(zoomSlider.value)
                        color: "#ffffff"
                        width: 45
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 14
                    }
                }
            }

            // Ayırıcı
            Rectangle {
                width: 2
                height: 110
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: "#505050" }
                    GradientStop { position: 0.8; color: "#505050" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Ölçek Bölümü
            Column {
                spacing: 10

                Rectangle {
                    width: 220
                    height: 35
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#2d2d2d"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "📏 ÖLÇEK"
                        color: "#ff5722"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Slider {
                        id: scaleSlider
                        from: 0.5
                        to: 3.0
                        value: 1.5
                        stepSize: 0.1
                        width: 150
                        anchors.verticalCenter: parent.verticalCenter

                        onValueChanged: {
                            excavatorContainer.currentScale = value
                        }
                    }

                    Text {
                        text: scaleSlider.value.toFixed(1) + "x"
                        color: "#ffffff"
                        width: 50
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 14
                    }
                }
            }

            // Ayırıcı
            Rectangle {
                width: 2
                height: 110
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.2; color: "#505050" }
                    GradientStop { position: 0.8; color: "#505050" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Sıfırla Bölümü
            Column {
                spacing: 10

                Rectangle {
                    width: 130
                    height: 35
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#2d2d2d"
                        radius: 6
                        border.color: "#404040"
                        border.width: 1
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🔄 RESET"
                        color: "#f44336"
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                Button {
                    text: "Sıfırla"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 130
                    height: 55

                    background: Rectangle {
                        color: "#e53935"
                        radius: 8
                        border.color: "#ef5350"
                        border.width: 2

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#ef5350" }
                            GradientStop { position: 1.0; color: "#d32f2f" }
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        autoRotateCheckbox.checked = false
                        rotationSlider.value = 0
                        zoomSlider.value = 200
                        scaleSlider.value = 1.5
                        excavatorContainer.eulerRotation.y = 0
                        camera.position = Qt.vector3d(0, 50, 200)
                        camera.eulerRotation.x = -10
                    }
                }
            }
        }
    }

    // Mouse ile döndürme
    MouseArea {
        anchors.fill: view3D
        property real lastX: 0
        property real lastY: 0

        onPressed: (mouse) => {
            lastX = mouse.x
            lastY = mouse.y
        }

        onPositionChanged: (mouse) => {
            if (pressed && !autoRotateCheckbox.checked) {
                var deltaX = mouse.x - lastX
                var deltaY = mouse.y - lastY

                excavatorContainer.eulerRotation.y += deltaX * 0.5
                camera.eulerRotation.x += deltaY * 0.2
                camera.eulerRotation.x = Math.max(-45, Math.min(45, camera.eulerRotation.x))

                rotationSlider.value = excavatorContainer.eulerRotation.y % 360

                lastX = mouse.x
                lastY = mouse.y
            }
        }

        onWheel: (wheel) => {
            var delta = wheel.angleDelta.y / 120
            zoomSlider.value = Math.max(100, Math.min(500, zoomSlider.value - delta * 20))
        }
    }
}
