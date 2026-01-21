import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * ConfigDashboard - Ana konfigürasyon dashboard'u
 *
 * Kullanıcı giriş yaptıktan sonra bu ekran gösterilir.
 * 4 konfigürasyon kutucuğu içerir:
 * 1. Ekskavatör Ayarları
 * 2. Kazı Alanı Ayarları
 * 3. Emniyet Ayarları
 * 4. Kalibrasyon Ayarları
 */
Rectangle {
    id: root
    color: themeManager ? themeManager.backgroundColor : "#f7fafc"

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

    // Signals
    signal configurationComplete()
    signal openExcavatorConfig()
    signal openDigAreaConfig()
    signal openSafetyConfig()
    signal openCalibrationConfig()
    signal backToLogin()

    // Config progress hesaplama (root seviyesinde)
    property real configProgress: {
        var count = 0;
        if (configManager && configManager.excavatorConfigured) count++;
        if (configManager && configManager.digAreaConfigured) count++;
        if (configManager && configManager.safetyConfigured) count++;
        if (configManager && configManager.calibrationConfigured) count++;
        return count / 4;
    }

    // Theme colors - themeManager'dan al (softer light theme fallbacks)
    property color primaryColor: themeManager ? themeManager.primaryColor : "#319795"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#ffffff"
    property color backgroundColor: themeManager ? themeManager.backgroundColor : "#f7fafc"
    property color textColor: themeManager ? themeManager.textColor : "#2d3748"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#718096"
    property color borderColor: themeManager ? themeManager.borderColor : "#e2e8f0"
    property color successColor: themeManager ? themeManager.successColor : "#48bb78"
    property color warningColor: themeManager ? themeManager.warningColor : "#ed8936"

    // StackView for navigation
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: dashboardView
    }

    // Settings Menu
    Menu {
        id: settingsMenu
        width: 200

        background: Rectangle {
            color: root.surfaceColor
            radius: 8
            border.width: 1
            border.color: root.borderColor
        }

        MenuItem {
            text: "🌐 " + (translationService && translationService.currentLanguage === "tr_TR" ? "English" : "Türkçe")
            onTriggered: {
                if (translationService) {
                    translationService.switchLanguage(
                        translationService.currentLanguage === "tr_TR" ? "en_US" : "tr_TR"
                    )
                }
            }

            background: Rectangle {
                color: parent.highlighted ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.1) : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: app.baseFontSize
                color: root.textColor
                verticalAlignment: Text.AlignVCenter
            }
        }

        MenuItem {
            text: (themeManager && themeManager.isDarkTheme ? "☀️ " : "🌙 ") + root.tr("Tema")
            onTriggered: {
                if (themeManager) {
                    themeManager.toggleTheme()
                }
            }

            background: Rectangle {
                color: parent.highlighted ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.1) : "transparent"
            }

            contentItem: Text {
                text: parent.text
                font.pixelSize: app.baseFontSize
                color: root.textColor
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // Dashboard Ana Görünümü
    Component {
        id: dashboardView

        Rectangle {
            color: root.backgroundColor

            ScrollView {
                anchors.fill: parent
                contentWidth: parent.width

                ColumnLayout {
                    width: parent.width
                    spacing: 20

                    // Header - KÜÇÜLTÜLMÜŞ
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.buttonHeight * 1.5
                        color: root.primaryColor

                        // Back to Login Button (Top Left)
                        Button {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: app.smallPadding
                            width: app.buttonHeight
                            height: app.buttonHeight
                            flat: true

                            contentItem: Text {
                                text: "←"
                                font.pixelSize: 24
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "white"
                            }

                            background: Rectangle {
                                radius: 20
                                color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                            }

                            onClicked: root.backToLogin()
                        }

                        // Settings Button (Top Right)
                        Button {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: app.smallPadding
                            width: app.buttonHeight
                            height: app.buttonHeight
                            flat: true

                            contentItem: Text {
                                text: "⚙️"
                                font.pixelSize: app.mediumFontSize
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: app.buttonHeight / 2
                                color: parent.pressed ? Qt.rgba(1, 1, 1, 0.2) : (parent.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent")
                            }

                            onClicked: settingsMenu.popup()
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: app.smallSpacing

                            Text {
                                text: root.tr("Konfigürasyon Merkezi")
                                font.pixelSize: app.mediumFontSize
                                font.bold: true
                                color: "white"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: root.tr("Lütfen aşağıdaki ayarları tamamlayın")
                                font.pixelSize: app.smallFontSize
                                color: Qt.rgba(1, 1, 1, 0.8)
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Progress indicator
                            Rectangle {
                                Layout.preferredWidth: app.largeIconSize * 4
                                Layout.preferredHeight: app.smallSpacing * 0.6
                                Layout.alignment: Qt.AlignHCenter
                                radius: app.smallRadius * 0.5
                                color: Qt.rgba(1, 1, 1, 0.3)

                                Rectangle {
                                    width: parent.width * root.configProgress
                                    height: parent.height
                                    radius: app.smallRadius * 0.5
                                    color: "white"

                                    Behavior on width {
                                        NumberAnimation { duration: 300 }
                                    }
                                }
                            }
                        }
                    }

                    // Config Tiles Grid
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.margins: 20
                        columns: 2
                        rowSpacing: 20
                        columnSpacing: 20

                        // 1. Ekskavatör Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.largeIconSize * 3.8
                            title: root.tr("Ekskavatör Ayarları")
                            description: root.tr("Boom, arm uzunlukları ve ekskavatör adı")
                            imageSource: "qrc:/ExcavatorUI_Qt3D/resources/icons/config_excavator.png"
                            icon: "🚜"
                            stepNumber: 1
                            isConfigured: configManager ? configManager.excavatorConfigured : false
                            isEnabled: true
                            // Theme colors
                            tilePrimaryColor: root.primaryColor
                            tileSurfaceColor: root.surfaceColor
                            tileTextColor: root.textColor
                            tileTextSecondaryColor: root.textSecondaryColor
                            tileBorderColor: root.borderColor
                            tileWarningColor: root.warningColor

                            onClicked: {
                                stackView.push(excavatorConfigComponent)
                            }
                        }

                        // 2. Kazı Alanı Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.largeIconSize * 3.8
                            title: root.tr("Kazı Alanı Ayarları")
                            description: root.tr("Grid sistemi ve batimetrik veri girişi")
                            imageSource: "qrc:/ExcavatorUI_Qt3D/resources/icons/config_dig_area.png"
                            icon: "📐"
                            stepNumber: 2
                            isConfigured: configManager ? configManager.digAreaConfigured : false
                            isEnabled: true
                            // Theme colors
                            tilePrimaryColor: root.primaryColor
                            tileSurfaceColor: root.surfaceColor
                            tileTextColor: root.textColor
                            tileTextSecondaryColor: root.textSecondaryColor
                            tileBorderColor: root.borderColor
                            tileWarningColor: root.warningColor

                            onClicked: {
                                stackView.push(digAreaConfigComponent)
                            }
                        }

                        // 3. Emniyet Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.largeIconSize * 3.8
                            title: root.tr("Emniyet Ayarları")
                            description: root.tr("Sabit engeller ve çarpışma uyarısı")
                            imageSource: "qrc:/ExcavatorUI_Qt3D/resources/icons/config_safety.png"
                            icon: "🛡️"
                            stepNumber: 3
                            isConfigured: configManager ? configManager.safetyConfigured : false
                            isEnabled: true
                            // Theme colors
                            tilePrimaryColor: root.primaryColor
                            tileSurfaceColor: root.surfaceColor
                            tileTextColor: root.textColor
                            tileTextSecondaryColor: root.textSecondaryColor
                            tileBorderColor: root.borderColor
                            tileWarningColor: root.warningColor

                            onClicked: {
                                stackView.push(safetyConfigComponent)
                            }
                        }

                        // 4. Kalibrasyon Ayarları
                        ConfigTile {
                            Layout.fillWidth: true
                            Layout.preferredHeight: app.largeIconSize * 3.8
                            title: root.tr("Kalibrasyon Ayarları")
                            description: root.tr("Sensör kalibrasyonu ve ayarları")
                            imageSource: "qrc:/ExcavatorUI_Qt3D/resources/icons/config_calibration.png"
                            icon: "⚙️"
                            stepNumber: 4
                            isConfigured: configManager ? configManager.calibrationConfigured : false
                            isEnabled: true
                            // Theme colors
                            tilePrimaryColor: root.primaryColor
                            tileSurfaceColor: root.surfaceColor
                            tileTextColor: root.textColor
                            tileTextSecondaryColor: root.textSecondaryColor
                            tileBorderColor: root.borderColor
                            tileWarningColor: root.warningColor

                            onClicked: {
                                stackView.push(calibrationConfigComponent)
                            }
                        }
                    }

                    // Ana Ekrana Geç Butonu
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 56
                        Layout.bottomMargin: 40
                        text: root.tr("Ana Ekrana Geç")
                        enabled: configManager ? configManager.isConfigured : false

                        background: Rectangle {
                            radius: 12
                            color: parent.enabled
                                ? (parent.pressed ? Qt.darker(root.primaryColor, 1.2) : root.primaryColor)
                                : root.surfaceColor

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: parent.enabled ? "white" : root.textSecondaryColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (configManager) configManager.saveConfig()
                            root.configurationComplete()
                        }
                    }

                    // Yardım metni
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 20
                        text: (configManager && configManager.isConfigured)
                            ? root.tr("Tüm ayarlar tamamlandı!")
                            : root.tr("Tüm adımları tamamladığınızda ana ekrana geçebilirsiniz")
                        font.pixelSize: app.smallFontSize
                        color: (configManager && configManager.isConfigured) ? root.successColor : root.textSecondaryColor
                    }
                }
            }
        }
    }

    // Excavator Config Component
    Component {
        id: excavatorConfigComponent
        ExcavatorConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                if (configManager) {
                    configManager.markExcavatorConfigured()
                    configManager.saveConfig()
                }
                stackView.pop()
            }
        }
    }

    // Dig Area Config Component
    Component {
        id: digAreaConfigComponent
        DigAreaConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                if (configManager) {
                    configManager.markDigAreaConfigured()
                    configManager.saveConfig()
                }
                stackView.pop()
            }
        }
    }

    // Safety Config Component
    Component {
        id: safetyConfigComponent
        SafetyConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                if (configManager) {
                    configManager.markSafetyConfigured()
                    configManager.saveConfig()
                }
                stackView.pop()
            }
        }
    }

    // Calibration Config Component
    Component {
        id: calibrationConfigComponent
        CalibrationConfigPage {
            onBack: stackView.pop()
            onConfigSaved: {
                if (configManager) {
                    configManager.markCalibrationConfigured()
                    configManager.saveConfig()
                }
                stackView.pop()
            }
        }
    }

    // ConfigTile Component - with explicit color properties to avoid scope issues
    component ConfigTile: Rectangle {
        id: tile

        property string title: ""
        property string description: ""
        property string icon: ""  // Fallback emoji icon
        property string imageSource: ""  // Primary image icon
        property int stepNumber: 1
        property bool isConfigured: false
        property bool isEnabled: true

        // Theme color properties (passed from parent - softer fallbacks)
        property color tilePrimaryColor: "#319795"
        property color tileSurfaceColor: "#ffffff"
        property color tileTextColor: "white"
        property color tileTextSecondaryColor: "#e0e0e0"
        property color tileBorderColor: "#e2e8f0"
        property color tileWarningColor: "#ed8936"

        signal clicked()

        // Tamamlanan kutucuklar mavi, diğerleri normal
        color: tile.isConfigured ? tile.tilePrimaryColor : tile.tileSurfaceColor
        radius: 16
        border.width: tile.isConfigured ? 0 : 1
        border.color: tile.tileBorderColor

        MouseArea {
            anchors.fill: parent
            enabled: tile.isEnabled
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                tile.clicked()
            }

            onPressed: {
                tile.scale = 0.98
            }

            onReleased: {
                tile.scale = 1.0
            }
        }

        Behavior on scale {
            NumberAnimation { duration: 100 }
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: app.smallPadding * 0.8
            spacing: app.smallSpacing * 0.3

            // Üst kısım: Başlık ve durum badge yan yana
            RowLayout {
                Layout.fillWidth: true
                spacing: app.smallSpacing * 0.6

                // Başlık - kutucuğun üstünde belirgin şekilde
                Text {
                    Layout.fillWidth: true
                    text: tile.title
                    font.pixelSize: app.smallFontSize * 1.1
                    font.bold: true
                    color: tile.isConfigured ? "white" : tile.tileTextColor
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }

                // Status indicator
                Rectangle {
                    Layout.preferredWidth: statusText.width + 12
                    Layout.preferredHeight: 22
                    radius: 11
                    color: tile.isConfigured
                        ? Qt.rgba(1, 1, 1, 0.25)
                        : Qt.rgba(tile.tileWarningColor.r, tile.tileWarningColor.g, tile.tileWarningColor.b, 0.2)

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: tile.isConfigured ? "✓" : "..."
                        font.pixelSize: app.smallFontSize * 0.8
                        font.bold: true
                        color: tile.isConfigured ? "white" : tile.tileWarningColor
                    }
                }
            }

            // Icon - Image with emoji fallback (KÜÇÜLTÜLMÜŞ)
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: true
                Layout.preferredWidth: app.largeIconSize
                Layout.preferredHeight: app.largeIconSize

                // Image icon (primary)
                Image {
                    id: tileIconImage
                    anchors.centerIn: parent
                    source: tile.imageSource
                    width: app.iconSize
                    height: app.iconSize
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    antialiasing: true
                    visible: status === Image.Ready
                }

                // Emoji icon (fallback when image not available)
                Text {
                    anchors.centerIn: parent
                    text: tile.icon
                    font.pixelSize: app.iconSize
                    visible: tileIconImage.status !== Image.Ready
                }
            }

            // Description
            Text {
                Layout.fillWidth: true
                text: tile.description
                font.pixelSize: app.smallFontSize * 0.85
                color: tile.isConfigured ? Qt.rgba(1, 1, 1, 0.9) : tile.tileTextSecondaryColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            // Alt kısımda düzenle/yapılandır butonu görünümü
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: app.smallButtonHeight * 0.6
                radius: 6
                color: tile.isConfigured
                    ? Qt.rgba(1, 1, 1, 0.2)
                    : Qt.rgba(tile.tilePrimaryColor.r, tile.tilePrimaryColor.g, tile.tilePrimaryColor.b, 0.1)

                Text {
                    anchors.centerIn: parent
                    text: tile.isConfigured ? root.tr("Düzenle") : root.tr("Yapılandır")
                    font.pixelSize: app.smallFontSize * 0.9
                    font.bold: true
                    color: tile.isConfigured ? "white" : tile.tilePrimaryColor
                }
            }
        }
    }
}
