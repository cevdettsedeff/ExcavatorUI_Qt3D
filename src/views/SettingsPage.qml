import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Ayarlar Sayfası - StackView ile alt sayfa navigasyonu
Rectangle {
    id: settingsPage
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    // Theme colors
    property color primaryColor: themeManager ? themeManager.primaryColor : "#38b2ac"
    property color surfaceColor: themeManager ? themeManager.surfaceColor : "#2a2a2a"
    property color textColor: themeManager ? themeManager.textColor : "#ffffff"
    property color textSecondaryColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#3a3a3a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
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
                        }
                    }

                    delegate: Rectangle {
                        width: settingsListView.width
                        height: 80
                        radius: 10
                        color: model.enabled ? settingsPage.surfaceColor : Qt.darker(settingsPage.surfaceColor, 1.2)
                        border.color: settingsPage.borderColor
                        border.width: 1
                        opacity: model.enabled ? 1.0 : 0.6

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
                                        visible: !model.enabled
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
                                color: model.enabled ? settingsPage.textSecondaryColor : Qt.darker(settingsPage.textSecondaryColor, 1.5)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: model.enabled
                            cursorShape: model.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                            onClicked: {
                                if (model.pageName === "users") {
                                    settingsStack.push(userManagementComponent)
                                }
                                // Diğer sayfalar için benzer şekilde eklenebilir
                            }

                            onEntered: if (model.enabled) parent.color = Qt.lighter(settingsPage.surfaceColor, 1.1)
                            onExited: parent.color = model.enabled ? settingsPage.surfaceColor : Qt.darker(settingsPage.surfaceColor, 1.2)
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
}
