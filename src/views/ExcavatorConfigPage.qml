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
    color: themeManager.backgroundColor

    signal back()
    signal configSaved()

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: themeManager.primaryColor

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
                text: qsTr("Ekskavatör Ayarları")
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
                color: themeManager.surfaceColor
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
                label: qsTr("Ekskavatör Adı")
                placeholder: qsTr("Örn: CAT 320D")
                inputText: configManager.excavatorName
                onTextChanged: configManager.excavatorName = text
            }

            // Boom Length
            ConfigInputField {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: qsTr("Boom Uzunluğu (metre)")
                placeholder: qsTr("Örn: 12.0")
                inputText: configManager.boomLength.toFixed(1)
                inputType: "number"
                suffix: "m"
                onTextChanged: {
                    var val = parseFloat(text)
                    if (!isNaN(val) && val > 0) {
                        configManager.boomLength = val
                    }
                }
            }

            // Arm Length
            ConfigInputField {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: qsTr("Arm Uzunluğu (metre)")
                placeholder: qsTr("Örn: 10.0")
                inputText: configManager.armLength.toFixed(1)
                inputType: "number"
                suffix: "m"
                onTextChanged: {
                    var val = parseFloat(text)
                    if (!isNaN(val) && val > 0) {
                        configManager.armLength = val
                    }
                }
            }

            // Bucket Width
            ConfigInputField {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                label: qsTr("Bucket Genişliği (metre)")
                placeholder: qsTr("Örn: 2.0")
                inputText: configManager.bucketWidth.toFixed(1)
                inputType: "number"
                suffix: "m"
                onTextChanged: {
                    var val = parseFloat(text)
                    if (!isNaN(val) && val > 0) {
                        configManager.bucketWidth = val
                    }
                }
            }

            // Info Box
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: infoContent.height + 24
                color: Qt.rgba(themeManager.infoColor.r, themeManager.infoColor.g, themeManager.infoColor.b, 0.1)
                radius: 8
                border.width: 1
                border.color: Qt.rgba(themeManager.infoColor.r, themeManager.infoColor.g, themeManager.infoColor.b, 0.3)

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
                        text: qsTr("Bu ölçüler 3D görselleştirme ve kazı hesaplamaları için kullanılacaktır.")
                        font.pixelSize: 13
                        color: themeManager.textSecondaryColor
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
        color: themeManager.surfaceColor

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: themeManager.borderColor
        }

        Button {
            anchors.centerIn: parent
            width: parent.width - 40
            height: 50
            text: qsTr("Kaydet ve Devam Et")
            enabled: isFormValid

            property bool isFormValid: {
                return configManager.excavatorName.length > 0 &&
                       configManager.boomLength > 0 &&
                       configManager.armLength > 0 &&
                       configManager.bucketWidth > 0
            }

            background: Rectangle {
                radius: 12
                color: parent.enabled
                    ? (parent.pressed ? Qt.darker(themeManager.primaryColor, 1.2) : themeManager.primaryColor)
                    : themeManager.surfaceColor
                border.width: parent.enabled ? 0 : 1
                border.color: themeManager.borderColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                font.bold: true
                color: parent.enabled ? "white" : themeManager.textSecondaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                root.configSaved()
            }
        }
    }

    // ConfigInputField Component
    component ConfigInputField: ColumnLayout {
        property string label: ""
        property string placeholder: ""
        property string inputText: ""
        property string inputType: "text" // "text" or "number"
        property string suffix: ""

        signal textChanged(string text)

        spacing: 8

        Text {
            text: parent.label
            font.pixelSize: 14
            font.bold: true
            color: themeManager.textColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: themeManager.surfaceColor
            radius: 8
            border.width: inputField.activeFocus ? 2 : 1
            border.color: inputField.activeFocus ? themeManager.primaryColor : themeManager.borderColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                TextField {
                    id: inputField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: inputText
                    placeholderText: placeholder
                    font.pixelSize: 16
                    color: themeManager.textColor
                    placeholderTextColor: themeManager.textSecondaryColor

                    validator: inputType === "number" ? doubleValidator : null

                    background: Rectangle {
                        color: "transparent"
                    }

                    onTextChanged: {
                        parent.parent.parent.textChanged(text)
                    }

                    DoubleValidator {
                        id: doubleValidator
                        bottom: 0
                        decimals: 2
                    }
                }

                Text {
                    visible: suffix.length > 0
                    text: suffix
                    font.pixelSize: 14
                    color: themeManager.textSecondaryColor
                }
            }
        }
    }
}
