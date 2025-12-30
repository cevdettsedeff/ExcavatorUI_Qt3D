import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Alan Sayfası - Çalışma alanı yönetimi
Rectangle {
    id: areaPage
    color: "#1a1a1a"

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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Başlık
        Text {
            text: tr("Work Area")
            font.pixelSize: 28
            font.bold: true
            color: "#ffffff"
            Layout.fillWidth: true
        }

        // Aktif alan bilgisi
        Rectangle {
            Layout.fillWidth: true
            height: 120
            radius: 10
            color: "#2a2a2a"
            border.color: "#4CAF50"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Alan ikonu
                Rectangle {
                    width: 60
                    height: 60
                    radius: 10
                    color: "#4CAF5030"

                    Text {
                        anchors.centerIn: parent
                        text: "🚩"
                        font.pixelSize: 30
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: tr("Active Area")
                        font.pixelSize: 12
                        color: "#4CAF50"
                    }

                    Text {
                        text: "ALAN-001"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        text: "150m x 200m | " + tr("Depth") + ": -5m ~ -15m"
                        font.pixelSize: 12
                        color: "#888888"
                    }
                }
            }
        }

        // Alan listesi başlığı
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: tr("Defined Areas")
                font.pixelSize: 18
                font.bold: true
                color: "#ffffff"
            }

            Item { Layout.fillWidth: true }

            // Yeni alan ekle butonu
            Rectangle {
                width: 120
                height: 35
                radius: 5
                color: "#3498db"

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: "+"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        text: tr("New Area")
                        font.pixelSize: 12
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("New area clicked")
                }
            }
        }

        // Alan listesi
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true

            model: ListModel {
                ListElement { name: "ALAN-001"; size: "150m x 200m"; depth: "-5m ~ -15m"; status: "active" }
                ListElement { name: "ALAN-002"; size: "100m x 150m"; depth: "-3m ~ -10m"; status: "completed" }
                ListElement { name: "ALAN-003"; size: "200m x 250m"; depth: "-8m ~ -20m"; status: "pending" }
            }

            delegate: Rectangle {
                width: parent ? parent.width : 0
                height: 70
                radius: 10
                color: "#2a2a2a"
                border.color: model.status === "active" ? "#4CAF50" : "#3a3a3a"
                border.width: model.status === "active" ? 2 : 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Durum göstergesi
                    Rectangle {
                        width: 8
                        height: 40
                        radius: 4
                        color: {
                            if (model.status === "active") return "#4CAF50"
                            if (model.status === "completed") return "#2196F3"
                            return "#ff9800"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: model.name
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                        }

                        Text {
                            text: model.size + " | " + model.depth
                            font.pixelSize: 12
                            color: "#888888"
                        }
                    }

                    // Durum etiketi
                    Rectangle {
                        width: 80
                        height: 25
                        radius: 12
                        color: {
                            if (model.status === "active") return "#4CAF5030"
                            if (model.status === "completed") return "#2196F330"
                            return "#ff980030"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: {
                                if (model.status === "active") return areaPage.tr("Active")
                                if (model.status === "completed") return areaPage.tr("Completed")
                                return areaPage.tr("Pending")
                            }
                            font.pixelSize: 10
                            font.bold: true
                            color: {
                                if (model.status === "active") return "#4CAF50"
                                if (model.status === "completed") return "#2196F3"
                                return "#ff9800"
                            }
                        }
                    }

                    Text {
                        text: "›"
                        font.pixelSize: 24
                        color: "#888888"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("Area clicked:", model.name)
                }
            }
        }
    }
}
