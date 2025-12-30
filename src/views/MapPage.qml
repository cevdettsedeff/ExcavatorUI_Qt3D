import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Harita Sayfası - Mockup'a göre (Sol araç çubuğu + harita)
Rectangle {
    id: mapPage
    color: "#1a1a1a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // Konum verileri
    property real posX: 124.32
    property real posY: 842.11
    property real posZ: -2.45
    property real currentDepth: 5.5

    // Harita durumu
    property real mapZoom: 1.0
    property real mapCenterX: 0.5
    property real mapCenterY: 0.5

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Ana içerik
    Row {
        anchors.fill: parent
        spacing: 0

        // Sol Araç Çubuğu
        Rectangle {
            id: leftToolbar
            width: 70
            height: parent.height
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.topMargin: 10
                spacing: 5

                // Hedef butonu
                ToolbarButton {
                    icon: "◎"
                    label: "Hedef"
                    onClicked: console.log("Hedef clicked")
                }

                // Şantiye butonu
                ToolbarButton {
                    icon: "🏗️"
                    label: "Şantiye"
                    onClicked: console.log("Şantiye clicked")
                }

                // Katmanlar butonu
                ToolbarButton {
                    icon: "☰"
                    label: "Katmanlar"
                    onClicked: console.log("Katmanlar clicked")
                }

                // Mod butonu
                ToolbarButton {
                    icon: "🎲"
                    label: "Mod"
                    onClicked: console.log("Mod clicked")
                }

                // Ayırıcı
                Rectangle {
                    width: 50
                    height: 1
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Zoom In
                ToolbarButton {
                    icon: "+"
                    label: ""
                    onClicked: {
                        mapPage.mapZoom = Math.min(3.0, mapPage.mapZoom + 0.2)
                    }
                }

                // Zoom Out
                ToolbarButton {
                    icon: "−"
                    label: ""
                    onClicked: {
                        mapPage.mapZoom = Math.max(0.5, mapPage.mapZoom - 0.2)
                    }
                }

                // Zoom reset
                ToolbarButton {
                    icon: "🔍"
                    label: "Zoom"
                    onClicked: {
                        mapPage.mapZoom = 1.0
                    }
                }

                Item { height: 20; width: 1 }

                // Ayırıcı
                Rectangle {
                    width: 50
                    height: 1
                    color: "#333333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // 3D görünüm
                ToolbarButton {
                    icon: "▲"
                    label: ""
                    onClicked: console.log("3D view clicked")
                }

                // Reset
                ToolbarButton {
                    icon: "⟲"
                    label: ""
                    onClicked: {
                        mapPage.mapZoom = 1.0
                        mapPage.mapCenterX = 0.5
                        mapPage.mapCenterY = 0.5
                    }
                }
            }
        }

        // Harita Alanı
        Rectangle {
            width: parent.width - leftToolbar.width
            height: parent.height
            color: "#0a2040"

            // Harita içeriği
            Item {
                id: mapContent
                anchors.fill: parent

                // Arka plan - deniz/su
                Rectangle {
                    anchors.fill: parent
                    color: "#0a3050"

                    // Basit dalga efekti
                    Rectangle {
                        anchors.fill: parent
                        opacity: 0.3

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#0a4060" }
                            GradientStop { position: 0.5; color: "#0a3050" }
                            GradientStop { position: 1.0; color: "#0a4060" }
                        }
                    }
                }

                // Grid çizgileri
                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.strokeStyle = "#ffffff20"
                        ctx.lineWidth = 1

                        // Dikey çizgiler
                        var gridSpacing = 80 * mapPage.mapZoom
                        for (var x = 0; x < width; x += gridSpacing) {
                            ctx.beginPath()
                            ctx.moveTo(x, 0)
                            ctx.lineTo(x, height)
                            ctx.stroke()
                        }

                        // Yatay çizgiler
                        for (var y = 0; y < height; y += gridSpacing) {
                            ctx.beginPath()
                            ctx.moveTo(0, y)
                            ctx.lineTo(width, y)
                            ctx.stroke()
                        }
                    }
                }

                // Çalışma alanı (kesik çizgi ile gösterilen kare)
                Rectangle {
                    anchors.centerIn: parent
                    width: 200 * mapPage.mapZoom
                    height: 200 * mapPage.mapZoom
                    color: "#ff444430"
                    border.color: "#ff4444"
                    border.width: 2
                    radius: 5

                    // Kesik çizgi simülasyonu
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        color: "transparent"
                        border.color: "#ff4444"
                        border.width: 2
                        radius: 5
                        opacity: 0.5
                    }
                }

                // Derinlik haritası (renk gradient overlay)
                Rectangle {
                    anchors.centerIn: parent
                    width: 180 * mapPage.mapZoom
                    height: 180 * mapPage.mapZoom
                    radius: 10
                    opacity: 0.6

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#40ff8040" }
                        GradientStop { position: 0.3; color: "#ffff0040" }
                        GradientStop { position: 0.6; color: "#ff800040" }
                        GradientStop { position: 1.0; color: "#ff000040" }
                    }

                    // İç kısım (daha derin bölge)
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.5
                        height: parent.height * 0.5
                        radius: 8
                        color: "#ff600060"
                    }
                }

                // Ekskavatör ikonu (merkez)
                Rectangle {
                    id: excavatorIcon
                    anchors.centerIn: parent
                    width: 60 * mapPage.mapZoom
                    height: 40 * mapPage.mapZoom
                    color: "#FFB300"
                    radius: 5
                    rotation: -30

                    // Kova kolu
                    Rectangle {
                        anchors.left: parent.right
                        anchors.leftMargin: -5
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40 * mapPage.mapZoom
                        height: 8 * mapPage.mapZoom
                        color: "#FFB300"
                        rotation: -20
                        transformOrigin: Item.Left
                    }

                    // Palet
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.9
                        height: 8 * mapPage.mapZoom
                        color: "#333333"
                        radius: 2
                    }
                }

                // Koordinat etiketleri (kenarlar)
                // Sol kenar
                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 100

                    Repeater {
                        model: ["X840.5", "X840.5", "X844.5", "X841.5", "X840.5", "X845.5", "X124.5"]

                        Text {
                            text: modelData
                            font.pixelSize: 10
                            color: "#888888"
                        }
                    }
                }

                // Alt kenar
                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 60
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 100

                    Repeater {
                        model: ["Y840.5", "Y845.5"]

                        Text {
                            text: modelData
                            font.pixelSize: 10
                            color: "#888888"
                        }
                    }
                }

                // Ölçek göstergesi (sağ üst)
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 15
                    width: 80
                    height: 25
                    color: "#00000080"
                    radius: 3

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        Rectangle {
                            width: 40
                            height: 3
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "10m"
                            font.pixelSize: 11
                            color: "#ffffff"
                        }
                    }
                }

                // Arama butonu (sağ üst)
                Rectangle {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 50
                    anchors.rightMargin: 15
                    width: 40
                    height: 40
                    radius: 20
                    color: "#2a2a2a"
                    border.color: "#505050"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "🔍"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Search clicked")
                    }
                }

                // Derinlik skalası (sağ alt)
                Rectangle {
                    id: depthLegend
                    anchors.right: parent.right
                    anchors.bottom: coordinateBar.top
                    anchors.rightMargin: 15
                    anchors.bottomMargin: 15
                    width: 80
                    height: 180
                    color: "#1a1a1a90"
                    radius: 5
                    border.color: "#333333"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 3

                        Repeater {
                            model: [
                                { depth: "-0.5m", color: "#4CAF50" },
                                { depth: "-1.0m", color: "#8BC34A" },
                                { depth: "-1.5m", color: "#CDDC39" },
                                { depth: "-2.0m", color: "#FFEB3B" },
                                { depth: "-2.5m", color: "#FFC107" },
                                { depth: "-3.0m", color: "#FF9800" },
                                { depth: "-3.5m", color: "#f44336" }
                            ]

                            Row {
                                spacing: 5

                                Rectangle {
                                    width: 20
                                    height: 18
                                    color: modelData.color
                                    radius: 2
                                }

                                Text {
                                    text: modelData.depth
                                    font.pixelSize: 11
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }

                // Koordinat çubuğu (alt)
                Rectangle {
                    id: coordinateBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 40
                    color: "#1a1a1a"
                    border.color: "#333333"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Row {
                            spacing: 5

                            Text {
                                text: "X:"
                                font.pixelSize: 13
                                color: "#888888"
                            }

                            Text {
                                text: mapPage.posX.toFixed(2)
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                        }

                        Row {
                            spacing: 5

                            Text {
                                text: "Y:"
                                font.pixelSize: 13
                                color: "#888888"
                            }

                            Text {
                                text: mapPage.posY.toFixed(2)
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                        }

                        Row {
                            spacing: 5

                            Text {
                                text: "Z:"
                                font.pixelSize: 13
                                color: "#888888"
                            }

                            Text {
                                text: mapPage.posZ.toFixed(2)
                                font.pixelSize: 13
                                font.bold: true
                                color: "#00bcd4"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Row {
                            spacing: 5

                            Text {
                                text: "▲"
                                font.pixelSize: 12
                                color: "#888888"
                            }

                            Text {
                                text: mapPage.currentDepth.toFixed(1) + "m"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                        }

                        // Tam ekran butonu
                        Rectangle {
                            width: 30
                            height: 30
                            radius: 5
                            color: "#2a2a2a"

                            Text {
                                anchors.centerIn: parent
                                text: "⊕"
                                font.pixelSize: 16
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: console.log("Fullscreen clicked")
                            }
                        }
                    }
                }

                // Mouse drag ile harita kaydırma
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
                            var deltaX = (mouse.x - lastX) / width
                            var deltaY = (mouse.y - lastY) / height
                            mapPage.mapCenterX = Math.max(0, Math.min(1, mapPage.mapCenterX - deltaX * 0.5))
                            mapPage.mapCenterY = Math.max(0, Math.min(1, mapPage.mapCenterY - deltaY * 0.5))
                            lastX = mouse.x
                            lastY = mouse.y
                        }
                    }

                    onWheel: (wheel) => {
                        var delta = wheel.angleDelta.y / 120
                        mapPage.mapZoom = Math.max(0.5, Math.min(3.0, mapPage.mapZoom + delta * 0.1))
                    }
                }
            }
        }
    }

    // Araç çubuğu buton komponenti
    component ToolbarButton: Rectangle {
        property string icon: ""
        property string label: ""
        signal clicked()

        width: 60
        height: label !== "" ? 55 : 40
        color: mouseArea.containsMouse ? "#2a2a2a" : "transparent"
        radius: 5
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            anchors.centerIn: parent
            spacing: 3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: icon
                font.pixelSize: label !== "" ? 20 : 24
                color: "#ffffff"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                font.pixelSize: 9
                color: "#888888"
                visible: label !== ""
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }
}
