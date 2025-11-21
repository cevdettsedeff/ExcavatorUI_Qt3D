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
        anchors.bottomMargin: 120
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
            position: Qt.vector3d(0, 80, 200)
            eulerRotation.x: -15
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
            position: Qt.vector3d(0, 0, 0)  // Grid üzerinde (y=0 seviyesi)

            // Scale ve rotation bu node'a uygulanacak
            property real currentScale: 2.5
            scale: Qt.vector3d(currentScale, currentScale, currentScale)

            Excavator {
                id: excavatorModel
            }
        }

        // Sabit Zemin Düğümü - Excavator dönerken sabit kalır
        Node {
            id: groundNode
            position: Qt.vector3d(0, 0, 0)

            // Düz zemin platformu
            Model {
                source: "#Rectangle"
                position: Qt.vector3d(0, -5, 0)
                eulerRotation.x: -90
                scale: Qt.vector3d(20, 20, 1)

                materials: PrincipledMaterial {
                    baseColorMap: Texture {
                        source: "../resources/textures/toprak.png"
                        scaleU: 5
                        scaleV: 5
                    }
                    roughness: 0.8
                    metalness: 0.2
                }
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

    // GPS ve Pozisyon Bilgisi - Sol Alt Köşe
    Rectangle {
        anchors.left: parent.left
        anchors.bottom: controlPanel.top
        anchors.leftMargin: 20
        anchors.bottomMargin: 10
        width: 240
        height: gpsColumn.height + 30
        color: "#1a1a1a"
        opacity: 0.95
        radius: 10
        border.color: "#505050"
        border.width: 2

        Column {
            id: gpsColumn
            anchors.centerIn: parent
            spacing: 8

            // GPS Başlık
            Rectangle {
                width: 200
                height: 1
                color: "#505050"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "GPS: 40.1213, 29.1412"
                font.pixelSize: 14
                font.bold: true
                color: "#00bcd4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Derinlik: 33m"
                font.pixelSize: 13
                color: "#ffc107"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "Bağlantı: OK"
                font.pixelSize: 12
                color: "#4CAF50"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: 200
                height: 1
                color: "#505050"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // Kontroller - Alt Menü (Yatay Layout)
    Rectangle {
        id: controlPanel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        height: 100
        color: "#1e1e1e"
        opacity: 0.98
        radius: 10
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
            spacing: 8

            // Otomatik Dönme Bölümü
            Column {
                spacing: 5

                Text {
                    text: "OTO"
                    color: "#00bcd4"
                    font.pixelSize: 9
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    id: autoRotateButton
                    text: autoRotateCheckbox.checked ? "⏸" : "▶"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 45
                    height: 45

                    background: Rectangle {
                        color: autoRotateCheckbox.checked ? "#4CAF50" : "#424242"
                        radius: 6
                        border.color: autoRotateCheckbox.checked ? "#66BB6A" : "#616161"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: autoRotateButton.text
                        color: "#ffffff"
                        font.pixelSize: 18
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
                width: 1
                height: 90
                color: "#505050"
            }

            // Açı Bölümü
            Column {
                spacing: 5

                Text {
                    text: "AÇI"
                    color: "#ffc107"
                    font.pixelSize: 9
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "◄"
                        width: 35
                        height: 35
                        enabled: !autoRotateCheckbox.checked
                        font.pixelSize: 16
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
                        width: 70
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
                        width: 35
                        height: 35
                        enabled: !autoRotateCheckbox.checked
                        font.pixelSize: 16
                        onClicked: {
                            excavatorContainer.eulerRotation.y += 15
                            rotationSlider.value = excavatorContainer.eulerRotation.y % 360
                        }
                    }
                }

                Text {
                    text: Math.round(rotationSlider.value) + "°"
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 10
                }
            }

            // Ayırıcı
            Rectangle {
                width: 1
                height: 90
                color: "#505050"
            }

            // Zoom Bölümü
            Column {
                spacing: 5

                Text {
                    text: "ZOOM"
                    color: "#9c27b0"
                    font.pixelSize: 9
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    spacing: 3
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        text: "−"
                        width: 35
                        height: 35
                        font.pixelSize: 18
                        onClicked: {
                            zoomSlider.value = Math.min(500, zoomSlider.value + 20)  // Uzaklaştır
                        }
                    }

                    Slider {
                        id: zoomSlider
                        from: 100
                        to: 500
                        value: 200
                        width: 70
                        anchors.verticalCenter: parent.verticalCenter

                        onValueChanged: {
                            camera.position.z = value
                            camera.position.y = value * 0.4  // Y pozisyonunu da orantılı olarak ayarla
                        }
                    }

                    Button {
                        text: "+"
                        width: 35
                        height: 35
                        font.pixelSize: 18
                        onClicked: {
                            zoomSlider.value = Math.max(100, zoomSlider.value - 20)  // Yakınlaştır
                        }
                    }
                }

                Text {
                    text: Math.round(zoomSlider.value)
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 10
                }
            }

            // Ayırıcı
            Rectangle {
                width: 1
                height: 90
                color: "#505050"
            }

            // Ölçek Bölümü
            Column {
                spacing: 5

                Text {
                    text: "ÖLÇEK"
                    color: "#ff5722"
                    font.pixelSize: 9
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Slider {
                    id: scaleSlider
                    from: 0.5
                    to: 3.0
                    value: 2.5
                    stepSize: 0.1
                    width: 90
                    anchors.horizontalCenter: parent.horizontalCenter

                    onValueChanged: {
                        excavatorContainer.currentScale = value
                    }
                }

                Text {
                    text: scaleSlider.value.toFixed(1) + "x"
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 10
                }
            }

            // Ayırıcı
            Rectangle {
                width: 1
                height: 90
                color: "#505050"
            }

            // Sıfırla Bölümü
            Column {
                spacing: 5

                Text {
                    text: "RESET"
                    color: "#f44336"
                    font.pixelSize: 9
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    text: "⟲"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 45
                    height: 45

                    background: Rectangle {
                        color: "#e53935"
                        radius: 6
                        border.color: "#ef5350"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        autoRotateCheckbox.checked = false
                        rotationSlider.value = 0
                        zoomSlider.value = 200
                        scaleSlider.value = 2.5
                        excavatorContainer.eulerRotation.y = 0
                        camera.position = Qt.vector3d(0, 80, 200)
                        camera.eulerRotation.x = -15
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
