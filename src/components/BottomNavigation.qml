import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Alt Navigasyon Çubuğu - Mockup'a göre tasarlanmış
Rectangle {
    id: bottomNav
    height: 70
    color: "#1a1a1a"

    property int currentIndex: 0
    signal tabChanged(int index)

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

    // Üst çizgi
    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: "#333333"
    }

    // Tab modeli
    ListModel {
        id: tabModel

        ListElement {
            icon: "🏠"
            labelKey: "Home"
            labelTr: "Ana"
        }
        ListElement {
            icon: "🗺️"
            labelKey: "Map"
            labelTr: "Harita"
        }
        ListElement {
            icon: "🚩"
            labelKey: "Area"
            labelTr: "Alan"
        }
        ListElement {
            icon: "🔔"
            labelKey: "Alarm"
            labelTr: "Alarm"
        }
        ListElement {
            icon: "⚙️"
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

                    // İkon
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: model.icon
                        font.pixelSize: 24
                        opacity: isSelected ? 1.0 : 0.6

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    // Etiket
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: tabLabel
                        font.pixelSize: 12
                        font.bold: isSelected
                        color: isSelected ? "#FFB300" : "#888888"

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    // Seçim göstergesi
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: isSelected ? 30 : 0
                        height: 3
                        radius: 1.5
                        color: "#FFB300"

                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
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

                // Seçim arka plan efekti
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 5
                    radius: 10
                    color: isSelected ? "#FFB30020" : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
            }
        }
    }
}
