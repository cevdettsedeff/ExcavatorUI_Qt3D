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
                        ListElement {
                            icon: "📡"
                            titleKey: "Sensors"
                            titleTr: "Sensörler"
                            descKey: "IMU and GNSS calibration and sensor settings"
                            descTr: "IMU ve GNSS kalibrasyon ve sensör ayarları"
                            pageName: "sensors"
                            enabled: true
                        }
                        ListElement {
                            icon: "📍"
                            titleKey: "GPS"
                            titleTr: "GPS"
                            descKey: "GNSS configuration, input and corrections"
                            descTr: "GNSS yapılandırması, giriş ve düzeltmeler"
                            pageName: "gps"
                            enabled: true
                        }
                        ListElement {
                            icon: "🖥️"
                            titleKey: "Display"
                            titleTr: "Görünüm"
                            descKey: "Screen theme, brightness and 3D model settings"
                            descTr: "Ekran teması, parlaklık ve 3D model ayarları"
                            pageName: "display"
                            enabled: true
                        }
                        ListElement {
                            icon: "🌐"
                            titleKey: "Language & Units"
                            titleTr: "Dil & Birimler"
                            descKey: "Language, distance and depth unit settings"
                            descTr: "Dil, mesafe ve derinlik birim ayarları"
                            pageName: "language"
                            enabled: true
                        }
                        ListElement {
                            icon: "🔒"
                            titleKey: "Security"
                            titleTr: "Güvenlik"
                            descKey: "Encryption, authorization and session settings"
                            descTr: "Şifreleme, yetkilendirme ve oturum ayarları"
                            pageName: "security"
                            enabled: false
                        }
                        ListElement {
                            icon: "👥"
                            titleKey: "Users"
                            titleTr: "Kullanıcılar"
                            descKey: "User, role and permission management"
                            descTr: "Kullanıcı, roller ve izin yönetimi"
                            pageName: "users"
                            enabled: true
                            adminOnly: false
                        }
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
                                } else if (model.pageName === "sensors") {
                                    settingsStack.push(sensorSettingsComponent)
                                } else if (model.pageName === "gps") {
                                    settingsStack.push(gpsSettingsComponent)
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

    // Sensör Ayarları Sayfası Component
    Component {
        id: sensorSettingsComponent

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
                            text: tr("Sensors")
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

                // Sensör Ayarları içeriği
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 15
                        anchors.margins: 15

                        // IMU Sensör Kartı
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: imuContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: "#4CAF50"
                            border.width: 2

                            ColumnLayout {
                                id: imuContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 15

                                // Başlık
                                RowLayout {
                                    Layout.fillWidth: true

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: "#4CAF50"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "✓"
                                            font.pixelSize: 20
                                            font.bold: true
                                            color: "white"
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: "IMU " + tr("Sensor")
                                            font.pixelSize: app.mediumFontSize
                                            font.bold: true
                                            color: settingsPage.textColor
                                        }

                                        Text {
                                            text: tr("Connected") + " - OK"
                                            font.pixelSize: app.smallFontSize
                                            color: "#4CAF50"
                                        }
                                    }
                                }

                                // Kalibrasyon butonu
                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? Qt.darker("#FF9800", 1.2) : "#FF9800"
                                    }

                                    contentItem: Text {
                                        text: tr("IMU Calibration")
                                        font.pixelSize: app.baseFontSize
                                        font.bold: true
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        console.log("IMU Kalibrasyon başlatılıyor...")
                                    }
                                }

                                // IMU Verileri
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 3
                                    rowSpacing: 10
                                    columnSpacing: 10

                                    // Pitch
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "Pitch"
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: imuService ? imuService.pitch.toFixed(2) + "°" : "0.00°"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Roll
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "Roll"
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: imuService ? imuService.roll.toFixed(2) + "°" : "0.00°"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Yaw
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "Yaw"
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: imuService ? imuService.yaw.toFixed(2) + "°" : "0.00°"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
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

    // GPS Ayarları Sayfası Component
    Component {
        id: gpsSettingsComponent

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
                            text: "GPS / GNSS"
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

                // GPS Ayarları içeriği
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: availableWidth
                    clip: true

                    ColumnLayout {
                        width: parent.width
                        spacing: 15
                        anchors.margins: 15

                        // GNSS Durum Kartı
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.margins: 15
                            Layout.preferredHeight: gnssContent.height + 40
                            radius: 12
                            color: settingsPage.surfaceColor
                            border.color: "#4CAF50"
                            border.width: 2

                            ColumnLayout {
                                id: gnssContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 15

                                // Başlık
                                RowLayout {
                                    Layout.fillWidth: true

                                    // Sinyal çubukları
                                    Row {
                                        spacing: 3
                                        height: 30

                                        Repeater {
                                            model: 4

                                            Rectangle {
                                                width: 6
                                                height: 8 + index * 6
                                                radius: 2
                                                anchors.bottom: parent.bottom
                                                color: index < 4 ? "#4CAF50" : "#555555"
                                            }
                                        }
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: "GNSS / RTK"
                                            font.pixelSize: app.mediumFontSize
                                            font.bold: true
                                            color: settingsPage.textColor
                                        }

                                        Text {
                                            text: "RTK FIX - " + tr("High Precision")
                                            font.pixelSize: app.smallFontSize
                                            color: "#4CAF50"
                                        }
                                    }
                                }

                                // GPS Verileri
                                GridLayout {
                                    Layout.fillWidth: true
                                    columns: 2
                                    rowSpacing: 10
                                    columnSpacing: 10

                                    // Latitude
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: tr("Latitude")
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: "41.0082°"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Longitude
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: tr("Longitude")
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: "28.9784°"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: settingsPage.textColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Uydu Sayısı
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: tr("Satellites")
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: "12"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: "#4CAF50"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // HDOP
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 60
                                        radius: 8
                                        color: Qt.darker(settingsPage.surfaceColor, 1.1)

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "HDOP"
                                                font.pixelSize: app.smallFontSize
                                                color: settingsPage.textSecondaryColor
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: "0.8"
                                                font.pixelSize: app.baseFontSize
                                                font.bold: true
                                                color: "#4CAF50"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }
                                }

                                // NTRIP Ayarları butonu
                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 45

                                    background: Rectangle {
                                        radius: 8
                                        color: parent.pressed ? Qt.darker(settingsPage.primaryColor, 1.2) : settingsPage.primaryColor
                                    }

                                    contentItem: Text {
                                        text: tr("NTRIP Settings")
                                        font.pixelSize: app.baseFontSize
                                        font.bold: true
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    onClicked: {
                                        console.log("NTRIP ayarları...")
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
