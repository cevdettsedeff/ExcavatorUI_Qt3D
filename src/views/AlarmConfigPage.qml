import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * AlarmConfigPage - Alarm Ayarları Sayfası
 *
 * Kullanıcı alarm renklerini özelleştirir:
 * - Kritik alarm rengi
 * - Uyarı rengi
 * - Bilgi rengi
 * - Başarı rengi
 */
Rectangle {
    id: root
    color: themeManager.backgroundColor

    signal back()
    signal configSaved()

    // Current colors
    property string criticalColor: configManager.alarmColorCritical
    property string warningColor: configManager.alarmColorWarning
    property string infoColor: configManager.alarmColorInfo
    property string successColor: configManager.alarmColorSuccess

    // Color picker state
    property string editingColorType: ""
    property string editingColor: ""

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
                text: qsTr("Alarm Ayarları")
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
            spacing: 20

            Item { Layout.preferredHeight: 10 }

            // Info Card
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: infoContent.height + 24
                color: Qt.rgba(themeManager.infoColor.r, themeManager.infoColor.g, themeManager.infoColor.b, 0.1)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(themeManager.infoColor.r, themeManager.infoColor.g, themeManager.infoColor.b, 0.3)

                RowLayout {
                    id: infoContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "🔔"
                        font.pixelSize: 24
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Alarm renkleri, uygulamadaki tüm uyarı ve bildirimlerde kullanılacaktır. İstediğiniz renkleri seçerek arayüzü özelleştirebilirsiniz.")
                        font.pixelSize: 13
                        color: themeManager.textSecondaryColor
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Color Settings
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: colorSettingsContent.height + 32
                color: themeManager.surfaceColor
                radius: 12

                ColumnLayout {
                    id: colorSettingsContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 16

                    Text {
                        text: qsTr("Alarm Renkleri")
                        font.pixelSize: 16
                        font.bold: true
                        color: themeManager.textColor
                    }

                    // Critical Color
                    AlarmColorRow {
                        Layout.fillWidth: true
                        label: qsTr("Kritik Alarm")
                        description: qsTr("Acil durumlar ve kritik hatalar")
                        icon: "🚨"
                        currentColor: criticalColor
                        onColorClicked: {
                            editingColorType = "critical"
                            editingColor = criticalColor
                            colorPickerPopup.open()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: themeManager.borderColor
                    }

                    // Warning Color
                    AlarmColorRow {
                        Layout.fillWidth: true
                        label: qsTr("Uyarı")
                        description: qsTr("Dikkat gerektiren durumlar")
                        icon: "⚠️"
                        currentColor: warningColor
                        onColorClicked: {
                            editingColorType = "warning"
                            editingColor = warningColor
                            colorPickerPopup.open()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: themeManager.borderColor
                    }

                    // Info Color
                    AlarmColorRow {
                        Layout.fillWidth: true
                        label: qsTr("Bilgi")
                        description: qsTr("Genel bilgilendirmeler")
                        icon: "ℹ️"
                        currentColor: infoColor
                        onColorClicked: {
                            editingColorType = "info"
                            editingColor = infoColor
                            colorPickerPopup.open()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: themeManager.borderColor
                    }

                    // Success Color
                    AlarmColorRow {
                        Layout.fillWidth: true
                        label: qsTr("Başarı")
                        description: qsTr("Başarılı işlemler ve onaylar")
                        icon: "✅"
                        currentColor: successColor
                        onColorClicked: {
                            editingColorType = "success"
                            editingColor = successColor
                            colorPickerPopup.open()
                        }
                    }
                }
            }

            // Preview Section
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 20
                Layout.preferredHeight: previewContent.height + 32
                color: themeManager.surfaceColor
                radius: 12

                ColumnLayout {
                    id: previewContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: qsTr("Önizleme")
                        font.pixelSize: 16
                        font.bold: true
                        color: themeManager.textColor
                    }

                    // Preview alarms
                    AlarmPreviewCard {
                        Layout.fillWidth: true
                        alarmColor: criticalColor
                        title: qsTr("Kritik: Sistem Hatası")
                        message: qsTr("Acil müdahale gerekiyor")
                        icon: "🚨"
                    }

                    AlarmPreviewCard {
                        Layout.fillWidth: true
                        alarmColor: warningColor
                        title: qsTr("Uyarı: Düşük Yakıt")
                        message: qsTr("Yakıt seviyesi %15'in altında")
                        icon: "⚠️"
                    }

                    AlarmPreviewCard {
                        Layout.fillWidth: true
                        alarmColor: infoColor
                        title: qsTr("Bilgi: GPS Bağlantısı")
                        message: qsTr("GPS sinyali alınıyor")
                        icon: "ℹ️"
                    }

                    AlarmPreviewCard {
                        Layout.fillWidth: true
                        alarmColor: successColor
                        title: qsTr("Başarılı: Kalibrasyon")
                        message: qsTr("Sensör kalibrasyonu tamamlandı")
                        icon: "✅"
                    }
                }
            }

            // Reset to defaults button
            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 20
                text: qsTr("Varsayılana Sıfırla")
                flat: true

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    color: themeManager.textSecondaryColor
                    horizontalAlignment: Text.AlignHCenter
                }

                onClicked: {
                    criticalColor = "#FF4444"
                    warningColor = "#FFA500"
                    infoColor = "#2196F3"
                    successColor = "#4CAF50"
                }
            }
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

            background: Rectangle {
                radius: 12
                color: parent.pressed ? Qt.darker(themeManager.primaryColor, 1.2) : themeManager.primaryColor
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: 16
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                configManager.alarmColorCritical = criticalColor
                configManager.alarmColorWarning = warningColor
                configManager.alarmColorInfo = infoColor
                configManager.alarmColorSuccess = successColor
                root.configSaved()
            }
        }
    }

    // Color Picker Popup
    Popup {
        id: colorPickerPopup
        anchors.centerIn: parent
        width: 320
        height: 450
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: themeManager.backgroundColor
            radius: 16
            border.width: 1
            border.color: themeManager.borderColor
        }

        contentItem: ColumnLayout {
            spacing: 16

            // Header
            Text {
                Layout.fillWidth: true
                text: qsTr("Renk Seçin")
                font.pixelSize: 18
                font.bold: true
                color: themeManager.textColor
                horizontalAlignment: Text.AlignHCenter
            }

            // Current color preview
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: 40
                color: editingColor
                border.width: 3
                border.color: themeManager.borderColor
            }

            // Predefined colors grid
            Text {
                text: qsTr("Hazır Renkler")
                font.pixelSize: 13
                color: themeManager.textSecondaryColor
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 6
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: [
                        "#F44336", "#E91E63", "#9C27B0", "#673AB7", "#3F51B5", "#2196F3",
                        "#03A9F4", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#CDDC39",
                        "#FFEB3B", "#FFC107", "#FF9800", "#FF5722", "#795548", "#9E9E9E",
                        "#607D8B", "#000000", "#FF1744", "#F50057", "#D500F9", "#651FFF"
                    ]

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 8
                        color: modelData
                        border.width: editingColor === modelData ? 3 : 1
                        border.color: editingColor === modelData ? "white" : Qt.darker(modelData, 1.2)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: editingColor = modelData
                        }
                    }
                }
            }

            // Custom color input
            Text {
                text: qsTr("Özel Renk (HEX)")
                font.pixelSize: 13
                color: themeManager.textSecondaryColor
            }

            TextField {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: editingColor
                font.pixelSize: 16
                font.family: "monospace"
                color: themeManager.textColor
                horizontalAlignment: Text.AlignHCenter

                background: Rectangle {
                    color: themeManager.surfaceColor
                    radius: 8
                    border.width: parent.activeFocus ? 2 : 1
                    border.color: parent.activeFocus ? themeManager.primaryColor : themeManager.borderColor
                }

                onTextChanged: {
                    if (text.match(/^#[0-9A-Fa-f]{6}$/)) {
                        editingColor = text.toUpperCase()
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("İptal")
                    flat: true

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? themeManager.surfaceColor : "transparent"
                        border.width: 1
                        border.color: themeManager.borderColor
                    }

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: themeManager.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: colorPickerPopup.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    text: qsTr("Uygula")

                    background: Rectangle {
                        radius: 8
                        color: parent.pressed ? Qt.darker(themeManager.primaryColor, 1.2) : themeManager.primaryColor
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
                        switch (editingColorType) {
                            case "critical": criticalColor = editingColor; break;
                            case "warning": warningColor = editingColor; break;
                            case "info": infoColor = editingColor; break;
                            case "success": successColor = editingColor; break;
                        }
                        colorPickerPopup.close()
                    }
                }
            }
        }
    }

    // AlarmColorRow Component
    component AlarmColorRow: RowLayout {
        property string label: ""
        property string description: ""
        property string icon: ""
        property string currentColor: "#000000"

        signal colorClicked()

        spacing: 12

        Text {
            text: icon
            font.pixelSize: 28
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: label
                font.pixelSize: 15
                font.bold: true
                color: themeManager.textColor
            }

            Text {
                text: description
                font.pixelSize: 12
                color: themeManager.textSecondaryColor
            }
        }

        Rectangle {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            radius: 12
            color: currentColor
            border.width: 2
            border.color: Qt.darker(currentColor, 1.3)

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: colorClicked()
            }

            // Edit icon
            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: -4
                width: 20
                height: 20
                radius: 10
                color: themeManager.surfaceColor
                border.width: 1
                border.color: themeManager.borderColor

                Text {
                    anchors.centerIn: parent
                    text: "✎"
                    font.pixelSize: 10
                    color: themeManager.textColor
                }
            }
        }
    }

    // AlarmPreviewCard Component
    component AlarmPreviewCard: Rectangle {
        property string alarmColor: "#FF4444"
        property string title: ""
        property string message: ""
        property string icon: ""

        height: 60
        radius: 8
        color: Qt.rgba(
            parseInt(alarmColor.substr(1, 2), 16) / 255,
            parseInt(alarmColor.substr(3, 2), 16) / 255,
            parseInt(alarmColor.substr(5, 2), 16) / 255,
            0.15
        )
        border.width: 1
        border.color: alarmColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: alarmColor

                Text {
                    anchors.centerIn: parent
                    text: icon
                    font.pixelSize: 18
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: title
                    font.pixelSize: 13
                    font.bold: true
                    color: themeManager.textColor
                }

                Text {
                    text: message
                    font.pixelSize: 11
                    color: themeManager.textSecondaryColor
                }
            }
        }
    }
}
