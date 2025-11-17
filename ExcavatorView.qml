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
            position: Qt.vector3d(0, 0, 0)

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
        anchors.margins: 10
        height: 120
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: "#404040"
        border.width: 1

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
            spacing: 40

            // Otomatik Dönme Bölümü
            Column {
                spacing: 8

                Rectangle {
                    width: 180
                    height: 30
                    color: "#2a2a2a"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "OTOMATIK DÖNME"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Button {
                    id: autoRotateButton
                    text: autoRotateCheckbox.checked ? "Durdur ⏸" : "Başlat ▶"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 180
                    height: 50
                    palette.button: autoRotateCheckbox.checked ? "#4CAF50" : "#555555"
                    palette.buttonText: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true

                    onClicked: {
                        autoRotateCheckbox.checked = !autoRotateCheckbox.checked
                    }
                }
            }

            // Ayırıcı
            Rectangle {
                width: 2
                height: 100
                color: "#404040"
            }

            // Açı Bölümü
            Column {
                spacing: 8

                Rectangle {
                    width: 250
                    height: 30
                    color: "#2a2a2a"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "AÇI KONTROLÜ"
                        color: "#ffffff"
                        font.pixelSize: 12
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
                height: 100
                color: "#404040"
            }

            // Zoom Bölümü
            Column {
                spacing: 8

                Rectangle {
                    width: 250
                    height: 30
                    color: "#2a2a2a"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "ZOOM"
                        color: "#ffffff"
                        font.pixelSize: 12
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
                height: 100
                color: "#404040"
            }

            // Ölçek Bölümü
            Column {
                spacing: 8

                Rectangle {
                    width: 220
                    height: 30
                    color: "#2a2a2a"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "ÖLÇEK"
                        color: "#ffffff"
                        font.pixelSize: 12
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
                height: 100
                color: "#404040"
            }

            // Sıfırla Bölümü
            Column {
                spacing: 8

                Rectangle {
                    width: 120
                    height: 30
                    color: "#2a2a2a"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: "RESET"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Button {
                    text: "Sıfırla"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 120
                    height: 50
                    palette.button: "#e53935"
                    palette.buttonText: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
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
