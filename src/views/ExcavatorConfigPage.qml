import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ExcavatorConfigPage - Ekskavatör Ayarları Sayfası
 *
 * Kullanıcı ekskavatör ölçülerini girer:
 * - Ekskavatör Adı
 * - Boom Uzunluğu (metre)
 * - Arm Uzunluğu (metre)
 * - Bucket Genişliği (metre)
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#f7fafc"

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

    // Theme colors with fallbacks (softer light theme defaults)
    property color primaryColor: themeManager ? themeManager.primaryColor : "#319795"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "white"
    property color textSecondaryColor: themeManager ? themeManager.textSecondaryColor : "#e0e0e0"
    property color borderColor: themeManager ? themeManager.borderColor : "#e2e8f0"
    property color infoColor: themeManager ? themeManager.infoColor : "#4299e1"

    // Excavator preset selection state
    property int selectedPresetIndex: -1  // -1 means "Yeni Ekskavatör"

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

    // Content
    ScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        contentWidth: parent.width

        ColumnLayout {
            width: parent.width
            spacing: 24

            Item { Layout.preferredHeight: 20 }

            // Excavator Preset Selection
            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: 8

                Text {
                    text: root.tr("Ekskavatör Seçimi")
                    font.pixelSize: app ? app.baseFontSize : 14
                    font.bold: true
                    color: root.textColor
                }

                ComboBox {
                    id: presetComboBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: app ? app.buttonHeight : 50

                    model: {
                        var list = [root.tr("Yeni Ekskavatör")];
                        if (configManager && configManager.excavatorPresets) {
                            for (var i = 0; i < configManager.excavatorPresets.length; i++) {
                                list.push(configManager.excavatorPresets[i].name);
                            }
                        }
                        return list;
                    }

                    currentIndex: root.selectedPresetIndex + 1  // +1 because "Yeni Ekskavatör" is at index 0

                    onCurrentIndexChanged: {
                        if (currentIndex === 0) {
                            // "Yeni Ekskavatör" selected - clear fields
                            root.selectedPresetIndex = -1;
                            if (configManager) {
                                configManager.excavatorName = "";
                                configManager.scanningDepth = 15.0;
                                configManager.boomLength = 12.0;
                                configManager.armLength = 10.0;
                                configManager.bucketWidth = 3.0;
                            }
                        } else if (currentIndex > 0 && configManager) {
                            // Load preset
                            var presetIndex = currentIndex - 1;
                            root.selectedPresetIndex = presetIndex;
                            configManager.loadExcavatorPreset(presetIndex);
                        }
                    }

                    contentItem: Text {
                        leftPadding: 12
                        rightPadding: presetComboBox.indicator.width + 12
                        text: presetComboBox.displayText
                        font.pixelSize: app ? app.baseFontSize : 16
                        color: root.textColor
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: root.surfaceColor
                        radius: 8
                        border.width: presetComboBox.activeFocus ? 2 : 1
                        border.color: presetComboBox.activeFocus ? root.primaryColor : root.borderColor
                    }

                    delegate: ItemDelegate {
                        width: presetComboBox.width
                        contentItem: Text {
                            text: modelData
                            color: root.textColor
                            font.pixelSize: app ? app.baseFontSize : 16
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        highlighted: presetComboBox.highlightedIndex === index
                    }

                    popup: Popup {
                        y: presetComboBox.height - 1
                        width: presetComboBox.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: presetComboBox.popup.visible ? presetComboBox.delegateModel : null
                            currentIndex: presetComboBox.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            color: root.surfaceColor
                            border.color: root.borderColor
                            radius: 8
                        }
                    }
                }

                Text {
                    text: root.tr("Listeden bir ekskavatör seçin veya yeni ekskavatör bilgileri girin")
                    font.pixelSize: app ? app.smallFontSize : 12
                    color: "white"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            // Excavator Name
            ConfigInputField {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: root.tr("Ekskavatör Adı")
                placeholder: root.tr("Örn: UDHB Burak")
                inputText: configManager ? configManager.excavatorName : ""
                fieldPrimaryColor: root.primaryColor
                fieldSurfaceColor: root.surfaceColor
                fieldTextColor: root.textColor
                fieldTextSecondaryColor: root.textSecondaryColor
                fieldBorderColor: root.borderColor
                onFieldTextChanged: function(newText) {
                    if (configManager) {
                        configManager.excavatorName = newText;
                        // Reset preset selection when manually edited
                        root.selectedPresetIndex = -1;
                        presetComboBox.currentIndex = 0;
                    }
                }
            }

            // Row 1: Scanning Depth ve Boom Length
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: app ? app.normalSpacing : 12

                // Scanning Depth
                ConfigInputField {
                    Layout.fillWidth: true
                    label: root.tr("Tarama Derinliği (m)")
                    placeholder: root.tr("15.0")
                    inputText: configManager ? configManager.scanningDepth.toFixed(1) : "15.0"
                    inputType: "number"
                    suffix: "m"
                    fieldPrimaryColor: root.primaryColor
                    fieldSurfaceColor: root.surfaceColor
                    fieldTextColor: root.textColor
                    fieldTextSecondaryColor: root.textSecondaryColor
                    fieldBorderColor: root.borderColor
                    onFieldTextChanged: function(newText) {
                        var val = parseFloat(newText)
                        if (!isNaN(val) && val > 0 && configManager) {
                            configManager.scanningDepth = val
                        }
                    }
                }

                // Boom Length
                ConfigInputField {
                    Layout.fillWidth: true
                    label: root.tr("Ana Bom (m)")
                    placeholder: root.tr("12.0")
                    inputText: configManager ? configManager.boomLength.toFixed(1) : "0.0"
                    inputType: "number"
                    suffix: "m"
                    fieldPrimaryColor: root.primaryColor
                    fieldSurfaceColor: root.surfaceColor
                    fieldTextColor: root.textColor
                    fieldTextSecondaryColor: root.textSecondaryColor
                    fieldBorderColor: root.borderColor
                    onFieldTextChanged: function(newText) {
                        var val = parseFloat(newText)
                        if (!isNaN(val) && val > 0 && configManager) {
                            configManager.boomLength = val
                        }
                    }
                }
            }

            // Row 2: Arm Length ve Bucket Width
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                spacing: app ? app.normalSpacing : 12

                // Arm Length
                ConfigInputField {
                    Layout.fillWidth: true
                    label: root.tr("Arm Bom (m)")
                    placeholder: root.tr("10.0")
                    inputText: configManager ? configManager.armLength.toFixed(1) : "0.0"
                    inputType: "number"
                    suffix: "m"
                    fieldPrimaryColor: root.primaryColor
                    fieldSurfaceColor: root.surfaceColor
                    fieldTextColor: root.textColor
                    fieldTextSecondaryColor: root.textSecondaryColor
                    fieldBorderColor: root.borderColor
                    onFieldTextChanged: function(newText) {
                        var val = parseFloat(newText)
                        if (!isNaN(val) && val > 0 && configManager) {
                            configManager.armLength = val
                        }
                    }
                }

                // Bucket Width
                ConfigInputField {
                    Layout.fillWidth: true
                    label: root.tr("Kova (m³)")
                    placeholder: root.tr("3.0")
                    inputText: configManager ? configManager.bucketWidth.toFixed(1) : "0.0"
                    inputType: "number"
                    suffix: "m³"
                    fieldPrimaryColor: root.primaryColor
                    fieldSurfaceColor: root.surfaceColor
                    fieldTextColor: root.textColor
                    fieldTextSecondaryColor: root.textSecondaryColor
                    fieldBorderColor: root.borderColor
                    onFieldTextChanged: function(newText) {
                        var val = parseFloat(newText)
                        if (!isNaN(val) && val > 0 && configManager) {
                            configManager.bucketWidth = val
                        }
                    }
                }
            }

            // Info Box
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: infoContent.height + 24
                color: Qt.rgba(root.infoColor.r, root.infoColor.g, root.infoColor.b, 0.1)
                radius: 8
                border.width: 1
                border.color: Qt.rgba(root.infoColor.r, root.infoColor.g, root.infoColor.b, 0.3)

                RowLayout {
                    id: infoContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: "ℹ️"
                        font.pixelSize: app ? app.mediumFontSize : 20
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.tr("Listeden bir ekskavatör seçin veya yeni ekskavatör bilgileri girin. Bu ölçüler 3D görselleştirme ve kazı hesaplamaları için kullanılacaktır.")
                        font.pixelSize: app ? app.smallFontSize : 13
                        color: "white"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: app ? app.buttonHeight * 1.8 : 80
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.borderColor
        }

        RowLayout {
            anchors.centerIn: parent
            width: parent.width - (app ? app.xlSpacing * 2 : 40)
            spacing: app ? app.normalSpacing : 12

            // Preset olarak kaydet butonu
            Button {
                Layout.preferredWidth: parent.width * 0.35
                Layout.preferredHeight: app ? app.buttonHeight : 50
                text: root.tr("Kaydet")
                enabled: isFormValid && root.selectedPresetIndex === -1

                property bool isFormValid: {
                    if (!configManager) return false
                    return configManager.excavatorName.length > 0 &&
                           configManager.scanningDepth > 0 &&
                           configManager.boomLength > 0 &&
                           configManager.armLength > 0 &&
                           configManager.bucketWidth > 0
                }

                background: Rectangle {
                    radius: 12
                    color: parent.enabled
                        ? (parent.pressed ? Qt.darker("#4CAF50", 1.2) : "#4CAF50")
                        : Qt.rgba(0.5, 0.5, 0.5, 0.15)
                    border.width: parent.enabled ? 0 : 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: app ? app.baseFontSize : 14
                    font.bold: true
                    color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.3)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    if (configManager) {
                        configManager.saveCurrentAsPreset();
                    }
                }
            }

            // Kaydet ve devam et butonu
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: app ? app.buttonHeight : 50
                text: root.tr("Kaydet ve Devam Et")
                enabled: isFormValid

                property bool isFormValid: {
                    if (!configManager) return false
                    return configManager.excavatorName.length > 0 &&
                           configManager.scanningDepth > 0 &&
                           configManager.boomLength > 0 &&
                           configManager.armLength > 0 &&
                           configManager.bucketWidth > 0
                }

                background: Rectangle {
                    radius: 12
                    color: parent.enabled
                        ? (parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor)
                        : Qt.rgba(0.5, 0.5, 0.5, 0.15)
                    border.width: parent.enabled ? 0 : 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: app ? app.mediumFontSize : 16
                    font.bold: true
                    color: parent.enabled ? "white" : Qt.rgba(1, 1, 1, 0.3)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    root.configSaved()
                }
            }
        }
    }

    // ConfigInputField Component with explicit color properties
    component ConfigInputField: ColumnLayout {
        id: inputFieldRoot
        property string label: ""
        property string placeholder: ""
        property string inputText: ""
        property string inputType: "text" // "text" or "number"
        property string suffix: ""

        // Theme colors (passed from parent - softer light theme defaults)
        property color fieldPrimaryColor: "#319795"
        property color fieldSurfaceColor: "#ffffff"
        property color fieldTextColor: "#2d3748"
        property color fieldTextSecondaryColor: "#a0aec0"
        property color fieldBorderColor: "#e2e8f0"

        signal fieldTextChanged(string newText)

        spacing: app ? app.smallSpacing : 8

        Text {
            text: inputFieldRoot.label
            font.pixelSize: app ? app.baseFontSize : 14
            font.bold: true
            color: inputFieldRoot.fieldTextColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: app ? app.buttonHeight : 50
            color: inputFieldRoot.fieldSurfaceColor
            radius: 8
            border.width: inputField.activeFocus ? 2 : 1
            border.color: inputField.activeFocus ? inputFieldRoot.fieldPrimaryColor : inputFieldRoot.fieldBorderColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: app ? app.smallPadding : 12
                spacing: app ? app.smallSpacing : 8

                TextField {
                    id: inputField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: inputFieldRoot.inputText
                    placeholderText: inputFieldRoot.placeholder
                    font.pixelSize: app ? app.baseFontSize : 16
                    color: inputFieldRoot.fieldTextColor
                    placeholderTextColor: inputFieldRoot.fieldTextSecondaryColor

                    validator: inputFieldRoot.inputType === "number" ? doubleValidator : null

                    background: Rectangle {
                        color: "transparent"
                    }

                    onTextChanged: {
                        inputFieldRoot.fieldTextChanged(inputField.text)
                    }

                    DoubleValidator {
                        id: doubleValidator
                        bottom: 0
                        decimals: 2
                    }
                }

                Text {
                    visible: inputFieldRoot.suffix.length > 0
                    text: inputFieldRoot.suffix
                    font.pixelSize: app ? app.baseFontSize : 14
                    color: inputFieldRoot.fieldTextSecondaryColor
                }
            }
        }
    }
}
