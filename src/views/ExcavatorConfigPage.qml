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

            RowLayout {
                anchors.fill: parent
                spacing: 16

                // Left side - Input Panel
                Rectangle {
                    Layout.preferredWidth: parent.width * 0.35
                    Layout.fillHeight: true
                    color: root.cardColor
                    radius: 12
                    border.width: 1
                    border.color: root.borderColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // Title
                        Text {
                            text: root.tr("Kova Ölçüleri")
                            font.pixelSize: 18
                            font.bold: true
                            color: root.textColor
                        }

                        // Bucket Selection
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: root.tr("Kova Seçimi")
                                font.pixelSize: 12
                                color: root.textSecondaryColor
                            }

                            ComboBox {
                                id: bucketComboBox
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44

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
                                    color: "white"
                                    radius: 6
                                    border.width: 1
                                    border.color: "#e0e0e0"
                                }

                                delegate: ItemDelegate {
                                    width: bucketComboBox.width
                                    contentItem: Text {
                                        text: modelData
                                        color: "#333"
                                        font.pixelSize: 14
                                    }
                                    highlighted: bucketComboBox.highlightedIndex === index
                                    background: Rectangle {
                                        color: parent.highlighted ? "#e3f2fd" : "white"
                                    }
                                }

                                popup: Popup {
                                    y: bucketComboBox.height
                                    width: bucketComboBox.width
                                    implicitHeight: contentItem.implicitHeight
                                    padding: 1

                                    contentItem: ListView {
                                        clip: true
                                        implicitHeight: contentHeight
                                        model: bucketComboBox.popup.visible ? bucketComboBox.delegateModel : null
                                    }

                                    background: Rectangle {
                                        color: "white"
                                        border.color: "#e0e0e0"
                                        radius: 6
                                    }
                                }
                            }
                        }

                        // Kova Adı
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: root.tr("Kova Adı")
                                font.pixelSize: 12
                                color: root.textSecondaryColor
                            }

                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                placeholderText: root.tr("Örn: Kova 1")
                                font.pixelSize: 14
                                color: "#333"
                                placeholderTextColor: "#999"

                                text: root.bucketName

                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.width: 1
                                    border.color: parent.activeFocus ? root.primaryColor : "#e0e0e0"
                                }

                                onTextChanged: {
                                    if (activeFocus) root.bucketName = text
                                }
                            }
                        }

                        // En (Width)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: root.tr("En (Width)") + " [mm]"
                                font.pixelSize: 12
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                placeholderText: "1200"
                                font.pixelSize: 16
                                color: "#333"
                                placeholderTextColor: "#999"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                horizontalAlignment: Text.AlignLeft

                                text: root.bucketWidth > 0 ? Math.round(root.bucketWidth).toString() : ""

                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.width: 1
                                    border.color: parent.activeFocus ? root.primaryColor : "#e0e0e0"
                                }

                                onTextChanged: {
                                    if (activeFocus) {
                                        var val = parseInt(text)
                                        root.bucketWidth = !isNaN(val) ? val : 0
                                    }
                                }
                            }
                        }

                        // Boy (Height)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: root.tr("Boy (Height)") + " [mm]"
                                font.pixelSize: 12
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                placeholderText: "900"
                                font.pixelSize: 16
                                color: "#333"
                                placeholderTextColor: "#999"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                horizontalAlignment: Text.AlignLeft

                                text: root.bucketLength > 0 ? Math.round(root.bucketLength).toString() : ""

                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.width: 1
                                    border.color: parent.activeFocus ? root.primaryColor : "#e0e0e0"
                                }

                                onTextChanged: {
                                    if (activeFocus) {
                                        var val = parseInt(text)
                                        root.bucketLength = !isNaN(val) ? val : 0
                                    }
                                }
                            }
                        }

                        // Derinlik (Depth)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: root.tr("Derinlik (Depth)") + " [mm]"
                                font.pixelSize: 12
                                font.bold: true
                                color: root.textColor
                            }

                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                placeholderText: "1100"
                                font.pixelSize: 16
                                color: "#333"
                                placeholderTextColor: "#999"
                                inputMethodHints: Qt.ImhFormattedNumbersOnly
                                horizontalAlignment: Text.AlignLeft

                                text: root.bucketDepth > 0 ? Math.round(root.bucketDepth).toString() : ""

                                background: Rectangle {
                                    color: "white"
                                    radius: 6
                                    border.width: 1
                                    border.color: parent.activeFocus ? root.primaryColor : "#e0e0e0"
                                }

                                onTextChanged: {
                                    if (activeFocus) {
                                        var val = parseInt(text)
                                        root.bucketDepth = !isNaN(val) ? val : 0
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // UYGULA button
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            text: root.tr("UYGULA")
                            enabled: root.bucketName.length > 0 &&
                                     root.bucketLength > 0 &&
                                     root.bucketWidth > 0 &&
                                     root.bucketDepth > 0

                            background: Rectangle {
                                radius: 6
                                color: parent.enabled ?
                                       (parent.pressed ? Qt.darker("#1976D2", 1.2) : "#1976D2") :
                                       "#ccc"
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
                                saveBucket()
                            }
                        }
                    }
                }

                // Right side - Bucket Image with dimensions
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#e8e8e8"  // Light gray background like reference
                    radius: 12

                    Canvas {
                        id: bucketCanvas
                        anchors.fill: parent
                        anchors.margins: 20

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()

                            // Light background
                            ctx.fillStyle = "#e8e8e8"
                            ctx.fillRect(0, 0, width, height)

                            // Bucket dimensions for drawing
                            var bucketW = width * 0.55
                            var bucketH = height * 0.6
                            var bucketX = width * 0.35
                            var bucketY = height * 0.2

                            // 3D perspective offset
                            var depth3D = bucketW * 0.3

                            // Draw bucket - Blue color like Lehnhoff
                            var bucketColor = "#1565C0"
                            var bucketDark = "#0D47A1"
                            var bucketLight = "#1E88E5"

                            // Back panel (3D depth)
                            ctx.fillStyle = bucketDark
                            ctx.beginPath()
                            ctx.moveTo(bucketX + depth3D, bucketY - depth3D * 0.5)
                            ctx.lineTo(bucketX + bucketW + depth3D, bucketY - depth3D * 0.5)
                            ctx.lineTo(bucketX + bucketW, bucketY)
                            ctx.lineTo(bucketX, bucketY)
                            ctx.closePath()
                            ctx.fill()

                            // Right side panel (3D depth)
                            ctx.fillStyle = bucketDark
                            ctx.beginPath()
                            ctx.moveTo(bucketX + bucketW, bucketY)
                            ctx.lineTo(bucketX + bucketW + depth3D, bucketY - depth3D * 0.5)
                            ctx.lineTo(bucketX + bucketW + depth3D, bucketY + bucketH - depth3D * 0.3)
                            ctx.lineTo(bucketX + bucketW, bucketY + bucketH)
                            ctx.closePath()
                            ctx.fill()

                            // Main front panel
                            ctx.fillStyle = bucketColor
                            ctx.strokeStyle = bucketDark
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            ctx.moveTo(bucketX, bucketY)
                            ctx.lineTo(bucketX + bucketW, bucketY)
                            ctx.lineTo(bucketX + bucketW, bucketY + bucketH)
                            ctx.lineTo(bucketX, bucketY + bucketH)
                            ctx.closePath()
                            ctx.fill()
                            ctx.stroke()

                            // Inner cavity (darker)
                            ctx.fillStyle = "#0D47A1"
                            var innerMargin = bucketW * 0.08
                            ctx.beginPath()
                            ctx.moveTo(bucketX + innerMargin, bucketY + innerMargin)
                            ctx.lineTo(bucketX + bucketW - innerMargin, bucketY + innerMargin)
                            ctx.lineTo(bucketX + bucketW - innerMargin * 1.5, bucketY + bucketH - innerMargin)
                            ctx.lineTo(bucketX + innerMargin * 1.5, bucketY + bucketH - innerMargin)
                            ctx.closePath()
                            ctx.fill()

                            // Teeth at bottom
                            var teethCount = 5
                            var teethW = bucketW * 0.1
                            var teethH = bucketH * 0.15
                            var teethSpacing = (bucketW - teethW * teethCount) / (teethCount + 1)

                            ctx.fillStyle = "#90A4AE"  // Gray metallic teeth
                            ctx.strokeStyle = "#607D8B"
                            ctx.lineWidth = 1

                            for (var i = 0; i < teethCount; i++) {
                                var tx = bucketX + teethSpacing * (i + 1) + teethW * i
                                var ty = bucketY + bucketH

                                ctx.beginPath()
                                ctx.moveTo(tx, ty)
                                ctx.lineTo(tx + teethW * 0.3, ty + teethH)
                                ctx.lineTo(tx + teethW * 0.7, ty + teethH)
                                ctx.lineTo(tx + teethW, ty)
                                ctx.closePath()
                                ctx.fill()
                                ctx.stroke()
                            }

                            // Mounting bracket on top
                            ctx.fillStyle = "#1565C0"
                            ctx.strokeStyle = bucketDark
                            var bracketW = bucketW * 0.25
                            var bracketH = bucketH * 0.2
                            var bracketX = bucketX + bucketW * 0.4
                            var bracketY = bucketY - bracketH

                            ctx.fillRect(bracketX, bracketY, bracketW, bracketH)
                            ctx.strokeRect(bracketX, bracketY, bracketW, bracketH)

                            // Pin hole
                            ctx.fillStyle = "#90A4AE"
                            ctx.beginPath()
                            ctx.arc(bracketX + bracketW / 2, bracketY + bracketH * 0.4, bracketW * 0.15, 0, Math.PI * 2)
                            ctx.fill()
                            ctx.stroke()

                            // ==================== DIMENSION LINES ====================
                            ctx.strokeStyle = "#2E7D32"  // Green color for dimension lines
                            ctx.fillStyle = "#2E7D32"
                            ctx.lineWidth = 2
                            ctx.font = "bold 14px sans-serif"

                            // Boy (Height) - vertical line on left
                            var boyLineX = bucketX - 40
                            var boyLineY1 = bucketY - depth3D * 0.5
                            var boyLineY2 = bucketY + bucketH

                            ctx.beginPath()
                            ctx.moveTo(boyLineX, boyLineY1)
                            ctx.lineTo(boyLineX, boyLineY2)
                            ctx.stroke()

                            // Arrow heads for Boy
                            ctx.beginPath()
                            ctx.moveTo(boyLineX - 6, boyLineY1 + 10)
                            ctx.lineTo(boyLineX, boyLineY1)
                            ctx.lineTo(boyLineX + 6, boyLineY1 + 10)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(boyLineX - 6, boyLineY2 - 10)
                            ctx.lineTo(boyLineX, boyLineY2)
                            ctx.lineTo(boyLineX + 6, boyLineY2 - 10)
                            ctx.stroke()

                            // Boy label
                            ctx.save()
                            ctx.translate(boyLineX - 15, (boyLineY1 + boyLineY2) / 2)
                            ctx.rotate(-Math.PI / 2)
                            ctx.textAlign = "center"
                            var boyText = root.bucketLength > 0 ? Math.round(root.bucketLength) + " mm" : "--- mm"
                            ctx.fillText(boyText, 0, 0)
                            ctx.fillStyle = "#666"
                            ctx.font = "12px sans-serif"
                            ctx.fillText("(Boy)", 0, 16)
                            ctx.restore()

                            // En (Width) - horizontal line at bottom
                            ctx.strokeStyle = "#1565C0"  // Blue color
                            ctx.fillStyle = "#1565C0"
                            var enLineY = bucketY + bucketH + teethH + 30
                            var enLineX1 = bucketX
                            var enLineX2 = bucketX + bucketW

                            ctx.beginPath()
                            ctx.moveTo(enLineX1, enLineY)
                            ctx.lineTo(enLineX2, enLineY)
                            ctx.stroke()

                            // Arrow heads for En
                            ctx.beginPath()
                            ctx.moveTo(enLineX1 + 10, enLineY - 6)
                            ctx.lineTo(enLineX1, enLineY)
                            ctx.lineTo(enLineX1 + 10, enLineY + 6)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(enLineX2 - 10, enLineY - 6)
                            ctx.lineTo(enLineX2, enLineY)
                            ctx.lineTo(enLineX2 - 10, enLineY + 6)
                            ctx.stroke()

                            // En label
                            ctx.textAlign = "center"
                            ctx.font = "bold 14px sans-serif"
                            var enText = root.bucketWidth > 0 ? Math.round(root.bucketWidth) + " mm" : "--- mm"
                            ctx.fillText(enText, (enLineX1 + enLineX2) / 2, enLineY + 20)
                            ctx.fillStyle = "#666"
                            ctx.font = "12px sans-serif"
                            ctx.fillText("(En)", (enLineX1 + enLineX2) / 2, enLineY + 35)

                            // Derinlik (Depth) - diagonal line on right
                            ctx.strokeStyle = "#E65100"  // Orange color
                            ctx.fillStyle = "#E65100"
                            ctx.setLineDash([5, 5])

                            var depthLineX1 = bucketX + bucketW + 20
                            var depthLineY1 = bucketY + bucketH
                            var depthLineX2 = bucketX + bucketW + depth3D + 20
                            var depthLineY2 = bucketY - depth3D * 0.5

                            ctx.beginPath()
                            ctx.moveTo(depthLineX1, depthLineY1)
                            ctx.lineTo(depthLineX2, depthLineY2)
                            ctx.stroke()
                            ctx.setLineDash([])

                            // Arrow heads for Derinlik
                            ctx.beginPath()
                            ctx.moveTo(depthLineX1 + 8, depthLineY1 - 8)
                            ctx.lineTo(depthLineX1, depthLineY1)
                            ctx.lineTo(depthLineX1 + 10, depthLineY1 + 4)
                            ctx.stroke()

                            // Derinlik label
                            ctx.save()
                            ctx.translate(depthLineX2 + 15, (depthLineY1 + depthLineY2) / 2)
                            ctx.font = "bold 14px sans-serif"
                            ctx.textAlign = "left"
                            var depthText = root.bucketDepth > 0 ? Math.round(root.bucketDepth) + " mm" : "--- mm"
                            ctx.fillText(depthText, 0, 0)
                            ctx.fillStyle = "#666"
                            ctx.font = "12px sans-serif"
                            ctx.fillText("(Derinlik)", 0, 16)
                            ctx.restore()
                        }

                        Connections {
                            target: root
                            function onBucketLengthChanged() { bucketCanvas.requestPaint() }
                            function onBucketWidthChanged() { bucketCanvas.requestPaint() }
                            function onBucketDepthChanged() { bucketCanvas.requestPaint() }
                        }

                        Component.onCompleted: requestPaint()
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
