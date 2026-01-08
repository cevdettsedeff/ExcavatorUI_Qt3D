import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - İki satırlı: Üst başlık + Sensör durumları
Rectangle {
    id: statusBar
    height: 100
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // Proje adı property'si
    property string projectName: "AŞ-KAZI-042"
    property bool rtkConnected: true
    property string rtkStatus: "FIX"  // FIX, FLOAT, SINGLE, NONE
    property bool imuOk: true
    property int alarmCount: 1
    property bool gpsConnected: true
    property int satellites: 12
    property string excavatorName: "CAT 390F LME"
    property string currentDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy")
    property string currentTime: Qt.formatDateTime(new Date(), "HH:mm:ss")

    signal userIconClicked()

    // Saat güncelleyici
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            statusBar.currentDate = Qt.formatDateTime(new Date(), "dd.MM.yyyy")
            statusBar.currentTime = Qt.formatDateTime(new Date(), "HH:mm:ss")
        }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ÜST SATIR - Ekskavatör adı, kullanıcı, saat/tarih
        Rectangle {
            width: parent.width
            height: 50
            color: themeManager ? themeManager.backgroundColorDark : "#1e1e1e"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 20

                // SOL: Ekskavatör Adı
                Row {
                    spacing: 8

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#4CAF50"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: statusBar.excavatorName
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // ORTA: Kullanıcı Adı ve Rolü
                Row {
                    spacing: 8

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: "#3f51b5"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: authService && authService.currentUser ? authService.currentUser.charAt(0).toUpperCase() : "U"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    Column {
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: authService && authService.currentUser ? authService.currentUser : "Kullanıcı"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#ffffff"
                        }

                        Text {
                            text: authService && authService.currentRole ? authService.currentRole : "Operatör"
                            font.pixelSize: 10
                            color: "#888888"
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // SAĞ: Saat ve Tarih
                Row {
                    spacing: 15

                    Column {
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: statusBar.currentTime
                            font.pixelSize: 16
                            font.bold: true
                            color: "#00bcd4"
                            anchors.right: parent.right
                        }

                        Text {
                            text: statusBar.currentDate
                            font.pixelSize: 11
                            color: "#888888"
                            anchors.right: parent.right
                        }
                    }

                    // Kullanıcı Menü İkonu
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: "#2a2a2a"
                        border.color: "#505050"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "☰"
                            font.pixelSize: 18
                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: statusBar.userIconClicked()
                        }
                    }
                }
            }

            // Alt çizgi
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#444444"
            }
        }

        // ALT SATIR - RTK, IMU ve Alarm durumları
        Rectangle {
            width: parent.width
            height: 50
            color: themeManager ? themeManager.backgroundColor : "#2d3748"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                // Proje Adı - SOLDA
                Rectangle {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: projeText.width + 20
                    radius: 5
                    color: "#2a2a2a"
                    border.color: "#444444"
                    border.width: 1

                    Text {
                        id: projeText
                        anchors.centerIn: parent
                        text: "Proje: " + statusBar.projectName
                        font.pixelSize: 12
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Boşluk
                Item {
                    Layout.fillWidth: true
                }

                // RTK Durumu - Detaylı
                Rectangle {
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 36
                    radius: 5
                    color: "#2a2a2a"
                    border.color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        // Sinyal ikonu - Row ile yatay dizilim
                        Row {
                            spacing: 1
                            anchors.verticalCenter: parent.verticalCenter
                            height: 16

                            Repeater {
                                model: 4

                                Rectangle {
                                    width: 3
                                    height: 4 + index * 3
                                    radius: 1
                                    anchors.bottom: parent.bottom
                                    color: {
                                        var strength = statusBar.rtkConnected ? (statusBar.rtkStatus === "FIX" ? 4 : (statusBar.rtkStatus === "FLOAT" ? 3 : 2)) : 0
                                        return index < strength ? "#4CAF50" : "#555555"
                                    }
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Text {
                                text: "RTK"
                                font.pixelSize: 11
                                font.bold: true
                                color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                            }

                            Text {
                                text: statusBar.rtkStatus
                                font.pixelSize: 9
                                color: "#888888"
                            }
                        }
                    }
                }

                // IMU Durumu - Detaylı
                Rectangle {
                    Layout.preferredWidth: 105
                    Layout.preferredHeight: 36
                    radius: 5
                    color: "#2a2a2a"
                    border.color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 5

                        // Durum ikonu
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: statusBar.imuOk ? "✓" : "!"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#ffffff"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Text {
                                text: "IMU"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                text: statusBar.imuOk ? "OK" : "ERR"
                                font.pixelSize: 9
                                color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                            }
                        }
                    }
                }

                // Alarm Badge
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 5
                    color: statusBar.alarmCount > 0 ? "#f44336" : "#2a2a2a"
                    visible: true
                    border.color: statusBar.alarmCount > 0 ? "#ff6b6b" : "#444444"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 0

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "▲"
                            font.pixelSize: 10
                            color: statusBar.alarmCount > 0 ? "#ffffff" : "#666666"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: statusBar.alarmCount.toString()
                            font.pixelSize: 12
                            font.bold: true
                            color: statusBar.alarmCount > 0 ? "#ffffff" : "#666666"
                        }
                    }
                }
            }

            // Alt çizgi
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#333333"
            }
        }
    }
}
