import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Ayarlar Sayfası - StackView ile alt sayfa navigasyonu
Rectangle {
    id: settingsPage
    // Global responsive değişkenlere erişim
    property var app: ApplicationWindow.window

    color: themeManager ? themeManager.backgroundColor : "#2d3748"
    // Global responsive değişkenlere erişim

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#38b2ac"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#2a2a2a"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#3a3a3a"

    // Dil değişikliği tetikleyici
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

    // Ana StackView - ayar kategorileri ve alt sayfalar arası geçiş
    StackView {
        id: settingsStack
        anchors.fill: parent
        initialItem: settingsListComponent
    }

    // Ana Ayarlar Listesi Component
    Component {
        id: settingsListComponent

        Rectangle {
            color: settingsPage.color
    // Global responsive değişkenlere erişim

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Başlık
                Text {
                    text: tr("Settings")
                    font.pixelSize: 28
                    font.bold: true
                    color: settingsPage.textColor
                    Layout.fillWidth: true
                }

                // Ayar kategorileri listesi
                ListView {
                    id: settingsListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    clip: true

                    model: ListModel {
                        // 1. Kullanıcı İşlemleri
                        ListElement {
                            icon: "👥"
                            titleKey: "User Operations"
                            titleTr: "Kullanıcı İşlemleri"
                            descKey: "Operator list, add/remove users, change password"
                            descTr: "Operatör listesi, kullanıcı ekleme/silme, şifre değiştirme"
                            pageName: "users"
                            enabled: true
                            adminOnly: false
                        }
                        // 2. Tema Seçimi
                        ListElement {
                            icon: "🎨"
                            titleKey: "Theme"
                            titleTr: "Tema Seçimi"
                            descKey: "Light and dark theme settings"
                            descTr: "Açık ve koyu tema ayarları"
                            pageName: "display"
                            enabled: true
                            adminOnly: false
                        }
                        // 3. Harita Ayarları
                        ListElement {
                            icon: "🗺️"
                            titleKey: "Map Settings"
                            titleTr: "Harita Ayarları"
                            descKey: "Map view and layer settings"
                            descTr: "Harita görünümü ve katman ayarları"
                            pageName: "map"
                            enabled: true
                            adminOnly: false
                        }
                        // 4. Alarm Ayarları
                        ListElement {
                            icon: "🔔"
                            titleKey: "Alarm Settings"
                            titleTr: "Alarm Ayarları"
                            descKey: "Alarm thresholds and notification settings"
                            descTr: "Alarm eşikleri ve bildirim ayarları"
                            pageName: "alarm"
                            enabled: true
                            adminOnly: false
                        }
                        // 5. Dil Seçimi
                        ListElement {
                            icon: "🌐"
                            titleKey: "Language"
                            titleTr: "Dil Seçimi"
                            descKey: "Application language settings"
                            descTr: "Uygulama dili ayarları"
                            pageName: "language"
                            enabled: true
                            adminOnly: false
                        }
                        // 6. Ekskavatör Ekran Ayarları
                        ListElement {
                            icon: "🚜"
                            titleKey: "Excavator Display"
                            titleTr: "Ekskavatör Ekran Ayarları"
                            descKey: "Excavator view and display settings"
                            descTr: "Ekskavatör görünüm ve ekran ayarları"
                            pageName: "excavatorDisplay"
                            enabled: true
                            adminOnly: false
                        }
                        // 7. Derinlik Paneli Ayarları
                        ListElement {
                            icon: "📊"
                            titleKey: "Depth Panel Settings"
                            titleTr: "Derinlik Paneli Ayarları"
                            descKey: "Color, reference points, 3D view settings"
                            descTr: "Renk, referans noktaları, 3B görünüm ayarları"
                            pageName: "depthPanel"
                            enabled: true
                            adminOnly: false
                        }
                        // 8. Raporlar ve Kayıtlar
                        ListElement {
                            icon: "📋"
                            titleKey: "Reports & Logs"
                            titleTr: "Raporlar ve Kayıtlar"
                            descKey: "Safety switch cancellations, alarm logs"
                            descTr: "Emniyet switch iptalleri, alarm kayıtları"
                            pageName: "reports"
                            enabled: true
                            adminOnly: false
                        }
                        // 9. Donanım Ayarları
                        ListElement {
                            icon: "🔧"
                            titleKey: "Hardware Settings"
                            titleTr: "Donanım Ayarları"
                            descKey: "Bluetooth, IMU, GNSS, safety switch management"
                            descTr: "Bluetooth, IMU, GNSS, emniyet anahtarı yönetimi"
                            pageName: "hardware"
                            enabled: true
                            adminOnly: false
                        }
                        // 10. Ekran Ayarları
                        ListElement {
                            icon: "🖵"
                            titleKey: "Screen Settings"
                            titleTr: "Ekran Ayarları"
                            descKey: "Screensaver timeout and display settings"
                            descTr: "Bekleme ekranı süresi ve görüntü ayarları"
                            pageName: "screen"
                            enabled: true
                            adminOnly: true
                        }
                        // 11. Sistem
                        ListElement {
                            icon: "💻"
                            titleKey: "System"
                            titleTr: "Sistem"
                            descKey: "Storage usage information"
                            descTr: "Kayıt alanı doluluk bilgileri"
                            pageName: "system"
                            enabled: true
                            adminOnly: false
                        }
                        // 12. Hakkında
                        ListElement {
                            icon: "ℹ️"
                            titleKey: "About"
                            titleTr: "Hakkında"
                            descKey: "Software version, license references"
                            descTr: "Yazılım sürüm bilgileri, lisans referansları"
                            pageName: "about"
                            enabled: true
                            adminOnly: false
                        }
                    }

                    delegate: Rectangle {
                        width: settingsListView.width
                        height: 80
                        radius: 10
                        color: itemEnabled ? settingsPage.surfaceColor : Qt.darker(settingsPage.surfaceColor, 1.2)
    // Global responsive değişkenlere erişim
                        border.color: settingsPage.borderColor
                        border.width: 1
                        opacity: itemEnabled ? 1.0 : 0.6

                        // Admin kontrolü - adminOnly true ise sadece admin görebilir
                        property bool isAdmin: authService ? authService.isAdmin : false
                        property bool itemEnabled: model.enabled && (!model.adminOnly || isAdmin)
                        visible: !model.adminOnly || isAdmin

                        property string itemTitle: {
                            if (translationService && translationService.currentLanguage === "tr_TR") {
                                return model.titleTr
                            } else {
                                return model.titleKey
                            }
                        }

                        property string itemDesc: {
                            if (translationService && translationService.currentLanguage === "tr_TR") {
                                return model.descTr
                            } else {
                                return model.descKey
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            // İkon
                            Rectangle {
                                width: 50
                                height: 50
                                radius: 10
                                color: Qt.darker(settingsPage.surfaceColor, 1.1)
    // Global responsive değişkenlere erişim

                                Text {
                                    anchors.centerIn: parent
                                    text: model.icon
                                    font.pixelSize: app.xlFontSize
                                }
                            }

                            // Başlık ve açıklama
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5

                                Row {
                                    spacing: 10

                                    Text {
                                        text: itemTitle
                                        font.pixelSize: app.mediumFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                    }

                                    // "Yakında" badge for disabled items
                                    Rectangle {
                                        visible: !itemEnabled
                                        width: yakindaText.width + 12
                                        height: 20
                                        radius: 10
                                        color: settingsPage.primaryColor
    // Global responsive değişkenlere erişim

                                        Text {
                                            id: yakindaText
                                            anchors.centerIn: parent
                                            text: tr("Soon")
                                            font.pixelSize: app.smallFontSize * 0.8
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    // Admin badge
                                    Rectangle {
                                        visible: model.adminOnly && isAdmin
                                        width: adminText.width + 12
                                        height: 20
                                        radius: 10
                                        color: "#e74c3c"
    // Global responsive değişkenlere erişim

                                        Text {
                                            id: adminText
                                            anchors.centerIn: parent
                                            text: "Admin"
                                            font.pixelSize: app.smallFontSize * 0.8
                                            font.bold: true
                                            color: "white"
                                        }
                                    }
                                }

                                Text {
                                    text: itemDesc
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            // Sağ ok
                            Text {
                                text: "›"
                                font.pixelSize: app.xlFontSize
                                color: itemEnabled ? settingsPage.textSecondaryColor : Qt.darker(settingsPage.textSecondaryColor, 1.5)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: itemEnabled
                            cursorShape: itemEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                            onClicked: {
                                if (model.pageName === "users") {
                                    settingsStack.push(userManagementComponent)
                                } else if (model.pageName === "screen") {
                                    settingsStack.push(screenSettingsComponent)
                                } else if (model.pageName === "display") {
                                    settingsStack.push(displaySettingsComponent)
                                } else if (model.pageName === "language") {
                                    settingsStack.push(languageSettingsComponent)
                                } else if (model.pageName === "map") {
                                    settingsStack.push(mapSettingsComponent)
                                } else if (model.pageName === "alarm") {
                                    settingsStack.push(alarmSettingsComponent)
                                } else if (model.pageName === "excavatorDisplay") {
                                    settingsStack.push(excavatorDisplaySettingsComponent)
                                } else if (model.pageName === "depthPanel") {
                                    settingsStack.push(depthPanelSettingsComponent)
                                } else if (model.pageName === "reports") {
                                    settingsStack.push(reportsSettingsComponent)
                                } else if (model.pageName === "hardware") {
                                    settingsStack.push(hardwareSettingsComponent)
                                } else if (model.pageName === "system") {
                                    settingsStack.push(systemSettingsComponent)
                                } else if (model.pageName === "about") {
                                    settingsStack.push(aboutSettingsComponent)
                                }
                            }

                            onEntered: if (itemEnabled) parent.color = Qt.lighter(settingsPage.surfaceColor, 1.1)
                            onExited: parent.color = itemEnabled ? settingsPage.surfaceColor : Qt.darker(settingsPage.surfaceColor, 1.2)
                        }

                        Behavior on color {
                            ColorAnimation { duration: 100 }
                        }
                    }
                }
            }
        }
    }

    // Kullanıcı Yönetimi Sayfası Component
    Component {
        id: userManagementComponent

        Rectangle {
            color: settingsPage.color
    // Global responsive değişkenlere erişim

            // Geri butonu ile birlikte UserManagementView
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Geri butonu header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor
    // Global responsive değişkenlere erişim

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
    // Global responsive değişkenlere erişim
                                radius: 8
                            }

                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Users")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }

                        // Boşluk için placeholder
                        Item { width: 80 }
                    }

                    // Alt çizgi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
    // Global responsive değişkenlere erişim
                    }
                }

                // UserManagementView içeriği - Loader yerine doğrudan kullanım
                UserManagementView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    // Ekran Ayarları Sayfası Component (Admin only)
    Component {
        id: screenSettingsComponent

        Rectangle {
            color: settingsPage.color
    // Global responsive değişkenlere erişim

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Geri butonu header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor
    // Global responsive değişkenlere erişim

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
    // Global responsive değişkenlere erişim
                                radius: 8
                            }

                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Screen Settings")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }

                        // Boşluk için placeholder
                        Item { width: 80 }
                    }

                    // Alt çizgi
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
    // Global responsive değişkenlere erişim
                    }
                }

                // Ekran Ayarları içeriği
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Bekleme Ekranı bölümü
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: screenSaverContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
    // Global responsive değişkenlere erişim
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: screenSaverContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                // Timeout değerini formatlama fonksiyonu
                                function formatTimeout(seconds) {
                                    if (seconds < 60) {
                                        return seconds + " " + tr("sec")
                                    } else {
                                        var mins = Math.floor(seconds / 60)
                                        var secs = seconds % 60
                                        if (secs === 0) {
                                            return mins + " " + tr("min")
                                        } else {
                                            return mins + " " + tr("min") + " " + secs + " " + tr("sec")
                                        }
                                    }
                                }

                                // Başlık
                                Text {
                                    text: tr("Screensaver")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                // Açık/Kapalı Switch
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Text {
                                        text: tr("Enable Screensaver")
                                        font.pixelSize: app.baseFontSize
                                        color: settingsPage.textColor
                                        Layout.fillWidth: true
                                    }

                                    Switch {
                                        id: screenSaverSwitch
                                        checked: configManager ? configManager.screenSaverEnabled : true

                                        onCheckedChanged: {
                                            if (configManager) {
                                                configManager.screenSaverEnabled = checked
                                            }
                                        }

                                        // Özel switch stili
                                        indicator: Rectangle {
                                            implicitWidth: 52
                                            implicitHeight: 28
                                            x: screenSaverSwitch.leftPadding
                                            y: parent.height / 2 - height / 2
                                            radius: 14
                                            color: screenSaverSwitch.checked ? settingsPage.primaryColor : Qt.darker(settingsPage.surfaceColor, 1.3)
    // Global responsive değişkenlere erişim
                                            border.color: screenSaverSwitch.checked ? Qt.darker(settingsPage.primaryColor, 1.1) : settingsPage.borderColor
                                            border.width: 1

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }

                                            Rectangle {
                                                x: screenSaverSwitch.checked ? parent.width - width - 3 : 3
                                                y: 3
                                                width: 22
                                                height: 22
                                                radius: 11
                                                color: "white"
    // Global responsive değişkenlere erişim

                                                Behavior on x {
                                                    NumberAnimation { duration: 150 }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Açıklama
                                Text {
                                    text: tr("When enabled, screensaver will appear after inactivity on login screen")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Ayırıcı
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: settingsPage.borderColor
    // Global responsive değişkenlere erişim
                                }

                                // Timeout ayarı
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    enabled: screenSaverSwitch.checked
                                    opacity: screenSaverSwitch.checked ? 1.0 : 0.5

                                    Text {
                                        text: tr("Timeout Duration")
                                        font.pixelSize: app.baseFontSize
                                        color: settingsPage.textColor
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15

                                        Slider {
                                            id: timeoutSlider
                                            Layout.fillWidth: true
                                            from: 10      // 10 saniye minimum
                                            to: 1800      // 30 dakika maksimum
                                            stepSize: 10  // 10 saniye adımlarla
                                            value: configManager ? configManager.screenSaverTimeoutSeconds : 120

                                            onValueChanged: {
                                                if (configManager) {
                                                    configManager.screenSaverTimeoutSeconds = value
                                                }
                                            }

                                            background: Rectangle {
                                                x: timeoutSlider.leftPadding
                                                y: timeoutSlider.topPadding + timeoutSlider.availableHeight / 2 - height / 2
                                                width: timeoutSlider.availableWidth
                                                height: 6
                                                radius: 3
                                                color: Qt.darker(settingsPage.surfaceColor, 1.3)
    // Global responsive değişkenlere erişim

                                                Rectangle {
                                                    width: timeoutSlider.visualPosition * parent.width
                                                    height: parent.height
                                                    radius: 3
                                                    color: settingsPage.primaryColor
    // Global responsive değişkenlere erişim
                                                }
                                            }

                                            handle: Rectangle {
                                                x: timeoutSlider.leftPadding + timeoutSlider.visualPosition * (timeoutSlider.availableWidth - width)
                                                y: timeoutSlider.topPadding + timeoutSlider.availableHeight / 2 - height / 2
                                                width: 20
                                                height: 20
                                                radius: 10
                                                color: timeoutSlider.pressed ? Qt.lighter(settingsPage.primaryColor, 1.2) : settingsPage.primaryColor
    // Global responsive değişkenlere erişim
                                                border.color: Qt.darker(settingsPage.primaryColor, 1.2)
                                                border.width: 2
                                            }
                                        }

                                        // Değer göstergesi
                                        Rectangle {
                                            width: 80
                                            height: 35
                                            radius: 8
                                            color: Qt.darker(settingsPage.surfaceColor, 1.2)
    // Global responsive değişkenlere erişim
                                            border.color: settingsPage.primaryColor
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: screenSaverContent.formatTimeout(timeoutSlider.value)
                                                font.pixelSize: app.smallFontSize
                                                font.bold: true
                                                color: settingsPage.primaryColor
                                            }
                                        }
                                    }

                                    // Preset butonları - 2 satır halinde
                                    GridLayout {
                                        Layout.fillWidth: true
                                        columns: 3
                                        rowSpacing: 8
                                        columnSpacing: 8

                                        Repeater {
                                            // [saniye değeri, gösterim metni]
                                            model: ListModel {
                                                ListElement { seconds: 10; labelKey: "10 sec"; labelTr: "10 sn" }
                                                ListElement { seconds: 30; labelKey: "30 sec"; labelTr: "30 sn" }
                                                ListElement { seconds: 60; labelKey: "1 min"; labelTr: "1 dk" }
                                                ListElement { seconds: 120; labelKey: "2 min"; labelTr: "2 dk" }
                                                ListElement { seconds: 300; labelKey: "5 min"; labelTr: "5 dk" }
                                                ListElement { seconds: 1800; labelKey: "30 min"; labelTr: "30 dk" }
                                            }

                                            Button {
                                                property string btnLabel: (translationService && translationService.currentLanguage === "tr_TR") ? model.labelTr : model.labelKey

                                                text: btnLabel
                                                flat: true
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 36

                                                background: Rectangle {
                                                    radius: 8
                                                    color: timeoutSlider.value === model.seconds ?
    // Global responsive değişkenlere erişim
                                                           settingsPage.primaryColor :
                                                           Qt.darker(settingsPage.surfaceColor, 1.2)
                                                    border.color: settingsPage.primaryColor
                                                    border.width: 1
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    font.pixelSize: app.smallFontSize
                                                    color: timeoutSlider.value === model.seconds ? "white" : settingsPage.textColor
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                onClicked: {
                                                    timeoutSlider.value = model.seconds
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Bilgi kartı
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: infoContent.height + 30
                            radius: 12
                            color: Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.1)
    // Global responsive değişkenlere erişim
                            border.color: settingsPage.primaryColor
                            border.width: 1

                            RowLayout {
                                id: infoContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 15
                                spacing: 15

                                Text {
                                    text: tr("Screensaver activates only on login screen when there is no user activity. Touch or move mouse to dismiss.")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // Splash Screen Timeout Ayarı
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: splashTimeoutContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: splashTimeoutContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Splash Screen Duration")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: tr("Set how long the splash screen is displayed when the application starts (1-10 seconds)")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Slider {
                                        id: splashTimeoutSlider
                                        Layout.fillWidth: true
                                        from: 1000
                                        to: 10000
                                        stepSize: 500
                                        value: configManager ? configManager.splashScreenTimeoutMilliseconds : 3000

                                        onValueChanged: {
                                            if (configManager && configManager.splashScreenTimeoutMilliseconds !== value) {
                                                configManager.splashScreenTimeoutMilliseconds = value
                                            }
                                        }

                                        background: Rectangle {
                                            x: splashTimeoutSlider.leftPadding
                                            y: splashTimeoutSlider.topPadding + splashTimeoutSlider.availableHeight / 2 - height / 2
                                            width: splashTimeoutSlider.availableWidth
                                            height: 6
                                            radius: 3
                                            color: Qt.darker(settingsPage.surfaceColor, 1.3)

                                            Rectangle {
                                                width: splashTimeoutSlider.visualPosition * parent.width
                                                height: parent.height
                                                radius: 3
                                                color: settingsPage.primaryColor
                                            }
                                        }

                                        handle: Rectangle {
                                            x: splashTimeoutSlider.leftPadding + splashTimeoutSlider.visualPosition * (splashTimeoutSlider.availableWidth - width)
                                            y: splashTimeoutSlider.topPadding + splashTimeoutSlider.availableHeight / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: splashTimeoutSlider.pressed ? Qt.lighter(settingsPage.primaryColor, 1.2) : settingsPage.primaryColor
                                            border.color: Qt.darker(settingsPage.primaryColor, 1.2)
                                            border.width: 2
                                        }
                                    }

                                    Rectangle {
                                        width: 80
                                        height: 35
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.2)
                                        border.color: settingsPage.primaryColor
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: (configManager ? configManager.splashScreenTimeoutMilliseconds / 1000 : 3) + " " + tr("sec")
                                            font.pixelSize: app.smallFontSize
                                            font.bold: true
                                            color: settingsPage.primaryColor
                                        }
                                    }
                                }

                                // Preset butonları
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 4
                                    rowSpacing: 8
                                    columnSpacing: 8

                                    Repeater {
                                        model: ListModel {
                                            ListElement { milliseconds: 1000; labelKey: "1 sec"; labelTr: "1 sn" }
                                            ListElement { milliseconds: 2000; labelKey: "2 sec"; labelTr: "2 sn" }
                                            ListElement { milliseconds: 3000; labelKey: "3 sec"; labelTr: "3 sn" }
                                            ListElement { milliseconds: 5000; labelKey: "5 sec"; labelTr: "5 sn" }
                                        }

                                        Button {
                                            property string btnLabel: (translationService && translationService.currentLanguage === "tr_TR") ? model.labelTr : model.labelKey

                                            text: btnLabel
                                            flat: true
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 36

                                            background: Rectangle {
                                                radius: 8
                                                color: splashTimeoutSlider.value === model.milliseconds ?
                                                       settingsPage.primaryColor :
                                                       Qt.darker(settingsPage.surfaceColor, 1.2)
                                                border.color: settingsPage.primaryColor
                                                border.width: 1
                                            }

                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: app.smallFontSize
                                                color: splashTimeoutSlider.value === model.milliseconds ? "white" : settingsPage.textColor
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                splashTimeoutSlider.value = model.milliseconds
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Alt boşluk
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Görünüm (Display/Tema) Ayarları Sayfası Component
    Component {
        id: displaySettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Geri butonu header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }

                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Display")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }

                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                // Tema Ayarları içeriği
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Tema bölümü
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: themeContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: themeContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Theme")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                // Tema seçimi
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    // Açık tema
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        radius: 12
                                        color: themeManager && !themeManager.isDarkTheme ? settingsPage.primaryColor : Qt.darker(settingsPage.surfaceColor, 1.1)
                                        border.color: themeManager && !themeManager.isDarkTheme ? settingsPage.primaryColor : settingsPage.borderColor
                                        border.width: 2

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 8

                                            Rectangle {
                                                width: 40
                                                height: 40
                                                radius: 20
                                                color: "#f7fafc"
                                                border.color: "#e2e8f0"
                                                border.width: 1
                                                anchors.horizontalCenter: parent.horizontalCenter

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "☀️"
                                                    font.pixelSize: 20
                                                }
                                            }

                                            Text {
                                                text: tr("Light")
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: themeManager && !themeManager.isDarkTheme ? "white" : settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (themeManager && themeManager.isDarkTheme) {
                                                    themeManager.toggleTheme()
                                                }
                                            }
                                        }
                                    }

                                    // Koyu tema
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 100
                                        radius: 12
                                        color: themeManager && themeManager.isDarkTheme ? settingsPage.primaryColor : Qt.darker(settingsPage.surfaceColor, 1.1)
                                        border.color: themeManager && themeManager.isDarkTheme ? settingsPage.primaryColor : settingsPage.borderColor
                                        border.width: 2

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 8

                                            Rectangle {
                                                width: 40
                                                height: 40
                                                radius: 20
                                                color: "#2d3748"
                                                border.color: "#4a5568"
                                                border.width: 1
                                                anchors.horizontalCenter: parent.horizontalCenter

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "🌙"
                                                    font.pixelSize: 20
                                                }
                                            }

                                            Text {
                                                text: tr("Dark")
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: themeManager && themeManager.isDarkTheme ? "white" : settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (themeManager && !themeManager.isDarkTheme) {
                                                    themeManager.toggleTheme()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Dil & Birimler Ayarları Sayfası Component
    Component {
        id: languageSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Geri butonu header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }

                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Language & Units")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }

                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                // Dil Ayarları içeriği
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Dil bölümü
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: languageContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: languageContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Language")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                // Dil seçimi
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    // Türkçe
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 80
                                        radius: 12
                                        color: translationService && translationService.currentLanguage === "tr_TR" ? settingsPage.primaryColor : Qt.darker(settingsPage.surfaceColor, 1.1)
                                        border.color: translationService && translationService.currentLanguage === "tr_TR" ? settingsPage.primaryColor : settingsPage.borderColor
                                        border.width: 2

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 12

                                            Text {
                                                text: "🇹🇷"
                                                font.pixelSize: 28
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "Türkçe"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: translationService && translationService.currentLanguage === "tr_TR" ? "white" : settingsPage.textColor
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (translationService && translationService.currentLanguage !== "tr_TR") {
                                                    translationService.switchLanguage("tr_TR")
                                                }
                                            }
                                        }
                                    }

                                    // English
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 80
                                        radius: 12
                                        color: translationService && translationService.currentLanguage === "en_US" ? settingsPage.primaryColor : Qt.darker(settingsPage.surfaceColor, 1.1)
                                        border.color: translationService && translationService.currentLanguage === "en_US" ? settingsPage.primaryColor : settingsPage.borderColor
                                        border.width: 2

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 12

                                            Text {
                                                text: "🇬🇧"
                                                font.pixelSize: 28
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "English"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: translationService && translationService.currentLanguage === "en_US" ? "white" : settingsPage.textColor
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (translationService && translationService.currentLanguage !== "en_US") {
                                                    translationService.switchLanguage("en_US")
                                                }
                                            }
                                        }
                                    }
                                }

                                // Açıklama
                                Text {
                                    text: tr("App language will change immediately after selection")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Harita Ayarları Sayfası Component
    Component {
        id: mapSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Map Settings")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Harita Katmanları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: mapLayersContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: mapLayersContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Map Layers")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("Configure visible map layers and display options")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Placeholder for map layer settings
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Map layer settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Alarm Ayarları Sayfası Component
    Component {
        id: alarmSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Alarm Settings")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Alarm Eşikleri
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: alarmThresholdsContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: alarmThresholdsContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Alarm Thresholds")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("Configure alarm thresholds and notification settings")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Placeholder for alarm settings
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Alarm threshold settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Ekskavatör Ekran Ayarları Sayfası Component
    Component {
        id: excavatorDisplaySettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Excavator Display")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Ekskavatör Görünüm Ayarları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: excavatorViewContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: excavatorViewContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Excavator View Settings")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("Configure excavator display and view options")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Placeholder for excavator display settings
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Excavator display settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Derinlik Paneli Ayarları Sayfası Component
    Component {
        id: depthPanelSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Depth Panel Settings")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Renk Ayarları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: depthColorContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: depthColorContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Color Settings")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("Configure depth panel color scheme")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Color settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        // Referans Noktaları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: refPointsContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: refPointsContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Reference Points")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("Configure depth reference points")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Reference point settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        // 3B Görünüm Ayarları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: view3DContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: view3DContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("3D View Settings")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("Configure 3D view display options")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("3D view settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Raporlar ve Kayıtlar Sayfası Component
    Component {
        id: reportsSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Reports & Logs")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Emniyet Switch İptalleri
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: safetySwitchContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: safetySwitchContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Safety Switch Cancellations")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("View safety switch cancellation logs")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Safety switch logs will be displayed here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        // Alarm Kayıtları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: alarmLogsContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: alarmLogsContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Alarm Logs")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("View alarm history and logs")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 100
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Alarm logs will be displayed here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Donanım Ayarları Sayfası Component
    Component {
        id: hardwareSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("Hardware Settings")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Bluetooth Ayarları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: bluetoothHwContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: bluetoothHwContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: settingsPage.primaryColor

                                        Text {
                                            anchors.centerIn: parent
                                            text: "🔵"
                                            font.pixelSize: 20
                                        }
                                    }

                                    Text {
                                        text: tr("Bluetooth Settings")
                                        font.pixelSize: app.mediumFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: tr("Configure Bluetooth connection and device management")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Bluetooth settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        // IMU Durum & Ayarları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: imuHwContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: imuHwContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "#4CAF50"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "📡"
                                            font.pixelSize: 20
                                        }
                                    }

                                    Text {
                                        text: tr("IMU Status & Settings")
                                        font.pixelSize: app.mediumFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: tr("IMU sensor calibration and status information")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("IMU settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        // GNSS Durum & Ayarları
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: gnssHwContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: gnssHwContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "#2196F3"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "📍"
                                            font.pixelSize: 20
                                        }
                                    }

                                    Text {
                                        text: tr("GNSS Status & Settings")
                                        font.pixelSize: app.mediumFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: tr("GNSS configuration and status information")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("GNSS settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        // Emniyet Anahtarı Yönetimi
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: safetyKeyContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: safetyKeyContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "#f44336"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "🔒"
                                            font.pixelSize: 20
                                        }
                                    }

                                    Text {
                                        text: tr("Safety Switch Management")
                                        font.pixelSize: app.mediumFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                        Layout.fillWidth: true
                                    }
                                }

                                Text {
                                    text: tr("Enable/disable safety switch and management settings")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    radius: 8
                                    color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                    Text {
                                        anchors.centerIn: parent
                                        text: tr("Safety switch settings will be configured here")
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Sistem Ayarları Sayfası Component
    Component {
        id: systemSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("System")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Kayıt Alanı Doluluk Bilgileri
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: storageContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: storageContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("Storage Usage")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("View storage space and usage information")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Storage progress bar
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    radius: 15
                                    color: Qt.darker(settingsPage.surfaceColor, 1.2)

                                    Rectangle {
                                        width: parent.width * 0.45 // Example: 45% used
                                        height: parent.height
                                        radius: 15
                                        color: settingsPage.primaryColor
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "45% " + tr("used")
                                        font.pixelSize: app.smallFontSize
                                        font.bold: true
                                        color: "white"
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 20

                                    Column {
                                        spacing: 4
                                        Text {
                                            text: tr("Used")
                                            font.pixelSize: app.smallFontSize
                                            color: settingsPage.textSecondaryColor
                                        }
                                        Text {
                                            text: "4.5 GB"
                                            font.pixelSize: app.baseFontSize
                                            font.bold: true
                                            color: settingsPage.textColor
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Text {
                                            text: tr("Free")
                                            font.pixelSize: app.smallFontSize
                                            color: settingsPage.textSecondaryColor
                                        }
                                        Text {
                                            text: "5.5 GB"
                                            font.pixelSize: app.baseFontSize
                                            font.bold: true
                                            color: settingsPage.textColor
                                        }
                                    }

                                    Column {
                                        spacing: 4
                                        Text {
                                            text: tr("Total")
                                            font.pixelSize: app.smallFontSize
                                            color: settingsPage.textSecondaryColor
                                        }
                                        Text {
                                            text: "10 GB"
                                            font.pixelSize: app.baseFontSize
                                            font.bold: true
                                            color: settingsPage.textColor
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }

    // Hakkında Sayfası Component
    Component {
        id: aboutSettingsComponent

        Rectangle {
            color: settingsPage.color

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: settingsPage.surfaceColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        Button {
                            text: "← " + tr("Back")
                            flat: true
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: app.mediumFontSize
                                color: settingsPage.primaryColor
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle {
                                color: parent.pressed ? Qt.rgba(settingsPage.primaryColor.r, settingsPage.primaryColor.g, settingsPage.primaryColor.b, 0.2) : "transparent"
                                radius: 8
                            }
                            onClicked: settingsStack.pop()
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: tr("About")
                            font.pixelSize: app.mediumFontSize
                            font.bold: true
                            color: settingsPage.textColor
                        }

                        Item { Layout.fillWidth: true }
                        Item { width: 80 }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: settingsPage.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 20
                        anchors.margins: 20

                        // Uygulama Bilgileri
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: appInfoContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: appInfoContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                // App Icon and Name
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 15

                                    Rectangle {
                                        width: 60
                                        height: 60
                                        radius: 12
                                        color: settingsPage.primaryColor

                                        Text {
                                            anchors.centerIn: parent
                                            text: "🚜"
                                            font.pixelSize: 30
                                        }
                                    }

                                    Column {
                                        spacing: 4

                                        Text {
                                            text: "Excavator UI"
                                            font.pixelSize: app.largeFontSize
                                            font.bold: true
                                            color: settingsPage.textColor
                                        }

                                        Text {
                                            text: tr("Excavator Control System")
                                            font.pixelSize: app.smallFontSize
                                            color: settingsPage.textSecondaryColor
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: settingsPage.borderColor
                                }

                                // Version Info
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 15
                                    columnSpacing: 20

                                    Text {
                                        text: tr("Version")
                                        font.pixelSize: app.baseFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                    Text {
                                        text: "1.0.0"
                                        font.pixelSize: app.baseFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                    }

                                    Text {
                                        text: tr("Build")
                                        font.pixelSize: app.baseFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                    Text {
                                        text: "2025.01.29"
                                        font.pixelSize: app.baseFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                    }

                                    Text {
                                        text: "Qt"
                                        font.pixelSize: app.baseFontSize
                                        color: settingsPage.textSecondaryColor
                                    }
                                    Text {
                                        text: "6.x"
                                        font.pixelSize: app.baseFontSize
                                        font.bold: true
                                        color: settingsPage.textColor
                                    }
                                }
                            }
                        }

                        // Lisans Bilgileri
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: licenseContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: licenseContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                Text {
                                    text: tr("License Information")
                                    font.pixelSize: app.mediumFontSize
                                    font.bold: true
                                    color: settingsPage.textColor
                                }

                                Text {
                                    text: tr("This software uses the following open source libraries:")
                                    font.pixelSize: app.smallFontSize
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Column {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: "• Qt Framework - LGPL v3"
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textColor
                                    }
                                    Text {
                                        text: "• Qt3D - LGPL v3"
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textColor
                                    }
                                    Text {
                                        text: "• SQLite - Public Domain"
                                        font.pixelSize: app.smallFontSize
                                        color: settingsPage.textColor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                        }
                    }
                }
            }
        }
    }
}
