import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

/**
 * AreaPage - Kazı Alanı Sayfası
 *
 * ArcGIS tarzı profesyonel batimetrik harita görselleştirmesi
 * - Interpolasyonlu derinlik haritası
 * - Kontur çizgileri
 * - Profesyonel lejant
 * - Kuzey oku ve ölçek çubuğu
 */
Rectangle {
    id: areaPage
    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

    color: themeManager ? themeManager.backgroundColor : "#2d3748"
    // Global responsive değişkenlere erişim

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // ConfigManager'dan gelen veriler
    property int gridRows: configManager ? configManager.gridRows : 5
    property int gridCols: configManager ? configManager.gridCols : 5
    property var gridDepths: configManager ? configManager.gridDepths : []

    // Hesaplanan değerler (cache'lenmiş - performans için)
    property real minDepth: 0
    property real maxDepth: 30

    // Değerleri güncelle (debounce ile)
    Timer {
        id: depthCalcTimer
        interval: 200
        onTriggered: {
            areaPage.minDepth = calculateMinDepth()
            areaPage.maxDepth = calculateMaxDepth()
        }
    }

    onGridDepthsChanged: depthCalcTimer.restart()

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#38b2ac"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#333333"

    // Harita ayarları
    property bool showContours: true
    property int contourInterval: 5
    property bool showGrid: false
    property bool show3DView: false

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    function calculateMinDepth() {
        if (!gridDepths || gridDepths.length === 0) return 0
        var min = Infinity
        for (var i = 0; i < gridDepths.length; i++) {
            var d = gridDepths[i]
            if (d !== null && d !== undefined && !isNaN(d) && d > 0 && d < min) {
                min = d
            }
        }
        return isFinite(min) ? min : 0
    }

    function calculateMaxDepth() {
        if (!gridDepths || gridDepths.length === 0) return 30
        var max = 0
        for (var i = 0; i < gridDepths.length; i++) {
            var d = gridDepths[i]
            if (d !== null && d !== undefined && !isNaN(d) && d > max) {
                max = d
            }
        }
        return max > 0 ? max : 30
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Başlık
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: areaPage.primaryColor
    // Global responsive değişkenlere erişim

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Text {
                    text: tr("Dig Area")
                    font.pixelSize: app.largeFontSize
                    font.bold: true
                    color: "white"
                }

                Item { Layout.fillWidth: true }

                // Görünüm seçenekleri
                Row {
                    spacing: 8

                    // Kontur toggle
                    Rectangle {
                        width: contourToggleRow.width + 16
                        height: 32
                        radius: 16
                        color: showContours ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)
    // Global responsive değişkenlere erişim

                        Row {
                            id: contourToggleRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "~"
                                font.pixelSize: app.baseFontSize
                                font.bold: true
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: tr("Contours")
                                font.pixelSize: app.smallFontSize
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showContours = !showContours
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    // Grid toggle
                    Rectangle {
                        width: gridToggleRow.width + 16
                        height: 32
                        radius: 16
                        color: showGrid ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.1)
    // Global responsive değişkenlere erişim

                        Row {
                            id: gridToggleRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "#"
                                font.pixelSize: app.baseFontSize
                                font.bold: true
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: tr("Grid")
                                font.pixelSize: app.smallFontSize
                                color: "white"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: showGrid = !showGrid
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                Item { width: 16 }

                // Grid bilgisi
                Rectangle {
                    width: gridInfoText.width + 20
                    height: 32
                    radius: 16
                    color: Qt.rgba(1, 1, 1, 0.2)
    // Global responsive değişkenlere erişim

                    Text {
                        id: gridInfoText
                        anchors.centerIn: parent
                        text: gridRows + " x " + gridCols + " " + tr("Grid")
                        font.pixelSize: app.smallFontSize
                        font.bold: true
                        color: "white"
                    }
                }
            }
        }

        // Ana içerik
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 16

            // Harita çerçevesi
            Rectangle {
                id: mapFrame
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: rightPanel.left
                anchors.rightMargin: 16
                color: areaPage.surfaceColor
    // Global responsive değişkenlere erişim
                radius: 12
                border.width: 2
                border.color: "#1A75A8"

                // Harita başlığı
                Rectangle {
                    id: mapTitle
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40
                    color: "#1A75A8"
    // Global responsive değişkenlere erişim
                    radius: 10

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.radius
                        color: parent.color
    // Global responsive değişkenlere erişim
                    }

                    Text {
                        anchors.centerIn: parent
                        text: tr("Bathymetric Map") + " - " + tr("Dig Area")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: "white"
                    }
                }

                // Batimetrik harita canvas'ı
                BathymetricMapCanvas {
                    id: bathymetricMap
                    anchors.top: mapTitle.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: mapFooter.top
                    anchors.margins: 8

                    gridRows: areaPage.gridRows
                    gridCols: areaPage.gridCols
                    gridDepths: areaPage.gridDepths
                    minDepth: areaPage.minDepth
                    maxDepth: areaPage.maxDepth

                    // Koordinatlar
                    startLatitude: configManager ? configManager.gridStartLatitude : 40.71
                    startLongitude: configManager ? configManager.gridStartLongitude : 29.00
                    endLatitude: configManager ? configManager.gridEndLatitude : 40.72
                    endLongitude: configManager ? configManager.gridEndLongitude : 29.01

                    showContours: areaPage.showContours
                    contourInterval: areaPage.contourInterval
                    showGrid: areaPage.showGrid
                    showCoordinates: true
                    smoothTransitions: true

                    // Tema renkleri
                    containerColor: Qt.lighter(areaPage.surfaceColor, 1.02)
                    labelColor: areaPage.textSecondaryColor
                }

                // Ekskavatör konumu göstergesi
                Rectangle {
                    anchors.top: mapTitle.bottom
                    anchors.left: parent.left
                    anchors.topMargin: 16
                    anchors.leftMargin: 36
                    width: excavatorPosRow.width + 16
                    height: 32
                    radius: 16
                    color: "#FF6B35"
    // Global responsive değişkenlere erişim

                    Row {
                        id: excavatorPosRow
                        anchors.centerIn: parent
                        spacing: 6

                        Image {
                            width: 18
                            height: 18
                            source: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_excavator.png"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "C3"
                            font.pixelSize: app.smallFontSize
                            font.bold: true
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Alt bilgi çubuğu
                Rectangle {
                    id: mapFooter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 30
                    color: Qt.lighter(areaPage.surfaceColor, 1.02)
    // Global responsive değişkenlere erişim
                    radius: 10

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.radius
                        color: parent.color
    // Global responsive değişkenlere erişim
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Text {
                            text: "Datum: WGS84"
                            font.pixelSize: app.smallFontSize * 0.8
                            color: areaPage.textSecondaryColor
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: bathymetricMap.isHovering ?
                                  "X: " + bathymetricMap.hoverX.toFixed(0) + " Y: " + bathymetricMap.hoverY.toFixed(0) +
                                  " | " + tr("Depth") + ": " + bathymetricMap.hoverDepth.toFixed(2) + "m" :
                                  tr("Hover for depth info")
                            font.pixelSize: app.smallFontSize * 0.8
                            color: areaPage.textColor
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "© 2024 ExcavatorUI"
                            font.pixelSize: app.smallFontSize * 0.8
                            color: areaPage.textSecondaryColor
                        }
                    }
                }
            }

            // Sağ panel
            Rectangle {
                id: rightPanel
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 220
                color: areaPage.surfaceColor
    // Global responsive değişkenlere erişim
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Lejant
                    BathymetricLegend {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 220
                        title: tr("Depth") + " (m)"
                        minDepth: areaPage.minDepth
                        maxDepth: Math.max(areaPage.maxDepth, 10)
                        textColor: areaPage.textColor
                        backgroundColor: Qt.lighter(areaPage.surfaceColor, 1.05)
                    }

                    // Ayırıcı
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: areaPage.borderColor
    // Global responsive değişkenlere erişim
                    }

                    // İstatistikler
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: statsColumn.height + 24
                        color: Qt.lighter(areaPage.surfaceColor, 1.05)
    // Global responsive değişkenlere erişim
                        radius: 8
                        border.width: 1
                        border.color: areaPage.borderColor

                        Column {
                            id: statsColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 10

                            Text {
                                text: tr("Statistics")
                                font.pixelSize: 13
                                font.bold: true
                                color: areaPage.textColor
                            }

                            // Grid boyutu
                            Row {
                                width: parent.width
                                Text {
                                    width: parent.width * 0.6
                                    text: tr("Grid Size") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                }
                                Text {
                                    text: gridRows + " x " + gridCols
                                    font.pixelSize: app.smallFontSize
                                    font.bold: true
                                    color: areaPage.textColor
                                }
                            }

                            // Toplam hücre
                            Row {
                                width: parent.width
                                Text {
                                    width: parent.width * 0.6
                                    text: tr("Total Cells") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                }
                                Text {
                                    text: (gridRows * gridCols).toString()
                                    font.pixelSize: app.smallFontSize
                                    font.bold: true
                                    color: areaPage.textColor
                                }
                            }

                            // Tanımlı hücre
                            Row {
                                width: parent.width
                                Text {
                                    width: parent.width * 0.6
                                    text: tr("Defined") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                }
                                Text {
                                    property int definedCount: {
                                        if (!gridDepths) return 0
                                        var count = 0
                                        for (var i = 0; i < gridDepths.length; i++) {
                                            if (gridDepths[i] > 0) count++
                                        }
                                        return count
                                    }
                                    text: definedCount.toString()
                                    font.pixelSize: app.smallFontSize
                                    font.bold: true
                                    color: "#38A169"
                                }
                            }

                            // Min derinlik
                            Row {
                                width: parent.width
                                Text {
                                    width: parent.width * 0.6
                                    text: tr("Min Depth") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                }
                                Text {
                                    text: minDepth > 0 ? minDepth.toFixed(2) + " m" : "-"
                                    font.pixelSize: app.smallFontSize
                                    font.bold: true
                                    color: "#55B0D4"
                                }
                            }

                            // Max derinlik
                            Row {
                                width: parent.width
                                Text {
                                    width: parent.width * 0.6
                                    text: tr("Max Depth") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                }
                                Text {
                                    text: maxDepth > 0 ? maxDepth.toFixed(2) + " m" : "-"
                                    font.pixelSize: app.smallFontSize
                                    font.bold: true
                                    color: "#2B6CB0"
                                }
                            }

                            // Ortalama derinlik
                            Row {
                                width: parent.width
                                Text {
                                    width: parent.width * 0.6
                                    text: tr("Average") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                }
                                Text {
                                    property real avgDepth: {
                                        if (!gridDepths || gridDepths.length === 0) return 0
                                        var sum = 0
                                        var count = 0
                                        for (var i = 0; i < gridDepths.length; i++) {
                                            if (gridDepths[i] > 0) {
                                                sum += gridDepths[i]
                                                count++
                                            }
                                        }
                                        return count > 0 ? sum / count : 0
                                    }
                                    text: avgDepth > 0 ? avgDepth.toFixed(2) + " m" : "-"
                                    font.pixelSize: app.smallFontSize
                                    font.bold: true
                                    color: "#1A75A8"
                                }
                            }
                        }
                    }

                    // Kontur aralığı ayarı
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contourSettingsCol.height + 24
                        color: Qt.lighter(areaPage.surfaceColor, 1.05)
    // Global responsive değişkenlere erişim
                        radius: 8
                        border.width: 1
                        border.color: areaPage.borderColor
                        visible: showContours

                        Column {
                            id: contourSettingsCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: tr("Contour Settings")
                                font.pixelSize: 13
                                font.bold: true
                                color: areaPage.textColor
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Text {
                                    text: tr("Interval") + ":"
                                    font.pixelSize: app.smallFontSize
                                    color: areaPage.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                ComboBox {
                                    id: contourIntervalCombo
                                    width: 80
                                    height: 28
                                    model: ["1m", "2m", "5m", "10m"]
                                    currentIndex: {
                                        switch(contourInterval) {
                                            case 1: return 0
                                            case 2: return 1
                                            case 5: return 2
                                            case 10: return 3
                                            default: return 2
                                        }
                                    }

                                    onCurrentIndexChanged: {
                                        var values = [1, 2, 5, 10]
                                        contourInterval = values[currentIndex]
                                    }

                                    background: Rectangle {
                                        color: areaPage.surfaceColor
    // Global responsive değişkenlere erişim
                                        radius: 4
                                        border.width: 1
                                        border.color: areaPage.borderColor
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Yapılandırma durumu
                    Rectangle {
                        Layout.fillWidth: true
                        height: 50
                        radius: 8
                        color: configManager && configManager.digAreaConfigured
    // Global responsive değişkenlere erişim
                            ? Qt.rgba(0.22, 0.65, 0.41, 0.15)
                            : Qt.rgba(1, 0.6, 0, 0.15)
                        border.width: 1
                        border.color: configManager && configManager.digAreaConfigured
                            ? "#38A169" : "#DD6B20"

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: configManager && configManager.digAreaConfigured ? "✓" : "!"
                                font.pixelSize: app.mediumFontSize
                                font.bold: true
                                color: configManager && configManager.digAreaConfigured ? "#38A169" : "#DD6B20"
                            }

                            Text {
                                text: configManager && configManager.digAreaConfigured
                                    ? tr("Configured")
                                    : tr("Not Configured")
                                font.pixelSize: app.smallFontSize
                                font.bold: true
                                color: configManager && configManager.digAreaConfigured ? "#38A169" : "#DD6B20"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
