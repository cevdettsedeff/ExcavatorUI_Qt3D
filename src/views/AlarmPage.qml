import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Alarm Sayfası - Uyarılar ve bildirimler
Rectangle {
    id: alarmPage
    color: "#1a1a1a"

    // Dil değişikliği tetikleyici
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0
    property int activeFilter: 0 // 0: Tümü, 1: Kritik, 2: Uyarı, 3: Bilgi

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
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

        // Başlık ve özet
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: tr("Alarms")
                font.pixelSize: 28
                font.bold: true
                color: "#ffffff"
            }

            Item { Layout.fillWidth: true }

            // Aktif alarm sayısı
            Rectangle {
                width: 100
                height: 40
                radius: 20
                color: "#f4433630"

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "🔔"
                        font.pixelSize: 18
                    }

                    Text {
                        text: "3 " + tr("Active")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#f44336"
                    }
                }
            }
        }

        // Filtre butonları
        Row {
            spacing: 8
            Layout.fillWidth: true

            Repeater {
                model: [
                    { label: "All", labelTr: "Tümü", color: "#888888" },
                    { label: "Critical", labelTr: "Kritik", color: "#f44336" },
                    { label: "Warning", labelTr: "Uyarı", color: "#ff9800" },
                    { label: "Info", labelTr: "Bilgi", color: "#2196F3" }
                ]

                delegate: Rectangle {
                    width: 80
                    height: 35
                    radius: 17
                    color: alarmPage.activeFilter === index ? modelData.color : "#2a2a2a"
                    border.color: modelData.color
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: translationService && translationService.currentLanguage === "tr_TR" ? modelData.labelTr : modelData.label
                        font.pixelSize: 12
                        font.bold: true
                        color: alarmPage.activeFilter === index ? "#ffffff" : modelData.color
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: alarmPage.activeFilter = index
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
        }

        // Alarm listesi
        ListView {
            id: alarmListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true

            model: ListModel {
                ListElement {
                    type: "critical"
                    icon: "⚠️"
                    titleKey: "RTK Signal Lost"
                    titleTr: "RTK Sinyali Kayboldu"
                    descKey: "RTK connection has been lost for 5 minutes"
                    descTr: "RTK bağlantısı 5 dakikadır kayıp"
                    time: "10:45"
                    isNew: true
                }
                ListElement {
                    type: "warning"
                    icon: "⚡"
                    titleKey: "Low Battery"
                    titleTr: "Düşük Pil"
                    descKey: "Battery level is below 20%"
                    descTr: "Pil seviyesi %20'nin altında"
                    time: "10:30"
                    isNew: true
                }
                ListElement {
                    type: "warning"
                    icon: "📐"
                    titleKey: "Tilt Warning"
                    titleTr: "Eğim Uyarısı"
                    descKey: "Machine tilt exceeds safe limits"
                    descTr: "Makine eğimi güvenli sınırları aşıyor"
                    time: "10:15"
                    isNew: false
                }
                ListElement {
                    type: "info"
                    icon: "📍"
                    titleKey: "Area Boundary"
                    titleTr: "Alan Sınırı"
                    descKey: "Approaching work area boundary"
                    descTr: "Çalışma alanı sınırına yaklaşılıyor"
                    time: "10:00"
                    isNew: false
                }
                ListElement {
                    type: "critical"
                    icon: "🌡️"
                    titleKey: "High Temperature"
                    titleTr: "Yüksek Sıcaklık"
                    descKey: "Engine temperature is critical"
                    descTr: "Motor sıcaklığı kritik seviyede"
                    time: "09:45"
                    isNew: true
                }
            }

            delegate: Rectangle {
                width: alarmListView.width
                height: 90
                radius: 10
                color: "#2a2a2a"
                border.color: {
                    if (model.type === "critical") return "#f44336"
                    if (model.type === "warning") return "#ff9800"
                    return "#2196F3"
                }
                border.width: model.isNew ? 2 : 1
                opacity: {
                    if (alarmPage.activeFilter === 0) return 1
                    if (alarmPage.activeFilter === 1 && model.type === "critical") return 1
                    if (alarmPage.activeFilter === 2 && model.type === "warning") return 1
                    if (alarmPage.activeFilter === 3 && model.type === "info") return 1
                    return 0.3
                }

                property string alarmTitle: {
                    if (translationService && translationService.currentLanguage === "tr_TR") {
                        return model.titleTr
                    }
                    return model.titleKey
                }

                property string alarmDesc: {
                    if (translationService && translationService.currentLanguage === "tr_TR") {
                        return model.descTr
                    }
                    return model.descKey
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Tip göstergesi
                    Rectangle {
                        width: 50
                        height: 50
                        radius: 10
                        color: {
                            if (model.type === "critical") return "#f4433630"
                            if (model.type === "warning") return "#ff980030"
                            return "#2196F330"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: model.icon
                            font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: alarmTitle
                                font.pixelSize: 15
                                font.bold: true
                                color: "#ffffff"
                            }

                            // Yeni badge
                            Rectangle {
                                visible: model.isNew
                                width: 40
                                height: 18
                                radius: 9
                                color: "#f44336"

                                Text {
                                    anchors.centerIn: parent
                                    text: alarmPage.tr("New")
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#ffffff"
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: model.time
                                font.pixelSize: 12
                                color: "#888888"
                            }
                        }

                        Text {
                            text: alarmDesc
                            font.pixelSize: 12
                            color: "#888888"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Alarm clicked:", model.titleKey)
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }
        }
    }
}
