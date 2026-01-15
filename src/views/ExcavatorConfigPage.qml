import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ExcavatorConfigPage - Ekskavatör Ayarları Sayfası (2 Sekmeli Wizard)
 *
 * Sekme 1: Ekskavatör Seçimi ve Ayarları
 * - Kayıtlı ekskavatörlerden seçim
 * - Yeni ekskavatör bilgileri girişi
 *
 * Sekme 2: Kova Ayarları
 * - Kova boyutları (boy, genişlik, derinlik)
 * - Kayıtlı kovalardan seçim
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#1a1a2e"

    signal back()
    signal configSaved()

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

    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

    // Theme colors
    property color primaryColor: (themeManager && themeManager.primaryColor) ? themeManager.primaryColor : "#319795"
    property color surfaceColor: (themeManager && themeManager.surfaceColor) ? themeManager.surfaceColor : "#ffffff"
    property color backgroundColor: (themeManager && themeManager.backgroundColor) ? themeManager.backgroundColor : "#1a1a2e"
    property color textColor: "white"
    property color textSecondaryColor: "#a0aec0"
    property color borderColor: Qt.rgba(1, 1, 1, 0.2)
    property color cardColor: Qt.rgba(1, 1, 1, 0.05)
    property color inputBgColor: Qt.rgba(1, 1, 1, 0.1)
    property color inputBorderColor: Qt.rgba(1, 1, 1, 0.3)
    property color filledBorderColor: "#319795"
    property color infoColor: "#4299e1"

    // ==================== WIZARD STATE ====================
    property int currentStep: 0  // 0: Ekskavatör, 1: Kova

    // ==================== EXCAVATOR DATA ====================
    property int selectedPresetIndex: -1  // -1 means "Yeni Ekskavatör"

    // ==================== BUCKET DATA ====================
    property var savedBuckets: []  // [{name: "Kova 1", length: 1.2, width: 1.8, depth: 0.9}, ...]
    property int selectedBucketIndex: -1  // -1 means "Yeni Kova"
    property real bucketLength: 0  // Boy (metre)
    property real bucketWidth: 0   // Genişlik (metre)
    property real bucketDepth: 0   // Derinlik (metre)
    property string bucketName: ""

    // Step titles for progress bar
    property var stepTitles: [
        tr("Ekskavatör"),
        tr("Kova")
    ]

    // Header
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

                onClicked: root.back()
            }

            Text {
                Layout.fillWidth: true
                text: root.tr("Ekskavatör Ayarları")
                font.pixelSize: app ? app.mediumFontSize : 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: app ? app.buttonHeight : 40 }
        }
    }

    // Progress Indicator
    Rectangle {
        id: progressBar
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
        color: root.cardColor

        RowLayout {
            anchors.centerIn: parent
            spacing: 0

            Repeater {
                model: stepTitles.length

                RowLayout {
                    spacing: 0

                    // Step circle
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: index < currentStep ? root.primaryColor :
                               (index === currentStep ? root.primaryColor : Qt.rgba(1, 1, 1, 0.1))
                        border.width: 2
                        border.color: index <= currentStep ? root.primaryColor : Qt.rgba(1, 1, 1, 0.3)

                        Text {
                            anchors.centerIn: parent
                            text: index < currentStep ? "✓" : (index + 1).toString()
                            font.pixelSize: 14
                            font.bold: true
                            color: index <= currentStep ? "white" : root.textSecondaryColor
                        }
                    }

                    // Step label
                    Column {
                        Layout.leftMargin: 8
                        Layout.rightMargin: index < stepTitles.length - 1 ? 0 : 0

                        Text {
                            text: stepTitles[index]
                            font.pixelSize: 12
                            font.bold: index === currentStep
                            color: index <= currentStep ? root.textColor : root.textSecondaryColor
                        }
                    }

                    // Connector line
                    Rectangle {
                        visible: index < stepTitles.length - 1
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 2
                        Layout.leftMargin: 12
                        Layout.rightMargin: 12
                        color: index < currentStep ? root.primaryColor : Qt.rgba(1, 1, 1, 0.2)
                    }
                }
            }
        }
    }

    // Content Area with Loader
    Item {
        id: contentArea
        anchors.top: progressBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.margins: app ? app.normalPadding : 16

        Loader {
            id: stepLoader
            anchors.fill: parent
            sourceComponent: currentStep === 0 ? step0ExcavatorSettings : step1BucketSettings
        }
    }

    // Footer with navigation buttons
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: app ? app.buttonHeight * 2 : 80
        color: root.cardColor

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

                onClicked: {
                    if (currentStep > 0) currentStep--
                }
            }

            Item { Layout.fillWidth: true }

            // Kaydet ve Bitir / Devam Et butonu
            Button {
                Layout.preferredWidth: currentStep === stepTitles.length - 1 ? 180 : 150
                Layout.preferredHeight: app ? app.buttonHeight : 50
                text: currentStep === stepTitles.length - 1 ?
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
                    if (currentStep < stepTitles.length - 1) {
                        currentStep++
                    } else {
                        saveConfiguration()
                        root.configSaved()
                    }
                }
            }
        }
    }

    // ==================== STEP 0: EXCAVATOR SETTINGS ====================
    Component {
        id: step0ExcavatorSettings

        Rectangle {
            color: "transparent"

            ScrollView {
                anchors.fill: parent
                contentWidth: parent.width
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    // Info text
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.2)
                        radius: 8

                        Text {
                            anchors.centerIn: parent
                            text: root.tr("Kayıtlı bir ekskavatör seçin veya yeni bilgileri girin")
                            font.pixelSize: 12
                            color: root.textSecondaryColor
                        }
                    }

                    // Excavator Preset Selection
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentCol.height + 24
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            id: contentCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 12
                            spacing: 12

                            Text {
                                text: root.tr("Ekskavatör Seçimi")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            ComboBox {
                                id: presetComboBox
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50

                                model: {
                                    var list = [root.tr("Yeni Ekskavatör")];
                                    if (configManager && configManager.excavatorPresets) {
                                        for (var i = 0; i < configManager.excavatorPresets.length; i++) {
                                            list.push(configManager.excavatorPresets[i].name);
                                        }
                                    }
                                    return list;
                                }

                                currentIndex: root.selectedPresetIndex + 1

                                onCurrentIndexChanged: {
                                    if (currentIndex === 0) {
                                        root.selectedPresetIndex = -1;
                                        if (configManager) {
                                            configManager.excavatorName = "";
                                            configManager.scanningDepth = 0.0;
                                            configManager.boomLength = 0.0;
                                            configManager.armLength = 0.0;
                                        }
                                    } else if (currentIndex > 0 && configManager) {
                                        var presetIndex = currentIndex - 1;
                                        root.selectedPresetIndex = presetIndex;
                                        configManager.loadExcavatorPreset(presetIndex);
                                    }
                                }

                                contentItem: Text {
                                    leftPadding: 12
                                    text: presetComboBox.displayText
                                    font.pixelSize: 14
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: root.inputBgColor
                                    radius: 8
                                    border.width: presetComboBox.activeFocus ? 2 : 1
                                    border.color: presetComboBox.activeFocus ? root.primaryColor : root.inputBorderColor
                                }

                                delegate: ItemDelegate {
                                    width: presetComboBox.width
                                    contentItem: Text {
                                        text: modelData
                                        color: "white"
                                        font.pixelSize: 14
                                    }
                                    highlighted: presetComboBox.highlightedIndex === index
                                    background: Rectangle {
                                        color: parent.highlighted ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.3) : root.inputBgColor
                                    }
                                }

                                popup: Popup {
                                    y: presetComboBox.height
                                    width: presetComboBox.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1

                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: presetComboBox.popup.visible ? presetComboBox.delegateModel : null
                                    }

                                    background: Rectangle {
                                        color: "#2d3748"
                                        border.color: root.borderColor
                                        radius: 8
                                    }
                                }
                            }
                        }
                    }

                    // Excavator Name
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: root.tr("Ekskavatör Adı")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                id: excavatorNameField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: root.tr("Örn: UDHB Burak")
                                font.pixelSize: 14
                                color: "white"
                                placeholderTextColor: root.textSecondaryColor

                                text: configManager ? configManager.excavatorName : ""

                                background: Rectangle {
                                    color: root.inputBgColor
                                    radius: 6
                                    border.width: parent.activeFocus ? 2 : 1
                                    border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                }

                                onTextChanged: {
                                    if (configManager && activeFocus) {
                                        configManager.excavatorName = text
                                    }
                                }
                            }
                        }
                    }

                    // Tarama Derinliği ve Ana Bom
                    Row {
                        Layout.fillWidth: true
                        spacing: 12

                        // Tarama Derinliği
                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 90
                            color: root.cardColor
                            radius: 12
                            border.width: 1
                            border.color: root.borderColor

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    text: root.tr("Tarama Derinliği (m)")
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: root.textColor
                                }

                                TextField {
                                    id: depthField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    placeholderText: "15.0"
                                    font.pixelSize: 14
                                    color: "white"
                                    placeholderTextColor: root.textSecondaryColor
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    enabled: root.selectedPresetIndex === -1

                                    text: configManager && configManager.scanningDepth > 0 ?
                                          configManager.scanningDepth.toFixed(1) : ""

                                    background: Rectangle {
                                        color: depthField.enabled ? root.inputBgColor : Qt.rgba(0.5, 0.5, 0.5, 0.2)
                                        radius: 6
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onTextChanged: {
                                        if (configManager && activeFocus) {
                                            var val = parseFloat(text)
                                            configManager.scanningDepth = !isNaN(val) ? val : 0
                                        }
                                    }
                                }
                            }
                        }

                        // Ana Bom
                        Rectangle {
                            width: (parent.width - 12) / 2
                            height: 90
                            color: root.cardColor
                            radius: 12
                            border.width: 1
                            border.color: root.borderColor

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 8

                                Text {
                                    text: root.tr("Ana Bom (m)")
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: root.textColor
                                }

                                TextField {
                                    id: boomField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    placeholderText: "12.0"
                                    font.pixelSize: 14
                                    color: "white"
                                    placeholderTextColor: root.textSecondaryColor
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    enabled: root.selectedPresetIndex === -1

                                    text: configManager && configManager.boomLength > 0 ?
                                          configManager.boomLength.toFixed(1) : ""

                                    background: Rectangle {
                                        color: boomField.enabled ? root.inputBgColor : Qt.rgba(0.5, 0.5, 0.5, 0.2)
                                        radius: 6
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onTextChanged: {
                                        if (configManager && activeFocus) {
                                            var val = parseFloat(text)
                                            configManager.boomLength = !isNaN(val) ? val : 0
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Arm Bom
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            Text {
                                text: root.tr("Arm Bom (m)")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                id: armField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "10.0"
                                font.pixelSize: 14
                                color: "white"
                                placeholderTextColor: root.textSecondaryColor
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                enabled: root.selectedPresetIndex === -1

                                text: configManager && configManager.armLength > 0 ?
                                      configManager.armLength.toFixed(1) : ""

                                background: Rectangle {
                                    color: armField.enabled ? root.inputBgColor : Qt.rgba(0.5, 0.5, 0.5, 0.2)
                                    radius: 6
                                    border.width: parent.activeFocus ? 2 : 1
                                    border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                }

                                onTextChanged: {
                                    if (configManager && activeFocus) {
                                        var val = parseFloat(text)
                                        configManager.armLength = !isNaN(val) ? val : 0
                                    }
                                }
                            }
                        }
                    }

                    // Kaydet butonu (Yeni ekskavatör için)
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 45
                        visible: root.selectedPresetIndex === -1
                        text: root.tr("Ekskavatörü Kaydet")
                        enabled: configManager && configManager.excavatorName.length > 0 &&
                                 configManager.scanningDepth > 0 &&
                                 configManager.boomLength > 0 &&
                                 configManager.armLength > 0

                        background: Rectangle {
                            radius: 8
                            color: parent.enabled ?
                                   (parent.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50") :
                                   Qt.rgba(0.5, 0.5, 0.5, 0.3)
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            font.bold: true
                            color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.5)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (configManager) {
                                configManager.saveCurrentAsPreset()
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 20 }
                }
            }
        }
    }

    // ==================== STEP 1: BUCKET SETTINGS ====================
    Component {
        id: step1BucketSettings

        Rectangle {
            color: "transparent"

            ScrollView {
                anchors.fill: parent
                clip: true
                contentWidth: availableWidth

                ColumnLayout {
                    width: parent.width
                    spacing: 10

                    // Top section - Bucket Image with dimension labels (smaller)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor

                        // Bucket Image
                        Image {
                            id: bucketImage
                            anchors.centerIn: parent
                            width: parent.width * 0.55
                            height: parent.height * 0.85
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:/ExcavatorUI_Qt3D/resources/images/bucket.png"
                            visible: status === Image.Ready
                        }

                        // Fallback placeholder
                        Text {
                            anchors.centerIn: parent
                            text: "🪣"
                            font.pixelSize: 60
                            opacity: 0.3
                            visible: bucketImage.status !== Image.Ready
                        }

                        // Boy (Height) label - Green, left side with vertical arrow
                        Item {
                            anchors.left: parent.left
                            anchors.leftMargin: 50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -10
                            width: 70
                            height: 80

                            // Vertical line
                            Rectangle {
                                id: boyLine
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter
                                width: 2
                                height: 60
                                color: "#4CAF50"
                            }

                            // Top arrow head
                            Canvas {
                                anchors.horizontalCenter: boyLine.horizontalCenter
                                anchors.bottom: boyLine.top
                                width: 10
                                height: 8
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.fillStyle = "#4CAF50"
                                    ctx.beginPath()
                                    ctx.moveTo(5, 0)
                                    ctx.lineTo(0, 8)
                                    ctx.lineTo(10, 8)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            // Bottom arrow head
                            Canvas {
                                anchors.horizontalCenter: boyLine.horizontalCenter
                                anchors.top: boyLine.bottom
                                width: 10
                                height: 8
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.fillStyle = "#4CAF50"
                                    ctx.beginPath()
                                    ctx.moveTo(5, 8)
                                    ctx.lineTo(0, 0)
                                    ctx.lineTo(10, 0)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            // Label
                            Column {
                                anchors.left: boyLine.right
                                anchors.leftMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 0

                                Text {
                                    text: root.bucketLength > 0 ? root.bucketLength.toFixed(0) + " mm" : "— mm"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#4CAF50"
                                }
                                Text {
                                    text: "(Boy)"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }

                        // Derinlik (Depth) label - Green, right side diagonal
                        Item {
                            anchors.right: parent.right
                            anchors.rightMargin: -5
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 5
                            width: 80
                            height: 55

                            // Diagonal line with arrows at both ends
                            Canvas {
                                id: derinlikCanvas
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: 40
                                height: 50
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.strokeStyle = "#4CAF50"
                                    ctx.fillStyle = "#4CAF50"
                                    ctx.lineWidth = 2

                                    // Diagonal line (from bottom-left to top-right)
                                    ctx.beginPath()
                                    ctx.moveTo(5, height - 10)
                                    ctx.lineTo(width - 5, 10)
                                    ctx.stroke()

                                    // Bottom-left arrow head
                                    ctx.beginPath()
                                    ctx.moveTo(0, height - 5)
                                    ctx.lineTo(10, height - 8)
                                    ctx.lineTo(8, height - 15)
                                    ctx.closePath()
                                    ctx.fill()

                                    // Top-right arrow head
                                    ctx.beginPath()
                                    ctx.moveTo(width, 5)
                                    ctx.lineTo(width - 10, 8)
                                    ctx.lineTo(width - 8, 15)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            // Label
                            Column {
                                anchors.left: derinlikCanvas.right
                                anchors.leftMargin: 2
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 0

                                Text {
                                    text: root.bucketDepth > 0 ? root.bucketDepth.toFixed(0) + " mm" : "— mm"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#4CAF50"
                                }
                                Text {
                                    text: "(Derinlik)"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }

                        // En (Width) label - Green, bottom center with horizontal arrow (same style as Boy)
                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -5
                            width: 160
                            height: 35

                            // Horizontal line
                            Rectangle {
                                id: enLine
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 2
                                width: 100
                                height: 2
                                color: "#4CAF50"
                            }

                            // Left arrow head
                            Canvas {
                                anchors.verticalCenter: enLine.verticalCenter
                                anchors.right: enLine.left
                                width: 8
                                height: 10
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.fillStyle = "#4CAF50"
                                    ctx.beginPath()
                                    ctx.moveTo(0, 5)
                                    ctx.lineTo(8, 0)
                                    ctx.lineTo(8, 10)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            // Right arrow head
                            Canvas {
                                anchors.verticalCenter: enLine.verticalCenter
                                anchors.left: enLine.right
                                width: 8
                                height: 10
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.fillStyle = "#4CAF50"
                                    ctx.beginPath()
                                    ctx.moveTo(8, 5)
                                    ctx.lineTo(0, 0)
                                    ctx.lineTo(0, 10)
                                    ctx.closePath()
                                    ctx.fill()
                                }
                            }

                            // Label (above line)
                            Column {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: enLine.top
                                anchors.bottomMargin: 2
                                spacing: 0

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: root.bucketWidth > 0 ? root.bucketWidth.toFixed(0) + " mm" : "— mm"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#4CAF50"
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "(En)"
                                    font.pixelSize: 9
                                    color: "#4CAF50"
                                }
                            }
                        }
                    }

                    // Kova Seçimi Card
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 85
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Text {
                                text: root.tr("Kova Seçimi")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            ComboBox {
                                id: bucketComboBox
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38

                                model: {
                                    var list = [root.tr("Yeni Kova")];
                                    for (var i = 0; i < root.savedBuckets.length; i++) {
                                        list.push(root.savedBuckets[i].name);
                                    }
                                    return list;
                                }

                                currentIndex: root.selectedBucketIndex + 1

                                onCurrentIndexChanged: {
                                    if (currentIndex === 0) {
                                        root.selectedBucketIndex = -1;
                                        root.bucketName = "";
                                        root.bucketLength = 0;
                                        root.bucketWidth = 0;
                                        root.bucketDepth = 0;
                                    } else if (currentIndex > 0) {
                                        var idx = currentIndex - 1;
                                        root.selectedBucketIndex = idx;
                                        var bucket = root.savedBuckets[idx];
                                        root.bucketName = bucket.name;
                                        root.bucketLength = bucket.length;
                                        root.bucketWidth = bucket.width;
                                        root.bucketDepth = bucket.depth;
                                    }
                                }

                                contentItem: Text {
                                    leftPadding: 12
                                    text: bucketComboBox.displayText
                                    font.pixelSize: 14
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    color: root.inputBgColor
                                    radius: 6
                                    border.width: bucketComboBox.activeFocus ? 2 : 1
                                    border.color: bucketComboBox.activeFocus ? root.primaryColor : root.inputBorderColor
                                }

                                delegate: ItemDelegate {
                                    width: bucketComboBox.width
                                    height: 36
                                    contentItem: Text {
                                        text: modelData
                                        color: "white"
                                        font.pixelSize: 14
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    highlighted: bucketComboBox.highlightedIndex === index
                                    background: Rectangle {
                                        color: parent.highlighted ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.3) : root.inputBgColor
                                    }
                                }

                                popup: Popup {
                                    y: bucketComboBox.height
                                    width: bucketComboBox.width
                                    implicitHeight: Math.min(contentItem.implicitHeight + 2, 200)
                                    padding: 1

                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: bucketComboBox.popup.visible ? bucketComboBox.delegateModel : null
                                        ScrollIndicator.vertical: ScrollIndicator {}
                                    }

                                    background: Rectangle {
                                        color: "#2d3748"
                                        border.color: root.borderColor
                                        radius: 6
                                    }
                                }
                            }
                        }
                    }

                    // Kova Adı Card (only for new bucket)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 85
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor
                        visible: root.selectedBucketIndex === -1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Text {
                                text: root.tr("Kova Adı")
                                font.pixelSize: 14
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 38
                                placeholderText: root.tr("Örn: Kova 1")
                                font.pixelSize: 14
                                color: "white"
                                placeholderTextColor: root.textSecondaryColor

                                text: root.bucketName

                                background: Rectangle {
                                    color: root.inputBgColor
                                    radius: 6
                                    border.width: parent.activeFocus ? 2 : 1
                                    border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                }

                                onTextChanged: {
                                    if (activeFocus) root.bucketName = text
                                }
                            }
                        }
                    }

                    // Dimension inputs row
                    Row {
                        Layout.fillWidth: true
                        spacing: 8

                        // En (Width)
                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 85
                            color: root.cardColor
                            radius: 12
                            border.width: 1
                            border.color: root.borderColor

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                Text {
                                    text: root.tr("En") + " (mm)"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: root.textColor
                                }

                                TextField {
                                    id: widthField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38
                                    placeholderText: "1200"
                                    font.pixelSize: 14
                                    color: "white"
                                    placeholderTextColor: root.textSecondaryColor
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    horizontalAlignment: Text.AlignHCenter
                                    enabled: root.selectedBucketIndex === -1

                                    text: root.bucketWidth > 0 ? root.bucketWidth.toFixed(0) : ""

                                    background: Rectangle {
                                        color: widthField.enabled ? root.inputBgColor : Qt.rgba(0.5, 0.5, 0.5, 0.2)
                                        radius: 6
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onTextChanged: {
                                        if (activeFocus && root.selectedBucketIndex === -1) {
                                            var val = parseInt(text)
                                            root.bucketWidth = !isNaN(val) ? val : 0
                                        }
                                    }
                                }
                            }
                        }

                        // Boy (Height)
                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 85
                            color: root.cardColor
                            radius: 12
                            border.width: 1
                            border.color: root.borderColor

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                Text {
                                    text: root.tr("Boy") + " (mm)"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: root.textColor
                                }

                                TextField {
                                    id: lengthField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38
                                    placeholderText: "900"
                                    font.pixelSize: 14
                                    color: "white"
                                    placeholderTextColor: root.textSecondaryColor
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    horizontalAlignment: Text.AlignHCenter
                                    enabled: root.selectedBucketIndex === -1

                                    text: root.bucketLength > 0 ? root.bucketLength.toFixed(0) : ""

                                    background: Rectangle {
                                        color: lengthField.enabled ? root.inputBgColor : Qt.rgba(0.5, 0.5, 0.5, 0.2)
                                        radius: 6
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onTextChanged: {
                                        if (activeFocus && root.selectedBucketIndex === -1) {
                                            var val = parseInt(text)
                                            root.bucketLength = !isNaN(val) ? val : 0
                                        }
                                    }
                                }
                            }
                        }

                        // Derinlik (Depth)
                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 85
                            color: root.cardColor
                            radius: 12
                            border.width: 1
                            border.color: root.borderColor

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                Text {
                                    text: root.tr("Derinlik") + " (mm)"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: root.textColor
                                }

                                TextField {
                                    id: depthBucketField
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 38
                                    placeholderText: "1100"
                                    font.pixelSize: 14
                                    color: "white"
                                    placeholderTextColor: root.textSecondaryColor
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    horizontalAlignment: Text.AlignHCenter
                                    enabled: root.selectedBucketIndex === -1

                                    text: root.bucketDepth > 0 ? root.bucketDepth.toFixed(0) : ""

                                    background: Rectangle {
                                        color: depthBucketField.enabled ? root.inputBgColor : Qt.rgba(0.5, 0.5, 0.5, 0.2)
                                        radius: 6
                                        border.width: parent.activeFocus ? 2 : 1
                                        border.color: parent.activeFocus ? root.primaryColor : root.inputBorderColor
                                    }

                                    onTextChanged: {
                                        if (activeFocus && root.selectedBucketIndex === -1) {
                                            var val = parseInt(text)
                                            root.bucketDepth = !isNaN(val) ? val : 0
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Save button (only for new bucket)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: root.cardColor
                        radius: 12
                        border.width: 1
                        border.color: root.borderColor
                        visible: root.selectedBucketIndex === -1

                        Button {
                            anchors.fill: parent
                            anchors.margins: 4
                            enabled: root.bucketName.length > 0 &&
                                     root.bucketWidth > 0 &&
                                     root.bucketLength > 0 &&
                                     root.bucketDepth > 0

                            background: Rectangle {
                                radius: 8
                                color: parent.enabled ?
                                       (parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor) :
                                       Qt.rgba(0.5, 0.5, 0.5, 0.3)
                            }

                            contentItem: Text {
                                text: root.tr("Kovayı Kaydet")
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                saveBucket()
                            }
                        }
                    }

                    // Status text for saved bucket
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        visible: root.selectedBucketIndex >= 0
                        text: "✓ " + root.bucketName + " kovası seçildi"
                        font.pixelSize: 12
                        color: "#4CAF50"
                    }

                    // Spacer at bottom
                    Item {
                        Layout.preferredHeight: 10
                    }
                }
            }
        }
    }

    // Save bucket to list
    function saveBucket() {
        var newBucket = {
            name: bucketName,
            length: bucketLength,
            width: bucketWidth,
            depth: bucketDepth
        }

        var buckets = savedBuckets.slice()
        buckets.push(newBucket)
        savedBuckets = buckets

        // Select the newly saved bucket
        selectedBucketIndex = savedBuckets.length - 1

        console.log("Bucket saved:", JSON.stringify(newBucket))
    }

    // Save all configuration
    function saveConfiguration() {
        // Save bucket to configManager if available
        if (configManager) {
            configManager.bucketWidth = bucketWidth
            // Additional bucket properties could be saved here
        }

        console.log("Configuration saved:")
        console.log("- Excavator:", configManager ? configManager.excavatorName : "N/A")
        console.log("- Bucket:", bucketName, bucketLength, "x", bucketWidth, "x", bucketDepth, "m")
    }
}
