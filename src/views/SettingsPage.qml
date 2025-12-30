import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Ayarlar Sayfası - Mockup'a göre tasarlanmış
Rectangle {
    id: settingsPage
    color: "#1a1a1a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0
    property int activeTab: 0 // 0: Aktif, 1: Geçmiş

    function tr(text) {
        return languageTrigger >= 0 ? qsTr(text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Başlık
        Text {
            text: tr("Settings")
            font.pixelSize: 28
            font.bold: true
            color: "#ffffff"
            Layout.fillWidth: true
        }

        // Aktif / Geçmiş sekme butonları
        Row {
            spacing: 0
            Layout.fillWidth: true

            // Aktif butonu
            Rectangle {
                width: 100
                height: 40
                radius: 5
                color: settingsPage.activeTab === 0 ? "#4CAF50" : "#2a2a2a"

                Text {
                    anchors.centerIn: parent
                    text: tr("Active")
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: settingsPage.activeTab = 0
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            // Geçmiş butonu
            Rectangle {
                width: 100
                height: 40
                radius: 5
                color: settingsPage.activeTab === 1 ? "#4CAF50" : "#2a2a2a"

                Text {
                    anchors.centerIn: parent
                    text: tr("History")
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: settingsPage.activeTab = 1
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
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
                    iconColor: "#FFB300"
                }
                ListElement {
                    icon: "📍"
                    titleKey: "GPS"
                    titleTr: "GPS"
                    descKey: "GNSS configuration, input and corrections"
                    descTr: "GNSS yapılandırması, giriş ve düzeltmeler"
                    iconColor: "#FFB300"
                }
                ListElement {
                    icon: "🖥️"
                    titleKey: "Display"
                    titleTr: "Görünüm"
                    descKey: "Screen theme, brightness and 3D model settings"
                    descTr: "Ekran teması, parlaklık ve 3D model ayarları"
                    iconColor: "#FFB300"
                }
                ListElement {
                    icon: "🌐"
                    titleKey: "Language & Units"
                    titleTr: "Dil & Birimler"
                    descKey: "Language, distance and depth unit settings"
                    descTr: "Dil, mesafe ve derinlik birim ayarları"
                    iconColor: "#FFB300"
                }
                ListElement {
                    icon: "🔒"
                    titleKey: "Security"
                    titleTr: "Güvenlik"
                    descKey: "Encryption, authorization and session settings"
                    descTr: "Şifreleme, yetkilendirme ve oturum ayarları"
                    iconColor: "#FFB300"
                }
                ListElement {
                    icon: "👥"
                    titleKey: "Users"
                    titleTr: "Kullanıcılar"
                    descKey: "User, role and permission management"
                    descTr: "Kullanıcı, roller ve izin yönetimi"
                    iconColor: "#FFB300"
                }
            }

            delegate: Rectangle {
                width: settingsListView.width
                height: 80
                radius: 10
                color: "#2a2a2a"
                border.color: "#3a3a3a"
                border.width: 1

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
                        color: "#3a3a3a"

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

                        Text {
                            text: itemTitle
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                        }

                        Text {
                            text: itemDesc
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // Sağ ok
                    Text {
                        text: "›"
                        font.pixelSize: 24
                        color: "#888888"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Settings item clicked:", model.titleKey)
                        // TODO: Alt sayfaya yönlendirme
                    }
                    onEntered: parent.color = "#3a3a3a"
                    onExited: parent.color = "#2a2a2a"
                }

                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
            }
        }
    }
}
