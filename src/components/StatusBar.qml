import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Üst Durum Çubuğu - Tek satır, tüm sensörler dahil - 10.1 inç responsive
Rectangle {
    id: statusBar
    height: Math.max(parent.height * 0.055, 50)  // Tek satır, kompakt
    color: themeManager ? themeManager.backgroundColorDark : "#1a1a2e"

    // Responsive boyutlar - 10.1 inç için optimize
    property real baseFontSize: height * 0.24  // Ana font: küçültüldü
    property real smallFontSize: height * 0.20  // Küçük font
    property real tinyFontSize: height * 0.18  // Çok küçük font (altlı üstlü için)
    property real iconSize: height * 0.50  // İkon boyutu
    property real badgeHeight: height * 0.60  // Badge yüksekliği

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
    property bool bluetoothEnabled: true
    property bool audioEnabled: true

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

    // Sensör border yanıp sönme animasyonu
    property bool sensorBorderVisible: true
    Timer {
        id: blinkTimer
        interval: 800
        running: true
        repeat: true
        onTriggered: {
            statusBar.sensorBorderVisible = !statusBar.sensorBorderVisible
        }
    }

    // Tek satır içerik
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 6

        // SOL: Proje İkonu + Proje Adı (Altlı Üstlü)
        Row {
            spacing: 6
            Layout.alignment: Qt.AlignVCenter

            // Proje ikonu (küp)
            Rectangle {
                width: statusBar.iconSize * 0.7
                height: statusBar.iconSize * 0.7
                radius: 3
                color: "#FF9800"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "◇"
                    font.pixelSize: statusBar.iconSize * 0.38
                    font.bold: true
                    color: "#ffffff"
                }
            }

            // Proje adı - Altlı üstlü
            Column {
                spacing: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: tr("Project") + ":"
                    font.pixelSize: statusBar.tinyFontSize
                    color: "#888888"
                }

                Text {
                    text: statusBar.projectName
                    font.pixelSize: statusBar.smallFontSize
                    font.bold: true
                    color: "#ffffff"
                }
            }
        }

        // Ayırıcı çizgi - Proje ve Ekskavatör arası
        Rectangle {
            width: 1
            height: statusBar.badgeHeight
            color: "#444444"
            Layout.alignment: Qt.AlignVCenter
        }

        // Ekskavatör Adı - Altlı Üstlü
        Column {
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: tr("Excavator") + ":"
                font.pixelSize: statusBar.tinyFontSize
                color: "#888888"
            }

            Text {
                text: statusBar.excavatorName
                font.pixelSize: statusBar.smallFontSize
                font.bold: true
                color: "#ffffff"
            }
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
                border.color: statusBar.rtkConnected ?
                    (statusBar.sensorBorderVisible ? "#4CAF50" : "#2a5a2a") :
                    (statusBar.sensorBorderVisible ? "#f44336" : "#7a2a2a")
                border.width: 2

                Behavior on border.color {
                    ColorAnimation { duration: 300 }
                }

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
                border.color: statusBar.imuOk ?
                    (statusBar.sensorBorderVisible ? "#4CAF50" : "#2a5a2a") :
                    (statusBar.sensorBorderVisible ? "#f44336" : "#7a2a2a")
                border.width: 2

                Behavior on border.color {
                    ColorAnimation { duration: 300 }
                }

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

            // Bluetooth Toggle
            Rectangle {
                id: bluetoothBox
                width: statusBar.iconSize * 1.2
                height: statusBar.iconSize * 1.2
                radius: 4
                color: bluetoothMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                border.color: statusBar.bluetoothEnabled ? "#2196F3" : "#666666"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                // Ikon buraya eklenecek

                MouseArea {
                    id: bluetoothMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        statusBar.bluetoothEnabled = !statusBar.bluetoothEnabled
                        console.log("Bluetooth:", statusBar.bluetoothEnabled ? "Açık" : "Kapalı")
                    }
                }
            }

            // Audio Toggle
            Rectangle {
                id: audioBox
                width: statusBar.iconSize * 1.2
                height: statusBar.iconSize * 1.2
                radius: 4
                color: audioMouseArea.containsMouse ? "#3a3a3a" : "#2a2a2a"
                border.color: statusBar.audioEnabled ? "#FF9800" : "#666666"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                // Ikon buraya eklenecek

                MouseArea {
                    id: audioMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        statusBar.audioEnabled = !statusBar.audioEnabled
                        console.log("Ses:", statusBar.audioEnabled ? "Açık" : "Kapalı")
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Kullanıcı Rolü - Altlı Üstlü
        Column {
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: authService && authService.currentUser ? authService.currentUser : "admin"
                font.pixelSize: statusBar.tinyFontSize
                font.bold: true
                color: "#ffffff"
            }

            Text {
                text: authService && authService.currentRole ? authService.currentRole : "Operator"
                font.pixelSize: statusBar.tinyFontSize
                color: "#888888"
            }
        }

        // Ayırıcı çizgi
        Rectangle {
            width: 1
            height: statusBar.badgeHeight
            color: "#444444"
            Layout.alignment: Qt.AlignVCenter
        }

        // Tarih ve Saat - Altlı Üstlü
        Column {
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: statusBar.currentTime
                font.pixelSize: statusBar.tinyFontSize
                font.bold: true
                color: "#ffffff"
            }

            Text {
                text: statusBar.currentDate
                font.pixelSize: statusBar.tinyFontSize
                color: "#888888"
            }
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
