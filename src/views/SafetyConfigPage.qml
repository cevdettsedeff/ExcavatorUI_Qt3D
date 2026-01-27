import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

/**
 * SafetyConfigPage - Emniyet Ayarları Sayfası
 *
 * Kullanıcı emniyet ayarlarını yapılandırır:
 * - Sabit engel tanımlama
 * - Çarpışma uyarısı ayarları
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

    // Safety settings (placeholder values - will be connected to ConfigManager)
    property int collisionWarningDistance: 50  // cm
    property bool obstacleDetectionEnabled: true
    property var obstacles: []  // List of obstacles

    // Step indicator properties
    property int currentStep: 0
    property var stepTitles: [root.tr("Emniyet Ayarları")]

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
                text: root.tr("Emniyet Ayarları")
                font.pixelSize: app.mediumFontSize
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.preferredWidth: app.buttonHeight }
        }
    }

    // Progress Indicator
    StepProgressIndicator {
        id: progressBar
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        currentStep: root.currentStep
        stepTitles: root.stepTitles
        primaryColor: root.primaryColor
    }

    // Content
    ScrollView {
        anchors.top: progressBar.bottom
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
                color: Qt.rgba(root.infoColor.r, root.infoColor.g, root.infoColor.b, 0.15)
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
                        text: "🛡️"
                        font.pixelSize: app.mediumFontSize
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.tr("Emniyet ayarları ile sabit engelleri tanımlayabilir ve çarpışma uyarılarını yapılandırabilirsiniz.")
                        font.pixelSize: app.smallFontSize
                        color: root.textSecondaryColor
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Çarpışma Uyarısı Ayarları
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: app.normalPadding
                Layout.preferredHeight: collisionContent.height + app.normalPadding * 2
                color: root.cardColor
                radius: app.normalRadius
                border.width: 1
                border.color: root.borderColor

                ColumnLayout {
                    id: collisionContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: app.normalPadding
                    spacing: app.normalSpacing

                    Text {
                        text: root.tr("Çarpışma Uyarısı")
                        font.pixelSize: app.mediumFontSize
                        font.bold: true
                        color: root.textColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
                    }

                    // Minimum Mesafe Ayarı
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: app.normalSpacing

                        Column {
                            Layout.fillWidth: true
                            spacing: app.smallSpacing / 2

                            Text {
                                text: root.tr("Minimum Uyarı Mesafesi")
                                font.pixelSize: app.baseFontSize
                                color: root.textColor
                                font.bold: true
                            }

                            Text {
                                text: root.tr("Ekskavatörün engellere ne kadar yaklaştığında uyarı verileceğini belirleyin")
                                font.pixelSize: app.smallFontSize
                                color: root.textSecondaryColor
                                wrapMode: Text.WordWrap
                            }
                        }

                        Text {
                            text: root.collisionWarningDistance + " cm"
                            font.pixelSize: app.largeFontSize
                            font.bold: true
                            color: root.primaryColor
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 10
                        to: 200
                        stepSize: 10
                        value: root.collisionWarningDistance

                        onValueChanged: {
                            root.collisionWarningDistance = value
                        }

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth
                            height: 6
                            radius: 3
                            color: root.borderColor

                            Rectangle {
                                width: parent.width * parent.parent.visualPosition
                                height: parent.height
                                radius: parent.radius
                                color: root.primaryColor
                            }
                        }

                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: app.normalSpacing * 2
                            height: app.normalSpacing * 2
                            radius: app.normalSpacing
                            color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                            border.color: "white"
                            border.width: 2
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
                    }

                    // Engel Tespiti Aktif/Pasif
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: app.normalSpacing

                        Column {
                            Layout.fillWidth: true
                            spacing: app.smallSpacing / 2

                            Text {
                                text: root.tr("Engel Tespiti")
                                font.pixelSize: app.baseFontSize
                                color: root.textColor
                                font.bold: true
                            }

                            Text {
                                text: root.tr("Otomatik engel tespitini etkinleştirin veya devre dışı bırakın")
                                font.pixelSize: app.smallFontSize
                                color: root.textSecondaryColor
                                wrapMode: Text.WordWrap
                            }
                        }

                        Switch {
                            checked: root.obstacleDetectionEnabled
                            onToggled: {
                                root.obstacleDetectionEnabled = checked
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
                }
            }

            // Sabit Engeller
            Rectangle {
                Layout.fillWidth: true
                Layout.margins: app.normalPadding
                Layout.preferredHeight: obstaclesContent.height + app.normalPadding * 2
                color: root.cardColor
                radius: app.normalRadius
                border.width: 1
                border.color: root.borderColor

                ColumnLayout {
                    id: obstaclesContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: app.normalPadding
                    spacing: app.normalSpacing

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            Layout.fillWidth: true
                            text: root.tr("Sabit Engeller")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: root.textColor
                        }

                        Button {
                            text: "+ " + root.tr("Engel Ekle")
                            font.pixelSize: app.smallFontSize

                            background: Rectangle {
                                radius: app.smallRadius
                                color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
                            }

                            contentItem: Text {
                                text: parent.text
                                font: parent.font
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                // TODO: Engel ekleme dialog'u açılacak
                                console.log("Engel ekleme özelliği geliştirilecek")
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
                    }

                    // Engel listesi placeholder
                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: app.normalSpacing
                        Layout.bottomMargin: app.normalSpacing
                        text: root.obstacles.length === 0
                            ? root.tr("Henüz tanımlanmış engel bulunmuyor.\n'Engel Ekle' butonuna tıklayarak yeni engel ekleyebilirsiniz.")
                            : root.tr("Tanımlı engel sayısı: ") + root.obstacles.length
                        font.pixelSize: app.baseFontSize
                        color: root.textSecondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
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
        color: root.surfaceColor
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
                    color: parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor
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
                    // TODO: Save safety settings to ConfigManager
                    console.log("Emniyet ayarları kaydedilecek")
                    console.log("Çarpışma uyarı mesafesi:", root.collisionWarningDistance, "cm")
                    console.log("Engel tespiti:", root.obstacleDetectionEnabled)
                    root.configSaved()
                }
            }
        }
    }
}
