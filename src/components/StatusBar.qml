import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - İki satırlı: Üst başlık + Sensör durumları - 10.1 inç responsive
Rectangle {
    id: statusBar
    height: Math.max(parent.height * 0.065, 70)  // Ekranın %6.5'i, min 70px
    color: themeManager ? themeManager.backgroundColor : "#2d3748"

    // Responsive boyutlar
    property real rowHeight: height * 0.48  // Her satır yüksekliğin %48'i
    property real baseFontSize: height * 0.12  // Ana font: yüksekliğin %12'si
    property real iconSize: height * 0.28  // İkon boyutu: yüksekliğin %28'i
    property real smallFontSize: height * 0.09  // Küçük font: yüksekliğin %9'u
    property real miniIconSize: height * 0.15  // Mini ikon: yüksekliğin %15'i

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
    signal rtkClicked()
    signal imuClicked()
    signal goToDashboard()

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

        // ÜST SATIR - Proje adı, ekskavatör, kullanıcı rolü, saat/tarih (Responsive)
        Rectangle {
            width: parent.width
            height: statusBar.rowHeight
            color: themeManager ? themeManager.backgroundColorDark : "#1e1e1e"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: statusBar.height * 0.12
                anchors.rightMargin: statusBar.height * 0.12
                spacing: statusBar.height * 0.15

                // SOL: Proje Adı ve İkon (Responsive)
                Row {
                    spacing: statusBar.height * 0.08

                    // Proje ikonu (küp)
                    Rectangle {
                        width: statusBar.iconSize * 0.9
                        height: statusBar.iconSize * 0.9
                        radius: 4
                        color: "#FF9800"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "◇"
                            font.pixelSize: statusBar.iconSize * 0.5
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    // Proje adı badge
                    Rectangle {
                        height: statusBar.rowHeight * 0.65
                        width: projeNameText.width + statusBar.height * 0.2
                        radius: statusBar.height * 0.04
                        color: "#2a2a2a"
                        border.color: "#444444"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: projeNameText
                            anchors.centerIn: parent
                            text: statusBar.projectName
                            font.pixelSize: statusBar.baseFontSize * 0.9
                            font.bold: true
                            color: "#ffffff"
                        }
                    }
                }

                // ORTA-SOL: Ekskavatör Adı (Responsive)
                Text {
                    text: statusBar.excavatorName
                    font.pixelSize: statusBar.baseFontSize
                    font.bold: true
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // ORTA-SAĞ: Kullanıcı Rolü (Sadece metin, ikon yok)
                Text {
                    text: (authService && authService.currentUser ? authService.currentUser : "admin") +
                          " / " +
                          (authService && authService.currentRole ? authService.currentRole : "Operator")
                    font.pixelSize: statusBar.baseFontSize * 0.85
                    color: "#888888"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // SAĞ: Saat ve Tarih + Menü (Responsive)
                Row {
                    spacing: statusBar.height * 0.12

                    Column {
                        spacing: statusBar.height * 0.02
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: statusBar.currentDate + " | " + statusBar.currentTime.substring(0, 5)
                            font.pixelSize: statusBar.baseFontSize * 0.9
                            font.bold: true
                            color: "#ffffff"
                            anchors.right: parent.right
                        }
                    }

                    // Menü İkonu (Responsive)
                    Rectangle {
                        width: statusBar.iconSize * 1.1
                        height: statusBar.iconSize * 1.1
                        radius: width / 2
                        color: menuMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                        border.color: "#505050"
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: "☰"
                            font.pixelSize: statusBar.iconSize * 0.55
                            color: "#ffffff"
                        }

                        MouseArea {
                            id: menuMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
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

        // ALT SATIR - RTK, IMU ve Alarm durumları (Responsive)
        Rectangle {
            width: parent.width
            height: statusBar.rowHeight
            color: themeManager ? themeManager.backgroundColor : "#2d3748"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: statusBar.height * 0.08
                anchors.rightMargin: statusBar.height * 0.08
                spacing: statusBar.height * 0.06

                // Proje Adı - SOLDA (Responsive)
                Rectangle {
                    Layout.preferredHeight: statusBar.rowHeight * 0.75
                    Layout.preferredWidth: projeText.width + statusBar.height * 0.16
                    radius: statusBar.height * 0.04
                    color: "#2a2a2a"
                    border.color: "#444444"
                    border.width: 1

                    Text {
                        id: projeText
                        anchors.centerIn: parent
                        text: "Proje: " + statusBar.projectName
                        font.pixelSize: statusBar.baseFontSize * 0.85
                        font.bold: true
                        color: "#ffffff"
                    }
                }

                // Boşluk
                Item {
                    Layout.fillWidth: true
                }

                // RTK Durumu - Tıklanabilir (Responsive)
                Rectangle {
                    id: rtkBox
                    Layout.preferredWidth: statusBar.height * 0.85
                    Layout.preferredHeight: statusBar.rowHeight * 0.75
                    radius: statusBar.height * 0.04
                    color: rtkMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                    border.color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: statusBar.height * 0.04

                        // Sinyal ikonu - Row ile yatay dizilim (Responsive)
                        Row {
                            spacing: statusBar.height * 0.01
                            anchors.verticalCenter: parent.verticalCenter
                            height: statusBar.rowHeight * 0.35

                            Repeater {
                                model: 4

                                Rectangle {
                                    width: statusBar.height * 0.025
                                    height: statusBar.rowHeight * 0.08 + index * (statusBar.rowHeight * 0.06)
                                    radius: statusBar.height * 0.01
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
                                text: "GNSS"
                                font.pixelSize: statusBar.baseFontSize * 0.75
                                font.bold: true
                                color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                            }

                            Text {
                                text: statusBar.rtkStatus
                                font.pixelSize: statusBar.smallFontSize * 0.85
                                color: "#888888"
                            }
                        }
                    }

                    MouseArea {
                        id: rtkMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: statusBar.rtkClicked()
                    }

                    ToolTip {
                        visible: rtkMouseArea.containsMouse
                        text: qsTr("RTK/GNSS Ayarları")
                        delay: 500
                    }
                }

                // RTC Badge (Responsive)
                Rectangle {
                    Layout.preferredWidth: rtcText.width + statusBar.height * 0.12
                    Layout.preferredHeight: statusBar.rowHeight * 0.75
                    radius: statusBar.height * 0.04
                    color: "#2a2a2a"
                    border.color: "#00bcd4"
                    border.width: 1

                    Text {
                        id: rtcText
                        anchors.centerIn: parent
                        text: "RTC"
                        font.pixelSize: statusBar.baseFontSize * 0.75
                        font.bold: true
                        color: "#00bcd4"
                    }
                }

                // IMU Durumu - Tıklanabilir (Responsive)
                Rectangle {
                    id: imuBox
                    Layout.preferredWidth: statusBar.height * 0.8
                    Layout.preferredHeight: statusBar.rowHeight * 0.75
                    radius: statusBar.height * 0.04
                    color: imuMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                    border.color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: statusBar.height * 0.04

                        // Durum ikonu (Responsive)
                        Rectangle {
                            width: statusBar.miniIconSize * 1.1
                            height: statusBar.miniIconSize * 1.1
                            radius: width / 2
                            color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: statusBar.imuOk ? "✓" : "!"
                                font.pixelSize: statusBar.baseFontSize * 0.75
                                font.bold: true
                                color: "#ffffff"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Text {
                                text: "IMU"
                                font.pixelSize: statusBar.baseFontSize * 0.75
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                text: statusBar.imuOk ? "OK" : "ERR"
                                font.pixelSize: statusBar.smallFontSize * 0.85
                                color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                            }
                        }
                    }

                    MouseArea {
                        id: imuMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: statusBar.imuClicked()
                    }

                    ToolTip {
                        visible: imuMouseArea.containsMouse
                        text: qsTr("IMU Sensör Ayarları")
                        delay: 500
                    }
                }

                // Alarm Badge (Responsive)
                Rectangle {
                    Layout.preferredWidth: statusBar.iconSize * 0.95
                    Layout.preferredHeight: statusBar.iconSize * 0.95
                    radius: statusBar.height * 0.04
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
                            font.pixelSize: statusBar.smallFontSize * 0.9
                            color: statusBar.alarmCount > 0 ? "#ffffff" : "#666666"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: statusBar.alarmCount.toString()
                            font.pixelSize: statusBar.baseFontSize * 0.85
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
