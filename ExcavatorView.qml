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
            property real currentScale: 1.0
            scale: Qt.vector3d(currentScale, currentScale, currentScale)

            Excavator {
                id: excavatorModel
            }
        }

        // Zemin
        Model {
            source: "#Rectangle"
            position: Qt.vector3d(0, -50, 0)
            eulerRotation.x: -90
            scale: Qt.vector3d(20, 20, 1)
            materials: PrincipledMaterial {
                baseColor: "#2a2a2a"
                roughness: 0.9
                metalness: 0.1
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
            duration: 10000
            easing.type: Easing.InOutQuad
        }
    }

    // Kontroller - Buton Bazlı
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: controlsColumn.width + 40
        height: controlsColumn.height + 40
        color: "#1a1a1a"
        opacity: 0.9
        radius: 10
        border.color: "#404040"
        border.width: 1

        Column {
            id: controlsColumn
            anchors.centerIn: parent
            spacing: 15

            // Otomatik Dönme Butonu
            Button {
                id: autoRotateButton
                text: autoRotateCheckbox.checked ? "Otomatik Dönmeyi Durdur" : "Otomatik Döndür"
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                palette.button: autoRotateCheckbox.checked ? "#4CAF50" : "#555555"
                palette.buttonText: "#ffffff"

                onClicked: {
                    autoRotateCheckbox.checked = !autoRotateCheckbox.checked
                }
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

            // Döndürme Butonları
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "Döndür:"
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    text: "◄ Sola"
                    width: 80
                    enabled: !autoRotateCheckbox.checked
                    onClicked: {
                        excavatorContainer.eulerRotation.y -= 15
                        rotationSlider.value = excavatorContainer.eulerRotation.y % 360
                    }
                }

                Button {
                    text: "Sağa ►"
                    width: 80
                    enabled: !autoRotateCheckbox.checked
                    onClicked: {
                        excavatorContainer.eulerRotation.y += 15
                        rotationSlider.value = excavatorContainer.eulerRotation.y % 360
                    }
                }
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "Açı:"
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    id: rotationSlider
                    from: 0
                    to: 360
                    value: 0
                    width: 150
                    enabled: !autoRotateCheckbox.checked

                    onValueChanged: {
                        if (!autoRotateCheckbox.checked) {
                            excavatorContainer.eulerRotation.y = value
                        }
                    }
                }
                Text {
                    text: Math.round(rotationSlider.value) + "°"
                    color: "#ffffff"
                    width: 50
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Zoom Butonları
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: "Zoom:"
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Button {
                    text: "−"
                    width: 40
                    height: 40
                    font.pixelSize: 24
                    onClicked: {
                        zoomSlider.value = Math.min(500, zoomSlider.value + 20)
                    }
                }

                Button {
                    text: "+"
                    width: 40
                    height: 40
                    font.pixelSize: 24
                    onClicked: {
                        zoomSlider.value = Math.max(100, zoomSlider.value - 20)
                    }
                }

                Slider {
                    id: zoomSlider
                    from: 100
                    to: 500
                    value: 200
                    width: 150

                    onValueChanged: {
                        camera.position.z = value
                    }
                }

                Text {
                    text: Math.round(zoomSlider.value)
                    color: "#ffffff"
                    width: 50
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Ölçek Slider
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "Ölçek:"
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    id: scaleSlider
                    from: 0.5
                    to: 3.0
                    value: 1.0
                    stepSize: 0.1
                    width: 200

                    onValueChanged: {
                        excavatorContainer.currentScale = value
                    }
                }
                Text {
                    text: scaleSlider.value.toFixed(1) + "x"
                    color: "#ffffff"
                    width: 50
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Sıfırla Butonu
            Button {
                text: "Sıfırla"
                anchors.horizontalCenter: parent.horizontalCenter
                width: 120
                onClicked: {
                    autoRotateCheckbox.checked = false
                    rotationSlider.value = 0
                    zoomSlider.value = 200
                    scaleSlider.value = 1.0
                    excavatorContainer.eulerRotation.y = 0
                    camera.position = Qt.vector3d(0, 50, 200)
                    camera.eulerRotation.x = -10
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
