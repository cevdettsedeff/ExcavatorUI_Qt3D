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

    // Theme colors with fallbacks (softer light theme defaults)
    property color primaryColor: themeManager ? themeManager.primaryColor : "#319795"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color textColor: themeManager ? themeManager.textColor : "#2d3748"
    property color textSecondaryColor: themeManager ? themeManager.textSecondaryColor : "#718096"
    property color borderColor: themeManager ? themeManager.borderColor : "#e2e8f0"
    property color infoColor: themeManager ? themeManager.infoColor : "#4299e1"

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Button {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
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
                font.pixelSize: 20
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: 40 }
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

            // Excavator Preview
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 150
                color: root.surfaceColor
                radius: 12

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/ExcavatorUI_Qt3D/resources/icons/app_icon.ico"
                    width: 80
                    height: 80
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    antialiasing: true
                }
            }

            // Excavator Name
            ConfigInputField {
                Layout.fillWidth: true
                Layout.margins: 20
                label: root.tr("Ekskavatör Adı")
                placeholder: root.tr("Örn: CAT 320D")
                inputText: configManager ? configManager.excavatorName : ""
                fieldPrimaryColor: root.primaryColor
                fieldSurfaceColor: root.surfaceColor
                fieldTextColor: root.textColor
                fieldTextSecondaryColor: root.textSecondaryColor
                fieldBorderColor: root.borderColor
                onFieldTextChanged: function(newText) {
                    if (configManager) configManager.excavatorName = newText
                }
            }

            // Boom Length
            ConfigInputField {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: root.tr("Boom Uzunluğu (metre)")
                placeholder: root.tr("Örn: 12.0")
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

            // Arm Length
            ConfigInputField {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: root.tr("Arm Uzunluğu (metre)")
                placeholder: root.tr("Örn: 10.0")
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
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: root.tr("Bucket Genişliği (metre)")
                placeholder: root.tr("Örn: 2.0")
                inputText: configManager ? configManager.bucketWidth.toFixed(1) : "0.0"
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
                        configManager.bucketWidth = val
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
                        font.pixelSize: 20
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.tr("Bu ölçüler 3D görselleştirme ve kazı hesaplamaları için kullanılacaktır.")
                        font.pixelSize: 13
                        color: root.textSecondaryColor
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
        height: 80
        color: root.surfaceColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.borderColor
        }

        Button {
            anchors.centerIn: parent
            width: parent.width - 40
            height: 50
            text: root.tr("Kaydet ve Devam Et")
            enabled: isFormValid

            property bool isFormValid: {
                if (!configManager) return false
                return configManager.excavatorName.length > 0 &&
                       configManager.boomLength > 0 &&
                       configManager.armLength > 0 &&
                       configManager.bucketWidth > 0
            }

            background: Rectangle {
                radius: 12
                color: parent.enabled
                    ? (parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor)
                    : root.surfaceColor
                border.width: parent.enabled ? 0 : 1
                border.color: root.borderColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                font.bold: true
                color: parent.enabled ? "white" : root.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                root.configSaved()
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
        property color fieldTextSecondaryColor: "#718096"
        property color fieldBorderColor: "#e2e8f0"

        signal fieldTextChanged(string newText)

        spacing: 8

        Text {
            text: inputFieldRoot.label
            font.pixelSize: 14
            font.bold: true
            color: inputFieldRoot.fieldTextColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: inputFieldRoot.fieldSurfaceColor
            radius: 8
            border.width: inputField.activeFocus ? 2 : 1
            border.color: inputField.activeFocus ? inputFieldRoot.fieldPrimaryColor : inputFieldRoot.fieldBorderColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                TextField {
                    id: inputField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: inputFieldRoot.inputText
                    placeholderText: inputFieldRoot.placeholder
                    font.pixelSize: 16
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
                    font.pixelSize: 14
                    color: inputFieldRoot.fieldTextSecondaryColor
                }
            }
        }
    }
}
