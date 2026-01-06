import QtQuick
import QtQuick.Controls

Rectangle {
    id: mapViewRoot
    color: "#2a2a2a"

    // Harita placeholder - OpenStreetMap benzeri görünüm
    Rectangle {
        id: mapContainer
        anchors.fill: parent
        anchors.topMargin: 60
        anchors.margins: 20
        color: "#E5E5E5"
        clip: true

        // Grid pattern - harita benzeri görünüm
        Canvas {
            id: gridCanvas
            anchors.fill: parent
            property real offsetX: 0
            property real offsetY: 0
            property real zoom: 1.0

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                // Su rengi (okyanus)
                ctx.fillStyle = "#A8DADC"
                ctx.fillRect(0, 0, width, height)
                
                // Kara parçaları (basit şekiller)
                ctx.fillStyle = "#F1FAEE"
                ctx.strokeStyle = "#457B9D"
                ctx.lineWidth = 2
                
                // İstanbul'u temsil eden basit şekiller
                ctx.beginPath()
                ctx.moveTo(width * 0.3 + offsetX, height * 0.4 + offsetY)
                ctx.lineTo(width * 0.5 + offsetX, height * 0.35 + offsetY)
                ctx.lineTo(width * 0.7 + offsetX, height * 0.45 + offsetY)
                ctx.lineTo(width * 0.6 + offsetX, height * 0.6 + offsetY)
                ctx.lineTo(width * 0.4 + offsetX, height * 0.55 + offsetY)
                ctx.closePath()
                ctx.fill()
                ctx.stroke()
                
                // Yollar
                ctx.strokeStyle = "#E63946"
                ctx.lineWidth = 3
                ctx.beginPath()
                ctx.moveTo(width * 0.4 + offsetX, height * 0.45 + offsetY)
                ctx.lineTo(width * 0.6 + offsetX, height * 0.5 + offsetY)
                ctx.stroke()
                
                ctx.beginPath()
                ctx.moveTo(width * 0.5 + offsetX, height * 0.4 + offsetY)
                ctx.lineTo(width * 0.5 + offsetX, height * 0.55 + offsetY)
                ctx.stroke()
                
                // Grid çizgileri
                ctx.strokeStyle = "#1D3557"
                ctx.lineWidth = 0.5
                var gridSize = 50
                for (var x = 0; x < width; x += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                    ctx.stroke()
                }
                for (var y = 0; y < height; y += gridSize) {
                    ctx.beginPath()
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                    ctx.stroke()
                }
            }
        }

        // Excavator marker
        Rectangle {
            id: excavatorMarker
            width: 40
            height: 40
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            radius: 20
            color: "#2196F3"
            border.color: "#ffffff"
            border.width: 3
            
            Rectangle {
                anchors.centerIn: parent
                width: 12
                height: 12
                radius: 6
                color: "#ffffff"
            }
            
            // Animasyonlu pulse efekti
            SequentialAnimation on scale {
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    from: 1.0
                    to: 1.3
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    from: 1.3
                    to: 1.0
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Konum etiketleri
        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            spacing: 5

            Text {
                text: "📍 İstanbul, Türkiye"
                font.pixelSize: 14
                font.bold: true
                color: "#2d3748"
            }
            Text {
                text: "Lat: 41.0082"
                font.pixelSize: 11
                color: "#333333"
            }
            Text {
                text: "Lon: 28.9784"
                font.pixelSize: 11
                color: "#333333"
            }
        }

        // Mouse ile kaydırma
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
                    
                    gridCanvas.offsetX += deltaX * 0.5
                    gridCanvas.offsetY += deltaY * 0.5
                    gridCanvas.requestPaint()
                    
                    lastX = mouse.x
                    lastY = mouse.y
                }
            }

            onWheel: (wheel) => {
                var delta = wheel.angleDelta.y / 120
                gridCanvas.zoom += delta * 0.1
                gridCanvas.zoom = Math.max(0.5, Math.min(2.0, gridCanvas.zoom))
                gridCanvas.requestPaint()
            }
        }
    }

    // Harita kontrolleri
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: mapControlsColumn.width + 40
        height: mapControlsColumn.height + 40
        color: "#2d3748"
        opacity: 0.9
        radius: 10
        border.color: "#404040"
        border.width: 1

        Column {
            id: mapControlsColumn
            anchors.centerIn: parent
            spacing: 15

            // Zoom kontrolleri
            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "−"
                    font.pixelSize: 24
                    font.bold: true
                    width: 50
                    height: 50
                    onClicked: {
                        gridCanvas.zoom -= 0.2
                        gridCanvas.zoom = Math.max(0.5, gridCanvas.zoom)
                        gridCanvas.requestPaint()
                    }
                }

                Text {
                    text: "Zoom: " + gridCanvas.zoom.toFixed(1) + "x"
                    color: "#ffffff"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 120
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    text: "+"
                    font.pixelSize: 24
                    font.bold: true
                    width: 50
                    height: 50
                    onClicked: {
                        gridCanvas.zoom += 0.2
                        gridCanvas.zoom = Math.min(2.0, gridCanvas.zoom)
                        gridCanvas.requestPaint()
                    }
                }
            }

            // Sıfırlama butonu
            Button {
                text: "Merkeze Dön"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    gridCanvas.offsetX = 0
                    gridCanvas.offsetY = 0
                    gridCanvas.zoom = 1.0
                    gridCanvas.requestPaint()
                }
            }
        }
    }

    // Bilgi kutusu
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 70
        anchors.rightMargin: 30
        width: infoText.width + 20
        height: infoText.height + 20
        color: "#2d3748"
        opacity: 0.9
        radius: 5
        border.color: "#404040"
        border.width: 1

        Text {
            id: infoText
            anchors.centerIn: parent
            text: "📱 Harita Simülasyonu\n🖱️ Sürükle: Kaydır\n🖱️ Tekerlek: Zoom"
            color: "#ffffff"
            font.pixelSize: 11
            lineHeight: 1.3
        }
    }
}
