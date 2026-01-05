import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Alt Navigasyon Çubuğu - Özelleştirilmiş ikonlar ile
Rectangle {
    id: bottomNav
    height: 70
    color: themeManager ? themeManager.backgroundColor : "#1a1a1a"

    property int currentIndex: 0
    signal tabChanged(int index)

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    // Theme colors
    property color activeColor: themeManager ? themeManager.primaryColor : "#38b2ac"
    property color inactiveColor: themeManager ? themeManager.textColorSecondary : "#888888"
    property color borderColor: themeManager ? themeManager.borderColor : "#333333"

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    Connections {
        target: translationService
        function onLanguageChanged() {
            languageTrigger++
        }
    }

    Connections {
        target: themeManager
        function onThemeChanged() {
            bottomNav.activeColor = themeManager.primaryColor
            bottomNav.inactiveColor = themeManager.textSecondaryColor
            bottomNav.borderColor = themeManager.borderColor
        }
    }

    // Üst çizgi
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: bottomNav.borderColor
    }

    // Tab modeli - icon path ile
    ListModel {
        id: tabModel

        ListElement {
            iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_excavator.png"
            fallbackIcon: "🚜"
            labelKey: "Excavator"
            labelTr: "Ekskavatör"
        }
        ListElement {
            iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_map.png"
            fallbackIcon: "🗺"
            labelKey: "Map"
            labelTr: "Harita"
        }
        ListElement {
            iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_dig_area.png"
            fallbackIcon: "📐"
            labelKey: "Dig Area"
            labelTr: "Kazı Alanı"
        }
        ListElement {
            iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_alarm.png"
            fallbackIcon: "🔔"
            labelKey: "Alarm"
            labelTr: "Alarm"
        }
        ListElement {
            iconPath: "qrc:/ExcavatorUI_Qt3D/resources/icons/nav_settings.png"
            fallbackIcon: "⚙"
            labelKey: "Settings"
            labelTr: "Ayarlar"
        }
    }

    Row {
        anchors.fill: parent
        anchors.topMargin: 5

        Repeater {
            model: tabModel

            delegate: Rectangle {
                width: bottomNav.width / 5
                height: parent.height - 5
                color: "transparent"

                property bool isSelected: bottomNav.currentIndex === index
                property string tabLabel: {
                    if (translationService && translationService.currentLanguage === "tr_TR") {
                        return model.labelTr
                    } else {
                        return model.labelKey
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    // İkon - Image veya fallback Text
                    Item {
                        width: 32
                        height: 32
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            id: iconImage
                            anchors.fill: parent
                            source: model.iconPath
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                            opacity: isSelected ? 1.0 : 0.6
                        }

                        // Fallback emoji if image not found
                        Text {
                            anchors.centerIn: parent
                            text: model.fallbackIcon
                            font.pixelSize: 28
                            color: isSelected ? bottomNav.activeColor : bottomNav.inactiveColor
                            visible: iconImage.status !== Image.Ready

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }
                    }

                    // Etiket
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: tabLabel
                        font.pixelSize: 10
                        color: isSelected ? bottomNav.activeColor : bottomNav.inactiveColor

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    // Alt çizgi - sadece seçili olunca görünür
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isSelected ? 40 : 0
                        height: 2
                        color: bottomNav.activeColor
                        opacity: isSelected ? 1 : 0

                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 200 }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        bottomNav.currentIndex = index
                        bottomNav.tabChanged(index)
                    }
                }
            }
        }
    }
}
