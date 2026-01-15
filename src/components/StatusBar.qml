import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - Tek satır, tüm sensörler dahil - 10.1 inç responsive
Rectangle {
    id: statusBar
    height: Math.max(parent.height * 0.055, 55)  // Tek satır, daha kompakt
    color: themeManager ? themeManager.backgroundColorDark : "#1a1a2e"

    // Responsive boyutlar - BÜYÜTÜLMÜŞ
    property real baseFontSize: height * 0.28  // Ana font: yüksekliğin %28'i
    property real smallFontSize: height * 0.22  // Küçük font: yüksekliğin %22'si
    property real iconSize: height * 0.55  // İkon boyutu: yüksekliğin %55'i
    property real badgeHeight: height * 0.65  // Badge yüksekliği

    // Properties
    property string projectName: "AŞ-KAZI-042"
    property bool rtkConnected: true
    property string rtkStatus: "FIX"  // FIX, FLOAT, SINGLE, NONE
    property bool imuOk: true
    property int alarmCount: 1
    property bool gpsConnected: true
    property int satellites: 12
    property string excavatorName: "CAT 390F LME"
    property string currentDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy")
    property string currentTime: Qt.formatDateTime(new Date(), "HH:mm")

    // Signals
    signal userIconClicked()
    signal sensorClicked()  // Tüm sensörler için tek signal
    signal goToDashboard()

    // Dil desteği
    property int languageTrigger: translationService ? translationService.currentLanguage.length : 0

    function tr(text) {
        return languageTrigger >= 0 ? qsTranslate("Main", text) : ""
    }

    // Saat güncelleyici
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            statusBar.currentDate = Qt.formatDateTime(new Date(), "dd.MM.yyyy")
            statusBar.currentTime = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

    // Tek satır içerik
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // SOL: Proje İkonu + Proje Adı
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            // Proje ikonu (küp)
            Rectangle {
                width: statusBar.iconSize * 0.85
                height: statusBar.iconSize * 0.85
                radius: 4
                color: "#FF9800"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "◇"
                    font.pixelSize: statusBar.iconSize * 0.45
                    font.bold: true
                    color: "#ffffff"
                }
            }

            // Proje adı badge
            Rectangle {
                height: statusBar.badgeHeight
                width: projeNameText.width + 16
                radius: 4
                color: "#2a2a2a"
                border.color: "#444444"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: projeNameText
                    anchors.centerIn: parent
                    text: statusBar.projectName
                    font.pixelSize: statusBar.baseFontSize
                    font.bold: true
                    color: "#ffffff"
                }
            }
        }

        // Ekskavatör Adı
        Text {
            text: statusBar.excavatorName
            font.pixelSize: statusBar.baseFontSize * 1.1
            font.bold: true
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }

        Item { Layout.fillWidth: true }

        // SENSÖRLER GRUBU - Tıklanabilir
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            // GNSS/RTK Durumu
            Rectangle {
                id: gnssBox
                width: gnssContent.width + 16
                height: statusBar.badgeHeight
                radius: 4
                color: gnssMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                border.color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                border.width: 1

                Row {
                    id: gnssContent
                    anchors.centerIn: parent
                    spacing: 6

                    // Sinyal çubukları
                    Row {
                        spacing: 2
                        anchors.verticalCenter: parent.verticalCenter
                        height: statusBar.badgeHeight * 0.6

                        Repeater {
                            model: 4

                            Rectangle {
                                width: 3
                                height: 4 + index * 4
                                radius: 1
                                anchors.bottom: parent.bottom
                                color: {
                                    var strength = statusBar.rtkConnected ? (statusBar.rtkStatus === "FIX" ? 4 : (statusBar.rtkStatus === "FLOAT" ? 3 : 2)) : 0
                                    return index < strength ? "#4CAF50" : "#555555"
                                }
                            }
                        }
                    }

                    Text {
                        text: "GNSS"
                        font.pixelSize: statusBar.smallFontSize
                        font.bold: true
                        color: statusBar.rtkConnected ? "#4CAF50" : "#f44336"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: gnssMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: statusBar.sensorClicked()
                }
            }

            // IMU Durumu
            Rectangle {
                id: imuBox
                width: imuContent.width + 16
                height: statusBar.badgeHeight
                radius: 4
                color: imuMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                border.color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                border.width: 1

                Row {
                    id: imuContent
                    anchors.centerIn: parent
                    spacing: 6

                    // Durum ikonu
                    Rectangle {
                        width: statusBar.smallFontSize * 1.1
                        height: statusBar.smallFontSize * 1.1
                        radius: width / 2
                        color: statusBar.imuOk ? "#4CAF50" : "#f44336"
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: statusBar.imuOk ? "✓" : "!"
                            font.pixelSize: statusBar.smallFontSize * 0.7
                            font.bold: true
                            color: "#ffffff"
                        }
                    }

                    Text {
                        text: "IMU"
                        font.pixelSize: statusBar.smallFontSize
                        font.bold: true
                        color: "#ffffff"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: imuMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: statusBar.sensorClicked()
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Kullanıcı Rolü
        Text {
            text: (authService && authService.currentUser ? authService.currentUser : "admin") +
                  " / " +
                  (authService && authService.currentRole ? authService.currentRole : "Operator")
            font.pixelSize: statusBar.smallFontSize
            color: "#888888"
            Layout.alignment: Qt.AlignVCenter
        }

        // Ayırıcı çizgi
        Rectangle {
            width: 1
            height: statusBar.badgeHeight
            color: "#444444"
            Layout.alignment: Qt.AlignVCenter
        }

        // Tarih ve Saat
        Text {
            text: statusBar.currentDate + " | " + statusBar.currentTime
            font.pixelSize: statusBar.baseFontSize
            font.bold: true
            color: "#ffffff"
            Layout.alignment: Qt.AlignVCenter
        }

        // Menü İkonu
        Rectangle {
            width: statusBar.iconSize
            height: statusBar.iconSize
            radius: 4
            color: menuMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
            border.color: "#505050"
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: "☰"
                font.pixelSize: statusBar.iconSize * 0.5
                color: "#ffffff"
            }

            MouseArea {
                id: menuMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: statusBar.userIconClicked()
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
