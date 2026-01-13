import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

/**
 * DigAreaConfigPage - Kazı Alanı Ayarları Sayfası
 *
 * Wizard-style adım adım ilerleyen tasarım:
 * 1. Köşe sayısı seçimi
 * 2. Köşe koordinatları girişi
 * 3. Polygon önizlemesi
 * 4. Batimetrik veri girişi
 * 5. Harita görünümleri (çizgili ve gridli)
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#1a1a2e"

    signal back()
    signal configSaved()

    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

    // Translation support
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    // Theme colors (dark theme optimized)
    property color primaryColor: (themeManager && themeManager.primaryColor) ? themeManager.primaryColor : "#319795"
    property color surfaceColor: (themeManager && themeManager.surfaceColor) ? themeManager.surfaceColor : "#ffffff"
    property color textColor: "white"
    property color textSecondaryColor: Qt.rgba(1, 1, 1, 0.7)
    property color borderColor: Qt.rgba(1, 1, 1, 0.3)
    property color inputTextColor: "white"  // Changed to white for dark theme
    property color inputBgColor: Qt.rgba(1, 1, 1, 0.1)  // Dark input background
    property color inputBorderColor: Qt.rgba(1, 1, 1, 0.3)
    property color filledBorderColor: "#319795"  // Teal border when filled
    property color cardColor: Qt.rgba(1, 1, 1, 0.08)
    property color canvasBgColor: Qt.rgba(0, 0, 0, 0.3)  // Dark canvas background

    // ==================== WIZARD STATE ====================
    property int currentStep: 0  // 0-4 arası
    property int totalSteps: 5

    // Step titles
    property var stepTitles: [
        root.tr("Köşe Sayısı"),
        root.tr("Koordinatlar"),
        root.tr("Önizleme"),
        root.tr("Batimetri"),
        root.tr("Harita")
    ]

    // ==================== POLYGON DATA ====================
    property int cornerCount: 4
    property var cornerPoints: []  // [{x: 454704.32, y: 4508264.38, label: "T1"}, ...]

    // ==================== BATHYMETRIC DATA ====================
    property var bathymetricPoints: []  // [{x: 454700, y: 4508260, depth: -9.5}, ...]

    // ==================== MAP VIEW MODE ====================
    property int mapViewMode: 0  // 0: Contour lines, 1: Grid
    property real mapZoom: 1.0  // Zoom level for map

    // Initialize corner points when count changes
    onCornerCountChanged: {
        initializeCornerPoints()
    }

    function initializeCornerPoints() {
        var newPoints = []
        for (var i = 0; i < cornerCount; i++) {
            if (i < cornerPoints.length) {
                newPoints.push(cornerPoints[i])
            } else {
                newPoints.push({
                    x: 454700 + (i * 50),
                    y: 4508200 + (i * 50),
                    label: "T" + (i + 1)
                })
            }
        }
        cornerPoints = newPoints
    }

    // Generate random polygon coordinates based on corner count
    function generateRandomPolygon() {
        var centerX = 454750
        var centerY = 4508350
        var radius = 150
        var newPoints = []

        for (var i = 0; i < cornerCount; i++) {
            var angle = (2 * Math.PI * i / cornerCount) - Math.PI / 2
            var randomRadius = radius + (Math.random() - 0.5) * 60
            newPoints.push({
                x: centerX + Math.cos(angle) * randomRadius,
                y: centerY + Math.sin(angle) * randomRadius,
                label: "T" + (i + 1)
            })
        }
        cornerPoints = newPoints
    }

    Component.onCompleted: {
        initializeCornerPoints()
    }

    // ==================== HEADER ====================
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: app ? app.buttonHeight * 1.3 : 55
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: app ? app.smallPadding : 12
            anchors.rightMargin: app ? app.smallPadding : 12

            Button {
                Layout.preferredWidth: app ? app.buttonHeight * 0.8 : 35
                Layout.preferredHeight: app ? app.buttonHeight * 0.8 : 35
                flat: true

                contentItem: Text {
                    text: "←"
                    font.pixelSize: 22
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 17
                    color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                }

                onClicked: {
                    if (currentStep > 0) {
                        currentStep--
                    } else {
                        root.back()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.tr("Kazı Alanı Ayarları")
                font.pixelSize: app ? app.mediumFontSize * 0.9 : 18
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: app ? app.buttonHeight * 0.8 : 35 }
        }
    }

    // ==================== PROGRESS INDICATOR ====================
    Rectangle {
        id: progressBar
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
        color: Qt.rgba(0, 0, 0, 0.2)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: totalSteps

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 28
                            height: 28
                            radius: 14
                            color: index < currentStep ? "#38A169" :
                                   index === currentStep ? root.primaryColor :
                                   Qt.rgba(1, 1, 1, 0.2)
                            border.width: index === currentStep ? 2 : 0
                            border.color: "white"

                            Text {
                                anchors.centerIn: parent
                                text: index < currentStep ? "✓" : (index + 1).toString()
                                font.pixelSize: 12
                                font.bold: true
                                color: "white"
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: stepTitles[index]
                            font.pixelSize: app ? app.smallFontSize * 0.7 : 10
                            color: index === currentStep ? "white" : root.textSecondaryColor
                            font.bold: index === currentStep
                        }
                    }

                    // Connector line
                    Rectangle {
                        visible: index < totalSteps - 1
                        anchors.right: parent.right
                        anchors.rightMargin: -2
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -10
                        width: 4
                        height: 2
                        color: index < currentStep ? "#38A169" : Qt.rgba(1, 1, 1, 0.2)
                    }
                }
            }
        }
    }

    // ==================== MAIN CONTENT ====================
    Item {
        id: contentArea
        anchors.top: progressBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.margins: app ? app.smallPadding : 12

        // Step 0: Corner Count Selection
        Loader {
            anchors.fill: parent
            active: currentStep === 0
            sourceComponent: step0CornerCount
        }

        // Step 1: Corner Coordinates Input
        Loader {
            anchors.fill: parent
            active: currentStep === 1
            sourceComponent: step1CornerCoordinates
        }

        // Step 2: Polygon Preview
        Loader {
            anchors.fill: parent
            active: currentStep === 2
            sourceComponent: step2PolygonPreview
        }

        // Step 3: Bathymetric Data Entry
        Loader {
            anchors.fill: parent
            active: currentStep === 3
            sourceComponent: step3BathymetricData
        }

        // Step 4: Map Views
        Loader {
            anchors.fill: parent
            active: currentStep === 4
            sourceComponent: step4MapViews
        }
    }

    // ==================== FOOTER ====================
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: app ? app.buttonHeight * 1.3 : 60
        color: Qt.rgba(0, 0, 0, 0.3)

        RowLayout {
            anchors.fill: parent
            anchors.margins: app ? app.smallPadding : 12
            spacing: 12

            Button {
                Layout.preferredWidth: 120
                Layout.fillHeight: true
                visible: currentStep > 0
                text: root.tr("Geri")

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1
                    border.color: root.borderColor
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: app ? app.baseFontSize : 14
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: currentStep--
            }

            Item { Layout.fillWidth: true }

            Button {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                text: currentStep === totalSteps - 1 ? root.tr("Kaydet ve Bitir") : root.tr("Devam Et")

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                }

                contentItem: Row {
                    spacing: 8
                    anchors.centerIn: parent

                    Text {
                        text: parent.parent.text
                        font.pixelSize: app ? app.baseFontSize : 14
                        font.bold: true
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: currentStep === totalSteps - 1 ? "✓" : "→"
                        font.pixelSize: 16
                        color: "white"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    if (currentStep < totalSteps - 1) {
                        currentStep++
                    } else {
                        // Save and finish
                        saveConfiguration()
                        root.configSaved()
                    }
                }
            }
        }
    }

    // ==================== STEP 0: CORNER COUNT ====================
    Component {
        id: step0CornerCount

        Rectangle {
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: app ? app.normalSpacing : 16

                // Title card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tr("Kazı alanınız kaç köşeli?")
                            font.pixelSize: app ? app.mediumFontSize : 18
                            font.bold: true
                            color: root.textColor
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tr("L şeklinde alanlar için 6, dikdörtgen için 4 seçin")
                            font.pixelSize: app ? app.smallFontSize : 12
                            color: root.textSecondaryColor
                        }
                    }
                }

                // Corner count selector
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    Column {
                        anchors.centerIn: parent
                        spacing: 20

                        // Number display with input
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 20

                            Button {
                                width: 60
                                height: 60
                                enabled: cornerCount > 3

                                background: Rectangle {
                                    radius: 30
                                    color: parent.enabled ?
                                           (parent.pressed ? Qt.darker("#E53E3E", 1.2) : "#E53E3E") :
                                           Qt.rgba(1, 1, 1, 0.1)
                                }

                                contentItem: Text {
                                    text: "−"
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: if (cornerCount > 3) cornerCount--
                            }

                            // Input field for corner count
                            Rectangle {
                                width: 100
                                height: 100
                                radius: 50
                                color: root.primaryColor
                                border.width: 3
                                border.color: "white"

                                TextField {
                                    anchors.centerIn: parent
                                    width: 70
                                    height: 50
                                    text: cornerCount.toString()
                                    font.pixelSize: 36
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    validator: IntValidator { bottom: 3; top: 99 }

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    onEditingFinished: {
                                        var val = parseInt(text)
                                        if (!isNaN(val) && val >= 3 && val <= 99) {
                                            cornerCount = val
                                        } else {
                                            text = cornerCount.toString()
                                        }
                                    }
                                }
                            }

                            Button {
                                width: 60
                                height: 60
                                enabled: cornerCount < 99

                                background: Rectangle {
                                    radius: 30
                                    color: parent.enabled ?
                                           (parent.pressed ? Qt.darker("#38A169", 1.2) : "#38A169") :
                                           Qt.rgba(1, 1, 1, 0.1)
                                }

                                contentItem: Text {
                                    text: "+"
                                    font.pixelSize: 32
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: if (cornerCount < 99) cornerCount++
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tr("Köşe Noktası")
                            font.pixelSize: app ? app.baseFontSize : 14
                            color: root.textSecondaryColor
                        }

                        // Quick select buttons
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10

                            Repeater {
                                model: [3, 4, 5, 6, 8, 10, 12]

                                Button {
                                    width: 45
                                    height: 38

                                    background: Rectangle {
                                        radius: 8
                                        color: cornerCount === modelData ?
                                               root.primaryColor : Qt.rgba(1, 1, 1, 0.1)
                                        border.width: 1
                                        border.color: cornerCount === modelData ?
                                                      root.primaryColor : root.borderColor
                                    }

                                    contentItem: Text {
                                        text: modelData.toString()
                                        font.pixelSize: 13
                                        font.bold: cornerCount === modelData
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: cornerCount = modelData
                                }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tr("veya doğrudan sayı girin")
                            font.pixelSize: app ? app.smallFontSize * 0.9 : 11
                            color: root.textSecondaryColor
                        }
                    }
                }
            }
        }
    }

    // ==================== STEP 1: CORNER COORDINATES ====================
    Component {
        id: step1CornerCoordinates

        Rectangle {
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: app ? app.smallSpacing : 8

                // Header info with test button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: root.cardColor
                    radius: 8
                    border.width: 1
                    border.color: root.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Text {
                            text: root.tr("Kazı Alanı Koordinatları")
                            font.pixelSize: app ? app.baseFontSize : 14
                            font.bold: true
                            color: root.textColor
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 34
                            text: root.tr("Test Verisi")

                            background: Rectangle {
                                radius: 6
                                color: parent.pressed ? Qt.darker("#2589BC", 1.2) : "#2589BC"
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 11
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: generateRandomPolygon()
                        }
                    }
                }

                // Coordinates list
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    // Table header
                    Rectangle {
                        id: tableHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        height: 36
                        color: Qt.rgba(1, 1, 1, 0.1)
                        radius: 6

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Text {
                                width: 50
                                text: root.tr("No")
                                font.pixelSize: app ? app.smallFontSize : 12
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Text {
                                width: (parent.width - 50) / 2
                                text: root.tr("Y Koordinatı")
                                font.pixelSize: app ? app.smallFontSize : 12
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignCenter
                            }

                            Text {
                                width: (parent.width - 50) / 2
                                text: root.tr("X Koordinatı")
                                font.pixelSize: app ? app.smallFontSize : 12
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignCenter
                            }
                        }
                    }

                    // Scrollable coordinate inputs
                    ScrollView {
                        anchors.top: tableHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 8
                        anchors.topMargin: 4
                        clip: true

                        Column {
                            width: parent.width
                            spacing: 6

                            Repeater {
                                model: cornerCount

                                Rectangle {
                                    width: parent.width
                                    height: 50
                                    color: index % 2 === 0 ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                                    radius: 6

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8

                                        // Label
                                        Rectangle {
                                            width: 50
                                            height: parent.height
                                            color: "transparent"

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 36
                                                height: 28
                                                radius: 6
                                                color: root.primaryColor

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "T" + (index + 1)
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    color: "white"
                                                }
                                            }
                                        }

                                        // Y coordinate input
                                        Item {
                                            width: (parent.width - 50) / 2
                                            height: parent.height

                                            TextField {
                                                id: yInput
                                                anchors.centerIn: parent
                                                width: parent.width - 12
                                                height: 38
                                                text: cornerPoints[index] ? cornerPoints[index].x.toFixed(2) : ""
                                                font.pixelSize: app ? app.smallFontSize : 12
                                                color: root.inputTextColor
                                                horizontalAlignment: Text.AlignRight
                                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                                property bool hasValue: text.length > 0 && parseFloat(text) !== 0

                                                background: Rectangle {
                                                    color: root.inputBgColor
                                                    radius: 6
                                                    border.width: yInput.activeFocus ? 2 : (yInput.hasValue ? 1.5 : 1)
                                                    border.color: yInput.activeFocus ? root.primaryColor :
                                                                  (yInput.hasValue ? root.filledBorderColor : root.inputBorderColor)
                                                }

                                                onEditingFinished: {
                                                    var val = parseFloat(text.replace(",", "."))
                                                    if (!isNaN(val) && cornerPoints[index]) {
                                                        var pts = cornerPoints
                                                        pts[index].x = val
                                                        cornerPoints = pts
                                                    }
                                                }
                                            }
                                        }

                                        // X coordinate input
                                        Item {
                                            width: (parent.width - 50) / 2
                                            height: parent.height

                                            TextField {
                                                id: xInput
                                                anchors.centerIn: parent
                                                width: parent.width - 12
                                                height: 38
                                                text: cornerPoints[index] ? cornerPoints[index].y.toFixed(2) : ""
                                                font.pixelSize: app ? app.smallFontSize : 12
                                                color: root.inputTextColor
                                                horizontalAlignment: Text.AlignRight
                                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                                property bool hasValue: text.length > 0 && parseFloat(text) !== 0

                                                background: Rectangle {
                                                    color: root.inputBgColor
                                                    radius: 6
                                                    border.width: xInput.activeFocus ? 2 : (xInput.hasValue ? 1.5 : 1)
                                                    border.color: xInput.activeFocus ? root.primaryColor :
                                                                  (xInput.hasValue ? root.filledBorderColor : root.inputBorderColor)
                                                }

                                                onEditingFinished: {
                                                    var val = parseFloat(text.replace(",", "."))
                                                    if (!isNaN(val) && cornerPoints[index]) {
                                                        var pts = cornerPoints
                                                        pts[index].y = val
                                                        cornerPoints = pts
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== STEP 2: POLYGON PREVIEW ====================
    Component {
        id: step2PolygonPreview

        Rectangle {
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: app ? app.smallSpacing : 8

                // Info header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: root.cardColor
                    radius: 8
                    border.width: 1
                    border.color: root.borderColor

                    Text {
                        anchors.centerIn: parent
                        text: root.tr("Girdiğiniz köşe noktalarından oluşan alan önizlemesi")
                        font.pixelSize: app ? app.smallFontSize : 12
                        color: root.textSecondaryColor
                    }
                }

                // Polygon preview canvas - Dark theme
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.canvasBgColor
                    radius: 12
                    border.width: 2
                    border.color: root.primaryColor

                    // Title bar
                    Rectangle {
                        id: previewTitleBar
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 36
                        color: root.primaryColor
                        radius: 10

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 10
                            color: parent.color
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.tr("Kazı Alanı Önizlemesi") + " - " + cornerCount + " " + root.tr("Köşe")
                            font.pixelSize: app ? app.baseFontSize : 14
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Canvas for polygon
                    Canvas {
                        id: polygonCanvas
                        anchors.top: previewTitleBar.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: coordinateInfo.top
                        anchors.margins: 16

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()

                            // Dark background
                            ctx.fillStyle = "#1a1a2e"
                            ctx.fillRect(0, 0, width, height)

                            if (cornerPoints.length < 3) return

                            // Calculate bounds
                            var minX = Infinity, maxX = -Infinity
                            var minY = Infinity, maxY = -Infinity

                            for (var i = 0; i < cornerPoints.length; i++) {
                                var pt = cornerPoints[i]
                                if (pt.x < minX) minX = pt.x
                                if (pt.x > maxX) maxX = pt.x
                                if (pt.y < minY) minY = pt.y
                                if (pt.y > maxY) maxY = pt.y
                            }

                            var dataWidth = maxX - minX
                            var dataHeight = maxY - minY
                            if (dataWidth === 0) dataWidth = 1
                            if (dataHeight === 0) dataHeight = 1

                            var padding = 50
                            var scaleX = (width - 2 * padding) / dataWidth
                            var scaleY = (height - 2 * padding) / dataHeight
                            var scale = Math.min(scaleX, scaleY)

                            var offsetX = padding + (width - 2 * padding - dataWidth * scale) / 2
                            var offsetY = padding + (height - 2 * padding - dataHeight * scale) / 2

                            // Transform function
                            function transformX(x) {
                                return offsetX + (x - minX) * scale
                            }
                            function transformY(y) {
                                // Invert Y for proper display
                                return height - (offsetY + (y - minY) * scale)
                            }

                            // Draw grid - dark theme
                            ctx.strokeStyle = "rgba(255, 255, 255, 0.1)"
                            ctx.lineWidth = 1
                            for (var gx = 0; gx <= width; gx += 40) {
                                ctx.beginPath()
                                ctx.moveTo(gx, 0)
                                ctx.lineTo(gx, height)
                                ctx.stroke()
                            }
                            for (var gy = 0; gy <= height; gy += 40) {
                                ctx.beginPath()
                                ctx.moveTo(0, gy)
                                ctx.lineTo(width, gy)
                                ctx.stroke()
                            }

                            // Draw polygon fill
                            ctx.fillStyle = "rgba(49, 151, 149, 0.3)"
                            ctx.beginPath()
                            ctx.moveTo(transformX(cornerPoints[0].x), transformY(cornerPoints[0].y))
                            for (var j = 1; j < cornerPoints.length; j++) {
                                ctx.lineTo(transformX(cornerPoints[j].x), transformY(cornerPoints[j].y))
                            }
                            ctx.closePath()
                            ctx.fill()

                            // Draw polygon outline
                            ctx.strokeStyle = "#319795"
                            ctx.lineWidth = 3
                            ctx.setLineDash([])
                            ctx.beginPath()
                            ctx.moveTo(transformX(cornerPoints[0].x), transformY(cornerPoints[0].y))
                            for (var k = 1; k < cornerPoints.length; k++) {
                                ctx.lineTo(transformX(cornerPoints[k].x), transformY(cornerPoints[k].y))
                            }
                            ctx.closePath()
                            ctx.stroke()

                            // Draw corner points and labels
                            for (var m = 0; m < cornerPoints.length; m++) {
                                var px = transformX(cornerPoints[m].x)
                                var py = transformY(cornerPoints[m].y)

                                // Point circle
                                ctx.fillStyle = "#319795"
                                ctx.beginPath()
                                ctx.arc(px, py, 10, 0, 2 * Math.PI)
                                ctx.fill()

                                ctx.fillStyle = "white"
                                ctx.beginPath()
                                ctx.arc(px, py, 6, 0, 2 * Math.PI)
                                ctx.fill()

                                // Label - white for dark theme
                                ctx.fillStyle = "white"
                                ctx.font = "bold 12px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(cornerPoints[m].label, px, py - 16)
                            }
                        }

                        Connections {
                            target: root
                            function onCornerPointsChanged() {
                                polygonCanvas.requestPaint()
                            }
                        }

                        Component.onCompleted: requestPaint()
                    }

                    // Coordinate info - dark theme
                    Rectangle {
                        id: coordinateInfo
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 60
                        color: Qt.rgba(0, 0, 0, 0.4)
                        radius: 10

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 10
                            color: parent.color
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 30

                            Column {
                                spacing: 2
                                Text {
                                    text: root.tr("Alan")
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                }
                                Text {
                                    text: calculateArea().toFixed(0) + " m²"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            Rectangle { width: 1; height: 36; color: root.borderColor }

                            Column {
                                spacing: 2
                                Text {
                                    text: root.tr("Çevre")
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                }
                                Text {
                                    text: calculatePerimeter().toFixed(1) + " m"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            Rectangle { width: 1; height: 36; color: root.borderColor }

                            Column {
                                spacing: 2
                                Text {
                                    text: root.tr("Köşe Sayısı")
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                }
                                Text {
                                    text: cornerCount.toString()
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==================== STEP 3: BATHYMETRIC DATA ====================
    Component {
        id: step3BathymetricData

        Rectangle {
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: app ? app.smallSpacing : 8

                // Header with add button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: root.cardColor
                    radius: 8
                    border.width: 1
                    border.color: root.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12

                        Text {
                            text: root.tr("Batimetrik Derinlik Noktaları")
                            font.pixelSize: app ? app.baseFontSize : 14
                            font.bold: true
                            color: root.textColor
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 32
                            text: "+ " + root.tr("Ekle")

                            background: Rectangle {
                                radius: 6
                                color: parent.pressed ? Qt.darker("#38A169", 1.2) : "#38A169"
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                var pts = bathymetricPoints
                                pts.push({
                                    x: 454750 + Math.random() * 100,
                                    y: 4508300 + Math.random() * 100,
                                    depth: -(5 + Math.random() * 20)
                                })
                                bathymetricPoints = pts
                            }
                        }
                    }
                }

                // Data table
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    // Table header
                    Rectangle {
                        id: bathTableHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        height: 36
                        color: Qt.rgba(1, 1, 1, 0.1)
                        radius: 6

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8

                            Text {
                                width: 40
                                text: "#"
                                font.pixelSize: 12
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignCenter
                            }

                            Text {
                                width: (parent.width - 90) / 3
                                text: root.tr("Y Koordinatı")
                                font.pixelSize: 11
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignCenter
                            }

                            Text {
                                width: (parent.width - 90) / 3
                                text: root.tr("X Koordinatı")
                                font.pixelSize: 11
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignCenter
                            }

                            Text {
                                width: (parent.width - 90) / 3
                                text: root.tr("Derinlik") + " (m)"
                                font.pixelSize: 11
                                font.bold: true
                                color: root.textColor
                                anchors.verticalCenter: parent.verticalCenter
                                horizontalAlignment: Text.AlignCenter
                            }

                            Item {
                                width: 50
                                height: parent.height
                            }
                        }
                    }

                    // Empty state or data list
                    Item {
                        anchors.top: bathTableHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 8
                        anchors.topMargin: 4

                        // Empty state
                        Column {
                            visible: bathymetricPoints.length === 0
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "📍"
                                font.pixelSize: 40
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.tr("Henüz veri noktası eklenmedi")
                                font.pixelSize: app ? app.baseFontSize : 14
                                color: root.textSecondaryColor
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.tr("Derinlik verisi eklemek için + Ekle butonuna tıklayın")
                                font.pixelSize: app ? app.smallFontSize : 12
                                color: root.textSecondaryColor
                            }
                        }

                        // Data list
                        ScrollView {
                            visible: bathymetricPoints.length > 0
                            anchors.fill: parent
                            clip: true

                            Column {
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: bathymetricPoints.length

                                    Rectangle {
                                        width: parent.width
                                        height: 46
                                        color: index % 2 === 0 ? Qt.rgba(1, 1, 1, 0.03) : "transparent"
                                        radius: 4

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8

                                            // Index
                                            Item {
                                                width: 40
                                                height: parent.height

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: (index + 1).toString()
                                                    font.pixelSize: 12
                                                    color: root.textSecondaryColor
                                                }
                                            }

                                            // Y input
                                            Item {
                                                width: (parent.width - 90) / 3
                                                height: parent.height

                                                TextField {
                                                    id: bathYInput
                                                    anchors.centerIn: parent
                                                    width: parent.width - 8
                                                    height: 34
                                                    text: bathymetricPoints[index] ? bathymetricPoints[index].x.toFixed(2) : ""
                                                    font.pixelSize: 11
                                                    color: root.inputTextColor
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                                    property bool hasValue: text.length > 0

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: bathYInput.activeFocus ? 2 : (bathYInput.hasValue ? 1.5 : 1)
                                                        border.color: bathYInput.activeFocus ? root.primaryColor :
                                                                      (bathYInput.hasValue ? root.filledBorderColor : root.inputBorderColor)
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text.replace(",", "."))
                                                        if (!isNaN(val)) {
                                                            var pts = bathymetricPoints
                                                            pts[index].x = val
                                                            bathymetricPoints = pts
                                                        }
                                                    }
                                                }
                                            }

                                            // X input
                                            Item {
                                                width: (parent.width - 90) / 3
                                                height: parent.height

                                                TextField {
                                                    id: bathXInput
                                                    anchors.centerIn: parent
                                                    width: parent.width - 8
                                                    height: 34
                                                    text: bathymetricPoints[index] ? bathymetricPoints[index].y.toFixed(2) : ""
                                                    font.pixelSize: 11
                                                    color: root.inputTextColor
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                                    property bool hasValue: text.length > 0

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: bathXInput.activeFocus ? 2 : (bathXInput.hasValue ? 1.5 : 1)
                                                        border.color: bathXInput.activeFocus ? root.primaryColor :
                                                                      (bathXInput.hasValue ? root.filledBorderColor : root.inputBorderColor)
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text.replace(",", "."))
                                                        if (!isNaN(val)) {
                                                            var pts = bathymetricPoints
                                                            pts[index].y = val
                                                            bathymetricPoints = pts
                                                        }
                                                    }
                                                }
                                            }

                                            // Depth input
                                            Item {
                                                width: (parent.width - 90) / 3
                                                height: parent.height

                                                TextField {
                                                    id: bathDepthInput
                                                    anchors.centerIn: parent
                                                    width: parent.width - 8
                                                    height: 34
                                                    text: bathymetricPoints[index] ? bathymetricPoints[index].depth.toFixed(2) : ""
                                                    font.pixelSize: 11
                                                    color: root.inputTextColor
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                                    property bool hasValue: text.length > 0

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: bathDepthInput.activeFocus ? 2 : (bathDepthInput.hasValue ? 1.5 : 1)
                                                        border.color: bathDepthInput.activeFocus ? "#2589BC" :
                                                                      (bathDepthInput.hasValue ? "#2589BC" : root.inputBorderColor)
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text.replace(",", "."))
                                                        if (!isNaN(val)) {
                                                            var pts = bathymetricPoints
                                                            pts[index].depth = val
                                                            bathymetricPoints = pts
                                                        }
                                                    }
                                                }
                                            }

                                            // Delete button with red border
                                            Item {
                                                width: 50
                                                height: parent.height

                                                Button {
                                                    anchors.centerIn: parent
                                                    width: 32
                                                    height: 32

                                                    background: Rectangle {
                                                        radius: 6
                                                        color: parent.pressed ? Qt.darker("#E53E3E", 1.2) :
                                                               parent.hovered ? "#E53E3E" : Qt.rgba(1, 1, 1, 0.1)
                                                        border.width: 1.5
                                                        border.color: "#E53E3E"
                                                    }

                                                    contentItem: Text {
                                                        text: "×"
                                                        font.pixelSize: 18
                                                        color: parent.hovered ? "white" : "#E53E3E"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    onClicked: {
                                                        var pts = bathymetricPoints
                                                        pts.splice(index, 1)
                                                        bathymetricPoints = pts
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Quick add samples button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: root.cardColor
                    radius: 8
                    border.width: 1
                    border.color: root.borderColor

                    Button {
                        anchors.centerIn: parent
                        width: parent.width - 24
                        height: 32
                        text: root.tr("Örnek veri ekle") + " (5 " + root.tr("nokta") + ")"

                        background: Rectangle {
                            radius: 6
                            color: parent.pressed ? Qt.darker("#2589BC", 1.2) : "#2589BC"
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var samples = [
                                {x: 454704.32, y: 4508264.38, depth: -9.00},
                                {x: 454752.25, y: 4508402.99, depth: -14.20},
                                {x: 454770.28, y: 4508455.12, depth: -12.00},
                                {x: 454808.22, y: 4508557.97, depth: -14.20},
                                {x: 454987.71, y: 4508162.21, depth: -9.50}
                            ]
                            bathymetricPoints = samples
                        }
                    }
                }
            }
        }
    }

    // ==================== STEP 4: MAP VIEWS ====================
    Component {
        id: step4MapViews

        Rectangle {
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: app ? app.smallSpacing : 8

                // View mode tabs + zoom controls
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: root.cardColor
                    radius: 8
                    border.width: 1
                    border.color: root.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        // View mode buttons
                        Row {
                            spacing: 8

                            Button {
                                width: 130
                                height: 36
                                text: root.tr("Kontur Çizgili")

                                background: Rectangle {
                                    radius: 6
                                    color: mapViewMode === 0 ? root.primaryColor : Qt.rgba(1, 1, 1, 0.1)
                                    border.width: mapViewMode === 0 ? 0 : 1
                                    border.color: root.borderColor
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 11
                                    font.bold: mapViewMode === 0
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: mapViewMode = 0
                            }

                            Button {
                                width: 130
                                height: 36
                                text: root.tr("Grid Görünümü")

                                background: Rectangle {
                                    radius: 6
                                    color: mapViewMode === 1 ? root.primaryColor : Qt.rgba(1, 1, 1, 0.1)
                                    border.width: mapViewMode === 1 ? 0 : 1
                                    border.color: root.borderColor
                                }

                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 11
                                    font.bold: mapViewMode === 1
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: mapViewMode = 1
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Zoom controls
                        Row {
                            spacing: 6

                            Button {
                                width: 36
                                height: 36
                                enabled: mapZoom > 0.5

                                background: Rectangle {
                                    radius: 6
                                    color: parent.enabled ?
                                           (parent.pressed ? Qt.darker("#2589BC", 1.2) : "#2589BC") :
                                           Qt.rgba(1, 1, 1, 0.1)
                                }

                                contentItem: Text {
                                    text: "−"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: if (mapZoom > 0.5) mapZoom -= 0.25
                            }

                            Rectangle {
                                width: 50
                                height: 36
                                color: Qt.rgba(1, 1, 1, 0.1)
                                radius: 6

                                Text {
                                    anchors.centerIn: parent
                                    text: Math.round(mapZoom * 100) + "%"
                                    font.pixelSize: 11
                                    color: "white"
                                }
                            }

                            Button {
                                width: 36
                                height: 36
                                enabled: mapZoom < 2.0

                                background: Rectangle {
                                    radius: 6
                                    color: parent.enabled ?
                                           (parent.pressed ? Qt.darker("#2589BC", 1.2) : "#2589BC") :
                                           Qt.rgba(1, 1, 1, 0.1)
                                }

                                contentItem: Text {
                                    text: "+"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: if (mapZoom < 2.0) mapZoom += 0.25
                            }
                        }
                    }
                }

                // Map display - Dark theme
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.canvasBgColor
                    radius: 12
                    border.width: 2
                    border.color: "#1A75A8"
                    clip: true

                    // Map title
                    Rectangle {
                        id: mapTitle
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 36
                        color: "#1A75A8"
                        radius: 10
                        z: 10

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 10
                            color: parent.color
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.tr("Batimetrik Harita") + " - " +
                                  (mapViewMode === 0 ? root.tr("Kontur Çizgili") : root.tr("Grid")) +
                                  " (" + bathymetricPoints.length + " " + root.tr("nokta") + ")"
                            font.pixelSize: 14
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Map canvas with zoom
                    Canvas {
                        id: bathymetricMapCanvas
                        anchors.top: mapTitle.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: legendBar.top
                        anchors.margins: 12

                        property int viewMode: mapViewMode
                        property real zoom: mapZoom

                        onViewModeChanged: requestPaint()
                        onZoomChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()

                            // Dark background
                            ctx.fillStyle = "#1a1a2e"
                            ctx.fillRect(0, 0, width, height)

                            if (cornerPoints.length < 3) {
                                ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
                                ctx.font = "14px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(root.tr("Köşe noktaları tanımlanmadı"), width/2, height/2)
                                return
                            }

                            // Calculate bounds from corner points
                            var minX = Infinity, maxX = -Infinity
                            var minY = Infinity, maxY = -Infinity

                            for (var i = 0; i < cornerPoints.length; i++) {
                                if (cornerPoints[i].x < minX) minX = cornerPoints[i].x
                                if (cornerPoints[i].x > maxX) maxX = cornerPoints[i].x
                                if (cornerPoints[i].y < minY) minY = cornerPoints[i].y
                                if (cornerPoints[i].y > maxY) maxY = cornerPoints[i].y
                            }

                            var dataWidth = maxX - minX
                            var dataHeight = maxY - minY
                            if (dataWidth === 0) dataWidth = 100
                            if (dataHeight === 0) dataHeight = 100

                            var padding = 40
                            var baseScale = Math.min((width - 2 * padding) / dataWidth,
                                                     (height - 2 * padding) / dataHeight)
                            var scale = baseScale * zoom

                            var offsetX = width / 2 - ((minX + maxX) / 2 - minX) * scale
                            var offsetY = height / 2 + ((minY + maxY) / 2 - minY) * scale

                            function tx(x) { return offsetX + (x - minX) * scale }
                            function ty(y) { return height - (offsetY + (y - minY) * scale) }

                            // Draw grid if grid mode
                            if (viewMode === 1) {
                                ctx.strokeStyle = "rgba(255, 255, 255, 0.15)"
                                ctx.lineWidth = 1
                                var gridSize = 30
                                for (var gx = 0; gx < width; gx += gridSize) {
                                    ctx.beginPath()
                                    ctx.moveTo(gx, 0)
                                    ctx.lineTo(gx, height)
                                    ctx.stroke()
                                }
                                for (var gy = 0; gy < height; gy += gridSize) {
                                    ctx.beginPath()
                                    ctx.moveTo(0, gy)
                                    ctx.lineTo(width, gy)
                                    ctx.stroke()
                                }
                            }

                            // Draw polygon boundary
                            ctx.strokeStyle = "#319795"
                            ctx.lineWidth = 3
                            ctx.setLineDash([])
                            ctx.beginPath()
                            ctx.moveTo(tx(cornerPoints[0].x), ty(cornerPoints[0].y))
                            for (var j = 1; j < cornerPoints.length; j++) {
                                ctx.lineTo(tx(cornerPoints[j].x), ty(cornerPoints[j].y))
                            }
                            ctx.closePath()
                            ctx.stroke()

                            // Fill polygon with light color
                            ctx.fillStyle = "rgba(49, 151, 149, 0.2)"
                            ctx.fill()

                            // Draw bathymetric points
                            if (bathymetricPoints.length > 0) {
                                // Draw contour lines if contour mode
                                if (viewMode === 0 && bathymetricPoints.length >= 2) {
                                    ctx.strokeStyle = "#2589BC"
                                    ctx.lineWidth = 2
                                    ctx.setLineDash([5, 5])

                                    for (var c = 0; c < bathymetricPoints.length - 1; c++) {
                                        var pt1 = bathymetricPoints[c]
                                        var pt2 = bathymetricPoints[c + 1]

                                        ctx.beginPath()
                                        ctx.moveTo(tx(pt1.x), ty(pt1.y))
                                        ctx.lineTo(tx(pt2.x), ty(pt2.y))
                                        ctx.stroke()
                                    }
                                    ctx.setLineDash([])
                                }

                                // Draw depth points
                                for (var p = 0; p < bathymetricPoints.length; p++) {
                                    var pt = bathymetricPoints[p]
                                    var px = tx(pt.x)
                                    var py = ty(pt.y)

                                    // Depth-based color
                                    var depthRatio = Math.abs(pt.depth) / 30
                                    var r = Math.floor(10 + depthRatio * 20)
                                    var g = Math.floor(100 + (1-depthRatio) * 50)
                                    var b = Math.floor(150 + depthRatio * 80)
                                    ctx.fillStyle = "rgb(" + r + "," + g + "," + b + ")"

                                    // Draw point
                                    ctx.beginPath()
                                    ctx.arc(px, py, 12 * zoom, 0, 2 * Math.PI)
                                    ctx.fill()

                                    ctx.fillStyle = "white"
                                    ctx.beginPath()
                                    ctx.arc(px, py, 8 * zoom, 0, 2 * Math.PI)
                                    ctx.fill()

                                    // Depth label
                                    ctx.fillStyle = "#1A75A8"
                                    ctx.font = "bold " + Math.round(10 * zoom) + "px sans-serif"
                                    ctx.textAlign = "center"
                                    ctx.fillText(pt.depth.toFixed(1), px, py + 4)
                                }
                            }

                            // Draw corner labels
                            ctx.fillStyle = "#319795"
                            ctx.font = "bold " + Math.round(11 * zoom) + "px sans-serif"
                            ctx.textAlign = "center"
                            for (var m = 0; m < cornerPoints.length; m++) {
                                var cpx = tx(cornerPoints[m].x)
                                var cpy = ty(cornerPoints[m].y)

                                ctx.beginPath()
                                ctx.arc(cpx, cpy, 6 * zoom, 0, 2 * Math.PI)
                                ctx.fill()

                                ctx.fillStyle = "white"
                                ctx.fillText(cornerPoints[m].label, cpx, cpy - 12 * zoom)
                                ctx.fillStyle = "#319795"
                            }
                        }

                        Connections {
                            target: root
                            function onCornerPointsChanged() {
                                bathymetricMapCanvas.requestPaint()
                            }
                            function onBathymetricPointsChanged() {
                                bathymetricMapCanvas.requestPaint()
                            }
                            function onMapViewModeChanged() {
                                bathymetricMapCanvas.requestPaint()
                            }
                            function onMapZoomChanged() {
                                bathymetricMapCanvas.requestPaint()
                            }
                        }

                        Component.onCompleted: requestPaint()
                    }

                    // Legend bar - dark theme
                    Rectangle {
                        id: legendBar
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 50
                        color: Qt.rgba(0, 0, 0, 0.4)
                        radius: 10

                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 10
                            color: parent.color
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 20

                            // Depth legend
                            Row {
                                spacing: 8
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: root.tr("Derinlik") + ":"
                                    font.pixelSize: 11
                                    color: root.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Gradient bar
                                Rectangle {
                                    width: 100
                                    height: 16
                                    radius: 3
                                    anchors.verticalCenter: parent.verticalCenter

                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#C6E7F2" }
                                        GradientStop { position: 0.3; color: "#55B0D4" }
                                        GradientStop { position: 0.6; color: "#1A75A8" }
                                        GradientStop { position: 1.0; color: "#063554" }
                                    }
                                }

                                Text {
                                    text: "0m → -30m"
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle { width: 1; height: 30; color: root.borderColor }

                            // Point count
                            Text {
                                text: bathymetricPoints.length + " " + root.tr("veri noktası")
                                font.pixelSize: 11
                                color: root.textSecondaryColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Summary info
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#38A169"
                    radius: 8

                    Row {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: "✓"
                            font.pixelSize: 20
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.tr("Kazı alanı yapılandırması tamamlandı!")
                            font.pixelSize: app ? app.baseFontSize : 14
                            font.bold: true
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }

    // ==================== HELPER FUNCTIONS ====================

    function calculateArea() {
        if (cornerPoints.length < 3) return 0

        // Shoelace formula for polygon area
        var area = 0
        var n = cornerPoints.length

        for (var i = 0; i < n; i++) {
            var j = (i + 1) % n
            area += cornerPoints[i].x * cornerPoints[j].y
            area -= cornerPoints[j].x * cornerPoints[i].y
        }

        return Math.abs(area) / 2
    }

    function calculatePerimeter() {
        if (cornerPoints.length < 2) return 0

        var perimeter = 0
        var n = cornerPoints.length

        for (var i = 0; i < n; i++) {
            var j = (i + 1) % n
            var dx = cornerPoints[j].x - cornerPoints[i].x
            var dy = cornerPoints[j].y - cornerPoints[i].y
            perimeter += Math.sqrt(dx * dx + dy * dy)
        }

        return perimeter
    }

    function saveConfiguration() {
        // Save corner points to ConfigManager if available
        if (configManager) {
            // For now, save polygon bounds as grid coordinates
            if (cornerPoints.length >= 2) {
                var minX = Infinity, maxX = -Infinity
                var minY = Infinity, maxY = -Infinity

                for (var i = 0; i < cornerPoints.length; i++) {
                    if (cornerPoints[i].x < minX) minX = cornerPoints[i].x
                    if (cornerPoints[i].x > maxX) maxX = cornerPoints[i].x
                    if (cornerPoints[i].y < minY) minY = cornerPoints[i].y
                    if (cornerPoints[i].y > maxY) maxY = cornerPoints[i].y
                }

                // Convert ITRF to approximate lat/lon for storage
                configManager.gridStartLatitude = minY / 111000
                configManager.gridStartLongitude = minX / (111000 * Math.cos(minY / 111000 * Math.PI / 180))
                configManager.gridEndLatitude = maxY / 111000
                configManager.gridEndLongitude = maxX / (111000 * Math.cos(maxY / 111000 * Math.PI / 180))
            }
        }

        console.log("Configuration saved:")
        console.log("- Corner count:", cornerCount)
        console.log("- Corner points:", JSON.stringify(cornerPoints))
        console.log("- Bathymetric points:", JSON.stringify(bathymetricPoints))
    }
}
