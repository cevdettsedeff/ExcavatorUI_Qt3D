import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Ayarlar Sayfası - StackView ile alt sayfa navigasyonu
Rectangle {
    id: settingsPage
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

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
                            descKey: "IMU, GNSS, laser and other sensor settings"
                            descTr: "IMU, GNSS, lazer ve diğer sensör ayarları"
                            pageName: "sensors"
                            enabled: false
                        }
                        ListElement {
                            icon: "📍"
                            titleKey: "GPS"
                            titleTr: "GPS"
                            descKey: "GNSS configuration, input and corrections"
                            descTr: "GNSS yapılandırması, giriş ve düzeltmeler"
                            pageName: "gps"
                            enabled: false
                        }
                        ListElement {
                            icon: "🖥️"
                            titleKey: "Display"
                            titleTr: "Görünüm"
                            descKey: "Screen theme, brightness and 3D model settings"
                            descTr: "Ekran teması, parlaklık ve 3D model ayarları"
                            pageName: "display"
                            enabled: false
                        }
                        ListElement {
                            icon: "🌐"
                            titleKey: "Language & Units"
                            titleTr: "Dil & Birimler"
                            descKey: "Language, distance and depth unit settings"
                            descTr: "Dil, mesafe ve derinlik birim ayarları"
                            pageName: "language"
                            enabled: false
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

                                Text {
                                    anchors.centerIn: parent
                                    text: model.icon
                                    font.pixelSize: 24
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
                                        font.pixelSize: 16
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

                                        Text {
                                            id: yakindaText
                                            anchors.centerIn: parent
                                            text: tr("Soon")
                                            font.pixelSize: 10
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

                                        Text {
                                            id: adminText
                                            anchors.centerIn: parent
                                            text: "Admin"
                                            font.pixelSize: 10
                                            font.bold: true
                                            color: "white"
                                        }
                                    }
                                }

                                Text {
                                    text: itemDesc
                                    font.pixelSize: 12
                                    color: settingsPage.textSecondaryColor
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            // Sağ ok
                            Text {
                                text: "›"
                                font.pixelSize: 24
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
                                }
                                // Diğer sayfalar için benzer şekilde eklenebilir
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

            // Geri butonu ile birlikte UserManagementView
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
                                font.pixelSize: 16
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
                            text: tr("Users")
                            font.pixelSize: 18
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
                                font.pixelSize: 16
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
                            text: tr("Screen Settings")
                            font.pixelSize: 18
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
                            border.color: settingsPage.borderColor
                            border.width: 1

                            ColumnLayout {
                                id: screenSaverContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 20
                                spacing: 20

                                // Başlık
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Text {
                                        text: "🖵"
                                        font.pixelSize: 24
                                    }

                                    Text {
                                        text: tr("Screensaver")
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: settingsPage.textColor
                                    }
                                }

                                // Açık/Kapalı Switch
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 15

                                    Text {
                                        text: tr("Enable Screensaver")
                                        font.pixelSize: 14
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
                                    }
                                }

                                // Açıklama
                                Text {
                                    text: tr("When enabled, screensaver will appear after inactivity on login screen")
                                    font.pixelSize: 12
                                    color: settingsPage.textSecondaryColor
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                // Ayırıcı
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: settingsPage.borderColor
                                }

                                // Timeout ayarı
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 10
                                    enabled: screenSaverSwitch.checked
                                    opacity: screenSaverSwitch.checked ? 1.0 : 0.5

                                    Text {
                                        text: tr("Timeout Duration")
                                        font.pixelSize: 14
                                        color: settingsPage.textColor
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 15

                                        Slider {
                                            id: timeoutSlider
                                            Layout.fillWidth: true
                                            from: 1
                                            to: 10
                                            stepSize: 1
                                            value: configManager ? configManager.screenSaverTimeout : 2

                                            onValueChanged: {
                                                if (configManager) {
                                                    configManager.screenSaverTimeout = value
                                                }
                                            }

                                            background: Rectangle {
                                                x: timeoutSlider.leftPadding
                                                y: timeoutSlider.topPadding + timeoutSlider.availableHeight / 2 - height / 2
                                                width: timeoutSlider.availableWidth
                                                height: 6
                                                radius: 3
                                                color: Qt.darker(settingsPage.surfaceColor, 1.3)

                                                Rectangle {
                                                    width: timeoutSlider.visualPosition * parent.width
                                                    height: parent.height
                                                    radius: 3
                                                    color: settingsPage.primaryColor
                                                }
                                            }

                                            handle: Rectangle {
                                                x: timeoutSlider.leftPadding + timeoutSlider.visualPosition * (timeoutSlider.availableWidth - width)
                                                y: timeoutSlider.topPadding + timeoutSlider.availableHeight / 2 - height / 2
                                                width: 20
                                                height: 20
                                                radius: 10
                                                color: timeoutSlider.pressed ? Qt.lighter(settingsPage.primaryColor, 1.2) : settingsPage.primaryColor
                                                border.color: Qt.darker(settingsPage.primaryColor, 1.2)
                                                border.width: 2
                                            }
                                        }

                                        // Değer göstergesi
                                        Rectangle {
                                            width: 60
                                            height: 35
                                            radius: 8
                                            color: Qt.darker(settingsPage.surfaceColor, 1.2)
                                            border.color: settingsPage.primaryColor
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: timeoutSlider.value + " " + tr("min")
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: settingsPage.primaryColor
                                            }
                                        }
                                    }

                                    // Preset butonları
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Repeater {
                                            model: [1, 2, 5, 10]

                                            Button {
                                                text: modelData + " " + tr("min")
                                                flat: true
                                                Layout.fillWidth: true

                                                background: Rectangle {
                                                    radius: 8
                                                    color: timeoutSlider.value === modelData ?
                                                           settingsPage.primaryColor :
                                                           Qt.darker(settingsPage.surfaceColor, 1.2)
                                                    border.color: settingsPage.primaryColor
                                                    border.width: 1
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    font.pixelSize: 12
                                                    color: timeoutSlider.value === modelData ? "white" : settingsPage.textColor
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                onClicked: {
                                                    timeoutSlider.value = modelData
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
                                    text: "ℹ️"
                                    font.pixelSize: 24
                                }

                                Text {
                                    text: tr("Screensaver activates only on login screen when there is no user activity. Touch or move mouse to dismiss.")
                                    font.pixelSize: 12
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
}
