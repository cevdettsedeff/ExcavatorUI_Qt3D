import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

/**
 * DigAreaConfigPage - Kazı Alanı Ayarları Sayfası
 *
 * Wizard-style adım adım ilerleyen tasarım:
 * 0. Proje seçimi (Yeni Proje / Mevcut Projeyi Aç)
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

    // FileDialog for loading existing projects
    FileDialog {
        id: projectFileDialog
        title: root.tr("Proje Dosyası Seç")
        currentFolder: Qt.resolvedUrl(".")
        nameFilters: [root.tr("JSON Dosyaları (*.json)"), "All files (*)"]
        fileMode: FileDialog.OpenFile

        onAccepted: {
            console.log("Selected project file:", selectedFile)
            root.projectFilePath = selectedFile.toString()

            // TODO: Load project from JSON file
            // For now, just move to next step
            if (root.projectMode === "existing" && root.projectFilePath !== "") {
                // Validate and load JSON
                loadProjectFromFile(root.projectFilePath)
            }
        }

        onRejected: {
            console.log("File selection cancelled")
        }
    }

    // Function to load project from JSON file
    function loadProjectFromFile(filePath) {
        console.log("Loading project from:", filePath)
        // TODO: Implement JSON loading logic
        // For now, just proceed to next step
        if (currentStep === 0) {
            currentStep = 1
        }
    }

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
    property int currentStep: 0  // 0-7 arası
    property int totalSteps: 8

    // Step titles
    property var stepTitles: [
        root.tr("Proje Seçimi"),
        root.tr("Köşe Sayısı"),
        root.tr("Koordinatlar"),
        root.tr("Önizleme"),
        root.tr("Batimetri"),
        root.tr("Harita"),
        root.tr("Engel Girişi"),
        root.tr("Engel Önizleme")
    ]

    // Project selection
    property string projectMode: "new"  // "new" or "existing"
    property string projectName: ""
    property string projectFilePath: ""

    // ==================== POLYGON DATA ====================
    property int cornerCount: 4
    property var cornerPoints: []  // [{x: 454704.32, y: 4508264.38, label: "T1"}, ...]

    // ==================== BATHYMETRIC DATA ====================
    property var bathymetricPoints: []  // [{x: 454700, y: 4508260, depth: -9.5}, ...]
    property int bathymetricUpdateTrigger: 0  // Force UI update when this changes

    // ==================== MAP VIEW MODE ====================
    property int mapViewMode: 0  // 0: Contour lines, 1: Grid
    property real mapZoom: 1.0  // Zoom level for map

    // ==================== OBSTACLES DATA ====================
    // Engeller listesi:
    // - Nokta: {id: "E1", type: "point", depth: -5.0, points: [{x, y, label: "E1"}]}
    // - Alan: {id: "E2", type: "area", depth: -5.0, points: [{x, y, label: "E2-1"}, {x, y, label: "E2-2"}, {x, y, label: "E2-3"}, {x, y, label: "E2-4"}]}
    property var obstacles: []
    property int selectedObstacleIndex: -1
    property int selectedCornerIndex: -1  // Seçili köşe indeksi (alan engelleri için)
    // Safe accessor for current obstacle
    property var currentObstacle: {
        if (selectedObstacleIndex >= 0 && selectedObstacleIndex < obstacles.length) {
            return obstacles[selectedObstacleIndex]
        }
        return null
    }

    // Safe obstacle getter
    function getObstacle(idx) {
        if (idx >= 0 && idx < obstacles.length) {
            return obstacles[idx]
        }
        return {id: "", type: "point", depth: 0, points: []}
    }

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
        height: app ? app.buttonHeight * 1.5 : 60
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: app ? app.smallPadding : 16
            anchors.rightMargin: app ? app.smallPadding : 16

            Button {
                Layout.preferredWidth: app ? app.buttonHeight : 40
                Layout.preferredHeight: app ? app.buttonHeight : 40
                flat: true

                contentItem: Text {
                    text: "←"
                    font.pixelSize: 24
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 20
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
                font.pixelSize: app ? app.mediumFontSize : 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: app ? app.buttonHeight : 40 }
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

        // Step 0: Project Selection
        Loader {
            anchors.fill: parent
            active: currentStep === 0
            sourceComponent: step0ProjectSelection
        }

        // Step 1: Corner Count Selection
        Loader {
            anchors.fill: parent
            active: currentStep === 1
            sourceComponent: step1CornerCount
        }

        // Step 2: Corner Coordinates Input
        Loader {
            anchors.fill: parent
            active: currentStep === 2
            sourceComponent: step2CornerCoordinates
        }

        // Step 3: Polygon Preview
        Loader {
            anchors.fill: parent
            active: currentStep === 3
            sourceComponent: step3PolygonPreview
        }

        // Step 4: Bathymetric Data Entry
        Loader {
            anchors.fill: parent
            active: currentStep === 4
            sourceComponent: step4BathymetricData
        }

        // Step 5: Map Views
        Loader {
            anchors.fill: parent
            active: currentStep === 5
            sourceComponent: step5MapViews
        }

        // Step 6: Obstacle Input (Engel Girişi)
        Loader {
            anchors.fill: parent
            active: currentStep === 6
            sourceComponent: step6ObstacleInput
        }

        // Step 7: Obstacle Preview (Engel Önizleme)
        Loader {
            anchors.fill: parent
            active: currentStep === 7
            sourceComponent: step7ObstaclePreview
        }
    }

    // ==================== FOOTER ====================
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: app ? app.buttonHeight * 2 : 80
        color: Qt.rgba(0, 0, 0, 0.3)

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: root.borderColor
        }

        RowLayout {
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 16

            // Geri butonu
            Button {
                Layout.preferredWidth: 100
                Layout.preferredHeight: app ? app.buttonHeight : 50
                visible: currentStep > 0
                text: root.tr("Geri")

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.3)
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: currentStep--
            }

            Item { Layout.fillWidth: true }

            // Kaydet ve Bitir / Devam Et butonu
            Button {
                Layout.preferredWidth: currentStep === totalSteps - 1 ? 180 : 150
                Layout.preferredHeight: app ? app.buttonHeight : 50
                text: currentStep === totalSteps - 1 ?
                      root.tr("Kaydet ve Bitir") + " ✓" :
                      root.tr("Devam Et") + " →"

                background: Rectangle {
                    radius: 8
                    color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
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

    // ==================== STEP 0: PROJECT SELECTION ====================
    Component {
        id: step0ProjectSelection

        Rectangle {
            color: "transparent"

            ScrollView {
                anchors.fill: parent
                contentWidth: parent.width

                ColumnLayout {
                    width: parent.width
                    spacing: app ? app.normalSpacing * 2 : 32

                    Item { height: app ? app.smallSpacing : 12 }

                    // Info Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.normalPadding : 20
                        Layout.preferredHeight: infoContent.height + (app ? app.normalPadding * 2 : 32)
                        color: Qt.rgba(0.2, 0.6, 0.8, 0.15)
                        radius: app ? app.normalRadius : 12
                        border.width: 1
                        border.color: Qt.rgba(0.2, 0.6, 0.8, 0.3)

                        RowLayout {
                            id: infoContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: app ? app.normalPadding : 20
                            spacing: app ? app.normalSpacing : 16

                            Text {
                                text: "📐"
                                font.pixelSize: app ? app.mediumFontSize : 24
                            }

                            Text {
                                Layout.fillWidth: true
                                text: root.tr("Yeni bir kazı alanı projesi oluşturabilir veya daha önce kaydedilmiş bir projeyi açabilirsiniz.")
                                font.pixelSize: app ? app.baseFontSize : 14
                                color: root.textSecondaryColor
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    // Project Selection Cards
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.normalPadding : 20
                        spacing: app ? app.normalSpacing * 1.5 : 24

                        // New Project Card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: newProjectContent.height + (app ? app.largePadding * 2 : 48)
                            color: root.projectMode === "new" ? Qt.rgba(0.2, 0.6, 0.5, 0.2) : root.cardColor
                            radius: app ? app.normalRadius : 16
                            border.width: root.projectMode === "new" ? 2 : 1
                            border.color: root.projectMode === "new" ? root.primaryColor : root.borderColor

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.projectMode = "new"
                                }
                            }

                            ColumnLayout {
                                id: newProjectContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: app ? app.largePadding : 32
                                spacing: app ? app.normalSpacing : 16

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: app ? app.normalSpacing : 16

                                    Rectangle {
                                        Layout.preferredWidth: app ? app.largeIconSize : 64
                                        Layout.preferredHeight: app ? app.largeIconSize : 64
                                        radius: (app ? app.largeIconSize : 64) / 2
                                        color: Qt.rgba(0.2, 0.6, 0.5, 0.2)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.pixelSize: app ? app.xlFontSize : 36
                                            font.bold: true
                                            color: root.primaryColor
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: app ? app.smallSpacing / 2 : 6

                                        Text {
                                            text: root.tr("Yeni Proje Oluştur")
                                            font.pixelSize: app ? app.largeFontSize : 24
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Text {
                                            text: root.tr("Sıfırdan yeni bir kazı alanı projesi başlatın")
                                            font.pixelSize: app ? app.baseFontSize : 14
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                        }
                                    }

                                    Item {
                                        Layout.preferredWidth: app ? app.iconSize : 32
                                        Layout.preferredHeight: app ? app.iconSize : 32

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: app ? app.normalSpacing * 1.5 : 24
                                            height: app ? app.normalSpacing * 1.5 : 24
                                            radius: (app ? app.normalSpacing * 1.5 : 24) / 2
                                            border.width: 2
                                            border.color: root.projectMode === "new" ? root.primaryColor : root.borderColor
                                            color: root.projectMode === "new" ? root.primaryColor : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✓"
                                                font.pixelSize: app ? app.smallFontSize : 14
                                                color: "white"
                                                visible: root.projectMode === "new"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Existing Project Card
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: existingProjectContent.height + (app ? app.largePadding * 2 : 48)
                            color: root.projectMode === "existing" ? Qt.rgba(0.2, 0.6, 0.5, 0.2) : root.cardColor
                            radius: app ? app.normalRadius : 16
                            border.width: root.projectMode === "existing" ? 2 : 1
                            border.color: root.projectMode === "existing" ? root.primaryColor : root.borderColor

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.projectMode = "existing"
                                    // Open file dialog to select project file
                                    projectFileDialog.open()
                                }
                            }

                            ColumnLayout {
                                id: existingProjectContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: app ? app.largePadding : 32
                                spacing: app ? app.normalSpacing : 16

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: app ? app.normalSpacing : 16

                                    Rectangle {
                                        Layout.preferredWidth: app ? app.largeIconSize : 64
                                        Layout.preferredHeight: app ? app.largeIconSize : 64
                                        radius: (app ? app.largeIconSize : 64) / 2
                                        color: Qt.rgba(0.6, 0.5, 0.2, 0.2)

                                        Text {
                                            anchors.centerIn: parent
                                            text: "📁"
                                            font.pixelSize: app ? app.iconSize : 32
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: app ? app.smallSpacing / 2 : 6

                                        Text {
                                            text: root.tr("Mevcut Projeyi Aç")
                                            font.pixelSize: app ? app.largeFontSize : 24
                                            font.bold: true
                                            color: root.textColor
                                        }

                                        Text {
                                            text: root.tr("Daha önce kaydedilmiş bir proje dosyasını yükleyin")
                                            font.pixelSize: app ? app.baseFontSize : 14
                                            color: root.textSecondaryColor
                                            wrapMode: Text.WordWrap
                                        }
                                    }

                                    Item {
                                        Layout.preferredWidth: app ? app.iconSize : 32
                                        Layout.preferredHeight: app ? app.iconSize : 32

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: app ? app.normalSpacing * 1.5 : 24
                                            height: app ? app.normalSpacing * 1.5 : 24
                                            radius: (app ? app.normalSpacing * 1.5 : 24) / 2
                                            border.width: 2
                                            border.color: root.projectMode === "existing" ? root.primaryColor : root.borderColor
                                            color: root.projectMode === "existing" ? root.primaryColor : "transparent"

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✓"
                                                font.pixelSize: app ? app.smallFontSize : 14
                                                color: "white"
                                                visible: root.projectMode === "existing"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Project Name Input (only for new project)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: app ? app.normalPadding : 20
                        Layout.preferredHeight: projectNameContent.height + (app ? app.normalPadding * 2 : 32)
                        color: root.cardColor
                        radius: app ? app.normalRadius : 12
                        border.width: 1
                        border.color: root.borderColor
                        visible: root.projectMode === "new"

                        ColumnLayout {
                            id: projectNameContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: app ? app.normalPadding : 20
                            spacing: app ? app.smallSpacing : 12

                            Text {
                                text: root.tr("Proje Adı")
                                font.pixelSize: app ? app.mediumFontSize : 18
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                Layout.fillWidth: true
                                placeholderText: root.tr("Örn: İstanbul Limanı Kazı Alanı")
                                text: root.projectName
                                font.pixelSize: app ? app.baseFontSize : 14
                                color: root.inputTextColor

                                background: Rectangle {
                                    radius: app ? app.smallRadius : 8
                                    color: root.inputBgColor
                                    border.width: parent.activeFocus ? 2 : 1
                                    border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                }

                                onTextChanged: {
                                    root.projectName = text
                                }
                            }
                        }
                    }

                    Item { height: app ? app.largeSpacing : 40 }
                }
            }
        }
    }

    // ==================== STEP 1: CORNER COUNT ====================
    Component {
        id: step1CornerCount

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

    // ==================== STEP 2: CORNER COORDINATES ====================
    Component {
        id: step2CornerCoordinates

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

                        Button {
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 34
                            text: root.tr("Temizle")

                            background: Rectangle {
                                radius: 6
                                color: parent.pressed ? Qt.darker("#E53E3E", 1.2) :
                                       parent.hovered ? "#E53E3E" : Qt.rgba(1, 1, 1, 0.1)
                                border.width: 1
                                border.color: "#E53E3E"
                            }

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 11
                                font.bold: true
                                color: parent.hovered ? "white" : "#E53E3E"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                // Reset all coordinates to 0
                                var newPoints = []
                                for (var i = 0; i < cornerCount; i++) {
                                    newPoints.push({
                                        x: 0,
                                        y: 0,
                                        label: "T" + (i + 1)
                                    })
                                }
                                cornerPoints = newPoints
                            }
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

    // ==================== STEP 3: POLYGON PREVIEW ====================
    Component {
        id: step3PolygonPreview

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

    // ==================== STEP 4: BATHYMETRIC DATA ====================
    Component {
        id: step4BathymetricData

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
                                var pts = root.bathymetricPoints.slice()  // Create new array copy
                                pts.push({
                                    x: NaN,
                                    y: NaN,
                                    depth: NaN
                                })
                                root.bathymetricPoints = pts
                                root.bathymetricUpdateTrigger++  // Force UI update
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

                            // Clear all button in header
                            Item {
                                width: 50
                                height: parent.height

                                Button {
                                    anchors.centerIn: parent
                                    width: 32
                                    height: 24
                                    visible: root.bathymetricPoints.length > 0

                                    background: Rectangle {
                                        radius: 4
                                        color: parent.pressed ? Qt.darker("#E53E3E", 1.2) :
                                               parent.hovered ? "#E53E3E" : Qt.rgba(1, 1, 1, 0.1)
                                        border.width: 1
                                        border.color: "#E53E3E"
                                    }

                                    contentItem: Text {
                                        text: "🗑"
                                        font.pixelSize: 12
                                        color: parent.hovered ? "white" : "#E53E3E"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        root.bathymetricPoints = []
                                        root.bathymetricUpdateTrigger++
                                    }

                                    ToolTip.visible: hovered
                                    ToolTip.text: root.tr("Tümünü Sil")
                                    ToolTip.delay: 500
                                }
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

                        // Empty state - use trigger to force updates
                        property int updateTrigger: root.bathymetricUpdateTrigger

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
                                                    text: (bathymetricPoints[index] && !isNaN(bathymetricPoints[index].x)) ? bathymetricPoints[index].x.toFixed(2) : ""
                                                    font.pixelSize: 11
                                                    color: root.inputTextColor
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                    placeholderText: "Y"
                                                    placeholderTextColor: Qt.rgba(1, 1, 1, 0.3)

                                                    property bool hasValue: text.length > 0 && !isNaN(parseFloat(text))

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: bathYInput.activeFocus ? 2 : (bathYInput.hasValue ? 1.5 : 0)
                                                        border.color: bathYInput.activeFocus ? root.primaryColor :
                                                                      (bathYInput.hasValue ? root.filledBorderColor : "transparent")
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text.replace(",", "."))
                                                        if (!isNaN(val)) {
                                                            var pts = root.bathymetricPoints.slice()
                                                            pts[index].x = val
                                                            root.bathymetricPoints = pts
                                                            root.bathymetricUpdateTrigger++
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
                                                    text: (bathymetricPoints[index] && !isNaN(bathymetricPoints[index].y)) ? bathymetricPoints[index].y.toFixed(2) : ""
                                                    font.pixelSize: 11
                                                    color: root.inputTextColor
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                    placeholderText: "X"
                                                    placeholderTextColor: Qt.rgba(1, 1, 1, 0.3)

                                                    property bool hasValue: text.length > 0 && !isNaN(parseFloat(text))

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: bathXInput.activeFocus ? 2 : (bathXInput.hasValue ? 1.5 : 0)
                                                        border.color: bathXInput.activeFocus ? root.primaryColor :
                                                                      (bathXInput.hasValue ? root.filledBorderColor : "transparent")
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text.replace(",", "."))
                                                        if (!isNaN(val)) {
                                                            var pts = root.bathymetricPoints.slice()
                                                            pts[index].y = val
                                                            root.bathymetricPoints = pts
                                                            root.bathymetricUpdateTrigger++
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
                                                    text: (bathymetricPoints[index] && !isNaN(bathymetricPoints[index].depth)) ? bathymetricPoints[index].depth.toFixed(2) : ""
                                                    font.pixelSize: 11
                                                    color: root.inputTextColor
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                    placeholderText: "-0.00"
                                                    placeholderTextColor: Qt.rgba(1, 1, 1, 0.3)

                                                    property bool hasValue: text.length > 0 && !isNaN(parseFloat(text))

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: bathDepthInput.activeFocus ? 2 : (bathDepthInput.hasValue ? 1.5 : 0)
                                                        border.color: bathDepthInput.activeFocus ? "#2589BC" :
                                                                      (bathDepthInput.hasValue ? "#2589BC" : "transparent")
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text.replace(",", "."))
                                                        if (!isNaN(val)) {
                                                            var pts = root.bathymetricPoints.slice()
                                                            pts[index].depth = val
                                                            root.bathymetricPoints = pts
                                                            root.bathymetricUpdateTrigger++
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
                                                        var pts = root.bathymetricPoints.slice()  // Create new array copy
                                                        pts.splice(index, 1)
                                                        root.bathymetricPoints = pts
                                                        root.bathymetricUpdateTrigger++  // Force UI update
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
                            root.bathymetricPoints = samples
                            root.bathymetricUpdateTrigger++
                        }
                    }
                }
            }
        }
    }

    // ==================== STEP 5: MAP VIEWS ====================
    Component {
        id: step5MapViews

        Rectangle {
            color: "transparent"

            // Pan offset için property'ler
            property real panOffsetX: 0
            property real panOffsetY: 0

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

                        // Reset Pan button
                        Button {
                            width: 36
                            height: 36
                            visible: panOffsetX !== 0 || panOffsetY !== 0

                            background: Rectangle {
                                radius: 6
                                color: parent.pressed ? Qt.darker("#FF9800", 1.2) : "#FF9800"
                            }

                            contentItem: Text {
                                text: "⟲"
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                panOffsetX = 0
                                panOffsetY = 0
                                bathymetricMapCanvas.requestPaint()
                            }

                            ToolTip.visible: hovered
                            ToolTip.text: root.tr("Görünümü Sıfırla")
                            ToolTip.delay: 500
                        }

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

                                onClicked: {
                                    if (mapZoom > 0.5) {
                                        mapZoom -= 0.25
                                        // Reset pan when zooming out to 100% or less
                                        if (mapZoom <= 1.0) {
                                            panOffsetX = 0
                                            panOffsetY = 0
                                        }
                                    }
                                }
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
                                enabled: mapZoom < 3.0

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

                                onClicked: if (mapZoom < 3.0) mapZoom += 0.25
                            }
                        }
                    }
                }

                // Map display - Dark theme with pan support
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

                        Row {
                            anchors.centerIn: parent
                            spacing: 10

                            Text {
                                text: root.tr("Batimetrik Harita") + " - " +
                                      (mapViewMode === 0 ? root.tr("Kontur Çizgili") : root.tr("Grid")) +
                                      " (" + bathymetricPoints.length + " " + root.tr("nokta") + ")"
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                            }

                            // Pan hint when zoomed
                            Rectangle {
                                visible: mapZoom > 1.0
                                width: panHintText.width + 12
                                height: 20
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.2)

                                Text {
                                    id: panHintText
                                    anchors.centerIn: parent
                                    text: "↔ " + root.tr("Sürükle")
                                    font.pixelSize: 10
                                    color: "white"
                                }
                            }
                        }
                    }

                    // Map canvas with zoom and pan
                    Canvas {
                        id: bathymetricMapCanvas
                        anchors.top: mapTitle.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: legendBar.top
                        anchors.margins: 12

                        property int viewMode: mapViewMode
                        property real zoom: mapZoom
                        property real offsetX: panOffsetX
                        property real offsetY: panOffsetY

                        onViewModeChanged: requestPaint()
                        onZoomChanged: requestPaint()
                        onOffsetXChanged: requestPaint()
                        onOffsetYChanged: requestPaint()

                        // Derinliğe göre renk hesaplama fonksiyonu
                        function getDepthColor(depth) {
                            var absDepth = Math.abs(depth)
                            if (absDepth <= 0) return "#E8F4F8"
                            if (absDepth < 3) return "#B8E0EE"
                            if (absDepth < 6) return "#64C0DC"
                            if (absDepth < 9) return "#3A9CC8"
                            if (absDepth < 12) return "#1A75A8"
                            if (absDepth < 15) return "#125E8C"
                            if (absDepth < 20) return "#0B4770"
                            if (absDepth < 25) return "#063554"
                            return "#022338"
                        }

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

                            // Center the polygon in the canvas with pan offset
                            var centerDataX = (minX + maxX) / 2
                            var centerDataY = (minY + maxY) / 2

                            function tx(x) {
                                return width / 2 + (x - centerDataX) * scale + offsetX
                            }
                            function ty(y) {
                                return height / 2 - (y - centerDataY) * scale + offsetY
                            }

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

                            // Draw bathymetric points with depth-based coloring
                            if (bathymetricPoints.length > 0) {
                                // Draw contour lines if contour mode
                                if (viewMode === 0 && bathymetricPoints.length >= 2) {
                                    ctx.lineWidth = 2
                                    ctx.setLineDash([5, 5])

                                    for (var c = 0; c < bathymetricPoints.length - 1; c++) {
                                        var pt1 = bathymetricPoints[c]
                                        var pt2 = bathymetricPoints[c + 1]

                                        // Gradient line color based on average depth
                                        var avgDepth = (Math.abs(pt1.depth) + Math.abs(pt2.depth)) / 2
                                        ctx.strokeStyle = getDepthColor(avgDepth)

                                        ctx.beginPath()
                                        ctx.moveTo(tx(pt1.x), ty(pt1.y))
                                        ctx.lineTo(tx(pt2.x), ty(pt2.y))
                                        ctx.stroke()
                                    }
                                    ctx.setLineDash([])
                                }

                                // Draw depth points with bathymetric coloring
                                for (var p = 0; p < bathymetricPoints.length; p++) {
                                    var pt = bathymetricPoints[p]
                                    var px = tx(pt.x)
                                    var py = ty(pt.y)

                                    // Get depth-based color
                                    var depthColor = getDepthColor(pt.depth)
                                    var pointRadius = 22 * zoom  // Larger radius to fit text

                                    // Outer glow effect
                                    var gradient = ctx.createRadialGradient(px, py, 0, px, py, pointRadius * 1.3)
                                    gradient.addColorStop(0, depthColor)
                                    gradient.addColorStop(0.8, depthColor)
                                    gradient.addColorStop(1, "transparent")
                                    ctx.fillStyle = gradient
                                    ctx.beginPath()
                                    ctx.arc(px, py, pointRadius * 1.3, 0, 2 * Math.PI)
                                    ctx.fill()

                                    // Main colored circle
                                    ctx.fillStyle = depthColor
                                    ctx.beginPath()
                                    ctx.arc(px, py, pointRadius, 0, 2 * Math.PI)
                                    ctx.fill()

                                    // White border
                                    ctx.strokeStyle = "white"
                                    ctx.lineWidth = 2.5 * zoom
                                    ctx.beginPath()
                                    ctx.arc(px, py, pointRadius, 0, 2 * Math.PI)
                                    ctx.stroke()

                                    // Depth value text INSIDE the circle
                                    var depthValue = Math.abs(pt.depth).toFixed(1)
                                    ctx.font = "bold " + Math.round(11 * zoom) + "px sans-serif"
                                    ctx.textAlign = "center"
                                    ctx.textBaseline = "middle"

                                    // Text shadow for better readability
                                    ctx.fillStyle = "rgba(0, 0, 0, 0.6)"
                                    ctx.fillText(depthValue, px + 1, py + 1)

                                    // White text
                                    ctx.fillStyle = "white"
                                    ctx.fillText(depthValue, px, py)

                                    // Small "m" label below the number
                                    ctx.font = Math.round(8 * zoom) + "px sans-serif"
                                    ctx.fillStyle = "rgba(255, 255, 255, 0.8)"
                                    ctx.fillText("m", px, py + 10 * zoom)

                                    // Reset textBaseline
                                    ctx.textBaseline = "alphabetic"
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

                    // Pan/Drag MouseArea - Always enabled for dragging
                    MouseArea {
                        id: mapPanArea
                        anchors.fill: bathymetricMapCanvas
                        z: 100  // Ensure it's on top
                        enabled: true
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        hoverEnabled: true

                        property real lastX: 0
                        property real lastY: 0
                        property bool isDragging: false

                        onPressed: function(mouse) {
                            lastX = mouse.x
                            lastY = mouse.y
                            isDragging = true
                        }

                        onReleased: {
                            isDragging = false
                        }

                        onPositionChanged: function(mouse) {
                            if (isDragging && pressed) {
                                var deltaX = mouse.x - lastX
                                var deltaY = mouse.y - lastY

                                // Calculate max pan based on zoom and canvas size
                                var maxPanX = bathymetricMapCanvas.width * Math.max(0.5, (mapZoom - 0.5)) * 0.6
                                var maxPanY = bathymetricMapCanvas.height * Math.max(0.5, (mapZoom - 0.5)) * 0.6

                                panOffsetX = Math.max(-maxPanX, Math.min(maxPanX, panOffsetX + deltaX))
                                panOffsetY = Math.max(-maxPanY, Math.min(maxPanY, panOffsetY + deltaY))

                                lastX = mouse.x
                                lastY = mouse.y

                                bathymetricMapCanvas.requestPaint()
                            }
                        }

                        // Mouse wheel zoom support
                        onWheel: function(wheel) {
                            if (wheel.angleDelta.y > 0) {
                                // Zoom in
                                if (mapZoom < 3.0) mapZoom += 0.25
                            } else {
                                // Zoom out
                                if (mapZoom > 0.5) {
                                    mapZoom -= 0.25
                                    // Reset pan when zooming out significantly
                                    if (mapZoom <= 0.75) {
                                        panOffsetX = 0
                                        panOffsetY = 0
                                    }
                                }
                            }
                        }
                    }

                    // Legend bar - dark theme
                    Rectangle {
                        id: legendBar
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 45
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
                            spacing: 15

                            // Depth legend
                            Row {
                                spacing: 6
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: root.tr("Derinlik") + ":"
                                    font.pixelSize: 10
                                    color: root.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Gradient bar
                                Rectangle {
                                    width: 80
                                    height: 14
                                    radius: 3
                                    anchors.verticalCenter: parent.verticalCenter

                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: "#E8F4F8" }
                                        GradientStop { position: 0.2; color: "#64C0DC" }
                                        GradientStop { position: 0.5; color: "#1A75A8" }
                                        GradientStop { position: 0.8; color: "#063554" }
                                        GradientStop { position: 1.0; color: "#022338" }
                                    }
                                }

                                Text {
                                    text: "0m → -30m"
                                    font.pixelSize: 9
                                    color: root.textSecondaryColor
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle { width: 1; height: 25; color: root.borderColor }

                            // Point count
                            Text {
                                text: bathymetricPoints.length + " " + root.tr("veri noktası")
                                font.pixelSize: 10
                                color: root.textSecondaryColor
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Summary info - compact
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: "#38A169"
                    radius: 6

                    Row {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "✓"
                            font.pixelSize: 12
                            color: "white"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.tr("Harita görünümü hazır")
                            font.pixelSize: 11
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
        console.log("- Obstacles:", JSON.stringify(obstacles))
    }

    // ==================== OBSTACLE HELPER FUNCTIONS ====================
    function addObstacle(type) {
        var newId = "E" + (obstacles.length + 1)
        var defaultPoints = []

        // Varsayılan koordinatları hesapla (kazı alanı merkezinde)
        var centerX = 0, centerY = 0
        if (cornerPoints.length > 0) {
            for (var i = 0; i < cornerPoints.length; i++) {
                centerX += cornerPoints[i].x
                centerY += cornerPoints[i].y
            }
            centerX /= cornerPoints.length
            centerY /= cornerPoints.length
        }

        if (type === "point") {
            // Tek nokta için
            defaultPoints = [{x: centerX, y: centerY, label: newId}]
        } else {
            // Alan için 4 köşe noktası (10m x 10m varsayılan)
            var size = 5  // Yarı kenar uzunluğu
            defaultPoints = [
                {x: centerX - size, y: centerY - size, label: newId + "-1"},
                {x: centerX + size, y: centerY - size, label: newId + "-2"},
                {x: centerX + size, y: centerY + size, label: newId + "-3"},
                {x: centerX - size, y: centerY + size, label: newId + "-4"}
            ]
        }

        var newObstacle = {
            id: newId,
            type: type,  // "point" or "area"
            depth: 0.0,
            points: defaultPoints
        }
        var list = obstacles.slice()
        list.push(newObstacle)
        obstacles = list
        selectedObstacleIndex = obstacles.length - 1
        selectedCornerIndex = 0
    }

    function removeObstacle(index) {
        if (index >= 0 && index < obstacles.length) {
            var list = obstacles.slice()
            list.splice(index, 1)
            // Re-number obstacles and their corner labels
            for (var i = 0; i < list.length; i++) {
                var newId = "E" + (i + 1)
                list[i].id = newId
                // Update point labels
                for (var j = 0; j < list[i].points.length; j++) {
                    if (list[i].type === "point") {
                        list[i].points[j].label = newId
                    } else {
                        list[i].points[j].label = newId + "-" + (j + 1)
                    }
                }
            }
            obstacles = list
            if (selectedObstacleIndex >= obstacles.length) {
                selectedObstacleIndex = obstacles.length - 1
            }
            selectedCornerIndex = 0
        }
    }

    function updateObstacle(index, field, value) {
        if (index >= 0 && index < obstacles.length) {
            var list = obstacles.slice()
            list[index][field] = value
            obstacles = list
        }
    }

    function updateObstacleCorner(obstacleIndex, cornerIndex, x, y) {
        if (obstacleIndex >= 0 && obstacleIndex < obstacles.length) {
            var obs = obstacles[obstacleIndex]
            if (cornerIndex >= 0 && cornerIndex < obs.points.length) {
                var list = obstacles.slice()
                list[obstacleIndex].points[cornerIndex].x = x
                list[obstacleIndex].points[cornerIndex].y = y
                obstacles = list
            }
        }
    }

    function addPointToObstacle(index, x, y) {
        if (index >= 0 && index < obstacles.length) {
            var list = obstacles.slice()
            var pointCount = list[index].points.length
            var label = list[index].type === "point" ? list[index].id : list[index].id + "-" + (pointCount + 1)
            list[index].points.push({x: x, y: y, label: label})
            obstacles = list
        }
    }

    // Örnek engel verisi oluştur
    function generateSampleObstacles() {
        if (cornerPoints.length < 3) return

        // Köşe noktalarından merkez ve boyut hesapla
        var minX = Infinity, maxX = -Infinity
        var minY = Infinity, maxY = -Infinity
        for (var i = 0; i < cornerPoints.length; i++) {
            if (cornerPoints[i].x < minX) minX = cornerPoints[i].x
            if (cornerPoints[i].x > maxX) maxX = cornerPoints[i].x
            if (cornerPoints[i].y < minY) minY = cornerPoints[i].y
            if (cornerPoints[i].y > maxY) maxY = cornerPoints[i].y
        }

        var centerX = (minX + maxX) / 2
        var centerY = (minY + maxY) / 2
        var rangeX = (maxX - minX) * 0.3
        var rangeY = (maxY - minY) * 0.3

        var newObstacles = []

        // Alan engeli (dikdörtgen benzeri - 4 köşe noktalı)
        var areaOffsetX = (Math.random() - 0.5) * rangeX * 0.5
        var areaOffsetY = (Math.random() - 0.5) * rangeY * 0.5
        var areaSize = Math.min(rangeX, rangeY) * 0.4
        newObstacles.push({
            id: "E1",
            type: "area",
            depth: -(Math.random() * 8 + 3).toFixed(1) * 1,  // -3 ile -11 arası
            points: [
                {x: centerX + areaOffsetX - areaSize/2, y: centerY + areaOffsetY - areaSize/2, label: "E1-1"},
                {x: centerX + areaOffsetX + areaSize/2, y: centerY + areaOffsetY - areaSize/2, label: "E1-2"},
                {x: centerX + areaOffsetX + areaSize/2, y: centerY + areaOffsetY + areaSize/2, label: "E1-3"},
                {x: centerX + areaOffsetX - areaSize/2, y: centerY + areaOffsetY + areaSize/2, label: "E1-4"}
            ]
        })

        // Nokta engeli
        var pointOffsetX = (Math.random() - 0.3) * rangeX
        var pointOffsetY = (Math.random() - 0.3) * rangeY
        newObstacles.push({
            id: "E2",
            type: "point",
            depth: -(Math.random() * 6 + 2).toFixed(1) * 1,  // -2 ile -8 arası
            points: [
                {x: centerX + pointOffsetX, y: centerY + pointOffsetY, label: "E2"}
            ]
        })

        obstacles = newObstacles
        selectedObstacleIndex = 0
        selectedCornerIndex = 0
    }

    // ==================== STEP 6: OBSTACLE INPUT ====================
    Component {
        id: step6ObstacleInput

        Rectangle {
            id: obstacleInputRoot
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 15

                // ========== LEFT: Obstacle List ==========
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.fillHeight: true
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        // Header with title and buttons
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: root.tr("Engeller")
                                font.pixelSize: 16
                                font.bold: true
                                color: root.textColor
                            }

                            Item { Layout.fillWidth: true }

                            // Add Point button
                            Button {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 32

                                background: Rectangle {
                                    radius: 6
                                    color: parent.pressed ? Qt.darker("#FF9800", 1.2) : "#FF9800"
                                }

                                contentItem: Text {
                                    text: "●"
                                    font.pixelSize: 14
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                ToolTip.visible: hovered
                                ToolTip.text: root.tr("Nokta Engel Ekle")
                                ToolTip.delay: 300

                                onClicked: root.addObstacle("point")
                            }

                            // Add Area button
                            Button {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 32

                                background: Rectangle {
                                    radius: 6
                                    color: parent.pressed ? Qt.darker("#E91E63", 1.2) : "#E91E63"
                                }

                                contentItem: Text {
                                    text: "◆"
                                    font.pixelSize: 14
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                ToolTip.visible: hovered
                                ToolTip.text: root.tr("Alan Engel Ekle (4 Köşe)")
                                ToolTip.delay: 300

                                onClicked: root.addObstacle("area")
                            }

                            // Sample data button
                            Button {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 32

                                background: Rectangle {
                                    radius: 6
                                    color: parent.pressed ? Qt.darker("#9C27B0", 1.2) : "#9C27B0"
                                }

                                contentItem: Text {
                                    text: "⚡"
                                    font.pixelSize: 14
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                ToolTip.visible: hovered
                                ToolTip.text: root.tr("Örnek Veri Oluştur")
                                ToolTip.delay: 300

                                onClicked: root.generateSampleObstacles()
                            }
                        }

                        // Obstacle count badge
                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.05)

                            Text {
                                anchors.centerIn: parent
                                text: obstacles.length + " " + root.tr("engel tanımlı")
                                font.pixelSize: 12
                                color: root.textSecondaryColor
                            }
                        }

                        // Obstacle list
                        ScrollView {
                            id: obstacleListScroll
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            Column {
                                width: obstacleListScroll.width - 5
                                spacing: 6

                                Repeater {
                                    model: obstacles

                                    Rectangle {
                                        width: obstacleListScroll.width - 10
                                        height: 56
                                        radius: 8
                                        color: index === selectedObstacleIndex ?
                                               Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.25) :
                                               Qt.rgba(1, 1, 1, 0.05)
                                        border.width: index === selectedObstacleIndex ? 2 : 1
                                        border.color: index === selectedObstacleIndex ? root.primaryColor : Qt.rgba(1,1,1,0.1)

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                selectedObstacleIndex = index
                                                selectedCornerIndex = 0
                                            }
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8

                                            // Type icon
                                            Rectangle {
                                                width: 36
                                                height: 36
                                                radius: 18
                                                color: modelData.type === "point" ? "#FF9800" : "#E91E63"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.type === "point" ? "●" : "◆"
                                                    font.pixelSize: 16
                                                    color: "white"
                                                }
                                            }

                                            // Info
                                            Column {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    text: modelData.id + " - " + (modelData.type === "point" ? root.tr("Nokta") : root.tr("Alan"))
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: root.textColor
                                                }

                                                Text {
                                                    text: root.tr("Derinlik") + ": " + modelData.depth.toFixed(1) + "m | " +
                                                          modelData.points.length + " " + root.tr("köşe")
                                                    font.pixelSize: 11
                                                    color: root.textSecondaryColor
                                                }
                                            }

                                            // Delete button
                                            Button {
                                                width: 28
                                                height: 28

                                                background: Rectangle {
                                                    radius: 14
                                                    color: parent.pressed ? Qt.rgba(1, 0, 0, 0.3) : Qt.rgba(1, 0, 0, 0.15)
                                                }

                                                contentItem: Text {
                                                    text: "✕"
                                                    font.pixelSize: 14
                                                    color: "#f56565"
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                onClicked: root.removeObstacle(index)
                                            }
                                        }
                                    }
                                }

                                // Empty state
                                Rectangle {
                                    width: obstacleListScroll.width - 10
                                    height: 100
                                    radius: 8
                                    color: Qt.rgba(1, 1, 1, 0.03)
                                    visible: obstacles.length === 0

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: "⚓"
                                            font.pixelSize: 32
                                            color: root.textSecondaryColor
                                            opacity: 0.5
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: root.tr("Henüz engel yok")
                                            font.pixelSize: 12
                                            color: root.textSecondaryColor
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: root.tr("Yukarıdaki butonlarla ekleyin")
                                            font.pixelSize: 11
                                            color: root.textSecondaryColor
                                            opacity: 0.7
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ========== RIGHT: Obstacle Editor ==========
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12
                        visible: root.currentObstacle !== null

                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                width: 44
                                height: 44
                                radius: 22
                                color: root.currentObstacle && root.currentObstacle.type === "point" ? "#FF9800" : "#E91E63"

                                Text {
                                    anchors.centerIn: parent
                                    text: root.currentObstacle && root.currentObstacle.type === "point" ? "●" : "◆"
                                    font.pixelSize: 20
                                    color: "white"
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: root.currentObstacle ? root.currentObstacle.id + " " + root.tr("Düzenleme") : ""
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: root.textColor
                                }

                                Text {
                                    text: root.currentObstacle ?
                                          (root.currentObstacle.type === "point" ? root.tr("Nokta Engel") : root.tr("Alan Engel (4 Köşe)")) : ""
                                    font.pixelSize: 12
                                    color: root.textSecondaryColor
                                }
                            }
                        }

                        // Separator
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: root.borderColor
                        }

                        // Depth input section
                        Rectangle {
                            Layout.fillWidth: true
                            height: 70
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.05)

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 15

                                Column {
                                    spacing: 4

                                    Text {
                                        text: root.tr("Derinlik")
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#FF9800"
                                    }

                                    Text {
                                        text: root.tr("Metre cinsinden")
                                        font.pixelSize: 10
                                        color: root.textSecondaryColor
                                    }
                                }

                                TextField {
                                    id: depthInputField
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 40
                                    placeholderText: "-5.0"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                                    text: root.currentObstacle ? root.currentObstacle.depth.toString() : ""

                                    background: Rectangle {
                                        color: root.inputBgColor
                                        radius: 6
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? "#FF9800" : root.inputBorderColor
                                    }

                                    onTextChanged: {
                                        if (activeFocus && selectedObstacleIndex >= 0) {
                                            var val = parseFloat(text)
                                            if (!isNaN(val)) {
                                                root.updateObstacle(selectedObstacleIndex, "depth", val)
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: "m"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: root.textSecondaryColor
                                }

                                Item { Layout.fillWidth: true }
                            }
                        }

                        // Coordinates section header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: root.tr("Köşe Koordinatları")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: root.currentObstacle ? root.currentObstacle.points.length + " " + root.tr("köşe") : ""
                                font.pixelSize: 12
                                color: root.textSecondaryColor
                            }
                        }

                        // Corner coordinates grid
                        ScrollView {
                            id: cornerScrollView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            GridLayout {
                                width: cornerScrollView.width - 10
                                columns: 2
                                columnSpacing: 10
                                rowSpacing: 10

                                Repeater {
                                    model: root.currentObstacle ? root.currentObstacle.points : []

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 90
                                        radius: 8
                                        color: index === selectedCornerIndex ?
                                               Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.2) :
                                               Qt.rgba(1, 1, 1, 0.05)
                                        border.width: index === selectedCornerIndex ? 2 : 1
                                        border.color: index === selectedCornerIndex ? root.primaryColor :
                                                     Qt.rgba(1, 1, 1, 0.1)

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: selectedCornerIndex = index
                                        }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 6

                                            // Corner label
                                            RowLayout {
                                                Layout.fillWidth: true

                                                Rectangle {
                                                    width: 50
                                                    height: 22
                                                    radius: 4
                                                    color: root.currentObstacle && root.currentObstacle.type === "point" ? "#FF9800" : "#E91E63"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.label || ""
                                                        font.pixelSize: 11
                                                        font.bold: true
                                                        color: "white"
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }
                                            }

                                            // X coordinate
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 6

                                                Text {
                                                    text: "X:"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                    color: root.textSecondaryColor
                                                    Layout.preferredWidth: 20
                                                }

                                                TextField {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 28
                                                    font.pixelSize: 11
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                    text: modelData.x.toFixed(2)

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: parent.activeFocus ? 2 : 1
                                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text)
                                                        if (!isNaN(val)) {
                                                            root.updateObstacleCorner(selectedObstacleIndex, index, val, modelData.y)
                                                        }
                                                    }
                                                }
                                            }

                                            // Y coordinate
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 6

                                                Text {
                                                    text: "Y:"
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                    color: root.textSecondaryColor
                                                    Layout.preferredWidth: 20
                                                }

                                                TextField {
                                                    Layout.fillWidth: true
                                                    Layout.preferredHeight: 28
                                                    font.pixelSize: 11
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignRight
                                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                                    text: modelData.y.toFixed(2)

                                                    background: Rectangle {
                                                        color: root.inputBgColor
                                                        radius: 4
                                                        border.width: parent.activeFocus ? 2 : 1
                                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                                    }

                                                    onEditingFinished: {
                                                        var val = parseFloat(text)
                                                        if (!isNaN(val)) {
                                                            root.updateObstacleCorner(selectedObstacleIndex, index, modelData.x, val)
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

                    // Empty state when no obstacle selected
                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        visible: root.currentObstacle === null

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "⚓"
                            font.pixelSize: 48
                            color: root.textSecondaryColor
                            opacity: 0.4
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tr("Düzenlemek için engel seçin")
                            font.pixelSize: 14
                            color: root.textSecondaryColor
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.tr("veya sol taraftan yeni engel ekleyin")
                            font.pixelSize: 12
                            color: root.textSecondaryColor
                            opacity: 0.7
                        }
                    }
                }
            }
        }
    }

    // ==================== STEP 7: OBSTACLE PREVIEW ====================
    Component {
        id: step7ObstaclePreview

        Rectangle {
            id: obstaclePreviewRoot
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: "#1a1a2e"
                radius: 12
                border.width: 2
                border.color: "#1A75A8"
                clip: true

                // Map header
                Rectangle {
                    id: previewMapHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 50
                    color: "#1A75A8"
                    radius: 10

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 10
                        color: parent.color
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15

                        Text {
                            text: root.tr("Engel Önizleme - Kazı Alanı Üzerinde")
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                        }

                        Item { Layout.fillWidth: true }

                        // Legend
                        Row {
                            spacing: 15

                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#FF9800"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: root.tr("Nokta")
                                    font.pixelSize: 12
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                spacing: 5
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 3
                                    color: "#E91E63"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: root.tr("Alan")
                                    font.pixelSize: 12
                                    color: "white"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            // Obstacle count
                            Rectangle {
                                width: obstacleCountText.width + 20
                                height: 28
                                radius: 14
                                color: Qt.rgba(1, 1, 1, 0.2)

                                Text {
                                    id: obstacleCountText
                                    anchors.centerIn: parent
                                    text: obstacles.length + " " + root.tr("engel")
                                    font.pixelSize: 12
                                    color: "white"
                                }
                            }
                        }
                    }
                }

                // Canvas for map preview
                Canvas {
                    id: obstaclePreviewCanvas
                    anchors.top: previewMapHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 20

                    onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()

                            ctx.fillStyle = "#1a1a2e"
                            ctx.fillRect(0, 0, width, height)

                            if (cornerPoints.length < 3) {
                                ctx.fillStyle = "rgba(255, 255, 255, 0.3)"
                                ctx.font = "14px sans-serif"
                                ctx.textAlign = "center"
                                ctx.fillText(root.tr("Köşe noktaları tanımlanmadı"), width/2, height/2)
                                return
                            }

                            var minX = Infinity, maxX = -Infinity
                            var minY = Infinity, maxY = -Infinity

                            for (var i = 0; i < cornerPoints.length; i++) {
                                if (cornerPoints[i].x < minX) minX = cornerPoints[i].x
                                if (cornerPoints[i].x > maxX) maxX = cornerPoints[i].x
                                if (cornerPoints[i].y < minY) minY = cornerPoints[i].y
                                if (cornerPoints[i].y > maxY) maxY = cornerPoints[i].y
                            }

                            var dataWidth = maxX - minX || 100
                            var dataHeight = maxY - minY || 100
                            var padding = 30
                            var scale = Math.min((width - 2 * padding) / dataWidth,
                                                (height - 2 * padding) / dataHeight)

                            var centerDataX = (minX + maxX) / 2
                            var centerDataY = (minY + maxY) / 2

                            function tx(x) { return width / 2 + (x - centerDataX) * scale }
                            function ty(y) { return height / 2 - (y - centerDataY) * scale }

                            // Draw grid
                            ctx.strokeStyle = "rgba(255, 255, 255, 0.1)"
                            ctx.lineWidth = 1
                            var gridSize = 40
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

                            // Draw polygon
                            ctx.strokeStyle = "#319795"
                            ctx.lineWidth = 3
                            ctx.beginPath()
                            ctx.moveTo(tx(cornerPoints[0].x), ty(cornerPoints[0].y))
                            for (var j = 1; j < cornerPoints.length; j++) {
                                ctx.lineTo(tx(cornerPoints[j].x), ty(cornerPoints[j].y))
                            }
                            ctx.closePath()
                            ctx.stroke()
                            ctx.fillStyle = "rgba(49, 151, 149, 0.2)"
                            ctx.fill()

                            // Draw corner labels
                            ctx.fillStyle = "#319795"
                            ctx.font = "bold 12px sans-serif"
                            ctx.textAlign = "center"
                            for (var c = 0; c < cornerPoints.length; c++) {
                                var cpx = tx(cornerPoints[c].x)
                                var cpy = ty(cornerPoints[c].y)
                                ctx.beginPath()
                                ctx.arc(cpx, cpy, 5, 0, 2 * Math.PI)
                                ctx.fill()
                                ctx.fillStyle = "white"
                                ctx.fillText(cornerPoints[c].label, cpx, cpy - 10)
                                ctx.fillStyle = "#319795"
                            }

                            // Draw obstacles
                            for (var k = 0; k < obstacles.length; k++) {
                                var obs = obstacles[k]
                                if (!obs) continue
                                var isSelected = k === selectedObstacleIndex

                                if (obs.type === "point" && obs.points && obs.points.length > 0) {
                                    var px = tx(obs.points[0].x)
                                    var py = ty(obs.points[0].y)

                                    // Glow effect
                                    if (isSelected) {
                                        var gradient = ctx.createRadialGradient(px, py, 0, px, py, 25)
                                        gradient.addColorStop(0, "rgba(255, 152, 0, 0.5)")
                                        gradient.addColorStop(1, "transparent")
                                        ctx.fillStyle = gradient
                                        ctx.beginPath()
                                        ctx.arc(px, py, 25, 0, 2 * Math.PI)
                                        ctx.fill()
                                    }

                                    ctx.fillStyle = isSelected ? "#FF9800" : "rgba(255, 152, 0, 0.7)"
                                    ctx.beginPath()
                                    ctx.arc(px, py, isSelected ? 14 : 10, 0, 2 * Math.PI)
                                    ctx.fill()

                                    ctx.strokeStyle = "white"
                                    ctx.lineWidth = 2
                                    ctx.stroke()

                                    // Label
                                    ctx.fillStyle = "white"
                                    ctx.font = "bold 11px sans-serif"
                                    ctx.textAlign = "center"
                                    ctx.fillText(obs.id, px, py + 4)
                                    ctx.fillText(obs.depth.toFixed(1) + "m", px, py + 28)

                                } else if (obs.type === "area" && obs.points && obs.points.length > 0) {
                                    ctx.strokeStyle = isSelected ? "#E91E63" : "rgba(233, 30, 99, 0.7)"
                                    ctx.fillStyle = isSelected ? "rgba(233, 30, 99, 0.35)" : "rgba(233, 30, 99, 0.2)"
                                    ctx.lineWidth = isSelected ? 3 : 2

                                    ctx.beginPath()
                                    ctx.moveTo(tx(obs.points[0].x), ty(obs.points[0].y))
                                    for (var m = 1; m < obs.points.length; m++) {
                                        ctx.lineTo(tx(obs.points[m].x), ty(obs.points[m].y))
                                    }
                                    if (obs.points.length > 2) ctx.closePath()
                                    ctx.stroke()
                                    if (obs.points.length > 2) ctx.fill()

                                    // Corner points with labels
                                    for (var n = 0; n < obs.points.length; n++) {
                                        var cpx = tx(obs.points[n].x)
                                        var cpy = ty(obs.points[n].y)

                                        // Draw corner point
                                        ctx.fillStyle = isSelected ? "#E91E63" : "rgba(233, 30, 99, 0.8)"
                                        ctx.beginPath()
                                        ctx.arc(cpx, cpy, isSelected ? 7 : 5, 0, 2 * Math.PI)
                                        ctx.fill()

                                        // Draw corner label (E1-1, E1-2, etc.)
                                        if (obs.points[n].label) {
                                            ctx.fillStyle = "white"
                                            ctx.font = "bold 9px sans-serif"
                                            ctx.textAlign = "center"
                                            ctx.fillText(obs.points[n].label, cpx, cpy - 10)
                                        }
                                    }

                                    // Label at center
                                    if (obs.points.length > 0) {
                                        var sumX = 0, sumY = 0
                                        for (var p = 0; p < obs.points.length; p++) {
                                            sumX += obs.points[p].x
                                            sumY += obs.points[p].y
                                        }
                                        var labelX = tx(sumX / obs.points.length)
                                        var labelY = ty(sumY / obs.points.length)

                                        ctx.fillStyle = "rgba(0, 0, 0, 0.7)"
                                        ctx.fillRect(labelX - 25, labelY - 10, 50, 28)
                                        ctx.fillStyle = "white"
                                        ctx.font = "bold 11px sans-serif"
                                        ctx.textAlign = "center"
                                        ctx.fillText(obs.id, labelX, labelY + 2)
                                        ctx.font = "10px sans-serif"
                                        ctx.fillText(obs.depth.toFixed(1) + "m", labelX, labelY + 14)
                                    }
                                }
                            }
                        }

                    Connections {
                        target: root
                        function onCornerPointsChanged() { obstaclePreviewCanvas.requestPaint() }
                        function onObstaclesChanged() { obstaclePreviewCanvas.requestPaint() }
                        function onSelectedObstacleIndexChanged() { obstaclePreviewCanvas.requestPaint() }
                    }

                    Component.onCompleted: requestPaint()

                    // Click to select obstacle
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // Find which obstacle was clicked
                            if (cornerPoints.length < 3) return

                            var minX = Infinity, maxX = -Infinity
                            var minY = Infinity, maxY = -Infinity

                            for (var i = 0; i < cornerPoints.length; i++) {
                                if (cornerPoints[i].x < minX) minX = cornerPoints[i].x
                                if (cornerPoints[i].x > maxX) maxX = cornerPoints[i].x
                                if (cornerPoints[i].y < minY) minY = cornerPoints[i].y
                                if (cornerPoints[i].y > maxY) maxY = cornerPoints[i].y
                            }

                            var dataWidth = maxX - minX || 100
                            var dataHeight = maxY - minY || 100
                            var padding = 30
                            var scale = Math.min((parent.width - 2 * padding) / dataWidth,
                                                (parent.height - 2 * padding) / dataHeight)

                            var centerDataX = (minX + maxX) / 2
                            var centerDataY = (minY + maxY) / 2

                            function tx(x) { return parent.width / 2 + (x - centerDataX) * scale }
                            function ty(y) { return parent.height / 2 - (y - centerDataY) * scale }

                            // Check each obstacle
                            for (var k = 0; k < obstacles.length; k++) {
                                var obs = obstacles[k]
                                if (!obs || !obs.points || obs.points.length === 0) continue

                                if (obs.type === "point") {
                                    var px = tx(obs.points[0].x)
                                    var py = ty(obs.points[0].y)
                                    var dist = Math.sqrt(Math.pow(mouse.x - px, 2) + Math.pow(mouse.y - py, 2))
                                    if (dist < 20) {
                                        selectedObstacleIndex = k
                                        return
                                    }
                                } else if (obs.type === "area" && obs.points.length >= 3) {
                                    // Check if click is inside polygon
                                    var sumX = 0, sumY = 0
                                    for (var p = 0; p < obs.points.length; p++) {
                                        sumX += obs.points[p].x
                                        sumY += obs.points[p].y
                                    }
                                    var cx = tx(sumX / obs.points.length)
                                    var cy = ty(sumY / obs.points.length)
                                    var distToCenter = Math.sqrt(Math.pow(mouse.x - cx, 2) + Math.pow(mouse.y - cy, 2))
                                    if (distToCenter < 40) {
                                        selectedObstacleIndex = k
                                        return
                                    }
                                }
                            }
                        }
                    }
                }

                // Info panel at bottom
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 15
                    height: 60
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.5)
                    visible: root.currentObstacle !== null

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 20

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: root.currentObstacle && root.currentObstacle.type === "point" ? "#FF9800" : "#E91E63"

                            Text {
                                anchors.centerIn: parent
                                text: root.currentObstacle && root.currentObstacle.type === "point" ? "●" : "◆"
                                font.pixelSize: 18
                                color: "white"
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: root.currentObstacle ? root.currentObstacle.id : ""
                                font.pixelSize: 16
                                font.bold: true
                                color: "white"
                            }

                            Text {
                                text: root.currentObstacle ?
                                      (root.currentObstacle.type === "point" ? root.tr("Nokta Engel") : root.tr("Alan Engel")) +
                                      " | " + root.tr("Derinlik") + ": " + root.currentObstacle.depth.toFixed(1) + "m" +
                                      " | " + root.currentObstacle.points.length + " " + root.tr("köşe") : ""
                                font.pixelSize: 12
                                color: Qt.rgba(1, 1, 1, 0.7)
                            }
                        }

                        Text {
                            text: root.tr("Tıklayarak engel seçin")
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.5)
                        }
                    }
                }

                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    visible: obstacles.length === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "⚓"
                        font.pixelSize: 64
                        color: "white"
                        opacity: 0.3
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.tr("Henüz engel tanımlanmadı")
                        font.pixelSize: 16
                        color: "white"
                        opacity: 0.6
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.tr("Önceki adımdan engel ekleyin")
                        font.pixelSize: 13
                        color: "white"
                        opacity: 0.4
                    }
                }
            }
        }
    }
}
