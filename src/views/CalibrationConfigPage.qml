import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * CalibrationConfigPage - Kalibrasyon Ayarları Sayfası
 *
 * Kullanıcı sensör kalibrasyonunu yapılandırır:
 * - IMU sensör kalibrasyonu
 * - GPS kalibrasyonu
 * - Açı sensörü ayarları
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

    // Global responsive değişkenlere erişim - fallback ile
    property var app: ApplicationWindow.window || defaultAppValues

    // Fallback values for when ApplicationWindow.window is not available yet
    readonly property QtObject defaultAppValues: QtObject {
        property real fontScale: 1.0
        property real baseFontSize: 16
        property real smallFontSize: 14
        property real mediumFontSize: 20
        property real largeFontSize: 24
        property real buttonHeight: 60
        property real smallButtonHeight: 50
        property real largeButtonHeight: 70
        property real smallSpacing: 10
        property real normalSpacing: 16
        property real largeSpacing: 26
        property real xlSpacing: 40
        property real smallPadding: 12
        property real normalPadding: 20
        property real largePadding: 32
        property real smallRadius: 4
        property real normalRadius: 8
        property real largeRadius: 12
        property real smallIconSize: 20
        property real normalIconSize: 24
        property real largeIconSize: 32
    }

    // Theme colors (dark theme optimized)
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
    property color warningColor: "#ed8936"
    property color successColor: "#48bb78"

    // Calibration settings (placeholder values - will be connected to ConfigManager)
    property real imuOffsetX: 0.0
    property real imuOffsetY: 0.0
    property real imuOffsetZ: 0.0
    property real gpsOffsetLat: 0.0
    property real gpsOffsetLon: 0.0
    property bool autoCalibrationEnabled: false

    // Calibration status
    property bool isCalibrating: false
    property int calibrationProgress: 0

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: app.buttonHeight * 1.5
        color: root.primaryColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: app.normalPadding
            anchors.rightMargin: app.normalPadding

            Button {
                Layout.preferredWidth: app.buttonHeight
                Layout.preferredHeight: app.buttonHeight
                flat: true

                contentItem: Text {
                    text: "←"
                    font.pixelSize: app.mediumFontSize
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: app.buttonHeight / 2
                    color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                }

                onClicked: root.back()
            }

            Text {
                Layout.fillWidth: true
                text: root.tr("Kalibrasyon Ayarları")
                font.pixelSize: app.mediumFontSize
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: app.buttonHeight }
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
            spacing: app.normalSpacing

            Item { Layout.preferredHeight: app.smallSpacing }

            // Info Card
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: app.normalPadding
                Layout.preferredHeight: infoContent.height + app.normalPadding * 1.5
                color: Qt.rgba(root.infoColor.r, root.infoColor.g, root.infoColor.b, 0.1)
                radius: app.normalRadius
                border.width: 1
                border.color: Qt.rgba(root.infoColor.r, root.infoColor.g, root.infoColor.b, 0.3)

                RowLayout {
                    id: infoContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: app.normalPadding
                    spacing: app.smallSpacing

                    Text {
                        text: "⚙️"
                        font.pixelSize: app.mediumFontSize
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.tr("Sensör kalibrasyonu, ekskavatörün doğru açı ve konum ölçümleri yapabilmesi için gereklidir. Kalibrasyonu başlatmadan önce ekskavatörün düz bir zemine park edildiğinden emin olun.")
                        font.pixelSize: app.smallFontSize
                        color: root.textSecondaryColor
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // IMU Kalibrasyon
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: app.normalPadding
                Layout.preferredHeight: imuContent.height + app.normalPadding * 2
                color: root.cardColor
                radius: app.normalRadius
                border.width: 1
                border.color: root.borderColor

                ColumnLayout {
                    id: imuContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: app.normalPadding
                    spacing: app.normalSpacing

                    Text {
                        text: root.tr("IMU Sensör Kalibrasyonu")
                        font.pixelSize: app.mediumFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
                    }

                    // Otomatik Kalibrasyon
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: app.normalSpacing

                        Column {
                            Layout.fillWidth: true
                            spacing: app.smallSpacing / 2

                            Text {
                                text: root.tr("Otomatik Kalibrasyon")
                                font.pixelSize: app.baseFontSize
                                color: root.textColor
                                font.bold: true
                            }

                            Text {
                                text: root.tr("Her başlatmada otomatik kalibrasyon yap")
                                font.pixelSize: app.smallFontSize
                                color: root.textSecondaryColor
                                wrapMode: Text.WordWrap
                            }
                        }

                        Switch {
                            checked: root.autoCalibrationEnabled
                            onToggled: {
                                root.autoCalibrationEnabled = checked
                            }

                            indicator: Rectangle {
                                implicitWidth: app.buttonHeight
                                implicitHeight: app.buttonHeight / 2
                                x: parent.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: height / 2
                                color: parent.checked ? root.successColor : root.borderColor

                                Rectangle {
                                    x: parent.parent.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: parent.height - 4
                                    height: parent.height - 4
                                    radius: width / 2
                                    color: "white"

                                    Behavior on x {
                                        NumberAnimation { duration: 150 }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
                    }

                    // Manuel Kalibrasyon Başlat
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight
                        text: root.isCalibrating
                            ? root.tr("Kalibrasyon Yapılıyor... %1%").arg(root.calibrationProgress)
                            : root.tr("Manuel Kalibrasyon Başlat")
                        enabled: !root.isCalibrating

                        background: Rectangle {
                            radius: app.normalRadius
                            color: parent.enabled
                                ? (parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor)
                                : root.borderColor
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: app.baseFontSize
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            // Simüle kalibrasyon başlat
                            root.isCalibrating = true
                            root.calibrationProgress = 0
                            calibrationTimer.start()
                        }
                    }

                    // Kalibrasyon Timer
                    Timer {
                        id: calibrationTimer
                        interval: 100
                        repeat: true
                        running: false

                        onTriggered: {
                            root.calibrationProgress += 5
                            if (root.calibrationProgress >= 100) {
                                root.calibrationProgress = 100
                                root.isCalibrating = false
                                calibrationTimer.stop()
                                console.log("IMU kalibrasyonu tamamlandı")
                            }
                        }
                    }

                    // IMU Offset Değerleri
                    Text {
                        Layout.topMargin: app.smallSpacing
                        text: root.tr("Offset Değerleri")
                        font.pixelSize: app.baseFontSize
                        font.bold: true
                        color: root.textSecondaryColor
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        rowSpacing: app.smallSpacing
                        columnSpacing: app.smallSpacing

                        // X Offset
                        Text {
                            text: "X:"
                            font.pixelSize: app.smallFontSize
                            color: root.textSecondaryColor
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.imuOffsetX.toFixed(3) + "°"
                            font.pixelSize: app.smallFontSize
                            color: root.textColor
                            font.family: "monospace"
                        }
                        Item { width: 1 }

                        // Y Offset
                        Text {
                            text: "Y:"
                            font.pixelSize: app.smallFontSize
                            color: root.textSecondaryColor
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.imuOffsetY.toFixed(3) + "°"
                            font.pixelSize: app.smallFontSize
                            color: root.textColor
                            font.family: "monospace"
                        }
                        Item { width: 1 }

                        // Z Offset
                        Text {
                            text: "Z:"
                            font.pixelSize: app.smallFontSize
                            color: root.textSecondaryColor
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.imuOffsetZ.toFixed(3) + "°"
                            font.pixelSize: app.smallFontSize
                            color: root.textColor
                            font.family: "monospace"
                        }
                        Item { width: 1 }
                    }
                }
            }

            // GPS Kalibrasyon
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: app.normalPadding
                Layout.preferredHeight: gpsContent.height + app.normalPadding * 2
                color: root.cardColor
                radius: app.normalRadius
                border.width: 1
                border.color: root.borderColor

                ColumnLayout {
                    id: gpsContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: app.normalPadding
                    spacing: app.normalSpacing

                    Text {
                        text: root.tr("GPS/Konum Kalibrasyonu")
                        font.pixelSize: app.mediumFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.tr("GPS offset değerleri, ekskavatörün gerçek konumu ile GPS'in gösterdiği konum arasındaki farkı düzeltir.")
                        font.pixelSize: app.smallFontSize
                        color: root.textSecondaryColor
                        wrapMode: Text.WordWrap
                    }

                    // GPS Offset Değerleri
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: app.smallSpacing
                        columns: 2
                        rowSpacing: app.normalSpacing
                        columnSpacing: app.normalSpacing

                        Text {
                            text: root.tr("Latitude Offset:")
                            font.pixelSize: app.baseFontSize
                            color: root.textSecondaryColor
                        }
                        Text {
                            text: root.gpsOffsetLat.toFixed(6) + "°"
                            font.pixelSize: app.baseFontSize
                            color: root.textColor
                            font.family: "monospace"
                        }

                        Text {
                            text: root.tr("Longitude Offset:")
                            font.pixelSize: app.baseFontSize
                            color: root.textSecondaryColor
                        }
                        Text {
                            text: root.gpsOffsetLon.toFixed(6) + "°"
                            font.pixelSize: app.baseFontSize
                            color: root.textColor
                            font.family: "monospace"
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight
                        Layout.topMargin: app.smallSpacing
                        text: root.tr("GPS Offsetlerini Sıfırla")

                        background: Rectangle {
                            radius: app.normalRadius
                            color: parent.pressed ? Qt.rgba(0, 0, 0, 0.1) : "transparent"
                            border.width: 1
                            border.color: root.borderColor
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: app.baseFontSize
                            color: root.textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            root.gpsOffsetLat = 0.0
                            root.gpsOffsetLon = 0.0
                            console.log("GPS offsetler sıfırlandı")
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: app.largeSpacing }
        }
    }

    // Footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: app.buttonHeight * 1.8
        color: root.cardColor
        border.width: 1
        border.color: root.borderColor

        RowLayout {
            anchors.centerIn: parent
            spacing: app.normalSpacing

            Button {
                Layout.preferredWidth: app.largeIconSize * 3
                Layout.preferredHeight: app.buttonHeight
                text: root.tr("İptal")

                background: Rectangle {
                    radius: app.normalRadius
                    color: parent.pressed ? Qt.rgba(0, 0, 0, 0.1) : "transparent"
                    border.width: 1
                    border.color: root.borderColor
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: app.baseFontSize
                    color: root.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.back()
            }

            Button {
                Layout.preferredWidth: app.largeIconSize * 3
                Layout.preferredHeight: app.buttonHeight
                text: root.tr("Kaydet")

                background: Rectangle {
                    radius: app.normalRadius
                    color: parent.pressed ? Qt.darker(root.successColor, 1.2) : root.successColor
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: app.baseFontSize
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    // TODO: Save calibration settings to ConfigManager
                    console.log("Kalibrasyon ayarları kaydedilecek")
                    console.log("Otomatik kalibrasyon:", root.autoCalibrationEnabled)
                    console.log("IMU Offset:", root.imuOffsetX, root.imuOffsetY, root.imuOffsetZ)
                    console.log("GPS Offset:", root.gpsOffsetLat, root.gpsOffsetLon)
                    root.configSaved()
                }
            }
        }
    }
}
